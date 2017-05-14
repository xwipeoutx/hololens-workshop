# Voice Input

## Goals

* Voice input to start/stop swarming

## 1. Set up some voice commands

1. Enable "Microphone" capability via `HoloToolKit`-`Configure`-`Apply HoloLens Capability Settings`
2. Add the `Speech Input Source` component to the `Bee Spawner` object
3. Expand `Keywords` and add the following keywords:
  * `Buzz Around` (shortcut: `Comma`)
  * `Buzz Off` (shortcut: `Period`)

> **Shortcuts**: Why use shortcuts? Because Cortana isn't perfect, and you _WILL_ get annoyed when testing it out.  Shortcuts only work within the editor.

## 2. Set up spawn script to accept those voice commands

1. Open up the `Spawn` script for editing
2. Add the following fields:

```cs
public AudioSource BuzzSound;
```

3. In Unity, drag the audio source to the `Buzz Sound` placeholder
4. Add methods to start / stop the spawnings.  These should also mute/play the sound, and destroy any bees that were around before

```cs
public void StartSpawning()
{
    BuzzSound.mute = false;
    StopAllCoroutines();
    StartCoroutine(DoTheSpawns());
}

public void StopSpawning()
{
    BuzzSound.mute = true;
    StopAllCoroutines();
    _spawnedThings.ForEach(obj => Destroy(obj));
    _spawnedThings.Clear();
}
```

5. Ensure the bees start spawning, update `Start` as follows

```cs
void Start()
{
    if (ThingToSpawn == null)
        Debug.LogError("Spawn: No things to spawn");

    if (NumberOfSecondsBetweenSpawns <= 0)
        Debug.LogError("Spawn: Need to have some positive time between spawns");

    StartSpawning();
}
```

6. Mark this component as a speech handler, and handle the keywords via the interface callbacks:

```cs
public class Spawn : MonoBehaviour, ISpeechHandler
{
    //...

    public void OnSpeechKeywordRecognized(SpeechKeywordRecognizedEventData eventData)
    {
        if (eventData.RecognizedText == "Buzz Around")
            StartSpawning();
        else
            StopSpawning();
    }
}
```

Run the app, the bees will only spawn after you say `Buzz around`.  This voice recognition works inside Unity, and on the emulator - but if you don't want to deal with that, use the shortcut keys (`,` and `.`) that we set up earlier.

## 3. Make it better (optional - extension)

This section is just some polish on the bee behaviour - feel free to skip it, as it has nothing hololens specific, but it makes the bees _much better_ at going home - by having them fly towards the hive when told to buzz off.

1. Open `FlyAround.cs` and change to be the following:

```cs
public class FlyAround : MonoBehaviour
{
    public float MinSpeed = 1;
    public float MaxSpeed = 5;
    public float MaxRadius = 0.5f;
    private float _speed;

    private Vector3? FlyTowards = null;
    private Vector3 _worldPosition;
    private bool _goingHome = true;

    void Start()
    {
        _worldPosition = transform.position;
        _speed = Random.Range(MinSpeed, MaxSpeed);
    }

    public void GoHome()
    {
        FlyTowards = Vector3.zero;
        _goingHome = true;
    }

    public void RandomlyFlyAround()
    {
        FlyTowards = Random.insideUnitSphere * MaxRadius;
        _goingHome = false;
    }

    void Update()
    {
        if (FlyTowards != null)
        {
            var isAtTarget = BuzzToTarget(_worldPosition + FlyTowards.Value);
            if (isAtTarget)
            {
                if (_goingHome)
                {
                    FlyTowards = null;
                }
                else
                {
                    RandomlyFlyAround();
                }
            }
        }
    }

    // ...
}
```

We've added some `public` methods here to inform the behaviour whether it's going to be going out or coming home.  Inside the script we keep track of that and make it _bee_have appropriately.

2. Update `DoTheSpawns()` to ensure bees flyout instantly

```cs
private void DoTheSpawns()
{
    // ...
    var newThing = Instantiate(ThingToSpawn, transform.position, Quaternion.identity, transform);
    _spawnedThings.Add(newThing);

    var flyAround = newThing.GetComponent<FlyAround>();
    if (flyAround != null)
    {
        flyAround.RandomlyFlyAround();
    }

    // ...
}
```

3. Update `StopSpawning` to cause bees to go back to their home:

```cs
private void StopSpawning()
{
    BuzzSound.mute = true;
    StopAllCoroutines();
    _spawnedThings.ForEach(obj =>
    {
        var flyAround = obj.GetComponent<FlyAround>();
        if (flyAround != null)
        {
            flyAround.GoHome();
        }
    });
}
```

4. Update `StartSpawning` to cause bees that are at home to come back out:

```cs
private void StartSpawning()
{
    BuzzSound.mute = false;
    StopAllCoroutines();

    _spawnedThings.ForEach(obj =>
    {
        var flyAround = obj.GetComponent<FlyAround>();
        if (flyAround != null)
        {
            flyAround.RandomlyFlyAround();
        }
    });

    StartCoroutine(DoTheSpawns());
}
```