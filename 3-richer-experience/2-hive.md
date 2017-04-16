# Hive

## Goals

While cubes are cool, they're not _that_ cool.  You know what's cool? Bees. Bees are cool.

* Make a hive that swarms these bees

## 1. Import a hive mesh for our bees

TODO: Check the scale factor

1. Grab the beehive mesh from `/assets/models/beehive.fbx` (along with the associated textures)
2. Copy it to the `Models` folder in your hierarchy

## 1. Change our spawner to spawn bees instead

1. Open the `Spawn` script, and change the `NumberOfSecondsBetweenSpawns` to a `float`
2. On our `Spawner` in the scene hierarchy:
  1. Change the `Number of seconds between spawns` to `0.1`
  2. Change the maximum number to `50`
  3. Drag the `Bee` to the `Thing to spawn` field.
3. For accuracy, rename the `Spawner` game object to `Beehive`
4. Drag the newly imported `Hive` model to be a child of the `Spawner`
5. Hit play

We should see bees swarming now instead of cubes falling. Nice!

## 2. Ensure the placed object is looking the right way.

if you did **Step 4**, you'll note the orientation of the beehive does not change - ideally it will face the normal of the wall. Let's make that happen now.  To do this, change `OnInputClicked` in `MoveToTapPosition` to:

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

    // New
    var lookDirection = hit.normal;
    lookDirection.y = 0;
    lookDirection.Normalize();

    var existingAnchor = gameObject.GetComponent<WorldAnchor>();
    if (existingAnchor != null) {
        gameObject.RemoveAnchor(existingAnchor);
    }

    gameObject.transform.position = spawnPosition;
    gameObject.transform.rotation = Quaternion.LookRotation(lookDirection, Vector3.up); // New

    var anchor = gameObject.AddComponent<WorldAnchor>();
    anchor.name = gameObject.name;
}
```

Play and run - now our beehive faces the right way every time. Perfect!

## 3. Ensuring our hives can only be attached to the mesh, not other holograms.

If you tap at the beehive right now, the raycast will hit the beehive - we need to ensure that it only hits surfaces.

Fortunately, this is easy to fix.  The Spatial Mapper puts the mesh in layer 31 by default - and this is exposed in the `SpatialMappingManager` singleton.  We can adjust our raycast code to only look at this layer.  

1. Open the `MoveToTapPosition` script.
2. Change the raycast code to:

```cs
var rayCastSuccessful = Physics.Raycast(origin, direction, out hit, 20, 1 << SpatialMappingManager.Instance.PhysicsLayer);
```

This method signature also requires a max ray length distance, I chose 20 metres.

Now when you run, it will only raycast against the mesh, not the hologram.