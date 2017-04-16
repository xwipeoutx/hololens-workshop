# World Anchors

## Goals

* Make the bees buzz

## 5. Let's have some sound

These hives are full of bees, let's make them sound like it

1. Enable the Spatial plugin by:
  1. Open the menu `Edit`-`Project Settings`-`Audio`
  2. Set Spatializer Plugin to `MS HRTF Spatializer`
  3. Set System Sample Rate to `48000`
2. Download [a bee buzzing sound](../assets/sounds/buzz.wav) and put it in `Assets/Sounds/buzz.wav`
  * This sound is courtesy of [pillonoise on freesound.org](http://www.freesound.org/people/pillonoise/sounds/353198/)
3. Unity will pick it up and import it
4. Select your `Beehive` game object
5. Click `Add Component` and choose `Audio Source`
  * Note your camera already has the `Audio Receiver` Component
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