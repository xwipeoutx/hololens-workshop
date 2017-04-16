# Richer Input

## Goals

* Richer input for pick up / place
* Plane detection

## 1. Modify the pick up script to do a pick up / drop

We're going to improve the interaction with our beehive - instead of any old tap moving it, we're going to make it so there's a tap to pick up, and then a tap to place.

Firstly, we make some changes to `MoveToTapPosition` to:

* Track whether it's currently "picked up" or not via the tap handler
* If it is picked up, then do the raycast and reposition every frame
* When picked up, detach the world anchor
* When dropped, attach the world anchor

```cs
using HoloToolkit.Unity;
using HoloToolkit.Unity.InputModule;
using HoloToolkit.Unity.SpatialMapping;
using UnityEngine;

public class MoveToTapPosition : MonoBehaviour, IInputClickHandler
{
    public Camera Camera;
    public float OffsetFromWall = 1;
    public string AnchorName = "GlobalMoveToPositionAnchor";

    private bool IsPickedUp = false;

    // Use this for initialization
    void Start()
    {
        var anchor = gameObject.AddComponent<WorldAnchor>();
        anchor.Name = AnchorName;
    }

    public void Update()
    {
        if (!IsPickedUp)
            return;

        var origin = Camera.transform.position;
        var direction = Camera.transform.rotation * Vector3.forward;

        RaycastHit hit;
        var rayCastSuccessful = Physics.Raycast(origin, direction, out hit, 20, 1 << SpatialMappingManager.Instance.PhysicsLayer);
        if (!rayCastSuccessful)
            return;

        var spawnPosition = hit.point + hit.normal * OffsetFromWall;

        var lookDirection = hit.normal;
        lookDirection.y = 0;
        lookDirection.Normalize();

        gameObject.transform.position = spawnPosition;
        gameObject.transform.rotation = Quaternion.LookRotation(lookDirection, Vector3.up);
    }

    public void OnInputClicked(InputEventData eventData)
    {
        if (IsPickedUp)
        {
            var anchor = gameObject.AddComponent<WorldAnchor>();
            anchor.Name = AnchorName;
            IsPickedUp = false;
        }
        else
        {
            gameObject.RemoveComponent<WorldAnchor>();
            IsPickedUp = true;
        }
    }
}
```