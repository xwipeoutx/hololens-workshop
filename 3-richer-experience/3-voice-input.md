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
// TODO: Make match the other thingy
public class FlyAround : MonoBehaviour
{
    public float MinSpeed = 1;
    public float MaxSpeed = 5;
    public float MaxRadius = 0.5f;
    private float _speed;

    public Vector3? FlyTowards = null;
    private bool _goingHome = true;

    void Start()
    {
        _speed = Random.Range(MinSpeed, MaxSpeed);
    }

    public void FlyOut()
    {
        FlyTowards = Random.insideUnitSphere * MaxRadius;
        _goingHome = false;
    }

    public void GoHome()
    {
        FlyTowards = Vector3.zero;
        _goingHome = true;
    }

    void Update()
    {
        if (FlyTowards != null)
        {
            var isAtTarget = BuzzToTarget(FlyTowards.Value);
            if (isAtTarget)
            {
                if (_goingHome)
                    FlyTowards = null;
                else
                    FlyOut();
            }
        }
    }

    private bool BuzzToTarget(Vector3 target)
    {
        var fromObjectToTarget = target - gameObject.transform.localPosition;

        var isAlreadyAtTarget = fromObjectToTarget.sqrMagnitude < 0.0001f;
        if (isAlreadyAtTarget)
        {
            gameObject.transform.localPosition = target;
            return true;
        }

        var delta = Time.deltaTime * fromObjectToTarget.normalized * _speed;
        gameObject.transform.localRotation = Quaternion.LookRotation(delta.normalized);

        var willOvershootTarget = delta.sqrMagnitude > fromObjectToTarget.sqrMagnitude;
        if (willOvershootTarget)
        {
            gameObject.transform.localPosition = target;
            return true;
        }

        gameObject.transform.localPosition = gameObject.transform.localPosition + delta;
        return false;
    }
}
```

We've added some `public` methods here to inform the behaviour whether it's going to be going out or coming home.  Inside the script, we keep track of that and make it _bee_have appropriately.

2. Allow `Spawn` script to access other component

Add the following method to `Spawn` script:

```cs
FlyAround GetFlyAround(GameObject thingToSpawn)
{
    var flyAround = thingToSpawn.GetComponent<FlyAround>();
    if (flyAround == null)
    {
        Debug.LogError("Expected ThingToSpawn to have FlyAround behaviour, but it did not.");
    }
    return flyAround;
}
````

3. Update `SpawnAThing()` to ensure bees flyout instantly

```cs
private void SpawnAThing()
{
    if (!AreBeesBuzzing)
        return;

    var newThing = Instantiate(ThingToSpawn, transform.position, Quaternion.identity, gameObject.transform);
    GetFlyAround(newThing).FlyOut();
    _spawnedThings.Add(newThing);
}
```

4. Update `OnSpeechKeywordRecognized` to cause bees to go back to their home:

```cs
public void OnSpeechKeywordRecognized(object sender, SpeechKeywordRecognizedEventArgs eventData)
{
    var phrase = eventData.RecognizedText.ToLowerInvariant();
    switch (phrase)
    {
        case "buzz around":
            AreBeesBuzzing = true;
            break;
        case "buzz off":
            AreBeesBuzzing = false;
            break;
    }

    BuzzSound.mute = !AreBeesBuzzing;

    foreach (var flyAround in _spawnedThings.Select(GetFlyAround))
    {
        if (AreBeesBuzzing)
        {
            flyAround.FlyOut();
        }
        else
        {
            flyAround.GoHome();
        }
    }
}
```