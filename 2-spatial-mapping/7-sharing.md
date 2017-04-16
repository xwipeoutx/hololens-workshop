TODO: Sharing service in assets/External
TODO: Internet client

# Sharing

## Goals

* Establish communication with a sharing server
* Put some framework in place for solid messaging
* Get some idea on how to diagnose this stuff

## 1. Install/run the sharing service

The repository for this project contains the sharing services that ship with `HoloToolkit`.  To make them easily available for our project, they should be copied to TODO.

Now to run the service

1. In Unity's menu, select `HoloToolkit`-`Sharing Service`-`Launch Sharing Service`
2. (maybe) Enable ports `20601` and `20602` inbound in your firewall.

The service will launch in a new window! Hurrah

## 2. Make a message bus

The code in `HoloToolkit/Sharing/Tests` does messaging that _works_, but we're going to go from scratch for 2 reasons: learning and safety.

Copy the following code into a new script `MessageBus.cs` 

```cs
using HoloToolkit.Sharing;
using HoloToolkit.Unity;
using System;
using System.Collections.Generic;
using UnityEngine;

public abstract class BusMessage
{
    public abstract byte MessageType { get; }
    public long UserId { get; private set; }

    protected BusMessage(long userId)
    {
        UserId = userId;
    }

    protected BusMessage(NetworkInMessage inMessage)
    {
        UserId = inMessage.ReadInt64();
    }

    public NetworkOutMessage ToOutMessage(NetworkConnection serverConnection)
    {
        NetworkOutMessage msg = serverConnection.CreateMessage(MessageType);

        msg.Write(MessageType);
        msg.Write(UserId);

        WriteAdditionalFields(msg);

        return msg;
    }

    protected abstract void WriteAdditionalFields(NetworkOutMessage msg);
}

public interface IHandle<in T> where T : BusMessage
{
    void Handle(T message);
}

public abstract class MessageDefinitions : MonoBehaviour
{
    public abstract IEnumerable<byte> AllTypes { get; }
    public abstract BusMessage Deserialize(NetworkInMessage inMessage);
}

public class MessageBus : Singleton<MessageBus>
{
    public MessageDefinitions MessageDefinitions;

    private long? _localUserId;

    public long LocalUserId
    {
        get
        {
            return _localUserId
                   ?? (long)(_localUserId = SharingStage.Instance.Manager.GetLocalUser().GetID());
        }
    }

    private readonly Dictionary<Type, Action<BusMessage>> _handlers = new Dictionary<Type, Action<BusMessage>>();

    public void Register<T>(IHandle<T> handler) where T : BusMessage
    {
        if (!_handlers.ContainsKey(typeof(T)))
            _handlers.Add(typeof(T), msg => { });

        _handlers[typeof(T)] += msg => { handler.Handle((T)msg); };
    }

    private NetworkConnectionAdapter _connectionAdapter;
    private NetworkConnection _serverConnection;

    void Start()
    {
        SharingStage.Instance.SharingManagerConnected += OnSharingManagerConnected;
    }

    private void OnSharingManagerConnected(object sender, EventArgs e)
    {
        Debug.Log("OnSharingManagerConnected.");
        SharingStage sharingStage = SharingStage.Instance;

        if (sharingStage == null)
        {
            Debug.Log("Cannot Initialize MessageBus. No SharingStage instance found.");
            return;
        }

        _serverConnection = sharingStage.Manager.GetServerConnection();
        if (_serverConnection == null)
        {
            Debug.Log("Cannot initialize MessageBus. Cannot get a server connection.");
            return;
        }

        _connectionAdapter = new NetworkConnectionAdapter();
        _connectionAdapter.MessageReceivedCallback += OnMessageReceived;

        foreach (var messageId in MessageDefinitions.AllTypes)
        {
            _serverConnection.AddListener(messageId, _connectionAdapter);
        }
    }

    private void OnMessageReceived(NetworkConnection arg1, NetworkInMessage arg2)
    {
        var message = MessageDefinitions.Deserialize(arg2);

        Debug.Log("Received message: " + message.GetType().Name);

        if (_handlers.ContainsKey(message.GetType()))
        {
            _handlers[message.GetType()](message);
        }
    }

    public void Broadcast<T>(T message) where T : BusMessage
    {
        if (_serverConnection == null || !_serverConnection.IsConnected())
            throw new InvalidOperationException("No server available to broadcast message");

        // If we are connected to a session, broadcast our head info
        if (_serverConnection != null && _serverConnection.IsConnected())
        {
            Debug.Log("Broadcasting message: " + message.GetType().Name);

            var outMessage = message.ToOutMessage(_serverConnection);

            _serverConnection.Broadcast(
                outMessage,
                MessagePriority.Medium,
                MessageReliability.UnreliableSequenced,
                MessageChannel.Default);
        }
    }

    protected override void OnDestroy()
    {
        foreach (var messageId in MessageDefinitions.AllTypes)
        {
            _serverConnection.RemoveListener(messageId, _connectionAdapter);
        }

        _connectionAdapter.MessageReceivedCallback -= OnMessageReceived;

        base.OnDestroy();
    }
}
```

