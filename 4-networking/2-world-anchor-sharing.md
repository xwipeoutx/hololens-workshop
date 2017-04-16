TODO: Sharing service in assets/External
TODO: Internet client

# Sharing

## Goals

* Share our world anchors (beehive position) across clients

## World Anchors and Sharing

Sharing world anchors is a tricky process.  Recall from [earlier](TODO) that a World Anchor represents a place in the real world. As the mapping of the real world becomes more defined, the World Anchor updates and stays in the same real world area.

This is useful in non-sharing situations, as it means the hologram will never sink behind a wall if the initial measurement was inaccurate, but it is absolutely necessary when sharing Holograms. Each Hololens will have different ideas on what a room looks like - this is just the nature of spatial mapping. 

A world anchor that is shared between devices will appear in the same place in the real world, as it is positioned based on queues and relative shape of the spatial map - not on absolute coordinates.

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
