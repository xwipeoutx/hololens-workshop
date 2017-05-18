# Interacting with world

## Goals

* Have our cube interact with the room
* Learn how to use the `tap` gesture in the Unity editor 

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
5. Search for and add `ThrowAtWall`
6. Right-click the script and choose `Edit Script`

This will launch Visual Studio with the script projects - handy!  You can open this in any code editor you like - in the end it will be compiled by Unity, not your IDE.

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

    public void OnInputClicked(InputClickedEventData eventData)
    {
        gameObject.transform.position = ThrowSource.transform.position;
        RigidBody.velocity = ThrowSource.transform.rotation * Vector3.forward * 10;
        RigidBody.angularVelocity = Vector3.forward * 4;
    }
}
```

A quick rundown:

1. Has an input for the throw source (ours will be the camera), and the rigid body.  These will be exposed in the Unity editor
2. The `Start()` method (called when the object is started) registers this script with `HoloToolkit`'s `InputManager` singleton
3. This is being registered as a global `Click` handler - which translates to tap in our gesture world
4. When the event is clicked, we:
  1. Set the position of the cube to the throw source
  2. Set the velocity of the rigid body to a multiple of the throw source's "look" vector (positive `z`).
  3. Put some angular velocity on so it tumbles through the air and looks freakin' amazing

## 3. Set up the throw source and rigid body

With the cube selected in the editor, under the `ThrowAtWall` script component

1. Drag the "camera" game object to the `Throw Source` parameter
2. Select the `Rigid Body` component for the `Rigid Body` parameter
3. Reduce the cube size to 20cm (set scale transform to `0.2, 0.2, 0.2`)

## 4. Test it out

Run!  With the default key bindings, here is how you tap.  You will likely be holding down the `Right Mouse Button` at the same time for mouselook.  It's a little awkward, honestly.

1. Hold `Space` to put your right hand into view
2. Hold `Left Mouse Button` to lower your finger
3. Release `Left Mouse Button` to raise again 

You'll need to be careful you're not inside a wall at the time, as that tends to mess things up.

---
Next: [Placing Objects](4-placing-objects.md)

Prev: [Spatial Mapper](2-using-spatial-mapper.md)