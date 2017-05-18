# Sharing

## Goals

* Share our world anchors (beehive position) across clients

## World Anchors and Sharing

Sharing world anchors is a tricky process.  Recall from [earlier](/2-spatial-mapping/5-world-anchors.md) that a World Anchor represents a place in the real world. As the mapping of the real world becomes more defined, the World Anchor updates and stays in the same real world area.

This is useful in non-sharing situations, as it means the hologram will never sink behind a wall if the initial measurement was inaccurate, but it is absolutely necessary when sharing Holograms. Each Hololens will have different ideas on what a room looks like - this is just the nature of spatial mapping. 

A world anchor that is shared between devices will appear in the same place in the real world, as it is positioned based on queues and relative shape of the spatial map - not on absolute coordinates.

## So uhh, what _is_ a world anchor?

_Like, data-structure wise?_

Honestly, I have no idea.  I have only speculated and have not found any info if my speculation is anywhere close to true.  I _do_ know that a spatial anchor clocks in at about 500b - which is enough for around 40 vectors in 32 bits, which is more than enough precision for this.

If I had space for 40 vectors and had to store a position in a room, I'd cast a bunch of rays out at predetermined angles, and store the vector to the spatial map along that ray. I'd do it along all the basis vectors at least (positive and negative), and then a bunch of times in between _just in case_.

When loading the anchor on a new device I would do some fancy walk algorithm to find the point that most closely matches that, remembering there could be errors.

This is speculation, I have no idea how it actually works. Luckily, you don't need to know either! You just need to know that, out of the box, Unity can give you a bunch of bytes that represents a world anchor, and it'll Just Work.

## Some caveats

Again, the Unity editor has no working implementation of anchor serialization/deserialization.  It just no worky - it's a device-only API.  So to test any of this out, it's deploy-to-the-emulator-o-clock.

And really, for sharing, you need 2 devices - two emulators - to test it out.  Our earlier hack of putting an extra device in won't work as nicely, since they'll be overlapping positions.

So...

## 1. Write some scripts to fire up 2 emulators at once.

Here's mine:

```
"C:\Program Files (x86)\Microsoft XDE\10.0.14393.0\XDE.exe" /name "HoloLens Emulator 10.0.0.14393.0.steve" /displayName "HoloLens Emulator 10.0.14393.0" /vhd "C:\Program Files (x86)\Windows Kits\10\Emulation\HoloLens\10.0.14393.0\flash.vhd" /video "1268x720" /memsize 2048 /language 409 /creatediffdisk "C:\Users\Steve\AppData\Local\Microsoft\XDE\10.0.14393.0\dd.1268x720.2048.vhd" /fastShutdown /sku HDE
```

and

```
"C:\Program Files (x86)\Microsoft XDE\10.0.14393.0\XDE.exe" /name "HoloLens Emulator 10.0.0.14393.1.steve" /displayName "HoloLens Emulator 10.0.14393.0" /vhd "C:\Program Files (x86)\Windows Kits\10\Emulation\HoloLens\10.0.14393.0\flash.vhd" /video "1268x720" /memsize 2048 /language 409 /creatediffdisk "C:\Users\Steve\AppData\Local\Microsoft\XDE\10.0.14393.0\dd.1268x720.2048.1.vhd" /fastShutdown /sku HDE
```

You can use these (without the `steve` perhaps), or make your own by launching an emulator instance, going to your task manager and copying the command that was used to create that window.  

I suggest using the above instead ;)

## 2. Set up Unity to deploy to both devices when you want to

Get the IP addresses from the 2 emulators

1. Open the emulator
2. Click the little chevrons
3. Go to the networking tab
4. Make note of the IP address - the `169.x.x.x` address works a treat for me

Now HoloToolkit has a nice little deploy helper thing, but unfortunately it doesn't support multiple devices, and it doesn't always discover the devices properly. If you're doing this long-term, you might just want to hack the editor files for that window and steal the deployment bits you need (I did this when I was writing holohelpers).

However for this workshop, let's just rely on the fact that when it probes for devices, it finds them in a seemingly random order.  So let's deploy to a device using the toolkit

1. Run the emulators
2. In Unity, go to `HoloToolkit`-`Build Window`
3. Ensure you've built a solution
4. Click `Build APPX from solution` - this will make a package that can be deployed
5. On the "IP Address" section, click `refresh` until the device you want appears in the list
6. Click `Install`

