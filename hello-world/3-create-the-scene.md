# Create the Scene

Now we've got a Hologram-ready project, let's make our first scene.

## 1. Create a scene

Unity projects have a top-level `Scene` under which everything sits.  In a traditional FF7-style RPG game for example, 
you might have a Scene for the menus, a scene for the world map, a scene for the area map, and a scene for battle mode.

For our project, we will have a single scene.

1. In the Unity editor, click new scene
2. Save it to `TODO: Folder` as `TODO: SceneName`

## 2. Apply HoloToolkit settings to scene

In order to work with Holographic devices, some project settings need to be set up - mainly around setting up the device capabilities and targets.

The Windows Holographic Academy tutorials go through this in detail, but HoloToolkit can do it for us:

1. Click the `HoloTookit` menu
2. Click `Configure`
3. Choose `Apply HoloLens Scene Settings`

Done!

## 3. Set up the camera, input and stuff

The default camera in the scene is not well suited for Holographic development, having unsuitable defaults for position and orientation, as well as having clipping planes that will give users headaches.  Fortunately, HoloToolkit has one for us!

1. In the scene, find the Camera game object
2. Delete it TODO: How
3. In the asset window, search for `Camera` (or navigate to `HoloToolkit/Input/Prefabs`)
4. Drag the camera into the scene

Most of the time the user will need to know what they're looking at - it isn't a natural thing to look with your head instead of
your eyes, so let's put a cursor in. The one in HoloToolkit will orient itself to appear to stick on the surface, or appear as a dot
when there is no surface found. 

1. In the asset window, search for `Cursor` (or navigate to `HoloToolkit/Input/Prefabs/Cursors`)
2. Drag the `DefaultCursor` prefab into the scene

At this point, while we have a camera and a cursor, we have no way of mapping head movements to camera movements - we need some input.

There are some oddities here around how Unity (and HoloToolkit) manages input as scripts (custom code) can only be run when attached to game objects. The usual way to deal with this is to create a dummy game object, with no meshes or anything, and attach scripts to that.  We also
put 

1. TODO: Create a game object, call it `Managers`
2. In the asset window, search for `InputManager`
3. Drag 