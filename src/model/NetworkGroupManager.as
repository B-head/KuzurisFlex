package model 
{
	import events.*;
	import flash.events.*;
	import flash.net.*;
	
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="connectNeighbor", type="events.KuzurisEvent")]
	[Event(name="disconnectNeighbor", type="events.KuzurisEvent")]
	[Event(name="notify", type="events.NotifyEvent")]
	public class NetworkGroupManager extends EventDispatcher
	{
		private var netConnection:NetConnection;
		private var netGroup:NetGroup;
		
		public function NetworkGroupManager(netConnection:NetConnection, specifier:String) 
		{
			this.netConnection = netConnection;
			netGroup = new NetGroup(netConnection, specifier);
			netGroup.addEventListener(NetStatusEvent.NET_STATUS, netStatusListener);
		}
		
		public function dispose():void
		{
			netConnection = null;
			netGroup.close();
		}
		
		public function getNetGroup():NetGroup
		{
			return netGroup;
		}
		
		public function post(type:String, obj:Object = null):void
		{
			var message:MessageObject = new MessageObject(type, obj, MessageObject.posting, netConnection.nearID);
			netGroup.post(message);
		}
		
		public function sendAll(type:String, obj:Object = null):void
		{
			var inc:MessageObject = new MessageObject(type, obj, MessageObject.increasing, netConnection.nearID);
			sendIncreasing(inc);
			var dec:MessageObject = new MessageObject(type, obj, MessageObject.decreasing, netConnection.nearID);
			sendDecreasing(dec);
		}
		
		public function sendPeer(toPeerID:String, type:String, obj:Object = null):void
		{
			var message:MessageObject = new MessageObject(type, obj, MessageObject.toPeer, netConnection.nearID, toPeerID);
			var groupAddress:String = netGroup.convertPeerIDToGroupAddress(toPeerID);
			sendNearest(message, groupAddress);
		}
		
		private function postingNotify(message:MessageObject, messageID:String):void
		{
			if (message == null) return;
			dispatchEvent(new NotifyEvent(NotifyEvent.notify, message));
		}
		
		private function sendToNotify(message:MessageObject, from:String, fromLocal:Boolean):void
		{
			if (message == null) return;
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
					sendDecreasing(message);
					break;
				case MessageObject.increasing:
					dispatchEvent(new NotifyEvent(NotifyEvent.notify, message));
					sendIncreasing(message);
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
		
		private function netStatusListener(e:NetStatusEvent):void
		{
			switch (e.info.code)
			{
				case "NetGroup.LocalCoverage.Notify":
					trace("LocalCoverage.Notify");
					break;
				case "NetGroup.Posting.Notify":
					postingNotify(e.info.message as MessageObject, e.info.messageID);
					break;
				case "NetGroup.Neighbor.Connect":
					dispatchEvent(new KuzurisEvent(KuzurisEvent.connectNeighbor));
					break;
				case "NetGroup.Neighbor.Disconnect":
					dispatchEvent(new KuzurisEvent(KuzurisEvent.disconnectNeighbor));
					break;
				case "NetGroup.SendTo.Notify":
					sendToNotify(e.info.message as MessageObject, e.info.from, e.info.formLocal);
					break;
			}
		}
		
	}

}