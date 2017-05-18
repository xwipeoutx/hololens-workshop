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

## World Anchor Store

**Note:** If you're having woes with emulators, skip this bit.  World anchor sharing, later, is much more useful and important.

**Note2:** If you get stuck here and it doesn't work, **MOVE ON** - debugging errors on the emulator is a slow and painful process - especially since you need to be running in `Release` or `Master` to have any hope of it not crashing the HoloLens. If you really want to debug, simply run the app with the debugger or attach to the remote UWP process.  You can use the assembly explorer to open scripts and add breakpoints.  But seriously, you're better off learning about new Hololens features and fixing these issues in your own time! 

If we want to persist these, we need to use the _world anchor store_.  Unfortunately, this doesn't work with the Unity Editor (apparently persisting these anchors requires some internal device thingies that they haven't bothered doingg for the editor).

In any case, persistent anchors aren't terribly important for the dev experience, and we can work around this issue with null checks or `#if !UNITY_EDITOR` statements. So let's get our bee position perstisting to the anchor store.

### 1. Extract delete to its own method

Find this code

```cs
var existingAnchor = gameObject.GetComponent<WorldAnchor>();
if (existingAnchor != null)
{
    DestroyImmediate(existingAnchor);
}
```

And put it in its own method `DestroyAnchor`

### 2. Bring in the WorldAnchorStore, load the anchor on startup

Add the following (along with the backing field) to the start method:

```cs

#if !UNITY_EDITOR
    WorldAnchorStore.GetAsync(store =>
    {
        _store = store;
        DestroyAnchor();

        var loadedAnchor = _store.Load(AnchorName, gameObject);
        if (loadedAnchor == null)
        {
            Debug.Log("No anchor found - saving");
            AttachAndPersistAnchor();
        }
        else
        {
            Debug.Log("Loaded Anchor " + AnchorName + ". located? " + loadedAnchor.isLocated);
        }
    });
#endif
```

But wait, what's `AttachAndPersistAnchor`?

```cs
    private void AttachAndPersistAnchor()
    {
        var anchor = gameObject.AddComponent<WorldAnchor>();
        anchor.name = gameObject.name;
#if !UNITY_EDITOR
        Debug.Log("Saving Anchor " + AnchorName + " located? " + anchor.isLocated);
        _store.Save(AnchorName, anchor);
#endif
    }
```

### 3. Add the store to delete as well

Update `DestroyAnchor` to use persistence.

```cs
private void DestroyAnchor()
{
    var existingAnchor = gameObject.GetComponent<WorldAnchor>();
    if (existingAnchor != null)
    {
        Debug.Log("Destroying Anchor " + AnchorName + " located? " + existingAnchor.isLocated);

        DestroyImmediate(existingAnchor);

#if !UNITY_EDITOR
        _store.Delete(AnchorName);
#endif
    }
}
```

All good! If you fire up your emulator, you should be able close/reopen your app and have a persisted anchor.  And the editor shouldn't explode with errors either! Win/win.

---
Next: [Richer Experience](/3-richer-experience/index.md)

Prev: [Placing Objects](4-placing-objects.md)