# World Anchors

## Goals

* Implement a cube spawner
* Place the spawner with a tap
* Use a world anchor

TODO: have a prefab package available for this part, up to `World Anchor`

## 1. Add a spawner

1. Right click the scene hierarchy, choose `Empty Game Object`
2. Call the game object `Spawner`
3. Place it at `(0,0,3)`
4. In the `Scripts` folder of your assets, add a new script, call it: `Spawn`
5. Add this script to your `Spawner` object
6. Edit the script (via `Right click`-`edit script`)

## 2. Write the script

Our spawner needs some inputs for sanity

* The game object to spawn copies of
* Time between spawns
* Maximum number of things to spawn

Our spawner will be resposible for the lifetime of the children.

Add the following fields. Note we've put a list in to keep track of our spawned objects.

```cs
    public GameObject ThingToSpawn;
    public int MaxNumberOfThings = 5;
    public int NumberOfSecondsBetweenSpawns = 1;
    
    private List<GameObject> _spawnedThings = new List<GameObject>();
```

We're going to use a [Coroutine](https://docs.unity3d.com/Manual/Coroutines.html) - which is a clever hack by Unity to
manage operations that need to be performed over multiple game loop cycles, by leveraging `yield`.  Let's write it now:

```cs
IEnumerator DoTheSpawns()
{
    if (ThingToSpawn == null)
        yield break;

    while (true)
    {
        // Pop things off if there are too many
        while (_spawnedThings.Count >= MaxNumberOfThings)
        {
            Destroy(_spawnedThings[0]);
            _spawnedThings.RemoveAt(0);
        }

        // Create a new thing
        var newThing = Instantiate(ThingToSpawn, transform.position, Quaternion.identity);
        _spawnedThings.Add(newThing);

        // Don't execute again until the time has passed
        yield return new WaitForSeconds(NumberOfSecondsBetweenSpawns);
    }
}
```

The Coroutine will be stopped when the Game Object is destroyed, so we need not worry about a terminating condition.

We'll start this coroutine in the `Start` method:

```cs
void Start()
{
    if (ThingToSpawn == null)
        Debug.LogError("Spawn: No things to spawn");

    if (NumberOfSecondsBetweenSpawns <= 0)
        Debug.LogError("Spawn: Need to have some positive time between spawns");

    StartCoroutine(DoTheSpawns());
}
```

## 3. Configure the objects

Switch back to the Unity editor to configure this script

1. Select the `Cube` game object
2. Remove the `ThrowAtWall` script
3. Select the `Spawner` game object
4. Drag the `Cube` game object to the appropriate field
5. Leave the other values at their defaults.

Hit play - you should see the cubes fall.

## 4. Extract a prefab for the cube

We no longer need the cube to be in the initial scene - so let's make a prefab out of it

1. Create a folder in your assets called `Prefabs`
2. Drag the cube to the folder
3. Delete the cube from the scene
4. Drag the cube prefab to the `Thing to Spawn` field of the spawner

Run again - it should work as before.

## 5. Create a script to move the spawner

As in step 1, add a script called `MoveToTapPosition`, attach it to the spawner.

This is the code we'll use:

```cs
using HoloToolkit.Unity.InputModule;
using UnityEngine;

public class MoveToTapPosition : MonoBehaviour, IInputClickHandler
{
    public Camera Camera;
    public float OffsetFromWall = 0.5f;
    public float OffsetWhenNoWall = 5;

    // Use this for initialization
    void Start()
    {
        InputManager.Instance.AddGlobalListener(gameObject);
    }

    public void OnInputClicked(InputEventData eventData)
    {
        var origin = Camera.transform.position;
        var direction = Camera.transform.rotation * Vector3.forward;

        RaycastHit hit;
        var rayCastSuccessful = Physics.Raycast(origin, direction, out hit);
        if (!rayCastSuccessful)
            return;

        var spawnPosition = hit.point + hit.normal * OffsetFromWall;
        
        gameObject.transform.position = spawnPosition;
    }
}
```

In this code we do a _Ray cast_ to look for an intersection with a surface - in this case, the room.

A ray cast works by starting from an _origin_ and moving along a particular _direction_ until it intersects with something (yes, this is a simplified explanation).  When it intersects with something, some information about the `RaycastHit` is calculated - such as the position and the normal.

In this case, we start the ray at the camera position and face it in the direction the camera is looking. If a hit is found, the spawn position is offset from the wall a specified amount.  If not, it sets the position to a specific distance along the ray.

## 6. Test it out

Back to Unity.

1. Select the `Spawner` game object
2. Drag the `HoloLensCamera` to the `Camera` section
3. Leave the rest as-is

Play!

Now whenever you tap, the spawner will move around. Hurrah!

## 7. World Anchors

While just setting the position directly is great and all, there are some issues with this approach when on a real device.

As the HoloLens user moves about the room, the room mesh is updated and becomes more and more precise - this can result in the mesh being in a different spot to when it was initially placed.  When this happens, the walls may start _occluding_ the placed hologram - I have seen it become completely inaccessible because the wall has shifted by more than the thickness of the Hologram.

We get around this by using [Spatial Anchors](https://developer.microsoft.com/en-us/windows/holographic/Coordinate_systems.html#spatial_anchors)- which is described as an "important place in the world where the user has placed holograms".  

Basically, it uses the geometry of the room as a basis for positioning, and can adjust over time. 

### Update the script

Open `MoveToTapPosition` for editing.

Add the following field:

```cs
public string AnchorName = "GlobalMoveToPositionAnchor";
```

Add the following line to the `Start` method:

```cs
WorldAnchorManager.Instance.AttachAnchor(gameObject, AnchorName);
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
        
        WorldAnchorManager.Instance.RemoveAnchor(gameObject); // New!
        gameObject.transform.position = spawnPosition;
        WorldAnchorManager.Instance.AttachAnchor(gameObject, AnchorName); // New!
}
```

Dealing with Anchors is relatively simple in HoloToolkit - it's simply a matter of attaching the anchor initially, and doing a remove/attach of the anchor when you move it.  Note you _should not_ move the game object while it's attached to an Anchor - remove it, move it, reattach it.

### Add a WorldAnchorManager to the scene

Our code uses HoloToolkit's `WorldAnchorManager` singleton - which means we need to add that script component.

1. Back to Unity
2. Select the `Managers` game object
3. Add the `WorldAnchorManager` to the scene

Play! Everything should still work.

### But...errors?

You may have noticed this error:

> `remove anchor called before anchor store is ready.`

You can inspect this file and see that the `WorldAnchorStore` is never created in the Unity Player.  Basically, that functionality doesn't exist within Unity - only in the emulator and the HoloLens.  So while everything still behaves properly, there is no effect _within Unity_ to using the anchors.

You should still use them though! They're very important for the real device.