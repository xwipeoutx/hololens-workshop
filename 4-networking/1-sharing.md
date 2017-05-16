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

Unfortunately, the restrictions on our deployed environment (Unity player on a UWP device) means there is no provided SignalR client (if you find one, please let me know)!  To get around this, I have written a `Script` component for the basic SignalR functionality of sending and receiving messages from a hub.

TODO: Download llnk and such
 
1. Download from wherever
2. Import it to the project
3. Drag the `Networking` prefab to the scene

## Configuring the SignalR Client

The SignalR client has 2 parameters - one for the host/path, and another for the hub names.

1. Set the `host/path` to `http://hololens-server.azurewebsites.net/signalr`
2. Set the hub names to a single element called `messageHub`
  - Note: it is preconfigured to listen to the anchor hub there - you can leave it populated if you want, it won't be used until the next chapter.

The component will connect and start listening to messages in the `Start()` phase.

## Updating buzzing to broadcast the message

ToDo: Write this bit

## Other options

Of course, this is just one way to achieve messaging - use whichever way is comfortable to you, and keep in mind the limitations of your environment.  `HoloToolkit`, for example, ships with a sharing server, and a lot of tutorials are based around this.  I found it to be too cumbersome for my purposes - it is designed to be sitting on an on-premises server, and provides no ability for server-side logic.  Given we're focusing on a business environment, I found web-friendly methods of communication were a better fit.
