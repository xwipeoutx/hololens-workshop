# Create the Scene

## Goals

* Have a project suitable for holographic development
* Configure the camera and input for speedy development
* Add a hologram to the game world
* See the results in the Unity editor

## 1. Create the Unity project

**Note**: If you did [Section 2](2-unity-overview.md) then you will already have a project.

1. Open Unity
2. Press the "New" button
3. Enter the project details, we'll call it "**The Swarm**".
4. Ensure the project is `3D` and, for simplicity, turn Unity Analytics `Off`
5. Click create project.

## 1. Create a scene

**Note:** Even if you made a scene [Section 2](2-unity-overview.md), create a new scene now - we will do our holograms in this scene.

For our project, we will have a single scene.

1. Create a new Unity scene, call it `Swarm`
2. Double click the scene to focus it to the hierarchy
3. Click the Directional light and change the colour to white

## 2. Add HoloToolkit to the project

We're now going to add `HoloToolkit` that we created/downloaded in the [previous section](3-holotoolkit.md) to our project.

1. Under `Assets`, choose `Import Package` then `Custom Package...`
2. Select your newly built HoloTookit package and press `Open`
3. Ensure everything is selected
4. Press `Import`

Your Assets window will now have 3 new folders - `HoloToolkit`, `HoloToolkit-Examples` and `HoloToolkit-UnitTests`.  Note that only `HoloToolkit` will be added to our scene - the others do not need to be imported, or can be deleted.  Depending on how you built `HoloToolKit`, or which package you downloaded, you may not see the examples or unit test packages.

A new menu will appear at the top - `HoloToolkit`. This is a cool feature of Unity - packages can change the editing experience.  In this case, HoloToolkit includes a bunch of tools to assist in setting up the scene and visual studio projects and even deploy to devices (yes, plural! It is much more useful for development deployments than Visual Studio)

## 3. Configure the Project

In order to work with Holographic devices, some project settings need to be set up - mainly around setting up the device capabilities and targets.

The Windows Holographic Academy tutorials go through this in detail, but HoloToolkit can do it for us:

1. Click the `HoloTookit` menu
2. Click `Configure`
3. Choose `Apply HoloLens Project Settings`
4. Ensure everything is selected and click `Apply`
5. You will be prompted to save and restart - do it.

### Aside: What are these other options?

Configuring the scene sets up the existing camera to be suitable for HoloLens development.  This does things like setting the camera background to "black" (HoloLens-speak for transparent apparently), setting the clipping planes to avoid eye fatigue and putting it at the origin.

We'll be using the Camera supplied by `HoloToolkit`, so this is not required.

We will apply the Capability settings as we need them - right now, we don't need to use any of the HoloLens-specific capabilities.

## 3. Add the camera

The default camera in the scene is not well suited for Holographic development, having unsuitable defaults for position and orientation, as well as having clipping planes that will give users headaches.  Fortunately, HoloToolkit has one for us!

1. In the scene, click `Main Camera` and press `Delete`
2. In the `Project` window, search for `Camera` (or navigate to `HoloToolkit/Input/Prefabs`)
3. Drag the `HoloLensCamera` prefab into the scene

This camera is configured with all the good defaults, including:

* Position of `(0,0,0)`
* Near clip plane of 85cm - holograms will clip at this point to avoid eye fatigue
* Black background - this is the HoloLens transparent colour
* Small Field of View (FOV) - since the viewport of the HoloLens is tiny

It also has scripts for manual control in the unity editor - extremely useful for rapid development feedback cycle.

## 4. Add the Cursor

Most of the time the user will need to know what they're looking at - it isn't a natural thing to look with your head instead of your eyes, and a cursor helps focus the attention to where it needs to be. The one in HoloToolkit will orient itself to appear to stick on the surface, or appear as a dot when there is no surface found. 

1. In the asset window, search for `Cursor` (or navigate to `HoloToolkit/Input/Prefabs/Cursors`)
2. Drag the `Cursor` prefab into the scene

## 5. Input and events

At this point, while we have a camera and a cursor, we have no way of mapping head movements to camera movements - we need some input.

1. Create an empty game object, call it `Managers` 
2. In the asset window, search for `InputManager`
3. Drag the `InputManager` prefab onto the `Managers` game object
4. Select the `Managers` game object
5. Right click it, and choose `UI -> Event System`

This adds HoloToolkit's input system (with all its gaze support and stabilization), along with Unity's event system.

## 6. Bring a hologram in

1. Create a Cube game object
2. Position it at `(0, 0, 3)`
3. Rotate it to `(45, 45, 45)`
4. Scale it to `(0.5, 0.5, 0.5)`
5. Under `Mesh Renderer` set the Material to `HoloToolkit-Default`, and change the colour to a vibrant blue.  This is a nice base material, as it is pretty configurable and is much faster than the default material - good for a constrained device like the HoloLens.  

**Aside:** The way we've changed the colour here means that all objects using this material will be that colour - normally you'd have a material for each colour.  We'll only have 1 colour, so it's no problem.

**Extra Credit:** If you're feeling brave, bring in the car prefab from [Section 2](2-unity-overview.md). You may need to turn off gravity and/or remove the Rigidbody from it for now.

### About transparency

We chose a vibrant colour for our material for a couple of reasons.  The first is that the design guidelines state that holograms should be so - vibrant, and largely self-illuminated.  Having a constant directional light and vibrant colours achieves this, while keeping the shading for 3D appearance (something that an emissive material wouldn't do).

Secondly, to achieve the holographic effect, the HoloLens display is a partial-reflection of a screen - kind of like a tinted window. To see through a tinted window, you make your side darker by cupping your hand over it - essentially removing the reflection.  That is, "black" is the absence of any reflection - and in this case will be transparent on the device.

Looking at it another way, the _lightness_ of a material defines its _opacity_ - which is why the design guidelines state that Holograms should be bright, vibrant colours.  Anything less would make it look ghostly and transparent.

You can see this in action by setting the material to completely black, and running it on the HoloLens - it will be invisible.

## 7. Have a look around

Press play and have a look.  Controls are similar to the Unity scene view - WASD and right-click-drag.

Some things to note.

1. We made a 50cm cube 3 meters away and it takes up the whole viewport - the field of view of the HoloLens is _that_ limited.    
    * If you're used to playing first person shooters, this can be difficult to get used to - it feels like everything is bigger, but actually the FOV is just smaller.
    * You can adjust the FOV to a more sensible `90` in the camera settings - this only applies to the Unity editor view - you just need to keep in mind the view in Unity is not going to be the same as the HoloLens.
    * With this lower FOV, the fake hand locations will be tiny and distant
    * If you do change the FOV, one little trick would be to draw a static rectangle representing the HoloLens viewport, in Unity only. We're not going to do that
2. The default cursor reacts differently for holograms and not.  Note it sticking to the hologram and orienting the right direction.
3. If you stand back too far, the collision no longer works - there is a maximum distance for the gaze collider, which is can configured in the `InputManager`.
4. There is some simulation of finger taps here, we will cover this later - but for now, you can see the hands at the bottom.  Trying tapping by using a combination of `Shift` or `Space`, plus the `Left Mouse Button`.

---
Next: [Deploying ot the device](5-deployment.md)

Prev: [HoloToolkit](3-holotoolkit.md)
