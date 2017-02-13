# HoloToolkit

The latest Unity releases have in-built support for Holographic development and UWP publishing, it doesn't hold your hands
with working in a holographic world - there are a few concepts andn setup that are unique to mixed reality - for example, camera
setup, device capabilities and depth buffers.

Fortunately, Microsoft have developed [HoloToolkit](https://github.com/Microsoft/HoloToolkit-Unity) - a Unity package that
contains a tonne of useful things to get going quickly:

* Easy-to-apply project, camera and scene settings
* Scripts to manage user input, spatial mapping, sound etc.
* Prefabs common Holographic things - cursors
* Helpers for things like finding planes, voice detection

## Building HoloToolkit

While there are a few pre-built releases of the HoloTookit, they're not fans of continuous builds, and are lagging behind the latest Unity builds, so it's better to build it yourself.

### 1. Clone the repo

Open your git client of choice and clone [https://github.com/Microsoft/HoloToolkit-Unity](https://github.com/Microsoft/HoloToolkit-Unity).

### 2. Open the project in Unity

1. Open Unity
2. Click "Open Project"
3. Choose the HoloToolkit folder 
4. Select the root "Assets" folder of the solution
5. Select `Assets -> Export Package`
6. Ensure everything is selected and press `Export`

This will create a package that can be imported into a Unity project.  You can now close the HoloToolkit project.

### 3. Initial Unity project

1. Open Unity
2. Create a new project

You will see a window like the following:
TODO: Image

I'm not a fan of the default layout, I recommend changing to the build-in vertical layout - that's what these screenshots will use.

TODO: Layout

### 4. Import HoloToolkit
3. Under `Assets`, choose `Import Package` then `Custom Package...`
4. Select your newly built HoloTookit package
5. Ensure everything is selected (`HoloTookit-examples` is optional, but useful. You can delete it later if you want)
6. Press `Import`

Your Assets window will now have 2 new folders - `HoloToolkit` and `HoloToolkit-Examples`.  Additionally, a new menu will appear
at the top - `HoloToolkit`. This is a cool feature of Unity - packages can change the editing experience.  In this case, HoloToolkit
includes a bunch of tools to assist in setting up the scene and visual studio projects.

### 5. Apply HoloToolkit settings to project.

In order to work with Holographic devices, some project settings need to be set up - mainly around setting up the device capabilities and targets.

The Windows Holographic Academy tutorials go through this in detail, but HoloToolkit can do it for us:

1. Click the `HoloTookit` menu
2. Click `Configure`
3. Choose `Apply HoloLens Scene Settings`

Done!