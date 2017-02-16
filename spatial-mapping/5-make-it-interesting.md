# World Anchors

## Goals

* Make a swarm of bees

## 1. Import a bee from the internet

Unfortunately, the Unity store has no good looking bees, so let's import one.

1. Download the [Bee 3DS Model](../assets/models/bee.3ds)
2. Create a `Models` folder in your hierarchy, and paste the model there
3. Drag the bee model onto your scene to see it render

Note the bee is _really_ large. Thanks, Internet.

4. Click the Bee model in your assets
5. Enter `3e-07` for the scale
6. Scroll down and click `Apply`

The bee will be smaller - a good size for our app, methinks.

## 2. Add flight behaviour for our bee

Add a script to the bee called `FlyAround` with the contents:

```cs
using UnityEngine;

public class FlyAround : MonoBehaviour
{
    public float MinSpeed = 5;
    public float MaxSpeed = 1;
    public float MaxRadius = 0.5f;
    public float MinRadius = 0.1f;
    public int PlaneAngleUpperLimit = 30;
    private float _radius;
    private float _speed;
    private float _direction;

    void Start()
    {
        _radius = Random.Range(MinRadius, MaxRadius);
        _speed = Random.Range(MinSpeed, MaxSpeed);
        _direction = Random.value > 0.5f ? 1 : -1;

        gameObject.transform.Rotate(Vector3.up, Random.Range(0, 360) * _direction, Space.Self);
        gameObject.transform.position -= _direction * gameObject.transform.right * _radius;
        gameObject.transform.Rotate(Vector3.forward, Random.Range(-60, 60), Space.Self);
    }

    void Update()
    {
        var delta = Time.deltaTime * _speed;

        // Speed is number of circumferences per second
        gameObject.transform.Rotate(Vector3.up, delta * 360 * _direction, Space.Self);

        // Now we can always move forward at a constant speed of circumference/Speed
        var circumference = Mathf.PI * 2 * _radius;
        gameObject.transform.position += gameObject.transform.forward * delta * circumference;
    }
}
```

It's just a random circle flying behaviour - with a lot of bees, it will look like a swarm.

Hit play to see if your bee goes around in circles.  Once you're happy, add it to your prefabs and delete the bee

## 3. Change our spawner to spawn bees instead

1. Open the `Spawn` script, and change the `NumberOfSecondsBetweenSpawns` to a `float`
2. On our `Spawner` in the scene hierarchy:
  1. Change the `Number of seconds between spawns` to `0.1`
  2. Change the maximum number to `50`
  3. Drag the `Bee` to the `Thing to spawn` field.
3. For accuracy, rename the `Spawner` game object to `Beehive`
4. TODO: Add a cube representing our beehive.
5. Hit play

We should see bees swarming now instead of cubes falling. Nice!

## 4. Ensure the placed object is looking the right way.

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

    var lookDirection = hit.normal;
    lookDirection.y = 0;
    lookDirection.Normalize();

    WorldAnchorManager.Instance.RemoveAnchor(gameObject);
    gameObject.transform.position = spawnPosition;
    gameObject.transform.rotation = Quaternion.LookRotation(lookDirection, Vector3.up);
    WorldAnchorManager.Instance.AttachAnchor(gameObject, AnchorName);
}
```

Play and run - now our beehive faces the right way every time. Perfect!

## 4. Ensuring our hives can only be attached to the mesh, not other holograms.

If you tap at the beehive right now, the raycast will hit the beehive - we need to ensure that it only hits surfaces.

Fortunately, this is easy to fix.  The Spatial Mapper puts the mesh in layer 31 by default - and this is exposed in the `SpatialMappingManager` singleton.  We can adjust our raycast code to only look at this layer.  

1. Open the `MoveToTapPosition` script.
2. Change the raycast code to:

```cs
var rayCastSuccessful = Physics.Raycast(origin, direction, out hit, 20, 1 << SpatialMappingManager.Instance.PhysicsLayer);
```

This method signature also requires a max ray length distance, I chose 20 metres.

Now when you run, it will only raycast against the mesh, not the hologram.