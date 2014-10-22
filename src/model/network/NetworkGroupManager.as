package model.network {
	import events.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="connectSuccess", type="events.KuzurisEvent")]
	[Event(name="connectClosed", type="events.KuzurisEvent")]
	[Event(name="disposed", type="events.KuzurisEvent")]
	[Event(name="firstConnectNeighbor", type="events.KuzurisEvent")]
	[Event(name="announceClock", type="events.KuzurisEvent")]
	[Event(name="connectFailed", type="events.KuzurisErrorEvent")]
	[Event(name="addedUser", type="events.UpdateUserEvent")]
	[Event(name="removedUser", type="events.UpdateUserEvent")]
	[Event(name="notify", type="events.NotifyEvent")]
	public class NetworkGroupManager extends EventDispatcher
	{
		private var _peerID:String;
		private var _isConnected:Boolean;
		private var networkManager:NetworkManager;
		private var netGroup:NetGroup;
		private var _specifier:String;
		private var users:Dictionary;
		private var timer:Timer;
		
		private const announcePeriod:int = 5000;
		private const timeoutPeriod:int = 10000;
		
		private const keepAlivePalse:String = "keepAlivePalse";
		private const disconnected:String = "disconnected";
		
		public function NetworkGroupManager(networkManager:NetworkManager, specifier:String) 
		{
			_peerID = networkManager.selfPeerID;
			this.networkManager = networkManager;
			networkManager.addEventListener(NetStatusEvent.NET_STATUS, netConnectionListener);
			this._specifier = specifier;
			netGroup = networkManager.createNetGroup(specifier);
			netGroup.addEventListener(NetStatusEvent.NET_STATUS, netGroupListener);
			users = new Dictionary();
			timer = new Timer(announcePeriod);
			timer.addEventListener(TimerEvent.TIMER, timerListener);
		}
		
		public function dispose():void
		{
			timer.stop();
			post(disconnected); //TODO 有効に働かないので別の方法を考える。
			netGroup.close();
			dispatchEvent(new KuzurisEvent(KuzurisEvent.disposed));
		}
		
		private function keepAlive():void
		{
			post(keepAlivePalse);
			var time:int = getTimer();
			for (var a:String in users)
			{
				if (users[a] + timeoutPeriod < time)
				{
					trace("removedUser", a);
					dispatchEvent(new UpdateUserEvent(UpdateUserEvent.removedUser, a));
					delete users[a];
				}
			}
		}
		
		private function updateUser(peerID:String):void
		{
			if (users[peerID] == null)
			{
				trace("addedUser", peerID);
				dispatchEvent(new UpdateUserEvent(UpdateUserEvent.addedUser, peerID));
			}
			users[peerID] = getTimer();
		}
		
		public function get isConnected():Boolean
		{
			return _isConnected;
		}
		
		public function get specifier():String
		{
			return _specifier;
		}
		
		public function containGroup(group:NetGroup):Boolean
		{
			return group == netGroup;
		}
		
		public function post(type:String, obj:Object = null):void
		{
			if (networkManager == null) return;
			if (obj == null) obj = new Object();
			var message:MessageObject = new MessageObject(type, obj, MessageObject.posting, networkManager.selfPeerID);
			netGroup.post(message);
			if (type != keepAlivePalse && type != "playerUpdate")
			{
				trace("post", message.type, _peerID);
			}
		}
		
		public function sendPeer(toPeerID:String, type:String, obj:Object = null):void
		{
			if (networkManager == null) return;
			if (obj == null) obj = new Object();
			var message:MessageObject = new MessageObject(type, obj, MessageObject.toPeer, networkManager.selfPeerID, toPeerID);
			var groupAddress:String = netGroup.convertPeerIDToGroupAddress(toPeerID);
			sendNearest(message, groupAddress);
			trace("sendPeer", message.type, _peerID);
		}
		
		private function postingNotify(message:MessageObject, messageID:String):void
		{
			if (message == null) return;
			if (message.type != keepAlivePalse && message.type != "playerUpdate")
			{
				trace("postingNotify", message.type, _peerID);
			}
			if (message.type == keepAlivePalse)
			{
				updateUser(message.peerID);
				return;
			}
			if (message.type == disconnected)
			{
				trace("disconnectedUser", message.peerID);
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
			trace("sendToNotify", message.type, _peerID);
			switch(message.sendMode)
			{
				case MessageObject.toPeer:
					if (fromLocal)
					{
						dispatchEvent(new NotifyEvent(NotifyEvent.notify, message));
					}
					else
					{
						var groupAddress:String = netGroup.convertPeerIDToGroupAddress(message.toPeerID);
						netGroup.sendToNearest(message, groupAddress);
					}
					break;
				case MessageObject.decreasing:
					dispatchEvent(new NotifyEvent(NotifyEvent.notify, message));
					break;
				case MessageObject.increasing:
					dispatchEvent(new NotifyEvent(NotifyEvent.notify, message));
					break;
				case MessageObject.neighbors:
					dispatchEvent(new NotifyEvent(NotifyEvent.notify, message));
					break;
			}
		}
		
		private function sendNeighbors(message:MessageObject):void
		{
			netGroup.sendToAllNeighbors(message);
		}
		
		private function sendIncreasing(message:MessageObject):void
		{
			netGroup.sendToNeighbor(message, NetGroupSendMode.NEXT_INCREASING);
		}
		
		private function sendDecreasing(message:MessageObject):void
		{
			netGroup.sendToNeighbor(message, NetGroupSendMode.NEXT_DECREASING);
		}
		
		private function sendNearest(message:MessageObject, groupAddress:String):void
		{
			netGroup.sendToNearest(message, groupAddress);
		}
		
		private function timerListener(e:TimerEvent):void
		{
			keepAlive();
			dispatchEvent(new KuzurisEvent(KuzurisEvent.announceClock));
		}
		
		private function netConnectionListener(e:NetStatusEvent):void
		{
			switch (e.info.code)
			{
				case "NetGroup.Connect.Closed":
					_isConnected = false;
					dispatchEvent(new KuzurisEvent(KuzurisEvent.connectClosed));
					break;
				case "NetGroup.Connect.Failed":
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.connectFailed, "グループに接続できませんでした。"));
					break;
				case "NetGroup.Connect.Rejected":
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.connectFailed, "グループへの接続が拒否されました。"));
					break;
				case "NetGroup.Connect.Success":
					_isConnected = true;
					timer.start();
					dispatchEvent(new KuzurisEvent(KuzurisEvent.connectSuccess));
					break;
			}
		}
		
		private function netGroupListener(e:NetStatusEvent):void
		{
			if (e.info.code != "NetGroup.Posting.Notify" && e.info.code != "NetGroup.SendTo.Notify")
			{
				trace(e.info.code, _peerID);
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
						dispatchEvent(new KuzurisEvent(KuzurisEvent.firstConnectNeighbor));
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