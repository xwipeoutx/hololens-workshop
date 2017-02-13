# Create the Scene

It's now time to start our unity project, configure it for holograms and go crazy!

## 1. Initial Unity project

1. Open Unity
2. Press the "New" button
3. Enter the project details, we'll call it "**The Swarm**" for now.
4. Ensure the project is `3D` and, for simplicity, turn Unity Analytics `Off`
5. Click create project.

At this point you'll be greeted with the Unity main window.  We're going to fiddle with the Unity layout a little
to make our lives easier

1. From the menu, Select `Window` -> `Layouts` -> `Tall`

Your window will look like this.

![Main Unity window](img/window-unity-main.png)

1. A preview of the unity scene.  Most of your layout and positioning will be done here.
2. The currently loaded scene - a hierarchy of all the game objects in the scene.
3. Your project assets.  Think icons, shaders, materials and meshes.
4. The inspector. Shows the properties of the selected game object, and allows you to attach components to each.
5. The play button. Starts your game within the unity editor - this is how you will do most of your previewing.

## 2. Crash Course: Unity concepts in 5m or less.

For those experienced in Unity, feel free to skip this section.  For the rest of us, let's take a quick peek at Unity.

The Unity editor is an easy-to-use game development platform, which we will be using to develop our holographic apps on.

A Unity project is comprised of Scenes, which act as a container for a set of Game Objects, and are generally the first thing you create in any project.

A game object is a container for anything visual or behavioural in your game.  Each Game Object can hold other Game Objects too, and their
position/rotation/scale transforms are hierarchical in nature.  This is very useful as a way of grouping and interacting with groups
of related things.  For example, you may have a car game object, with 5 child game objects - one for each wheel, and one for the chassis.
The wheels can rotate independently of the chassis, but you can move the parent and the whole thing will move.

Don't be afraid to create many game objects - they're cheap and the structural benefits you get out of them will be worth it.

Game Objects on their own do not do much besides transform themselves and children - they require Components to operate. A component
does a single thing, and does it well. It may render a mesh, run a script, execute a particle engine, handle input, and anything you
can think of.  When you write custom code, you write it as a Script Component that is attached to a Game Object.

Components often have configurable properties (eg. the spawn rate for the bees in a beehive component) and this is shown in the Inspector 
view.  Properties can be simple scalar variables, arrays or other game objects / components.  The UI supports all these with appropriate
controls, or drag-drop mechanisms - it makes configuring these things quite simple.

Scripts are compiled by the editor as they are saved, and the game can be run directly inside the editor.  This provides a very fast
feedback loop for your game.

With that block of text out of the way, let's start our first scene


Game objects also act as a container for Components - indeed, without Components, nothing would happen at all, as a game object on its
own does not do much.




You will see a window like the following:
TODO: Image

I'm not a fan of the default layout, I recommend changing to the build-in vertical layout - that's what these screenshots will use.

TODO: Layout

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