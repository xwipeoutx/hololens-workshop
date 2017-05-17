TODO: Sharing service in assets/External
TODO: Internet client

# Sharing

> **NOTE: THIS SECTION STILL UNDER DEVELOPMENT**

## Goals

* Share our world anchors (beehive position) across clients

## World Anchors and Sharing

Sharing world anchors is a tricky process.  Recall from [earlier](TODO) that a World Anchor represents a place in the real world. As the mapping of the real world becomes more defined, the World Anchor updates and stays in the same real world area.

This is useful in non-sharing situations, as it means the hologram will never sink behind a wall if the initial measurement was inaccurate, but it is absolutely necessary when sharing Holograms. Each Hololens will have different ideas on what a room looks like - this is just the nature of spatial mapping. 

A world anchor that is shared between devices will appear in the same place in the real world, as it is positioned based on queues and relative shape of the spatial map - not on absolute coordinates.

## So uhh, what _is_ a world anchor?

_Like, data-structure wise?_

Honestly, I have no idea.  I have only speculated and have not found any info if my speculation is anywhere close to true.  I _do_ know that a spatial anchor clocks in at about 500b - which is enough for around 40 vectors in 32 bits, which is more than enough precision for this.

If I had space for 40 vectors and had to store a position in a room, I'd cast a bunch of rays out at predetermined angles, and store the vector to the spatial map along that ray. I'd do it along all the basis vectors at least (positive and negative), and then a bunch of times in between _just in case_.

When loading the anchor on a new device I would do some fancy walk algorithm to find the point that most closely matches that, remembering there could be errors.

This is speculation, I have no idea how it actually works. Luckily, you don't need to know either! You just need to know that, out of the box, Unity can give you a bunch of bytes that represents a world anchor, and it'll Just Work.

## Some caveats

The Unity editor has no working implementation of anchor serialization/deserialization.  It just no worky - it's a device-only API.  So to test any of this out, it's deploy-to-the-emulator-o-clock.

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

## 3. 

## How the services interact

HoloToolkit's sharing service can be used to share World anchors. The flow is as follows:

1. Connect to the sharing service
2. Create/Join a _session_
3. Create/Join a _room_
4. To upload an anchor:
  1. Get the `WorldAnchor` from the `GameObject` (create one if it doesn't exist)
  2. Serialize it to a `byte` array using the `WorldAnchorTransferBatch`
  3. Send the bytes, along with a unique identifier, to the service via the `RoomManager`.  This is scoped to a single _room_
5. To download an anchor:
  1. Download anchor from the room by its unique identifier, as a `byte` array
  2. Deserialize the byte into a `WorldAnchorTransferBatch`
  3. Instruct the `WorldAnchorTransferBatch` to `Lock` the specified anchor to the `GameObject`.  This will add or update the relevant `WorldAnchor` component.

The concept of _session_ and _room_ has been introduced here - the sharing service has been designed to handle multiple of these at a time, each with a unique identifier.  For our purposes, we will be using a single session and room.

Sharing anchors is really just about uploading and downloading `byte` arrays
