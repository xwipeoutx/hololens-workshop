# World Anchors

## Goals

* Make the bees buzz, according to relative position to user

## 5. Let's have some sound

These hives are full of bees, let's make them sound like it.


1. Enable the Spatial plugin by:
  1. Open the menu `Edit`-`Project Settings`-`Audio`
  2. Set Spatializer Plugin to `MS HRTF Spatializer`
  3. Set System Sample Rate to `48000`
2. Download <a href="/assets/sounds/buzz.wav" target="_blank">a bee buzzing sound</a>  (TODO: Right-click, save as) and put it in `Assets/Sounds/buzz.wav`
  * This sound is courtesy of [pillonoise on freesound.org](http://www.freesound.org/people/pillonoise/sounds/353198/)
3. Unity will pick it up and import it
4. Select your `Beehive` game object
5. Click `Add Component` and choose `Audio Source`
  * Note your camera already has the `Audio Listener` Component
6. Configure the Audio source:
  1. Drag the `buzz` sound to the Audio Clip
  2. Select `Spatialize`
  3. Select `Play on Awake`
  4. Select `Loop`
  5. Set `Spatial Blend` to `1`
  5. In 3D Sound Settings:
    * Set Volume Rolloff to `Logarithmic Rolloff`
    * Min Distance to `1`
    * Max Distance to `20`

Now we're buzzing with excitement!

The effect works best if you're wearing headphones (or the Hololens), but you should be able to tell (without looking at the screen) whether the bees are in front, beside or even behind you.  The sound drops off as you move away, and it louder as you get closer - pretty good results for the minimal effort

At this point, it doesn't quite go as far as making it sound like the audio is going around corners or being muffled by doors, but some of this _is_ possible using the `Audio Occluder` script.  For now, we'll leave it as-is.

---
Next: [Voice Input: Control the bees](4-voice-input.md)

Prev: [Add a beehive](2-hive.md)