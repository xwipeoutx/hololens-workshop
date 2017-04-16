# Voice Input

## Goals

* Voice input to start/stop swarming

## 1. Set up some voice commands

1. Enable "Microphone" capability via `HoloToolKit`-`Configure`-`Apply HoloLens Capability Settings`
2. Add the `Speech Input Source` component to the `Managers` object
3. Expand `Keywords` and add the following keywords:
  * `Buzz Around` (shortcut: `Comma`)
  * `Buzz Off` (shortcut: `Period`)

## 2. Set up swarm script to accept those voice commands

1. Open up the `Swarm` script in Visual studio
2. Add the following fields:

```cs
public AudioSource BuzzSound;
public bool AreBeesBuzzing = false;
public SpeechInputSource SpeechSource;
```

3. In Unity, drag the audio source to the `Buzz Sound` placeholder
4. Select the speech input source from the `Manager` object for the `Speech Source`
5. Update `SpawnAThing()` to early return when bees aren't spawning

```cs
private void SpawnAThing()
{
    if (!AreBeesBuzzing)
        return;

    // ...as before
}
```

6. Register this class with the `InputManager`

```cs
void Start()
{
    // ... 
    SpeechSource.SpeechKeywordRecognized += OnSpeechKeywordRecognized;
}

void OnDestroy()
{
    SpeechSource.SpeechKeywordRecognized -= OnSpeechKeywordRecognized;
}
```

7. Add handler for the voice commands

Fill in the event handler

```cs
public class Spawn : MonoBehaviour, ISpeechHandler
{
    //...
    
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
                foreach (var obj in _spawnedThings)
                {
                    Destroy(obj);
                }
                _spawnedThings.Clear();
                break;
        }
        
        BuzzSound.mute = !AreBeesBuzzing;
    }
}
```

Run the app, the bees will only spawn after you say `Buzz around`.  This voice recognition works inside Unity, and on the emulator - but if you don't want to deal with that, use the shortcut keys (`,` and `.`) that we set up earlier.

## 3. Make it better (optional - extension)

Ideally, our bees should go home when we tell them to `buzz off`, and come back when we tell them to, with nice shiny animations.  Let's do that now

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