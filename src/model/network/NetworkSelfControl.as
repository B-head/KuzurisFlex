package model.network {
	import events.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import model.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="connectSuccess", type="events.KuzurisEvent")]
	[Event(name="connectClosed", type="events.KuzurisEvent")]
	[Event(name="disposed", type="events.KuzurisEvent")]
	[Event(name="connectFailed", type="events.KuzurisErrorEvent")]
	[Event(name="ioError", type="events.KuzurisErrorEvent")]
	[Event(name="asyncError", type="events.KuzurisErrorEvent")]
	public class NetworkSelfControl extends EventDispatcher implements GameControl 
	{
		private var _peerID:String;
		private var _isConnected:Boolean;
		private var networkManager:NetworkManager;
		private var netStream:NetStream;
		private var control:GameControl;
		private var gameModel:GameModel;
		private var commandRecord:Vector.<GameCommand>;
		private var hashRecord:Vector.<uint>;
		
		private const sendCommandLength:int = 10;
		
		public function NetworkSelfControl(networkManager:NetworkManager) 
		{
			_peerID = networkManager.selfPeerID;
			this.networkManager = networkManager;
			networkManager.addEventListener(NetStatusEvent.NET_STATUS, netConnectionListener);
			netStream = networkManager.createNetStream(NetStream.DIRECT_CONNECTIONS);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, netStreamListener);
			netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorListener);
			netStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorListener);
			netStream.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, mediaTypeDataListener);
			netStream.client = this;
			netStream.dataReliable = true;
			netStream.publish(_peerID);
			trace("publish", _peerID)
		}
		
		public function setControl(control:GameControl):void
		{
			this.control = control;
		}
		
		public function dispose():void
		{
			netStream.close();
			netStream.dispose();
			dispatchEvent(new KuzurisEvent(KuzurisEvent.disposed));
		}
		
		public function get isConnected():Boolean
		{
			return _isConnected;
		}
		
		public function onPeerConnect(subscriber:NetStream):Boolean
		{
			trace("onPeerConnect", subscriber.farID);
			return true;
		}
		
		public function sendCommand(all:Boolean):void
		{
			var startIndex:int = all ? 0 : Math.max(0, commandRecord.length - sendCommandLength);
			var sliceCommandRecord:Vector.<GameCommand> = commandRecord.slice(startIndex, commandRecord.length);
			var sliceHashRecord:Vector.<uint> = hashRecord.slice(startIndex, hashRecord.length);
			netStream.send(NetworkRemoteControl.gameCommnadHandlerName, startIndex, sliceCommandRecord, sliceHashRecord);
		}
		
		public function sendRequestCommand():void
		{
			trace("sendRequestCommand", _peerID);
			netStream.send(NetworkRemoteControl.gameRequestCommnadHandlerName);
		}
		
		public function sendSync():void
		{
			trace("sendSync", _peerID);
			tracePeerStreams();
			traceUnconnectedPeerStreams();
			netStream.send(NetworkRemoteControl.gameSyncHandlerName);
		}
		
		public function sendSyncReply():void
		{
			trace("sendSyncReply", _peerID);
			netStream.send(NetworkRemoteControl.gameSyncReplyHandlerName);
		}
		
		public function sendReady(playerIndex:int, setting:GameSetting, seed:XorShift128, delay:int):void
		{
			trace("sendReady", playerIndex, _peerID);
			netStream.send(NetworkRemoteControl.networkGameReadyHandlerName, playerIndex, setting, seed, delay);
		}
		
		private function tracePeerStreams():void
		{
			var peers:Array = netStream.peerStreams;
			for (var i:int = 0; i < peers.length; i++)
			{
				var ps:NetStream = peers[i] as NetStream;
				trace("peerStreams ", i, ps.farID);
			}
		}
		
		private function traceUnconnectedPeerStreams():void
		{
			var peers:Array = networkManager.unconnectedPeerStreams;
			for (var i:int = 0; i < peers.length; i++)
			{
				var ps:NetStream = peers[i] as NetStream;
				trace("unconnectedPeerStreams ", i, ps.farID);
			}
		}
		
		public function get peerID():String { return _peerID; }
		public function get enable():Boolean { return control.enable; }
		public function set enable(value:Boolean):void { control.enable = value; };
		
		public function initialize(gameModel:GameModel):void 
		{
			control.initialize(gameModel);
			this.gameModel = gameModel;
			commandRecord = new Vector.<GameCommand>();
			hashRecord = new Vector.<uint>();
		}
		
		public function setMaterialization(index:int):void
		{
			control.setMaterialization(index);
		}
		
		public function issueGameCommand():GameCommand 
		{
			var command:GameCommand = control.issueGameCommand();
			commandRecord.push(command);
			hashRecord.push(gameModel.hash());
			sendCommand(false);
			return command;
		}
		
		private function netConnectionListener(e:NetStatusEvent):void
		{
			if (e.info.stream != netStream) return;
			switch (e.info.code)
			{
				case "NetStream.Connect.Closed":
					_isConnected = false;
					dispatchEvent(new KuzurisEvent(KuzurisEvent.connectClosed));
					break;
				case "NetStream.Connect.Failed":
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.connectFailed, "ストリームに接続できませんでした。"));
					break;
				case "NetStream.Connect.Rejected":
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.connectFailed, "ストリームへの接続が拒否されました。"));
					break;
				case "NetStream.Connect.Success":
					_isConnected = true;
					dispatchEvent(new KuzurisEvent(KuzurisEvent.connectSuccess));
					break;
			}
		}
		
		private function netStreamListener(e:NetStatusEvent):void
		{
			trace(e.info.code, _peerID, "self");
			switch (e.info.code)
			{
				case "NetStream.Failed":
					break;
				case "NetStream.Publish.BadName":
					break;
			}
		}
		
		private function asyncErrorListener(e:AsyncErrorEvent):void
		{
			trace(e.text, e.error, e.errorID, _peerID, "self");
			dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.asyncError, "Flash playerにエラーが発生しました。\n\n" + e.text));
		}
		
		private function ioErrorListener(e:IOErrorEvent):void
		{
			trace(e.text, e.errorID, _peerID, "self");
			dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.ioError, "インターネット接続にエラーがあります。\n接続状況を確認してから再度接続して下さい。\n\n" + e.text));
		}
		
		private function mediaTypeDataListener(e:NetDataEvent):void
		{
			if (e.info.handler == NetworkRemoteControl.gameCommnadHandlerName) return;
			trace(e.info.handler, _peerID, "self");
		}
	}

}