The app will be available on the device.  You can either find it in the Emulator's start menu, or press `Launch Application` to do this.

> **Aside: But how on earth does this work?!?!** The HoloLens has APIs for all of the functions available in the device portal (remember, when we previewed it from the browser?).  You can upload and launch applications using these endpoints.  Want a hobby project? Improve this experience for multiple Hololenses!

## 3. All good? Awesome! Let's share those anchors

Serializing anchors manually will be covered soon, but let's get quick, easy* results so we feel good about ourselves!

> *not necessarily easy

We're going to leverage the SignalR server from [before](1-sharing.md), along with an abstraction around it that utilisates the `AnchorHub` to give us a `DistributedAnchorStore`

### 1. Add the anchor store and "glue" the game object to an anchor

Open `MoveToTapPosition.cs` and add the following field:

```cs
public DistributedHttpAnchorStore AnchorStore;
```

Update the start method:

```cs
IEnumerator Start()
{
    InputManager.Instance.AddGlobalListener(gameObject);

    yield return StartCoroutine(AnchorStore.GlueTogether(AnchorName, gameObject));
}
```

GlueTogether will download the anchor from the server, and attach it to the object if one was found.  If not, it will add a world anchor to the object _but not save it_.

### 2. Use the anchor store to destroy/attach the anchor

Update `OnInputClicked` to go via the anchor store to update anchors.  In this case, the anchor will be detached (so you can move it freely), and then saved (which also attaches it) when done.

```cs
  public void OnInputClicked(InputClickedEventData eventData)
  {
      var origin = Camera.transform.position;
      var direction = Camera.transform.rotation * Vector3.forward;

      RaycastHit hit;
      var rayCastSuccessful = Physics.Raycast(origin, direction, out hit, 20);
      if (!rayCastSuccessful || hit.collider.gameObject.layer != SpatialMappingManager.Instance.PhysicsLayer)
          return;

      var spawnPosition = hit.point + hit.normal * OffsetFromWall;

      AnchorStore.DetachAnchor(AnchorName, gameObject); // Changed

      var lookDirection = hit.normal;
      lookDirection.y = 0;
      lookDirection.Normalize();

      gameObject.transform.position = spawnPosition;
      gameObject.transform.rotation = Quaternion.LookRotation(lookDirection, Vector3.up);

      StartCoroutine(AnchorStore.SaveAnchor(AnchorName, gameObject)); // Changed
  }
```

### 3. Wire it up in the editor

We need to put the `DistributedWorldAnchorStore` script component onto here, and update our `SignalRClient` to honour the anchor hub too (it won't automatiacally register itself).

1. Select the `Networking` gameObject
2. Add another hub called `anchorHub` in the signalR client
3. Select the `Bee Spawner` prefab
4. Add the `DistributedWorldAnchorStore` to the new field from step 1

Deploy to both HoloLenses and see it in action.

## How does this actually work?

At the end of the day, an anchor is a series of bytes. What those bytes are, I don't know, but they're there - and Unity gives us a way to retrieve those bytes.  It's somewhat convoluted, but here it is:

```cs
var batch = new WorldAnchorTransferBatch();
batch.AddWorldAnchor(anchor.name, anchor);

var memoryStream = new MemoryStream();
WorldAnchorTransferBatch.ExportAsync(batch,
    bytes => memoryStream.Write(bytes, 0, bytes.Length),
    failureReason => { 
      var bytes = memoryStream.ToArray();
      // Do stuff with the bytes
    }
);
```

Basically, create a batch, add the anchor to it, and export it.  The second argument is called as data comes available, and the third when the serialization is completed - we can do whatever we want with the bytes (in this case, shoot it to a WebAPI endpoint and SignalR server).

We can deserialize them from bytes, too.

```cs
var isComplete = false;
WorldAnchorTransferBatch.ImportAsync(bytes, (failureReason, batch) =>
{
    var targetGameObject = /* find game object */;
    var anchor = batch.LockObject(worldAnchorId, targetGameObject);
    anchor.name = worldAnchorId;

    // Initially it won't be located (it may take a while to be found in the world), so we can wait for a callback:
    anchor.OnTrackingChanged += (WorldAnchor a, bool isLocated) => { /*...*/ };
});
```

And that's it! Most of the complexity is in the communication and managing `async` without `async`.

---
Next: Umm you're done

Prev: [Sharing](/4-networking/1-sharing.md)

