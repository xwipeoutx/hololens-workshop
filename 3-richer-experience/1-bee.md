# Bee 

## Goals

While cubes are cool, they're not _that_ cool.  You know what's cool? Bees. Bees are cool.

* Make a swarm of bees

## 1. Import a bee from the internet

Unfortunately, the Unity store has no good looking bees, so let's import one.

1. Download the [Bee 3DS Model](../assets/models/bee.3ds)
2. Create a `Models` folder in your hierarchy, and paste the model there
3. Drag the bee model onto your scene to see it render

Note the bee is _really_ large. Thanks, Internet.

4. Click the Bee model in your assets
5. Enter `3e-07` for the scale
6. Scroll down and click `Apply`

The bee will be smaller - a good size for our app, methinks.

## 2. Add flight behaviour for our bee

Add a script for the bee called `FlyAround` with the contents:

```cs
using UnityEngine;

public class FlyAround : MonoBehaviour
{
    public float MinSpeed = 1;
    public float MaxSpeed = 5;
    public float MaxRadius = 0.5f;
    private float _speed;

    public Vector3 FlyTowards;
    private Vector3 _worldPosition;

    void Start()
    {
        _worldPosition = transform.position;
        _speed = Random.Range(MinSpeed, MaxSpeed);
        RandomlyFlySomewhere();
    }

    public void RandomlyFlySomewhere()
    {
        FlyTowards = Random.insideUnitSphere * MaxRadius;
    }

    void Update()
    {
        var isAtTarget = BuzzToTarget(_worldPosition + FlyTowards);
        if (isAtTarget)
        {
            RandomlyFlySomewhere();
        }
    }

    private bool BuzzToTarget(Vector3 target)
    {
        var fromObjectToTarget = target - gameObject.transform.position;

        var isAlreadyAtTarget = fromObjectToTarget.sqrMagnitude < 0.0001f;
        if (isAlreadyAtTarget)
        {
            gameObject.transform.position = target;
            return true;
        }

        var delta = Time.deltaTime * fromObjectToTarget.normalized * _speed;
        gameObject.transform.localRotation = Quaternion.LookRotation(fromObjectToTarget.normalized);

        var willOvershootTarget = delta.sqrMagnitude > fromObjectToTarget.sqrMagnitude;
        if (willOvershootTarget)
        {
            gameObject.transform.position = target;
            return true;
        }

        gameObject.transform.position = gameObject.transform.position + delta;
        return false;
    }
}
```

It's just a bee flying towards random points in a sphere - it won't look like much with a single bee, but it works great with a bunch of them.

Hit play to see if it works.  If not, blame math.

Once you're happy:

1. Add the bee to your prefabs
2. Delete the bee from your scene hierarchy.
