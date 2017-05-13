# World Anchors

## Goals

* Use a world anchor to make our positioning world-aware

## World Anchors

While just setting the position directly is great and all, there are some issues with this approach when on a real device.

As the HoloLens user moves about the room, the room mesh is updated and becomes more and more precise - this can result in the mesh being in a different spot to when it was initially placed.  When this happens, the walls may start _occluding_ the placed hologram - I have seen the hologram become completely inaccessible and hidden because the wall has shifted by more than the thickness of the Hologram.

We get around this by using [Spatial Anchors](https://developer.microsoft.com/en-us/windows/holographic/Coordinate_systems.html#spatial_anchors)- which is described as an "important place in the world where the user has placed holograms".  

Basically, it uses the geometry of the room as a basis for positioning, and may adjust as more information about the room's geometry is discovered.  This is all built-in to the hololens, and is the same as placing apps around the room in the main OS - so you don't have to worry about the reliability of it.

### Update the script

Open `MoveToTapPosition` for editing.

Add the following field:

```cs
public string AnchorName = "GlobalMoveToPositionAnchor";
```

Add the following line to the `Start` method:

```cs
var anchor = gameObject.AddComponent<WorldAnchor>();
anchor.name = gameObject.name;
```

Modify `OnInputClicked`:

```cs
public void OnInputClicked(InputEventData eventData)
{
    var origin = Camera.transform.position;
    var direction = Camera.transform.rotation * Vector3.forward;

    RaycastHit hit;
    var rayCastSuccessful = Physics.Raycast(origin, direction, out hit);
    if (!rayCastSuccessful)
        return;

    var spawnPosition = hit.point + hit.normal * OffsetFromWall;

    var existingAnchor = gameObject.GetComponent<WorldAnchor>();
    if (existingAnchor != null)
    {
        DestroyImmediate(existingAnchor);
    }

    gameObject.transform.position = spawnPosition;

    var anchor = gameObject.AddComponent<WorldAnchor>();
    anchor.name = gameObject.name;
}
```

Dealing with anchors is relatively simple - it's simply a matter of attaching the supplied `WorldAnchor` component to the game object. Once attached, the `WorldAnchor` becomes responsible for managing the objects position and rotation.

Note that any attempt to move the object while it contains a `WorldAnchor` component will appear to do nothing - the `WorldAnchor` will shunt it back to the anchor's position immediately.

### But...errors?

TODO: Talk about anchors within Unity... if I still need to *gasp*

You may have noticed this error:

> `remove anchor called before anchor store is ready.`

You can inspect this file and see that the `WorldAnchorStore` is never created in the Unity Player.  Basically, that functionality doesn't exist within Unity - only in the emulator and the HoloLens.  So while everything still behaves properly, there is no effect _within Unity_ to using the anchors.

You still need to use them though!