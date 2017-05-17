# Sharing

What we've done so far works well for simple games and gimmicks, but to do any real applications, we need some sort of networking.

## Goals

* Communicate with an ASP.NET website using SignalR 
* Synchronize the swarm states of all the beehives on all the devices

## Preliminary stuff

I have set up a SignalR server for this workshop, with the ability to send and receive custom messages with unique ids and a string payload.  Of course, this is primitive, but it is enough for us at this point.

The server can be found at [http://hololens-server.azurewebsites.net/](http://hololens-server.azurewebsites.net/), which will also serve a diagnostics page that listens to the same hubs, as well as some of the WebAPI endpoints for the next chapter.

### MessageHub

This hub communicates log and custom messages to all other clients - essentially a broadcasting relay.  This will be used in this chapter.

- **`log(customMessage: string)`** - Calls `client.log(customMesasage)` on all other clients. Useful to send log messages to attached browsers.
- **`customMessage(messageId: long, messageContents: string)`** - Calls `client.customMessage(messageId, messageContents)` on all other clients. The main way to broadcast to all other clients without having to modify the server.

### AnchorHub

This hub notifies clients of changes to an anchor.  This will be used in the next chapter.

- **`anchorChanged(anchorId: string)`** - Calls `client.anchorChanged(anchorId)` on all other clients.

## Install my networking package

Unfortunately, the restrictions on our deployed environment (Unity player on a UWP device) means there is no provided SignalR client (if you find one, please let me know!)  To get around this, I have written a `Script` component for the basic SignalR functionality of sending and receiving messages from a hub.

1. Download the package from <a href="/assets/holohelpers/20170517-561f1.unitypackage" target="_blank" download>here</a>
2. Import it to the project
3. Drag `HoloHelpers/Networking/Prefabs/Networking` to the scene, under the `Managers` game object

### What is it?

This prefab is an empty game object with 2 scripts - one for the SignalR server, and one for a World Anchor Store that works with a `REST`ful and `SignalR` server configured with `WebSockets`.  As such, the store uses the SignalR script, and so it's handy to have them live together all friendly like.

The configuration for the SignalR hub is just a matter of setting host and path, and listing each hub name.  All messages for the hub will be received - it's fairly _naive_ at this point.

We we will use this now to remotely control the buzzing state

## Configuring the SignalR Client

The SignalR client has 2 parameters - one for the host/path, and another for the hub names.

1. Set the `host/path` to `hololens-server.azurewebsites.net/signalr`
2. Set the hub names to be a single element called `messageHub`

The component will connect and start listening to messages in the `Start()` phase.  You can check this now by running the app in your editor and looking at the logs.  Additionally, navigating to [the configured website](http://hololens-server.azurewebsites.net) will show log messages as each client connects.

## Updating the swarm to use the messages

We're going to implement the message broadcast in a way that is very trusting of the client - any client can broadcast a message about whether or not the other bees are buzzing, and the other clients will update their state accordingly. Let's do it.

### 1. Wait for SignalR to be ready

Open the script `Spawn.cs` and add a field for the `SignalRClient`, and update the `Start()` method as follows:

```cs
public SignalRClient SignalRClient;

IEnumerator Start()
{
    if (ThingToSpawn == null)
        Debug.LogError("Spawn: No things to spawn");

    if (NumberOfSecondsBetweenSpawns <= 0)
        Debug.LogError("Spawn: Need to have some positive time between spawns");

    yield return StartCoroutine(new WaitUntil(() => SignalRClient.IsStarted));

    StartSpawning();
}
```

We've rejigged  the `Start()` method to support coroutines, which we're using to ensure the SignalR client is started

1. Switch back to the editor
2. Select the `Bee Spawner`
3. Drag the `Networking` component to the placeholder in the `Spawn` component - it should populate with the `SignalRClient`

### 2. Listen for the messages

Now that we know our SignalR client has connected, let's listen for start/stop messages:

Add the following to the `Start()` method of the `Spawn` script, just below the `yield`

```cs
SignalRClient.On<long, string>("messageHub", "customMessage", HandleCustomMessage);
```

Add the following class members to handle the message

```cs
private const long StartBuzzingMessageId = 1;
private const long StopBuzzingMessageId = 2;
private void HandleCustomMessage(long messageId, string messageContents)
{
    switch (messageId)
    {
        case StartBuzzingMessageId:
            StartSpawning();
            break;
        case StopBuzzingMessageId:
            StopSpawning();
            break;
        default:
            break;
    }
}
```

You may want to use your own crazy high and random message ids, to avoid clashes with anyone else using the same server. Enterprise level solutions right here.

So what's going on here? The SignalR client has 2 methods - one for handling single parameter methods, and another for two-parameter methods - mainly because that's all I'd needed at the time.  These simply take a callback, which will be called whenever the message is received.

```cs
void On<T>(string hubName, string methodName, Action<T1> action)
void On<T1, T2>(string hubName, string methodName, Action<T1, T2> action)
```

Remember the method signatures further up, that's on our test server? We're using the `customMessage` one of those, which has 2 parameters - a `long` for the message id, and a `string` for the payload.  Complex objects can be handled via `Json` this way. 

> **Aside**: Feel free to crack open the SignalR client to see how we do it.  Essentially we open a WebSocket connection using whatever is available to us in the environment (`Windows.Networking.Sockets` or `WebSocketSharp`), and serialize/deserialize the correct payloads.  It's _very_ primitive so you have to be careful - for example, numbers will deserialize to `long`, not `int`, causing all sorts of reflection/casting problems.

### 3. Send messages on state change

All that's left now (or is it...?) is to make the clients broadcast the start and stop buzzing messages.  Easy!

Edit `StartSpawning` and add this:

```cs
SignalRClient.SendToServer("messageHub", "customMessage", new object[] { StartBuzzingMessageId, "Started Buzzing" });
```

Edit `StopSpawning` and add this:

```cs
SignalRClient.SendToServer("messageHub", "customMessage", new object[] { StopBuzzingMessageId, "Stopped Buzzing" });
```

### 4. Test it out!

Run your codes, and have a look at the SignalR server, it's totally working, right?

Here's where it gets a little annoying.  You can only run 1 Unity player at a time in the editor, so you can't test it out.  You have a few options.

* Work with a friend!
* Run one instance in the emulator, another in the unity editor.  Whoa.
* Buy a few hololenses

But let's instead just add a duplicate beehive and networking system to our scene:

1. Right-click the `Bee Spawner` and choose `Duplicate`
2. Move it to the side so you can see both
3. Uncheck the component `Speech Input Source`
4. Because each client can only register 1 callback for each method, you will also need to duplicate the `Networking` component and update the beehive references.  Hopefully you're a pro by now

If we run it, you will see freakiness and spammy messages abound.  Whoops! We've made our message handler also broadcast the message! It's like we've never done PubSub before in our lives.  

### 5. Fix that bug, ya scrub

Let's move those broadcasts up into the voice handler

Update the voice handler:

```cs
public void OnSpeechKeywordRecognized(SpeechKeywordRecognizedEventData eventData)
{
    if (eventData.RecognizedText == "Buzz Around")
    {
        SignalRClient.SendToServer("messageHub", "customMessage", new object[] { StartBuzzingMessageId, "Started Buzzing" });
        StartSpawning();
    }
    else
    {
        SignalRClient.SendToServer("messageHub", "customMessage", new object[] { StopBuzzingMessageId, "Stop Buzzing" });
        StopSpawning();
    }
}
``` 

Now:

1. Test it out. It works!
2. Never, ever tell anyone that you made this mistake, it's embarrasing!
3. Delete your test objects, noone needs to know about them either

## Other options

Of course, this is just one way to achieve messaging - and depending on your inclination, it may just be a big black box.

There are other ones out there - `HoloToolkit` has a sharing server available too, which you will see in a lot of tutorials.  I prefered this approach as it uses relatively open technologies - ones that we often see in the ecosystems we work in - and I'm already familiar with it.  Compare this to a bespoke C++ server that forces a particular hierarchy of rooms/users etc, and the choice was easy.

The challenge is to find a mechanism that works well in the strange environment that is a hybrid of UWP / MonoGame - a fork of Mono from before `await` was cool.

---
Next: [World Anchor Sharing](2-world-anchor-sharing.md)

Prev: [Networking](/4-networking/index.md)


