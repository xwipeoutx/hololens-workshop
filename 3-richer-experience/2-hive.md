# Hive

## Goals

While cubes are cool, they're not _that_ cool.  You know what's cool? Bees. Bees are cool.

* Make a hive that spawns these bees, and provides a central point for the swarm

## 1. Import a hive mesh for our bees

1. Grab the <a href="/assets/models/beehive.zip" target="_blank" download>beehive mesh</a>
2. Extract it to the `Models` folder in your hierarchy
3. Set the "Scale factor" to 0.001, and uncheck "Use file scale", or it will be too large

## 1. Change our spawner to spawn bees instead

1. Open the `Spawn` script, and change the `NumberOfSecondsBetweenSpawns` to a `float`
2. On our `Spawner` in the scene hierarchy:
  1. Change the `Number of seconds between spawns` to `0.1`
  2. Change the maximum number to `50`
  3. Drag the `Bee` to the `Thing to spawn` field.
3. For accuracy, rename the `Spawner` game object to `Bee Spawner`
4. Drag the newly imported `Hive` model to be a child of the `Spawner`
5. Hit play

We should see bees swarming now instead of cubes falling. Nice!

Try placing it around your room, and see the results on walls of differing orientation.

## 2. Ensure the placed object is looking the right way.

You'll note the orientation of the beehive does not change as you place it - ideally it will face the normal of the wall. Let's make that happen now.  To do this, change `OnInputClicked` in `MoveToTapPosition` to:

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

    var lookDirection = hit.normal;
    lookDirection.y = 0;
    lookDirection.Normalize();

    gameObject.transform.position = spawnPosition;
    gameObject.transform.rotation = Quaternion.LookRotation(lookDirection, Vector3.up); // New

    var anchor = gameObject.AddComponent<WorldAnchor>();
    anchor.name = gameObject.name;
}
```

Play and run - now our beehive faces the right way every time. Perfect!

## 3. Holograms, cursors and collisions.

When we added the beehive, it was imported without a `Mesh Collider` component - so the physics engine is completely unaware of its existence.  You can verify this by running the game and looking at the beehive - note that the cursor is _behind_ the beehive, not in front.

This is fine for what we have now, but if you want to interact with the hologram itself (eg. make it start and stop spawning bees on tap), then we'll need to give it a collider.

1. Add the "Mesh collider" component to the beehive
2. Run the game and play around

If you tap at the beehive right now, the raycast in our `MoveToTapPosition` script will hit the beehive - we need to ensure that it only hits surfaces from the spatial mapping.

Fortunately, this is easy to fix.  The Spatial Mapper puts the mesh in layer 31 by default - and this is exposed in the `SpatialMappingManager` singleton.  We can adjust our raycast code to only look at this layer.  

1. Open the `MoveToTapPosition` script.
2. Change the raycast code to:

```cs
var rayCastSuccessful = Physics.Raycast(origin, direction, out hit, 20, 1 << SpatialMappingManager.Instance.PhysicsLayer);
```

This method signature also requires a max ray length distance, I chose 20 metres.

Now when you run, it will only raycast against the mesh, not the hologram.

You might find this a little weird - that tapping the beehive makes it move.  The other option is to ignore collisions that hit any other layer, like so:

```cs
RaycastHit hit;
var rayCastSuccessful = Physics.Raycast(origin, direction, out hit, 20);
if (!rayCastSuccessful || hit.collider.gameObject.layer != SpatialMappingManager.Instance.PhysicsLayer)
    return;
```

I prefer the 2nd option myself.

---
Next: [Spatial Sound: Buzzing bees](3-spatial-sound.md)

Prev: [Model: Add a buzzing bee](1-bee.md)