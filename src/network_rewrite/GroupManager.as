package network_rewrite 
{
	import common.*;
	import events.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="connectClosed", type="events.NetworkEvent")]
	[Event(name="connectSuccess", type="events.NetworkEvent")]
	[Event(name="disposed", type="events.NetworkEvent")]
	[Event(name="firstConnectNeighbor", type="events.NetworkEvent")]
	[Event(name="connectFailed", type="events.NetworkErrorEvent")]
	[Event(name="connectRejected", type="events.NetworkErrorEvent")]
	[Event(name="addedUser", type="events.UpdateUserEvent")]
	[Event(name="removedUser", type="events.UpdateUserEvent")]
	[Event(name="notify", type="events.NotifyEvent")]
	public class GroupManager extends EventDispatcherEX 
	{
		private var connectionManager:ConnectionManager;
		private var netGroup:NetGroup;
		private var _isConnected:Boolean;
		private var _specifier:String;
		private var users:Dictionary;
		private var timer:Timer;
		
		private const announcePeriod:int = 2000;
		private const timeoutPeriod:int = 10000;
		private const keepAlivePalse:String = "keepAlivePalse";
		private const disconnected:String = "disconnected";
		private const updatePlayerInfo:String = "updatePlayerInfo";
		
		public function GroupManager(connectionManager:ConnectionManager, specifier:String) 
		{
			this.connectionManager = connectionManager;
			this._specifier = specifier;
			users = new Dictionary();
			timer = new Timer(announcePeriod);
			timer.addEventListener(TimerEvent.TIMER, timerListener, false, 0, true);
		}
		
		public function connect():void
		{
			netGroup = connectionManager.createNetGroup(specifier, netConnectionListener);
			netGroup.addEventListener(NetStatusEvent.NET_STATUS, netGroupListener, false, 0, true);	
		}
		
		public function dispose():void
		{
			timer.stop();
			post(disconnected); //TODO 有効に働かないので別の方法を考える。
			netGroup.close();
			dispatchEvent(new NetworkEvent(NetworkEvent.disposed));
		}
		
		public function get isConnected():Boolean
		{
			return _isConnected;
		}
		
		public function get specifier():String
		{
			return _specifier;
		}
		
		private function keepAlive():void
		{
			post(keepAlivePalse);
			var time:int = getTimer();
			for (var peerID:String in users)
			{
				if (users[peerID] + timeoutPeriod < time)
				{
					Debug.trace("removedUser", peerID);
					dispatchEvent(new UpdateUserEvent(UpdateUserEvent.removedUser, peerID));
					delete users[peerID];
				}
			}
		}
		
		private function updateUser(peerID:String):void
		{
			if (users[peerID] == null)
			{
				Debug.trace("addedUser", peerID);
				dispatchEvent(new UpdateUserEvent(UpdateUserEvent.addedUser, peerID));
			}
			users[peerID] = getTimer();
		}
		
		public function post(type:String, obj:Object = null):void
		{
			if (!_isConnected) return;
			if (obj == null) obj = new Object();
			var message:MessageObject = new MessageObject(type, obj, networkManager.selfPeerID);
			netGroup.post(message);
			if (type != keepAlivePalse && type != updatePlayerInfo)
			{
				Debug.trace("post", message.type);
			}
		}
		
		public function sendPeer(toPeerID:String, type:String, obj:Object = null):void
		{
			if (!_isConnected) return;
			if (obj == null) obj = new Object();
			var message:MessageObject = new MessageObject(type, obj, networkManager.selfPeerID, toPeerID);
			var groupAddress:String = netGroup.convertPeerIDToGroupAddress(toPeerID);
			var sendResult:String = netGroup.sendToNearest(message, groupAddress);
			Debug.trace("sendPeer", message.type, sendResult);
		}
		
		public function sendNeighbors(type:String, obj:Object = null):void
		{
			if (!_isConnected) return;
			if (obj == null) obj = new Object();
			var message:MessageObject = new MessageObject(type, obj, networkManager.selfPeerID);
			var sendResult:String = netGroup.sendToAllNeighbors(message);
			Debug.trace("sendNeighbors", message.type, sendResult);
		}
		
		public function sendDecreasing(type:String, obj:Object = null):void
		{
			if (!_isConnected) return;
			if (obj == null) obj = new Object();
			var message:MessageObject = new MessageObject(type, obj, networkManager.selfPeerID);
			var sendResult:String = netGroup.sendToNeighbor(message, NetGroupSendMode.NEXT_DECREASING);
			Debug.trace("sendDecreasing", message.type, sendResult);
		}
		
		public function sendIncreasing(type:String, obj:Object = null):void
		{
			if (!_isConnected) return;
			if (obj == null) obj = new Object();
			var message:MessageObject = new MessageObject(type, obj, networkManager.selfPeerID);
			var sendResult:String = netGroup.sendToNeighbor(message, NetGroupSendMode.NEXT_INCREASING);
			Debug.trace("sendIncreasing", message.type, sendResult);
		}
		
		private function postingNotify(message:MessageObject, messageID:String):void
		{
			if (message == null) return;
			if (message.type != keepAlivePalse && message.type != updatePlayerInfo)
			{
				Debug.trace("postingNotify", message.type);
			}
			if (message.type == keepAlivePalse)
			{
				updateUser(message.peerID);
				return;
			}
			if (message.type == disconnected)
			{
				Debug.trace("disconnectedUser", message.peerID);
				dispatchEvent(new UpdateUserEvent(UpdateUserEvent.removedUser, message.peerID));
				delete users[message.peerID];
				return;
			}
			updateUser(message.peerID);
			dispatchEvent(new NotifyEvent(NotifyEvent.notify, message));
		}
		
		private function sendToNotify(message:MessageObject, from:String, fromLocal:Boolean):void
		{
			if (message == null) return;
			Debug.trace("sendToNotify", message.type);
			if (message.toPeerID != "" && message.toPeerID != networkManager.selfPeerID)
			{
				var groupAddress:String = netGroup.convertPeerIDToGroupAddress(message.toPeerID);
				var sendResult:String = netGroup.sendToNearest(message, groupAddress);
				Debug.trace("sendRelay", message.type, sendResult);
				return;
			}
			dispatchEvent(new NotifyEvent(NotifyEvent.notify, message));
		}
		
		private function timerListener(e:TimerEvent):void
		{
			keepAlive();
			dispatchEvent(new NetworkEvent(NetworkEvent.announceClock));
		}
		
		private function netConnectionListener(e:NetStatusEvent):void
		{
			if (e.info.group != netGroup) return;
			switch (e.info.code)
			{
				case "NetGroup.Connect.Closed":
					_isConnected = false;
					dispatchEvent(new NetworkEvent(NetworkEvent.connectClosed));
					break;
				case "NetGroup.Connect.Failed":
					dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.connectFailed, "グループに接続できませんでした。"));
					break;
				case "NetGroup.Connect.Rejected":
					dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.connectRejected, "グループへの接続が拒否されました。"));
					break;
				case "NetGroup.Connect.Success":
					_isConnected = true;
					timer.start();
					dispatchEvent(new NetworkEvent(NetworkEvent.connectSuccess));
					break;
			}
		}
		
		private function netGroupListener(e:NetStatusEvent):void
		{
			if (e.info.code != "NetGroup.Posting.Notify" && e.info.code != "NetGroup.SendTo.Notify")
			{
				Debug.trace(e.info.code);
			}
			switch (e.info.code)
			{
				case "NetGroup.LocalCoverage.Notify":
					break;
				case "NetGroup.Posting.Notify":
					postingNotify(e.info.message as MessageObject, e.info.messageID);
					break;
				case "NetGroup.Neighbor.Connect":
					if (netGroup.neighborCount == 1)
					{
						keepAlive();
						dispatchEvent(new NetworkEvent(NetworkEvent.firstConnectNeighbor));
					}
					break;
				case "NetGroup.Neighbor.Disconnect":
					break;
				case "NetGroup.SendTo.Notify":
					sendToNotify(e.info.message as MessageObject, e.info.from, e.info.formLocal);
					break;
			}
		}
		
	}

}