Let's break it down.

This code utilises HoloToolkit's `SharingStage` singleton which takes all the handshakey and session management stuff out of the whole thing.  All this class does is provide a base class for messages, with a robust way to serialize and deserialize to and from the appropriate network messages, and provide a way to pub and sub to these.

So for any new messages, we need to

1. Create a message implementing `BusMessage`
2. Ensure our `MessageDefinitions` exposes the new message type, and implements the factory appropriately
3. Send the message using `MessageBus.Instance.Broadcast(message)`
4. Register a component as a handler using `MessageBus.Instance.Register(this)`

Note this is just a start - it doesn't handle deregistration or anything right now, and assumes perfect transport reliability - which may or may not be the case for this sharing service.  We're also piggy-backing on top of HoloToolkit's pattern of using a `byte` to represent the message type, starting at `MessageID.UserMessageIDStart`.

## 3. Define our messages

The messages start with a single byte that represents the type (or ID) of the message.  HoloToolkit messages start at `134` and have 50 messages reserved, so we start our at `184` - which you can find in `MessageID.UserMessageIDStart`.

We're going to make 2 messages - one of them a simple `ping`, and the other to say whether the hive is buzzing or not. I like to start with a `ping` message as the first in the set, as it can be used as a basis to ensure communication is working, which is kind of handy.  Given it doesn't change or have any data, it's reasonable

Create a new script `SwarmMessageDefinitions` and jam this stuff in it:

```cs
using HoloToolkit.Sharing;
using System;
using System.Collections.Generic;
using System.Linq;

public class SwarmMessageDefinitions : MessageDefinitions
{
    public override IEnumerable<byte> AllTypes
    {
        get
        {
            yield return MessageTypes.Ping;
            yield return MessageTypes.SetBuzziness;
        }
    }

    public override BusMessage Deserialize(NetworkInMessage inMessage)
    {
        var messageType = inMessage.ReadByte();
        if (!AllTypes.Contains(messageType))
            throw new ArgumentException("No custom messages exist for Message Id: " + messageType);

        return CreateMessage(inMessage, messageType);
    }

    private static BusMessage CreateMessage(NetworkInMessage inMessage, byte messageType)
    {
        BusMessage message;
        switch (messageType)
        {
            case MessageTypes.Ping:
                message = new PingMessage(inMessage);
                break;
            case MessageTypes.SetBuzziness:
                message = new SetBuzzinessMessage(inMessage);
                break;
            default:
                throw new ArgumentException("No message factory exist for Message: " + messageType);
        }

        if (message.MessageType != messageType)
        {
            throw new Exception("Message type mismatch");
        }
        return message;
    }
}

public static class MessageTypes
{
    private const byte UserIdStart = (byte)MessageID.UserMessageIDStart;

    public const byte Ping = UserIdStart;
    public const byte SetBuzziness = UserIdStart + 1;
}

public class PingMessage : BusMessage
{
    public override byte MessageType
    {
        get { return MessageTypes.Ping; }
    }

    public PingMessage(long userId)
        : base(userId)
    {
    }

    public PingMessage(NetworkInMessage inMessage)
        : base(inMessage)
    {
    }

    protected override void WriteAdditionalFields(NetworkOutMessage msg)
    {
    }
}

public class SetBuzzinessMessage : BusMessage
{
    public override byte MessageType
    {
        get { return MessageTypes.SetBuzziness; }
    }

    public bool IsBuzzing { get; private set; }

    public SetBuzzinessMessage(bool isBuzzing, long userId)
        : base(userId)
    {
        IsBuzzing = isBuzzing;
    }

    public SetBuzzinessMessage(NetworkInMessage inMessage)
        : base(inMessage)
    {
        IsBuzzing = inMessage.ReadInt32() != 0;
    }

    protected override void WriteAdditionalFields(NetworkOutMessage msg)
    {
        msg.Write(IsBuzzing ? 1 : 0);
    }
}
```

## 4. Wire up in the Spawn script

