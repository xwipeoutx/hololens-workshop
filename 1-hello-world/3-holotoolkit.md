# HoloToolkit

## Goals

* Build HoloToolkit, ready to import into your project

## Why HoloToolkit?

The latest Unity releases have in-built support for Holographic development and UWP publishing. It doesn't hold your hands
with working in a holographic world - there are a few concepts and setup that are unique to mixed reality - for example, camera
setup, device capabilities and depth buffers.

Fortunately, Microsoft have developed [HoloToolkit](https://github.com/Microsoft/HoloToolkit-Unity) - a Unity package that
contains a tonne of useful things to get going quickly:

* Easy-to-apply project, camera and scene settings
* Scripts to manage user input, spatial mapping, sound etc.
* Prefabs common Holographic things - like cursors and input
* Helpers for things like finding planes and voice detection

## Downloading HoloToolkit

Download the latest release (Built for Unity 5.5.2f1) from [their github repository](https://github.com/Microsoft/HoloToolkit-Unity/releases).

## Building HoloToolkit

If you want to be bleeding edge, you can build it yourself like so.  Use at your own risk.

### 1. Clone the repo

Open your git client of choice and clone [https://github.com/Microsoft/HoloToolkit-Unity](https://github.com/Microsoft/HoloToolkit-Unity).

### 2. Open the project in Unity

1. Open Unity
2. Click "Open Project"
3. Choose the HoloToolkit folder 

### 3. Package the project

1. In the menu, select `Assets -> Export Package`
2. Ensure everything is selected and press `Export All..`
3. Choose a folder and give it a good name (may I suggest `HoloToolkit`?)

This will create a package file `HoloToolkit.unitypackage` that can be imported into a Unity project.  

You can now close the HoloToolkit project.

---
Next: [Creating the scene](1-create-the-scene.md)

Prev: [Unity Overview](2-unity-overview.md)