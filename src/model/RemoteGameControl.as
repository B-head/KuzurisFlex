package model 
{
	import events.*;
	import flash.events.*;
	import flash.net.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="gameSync", type="events.KuzurisEvent")]
	[Event(name="gameSyncReply", type="events.KuzurisEvent")]
	[Event(name="streamError", type="events.KuzurisErrorEvent")]
	[Event(name="networkGameReady", type="events.NetworkGameReadyEvent")]
	public class RemoteGameControl extends EventDispatcher implements GameControl 
	{
		public static const gameCommnadHandlerName:String = "onGameCommnad";
		public static const gameSyncHandlerName:String = "onGameSync";
		public static const gameSyncReplyHandlerName:String = "onGameSyncReply";
		public static const networkGameReadyHandlerName:String = "onNetworkGameReady";
		
		private var _enable:Boolean;
		private var _peerID:String;
		private var netConnection:NetConnection;
		private var netStream:NetStream;
		private var buffer:Vector.<GameCommand>;
		
		public function RemoteGameControl(netConnection:NetConnection, peerID:String) 
		{
			_peerID = peerID;
			this.netConnection = netConnection;
			netStream = new NetStream(netConnection, peerID);
			netStream.client = this;
			netStream.dataReliable = false;
			netStream.play(peerID);
			buffer = new Vector.<GameCommand>();
		}
		
		public function dispose():void
		{
			netConnection = null;
			netStream.dispose();
		}
		
		public function onGameCommnad(command:GameCommand):void
		{
			buffer.push(command);
		}
		
		public function onGameSync():void
		{
			dispatchEvent(new KuzurisEvent(KuzurisEvent.gameSync));
		}
		
		public function onGameSyncReply():void
		{
			dispatchEvent(new KuzurisEvent(KuzurisEvent.gameSyncReply));
		}
		
		public function onNetworkGameReady(playerIndex:int, setting:GameSetting, seed:XorShift128, delay:int):void
		{
			dispatchEvent(new NetworkGameReadyEvent(NetworkGameReadyEvent.networkGameReady, playerIndex, setting, seed, delay));
		}
		
		public function get peerID():String { return _peerID; }
		public function get enable():Boolean { return _enable; }
		public function set enable(value:Boolean):void { _enable = value; };
		
		public function initialize(gameModel:GameModel):void 
		{
			buffer = new Vector.<GameCommand>();
		}
		
		public function setMaterialization(index:int):void
		{
			return;
		}
		
		public function issueGameCommand():GameCommand 
		{
			if (buffer.length == 0) return null;
			return buffer.shift();
		}
		
		private function netConnectionListener(e:NetStatusEvent):void
		{
			switch (e.info.code)
			{
				case "NetStream.Connect.Closed":
					if (e.info.stream != netStream) return;
					if (netConnection != null)
					{
						netStream.attach(netConnection);
						netStream.play(peerID);
					}
					break;
				case "NetStream.Connect.Failed":
					break;
				case "NetStream.Connect.Rejected":
					break;
				case "NetStream.Connect.Success":
					break;
			}
		}
	}
}