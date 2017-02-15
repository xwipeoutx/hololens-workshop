# Interacting with world

## Goals

* Have our cube interact with the room

## 1. Make the cube a physics object

1. Click the `Cube` game object
2. Click `Add Component`
3. Search for and add `Rigidbody`

If you play now, you will see the cube fall.  If you move the cube to be where the room would be on load, it will land in the room.

Easy, right? Let's make it a _little_ bit interactive

##2. Throw cube around the room

We will add a script so that whenever you use the `Tap` gesture, the cube will be thrown in the direction you face.

**Note:** This is a quick script to demonstrate physical response for the spatial map - we will cover input in greater detail later.

1. Add a `Scripts` folder to your assets
2. Create a new script, call it `ThrowAtWall` (Important: Do not add the `.cs` file extension)
3. Click the `Cube` game object
4. Click `Add Component`
5. Search for and ad `ThrowAtWall`
6. Right-click the script and choose `Edit Script`

This will launch Visual Studio with the script projects - handy!

Edit the file to look like this:

```cs
using HoloToolkit.Unity.InputModule;
using UnityEngine;

public class ThrowAtWall : MonoBehaviour, IInputClickHandler
{
    public GameObject ThrowSource;
    public Rigidbody RigidBody;

    void Start()
    {
        InputManager.Instance.AddGlobalListener(gameObject);
    }

    public void OnInputClicked(InputEventData eventData)
    {
        gameObject.transform.position = ThrowSource.transform.position;
        RigidBody.velocity = ThrowSource.transform.rotation * Vector3.forward * 10;
        RigidBody.angularVelocity = Vector3.forward * 4;
    }
}
```

A quick rundown:

1. Has an input for the throw source (ours will be the camera), and the rigid body.  These will be exposed in the UI
2. The `Start()` method (called when the object is started) registers this script with `HoloToolkit`'s `InputManager` singleton
3. This is being registered as a global `Click` handler - which translates to tap in our gesture world
4. When the event is clicked, we:
  1. Set the position of the cube to the throw source
  2. Set the velocity of the rigid body to a multiple of the direction the throw source
  3. Put some angular velocity on so it tumbles through the air and looks rad

## 3. Test it out

Run!  With the default key bindings, here is how you tap.  You will likely be holding down the `Right Mouse Button` at the same time for mouselook.  It's a little awkward, I'll be honest.

1. Hold `Space` to put your right hand into view
2. Hold `Left Mouse Button` to lower your finger
3. Release `Left Mouse Button` to raise again 

---
Next: [Plane Detection](4-plane-detection.md)

Prev: [Spatial Mapper](2-using-spatial-mapper.md)