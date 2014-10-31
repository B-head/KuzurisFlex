package model.network {
	import events.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Timer;
	import model.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="gameSync", type="events.KuzurisEvent")]
	[Event(name="gameSyncReply", type="events.KuzurisEvent")]
	[Event(name="connectSuccess", type="events.KuzurisEvent")]
	[Event(name="connectClosed", type="events.KuzurisEvent")]
	[Event(name="disposed", type="events.KuzurisEvent")]
	[Event(name="connectFailed", type="events.KuzurisErrorEvent")]
	[Event(name="notEqualHash", type="events.KuzurisErrorEvent")]
	[Event(name="ioError", type="events.KuzurisErrorEvent")]
	[Event(name="asyncError", type="events.KuzurisErrorEvent")]
	[Event(name="networkGameReady", type="events.NetworkGameReadyEvent")]
	public class NetworkRemoteControl extends EventDispatcher implements GameControl 
	{		
		private var _enable:Boolean;
		private var _peerID:String;
		private var _isConnected:Boolean;
		private var networkManager:NetworkManager;
		private var selfControl:NetworkSelfControl;
		private var netStream:NetStream;
		private var reconnectTimer:Timer;
		private var gameModel:GameModel;
		private var commandRecord:Vector.<GameCommand>;
		private var hashRecord:Vector.<uint>;
		private var currentCommandSequence:int;
		
		private const reconnectPeriod:int = 2000;
		
		public function NetworkRemoteControl(networkManager:NetworkManager, selfControl:NetworkSelfControl, peerID:String) 
		{
			commandRecord = new Vector.<GameCommand>();
			hashRecord = new Vector.<uint>();
			_peerID = peerID;
			this.networkManager = networkManager;
			networkManager.addEventListener(NetStatusEvent.NET_STATUS, netConnectionListener);
			this.selfControl = selfControl;
			initStream();
			trace("play", _peerID)
			reconnectTimer = new Timer(reconnectPeriod, 1);
			reconnectTimer.addEventListener(TimerEvent.TIMER, reconnectTimerListener);
		}
		
		private function initStream():void
		{
			netStream = networkManager.createNetStream(peerID);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, netStreamListener);
			netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorListener);
			netStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorListener);
			netStream.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, mediaTypeDataListener);
			netStream.client = this;
			netStream.dataReliable = true;
			netStream.play(_peerID);
		}
		
		public function dispose():void
		{
			reconnectTimer.stop();
			streamDispose()
			dispatchEvent(new KuzurisEvent(KuzurisEvent.disposed));
		}
		
		private function streamDispose():void
		{
			netStream.close();
			netStream.dispose();
			netStream.removeEventListener(NetStatusEvent.NET_STATUS, netStreamListener);
			netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorListener);
			netStream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorListener);
			netStream.removeEventListener(NetDataEvent.MEDIA_TYPE_DATA, mediaTypeDataListener);
		}
		
		public function get isConnected():Boolean
		{
			return _isConnected;
		}
		
		public function onGameCommnad(startIndex:int, sliceCommandRecord:Vector.<GameCommand>, sliceHashRecord:Vector.<uint>, receiveSendHash:uint):void
		{
			var sendHash:uint = 0;
			for (var i:int = 0; i < sliceCommandRecord.length; i++)
			{
				sendHash ^= sliceCommandRecord[i].toUInt();
				sendHash ^= sliceHashRecord[i];
			}
			if (sendHash != receiveSendHash)
			{
				trace("ignore onGameCommnad", _peerID);
				return;
			}
			commandRecord.length = Math.max(commandRecord.length, startIndex);
			hashRecord.length = Math.max(hashRecord.length, startIndex);
			for (i = 0; i < sliceCommandRecord.length; i++)
			{
				commandRecord[startIndex + i] = sliceCommandRecord[i];
				hashRecord[startIndex + i] = sliceHashRecord[i];
			}
		}
		
		public function onGameRequestCommnad():void
		{
			trace("onGameRequestCommnad", _peerID);
			selfControl.sendCommand(true);
		}
		
		public function onGameSync():void
		{
			trace("onGameSync", _peerID);
			dispatchEvent(new KuzurisEvent(KuzurisEvent.gameSync));
		}
		
		public function onGameSyncReply():void
		{
			trace("onGameSyncReply", _peerID);
			dispatchEvent(new KuzurisEvent(KuzurisEvent.gameSyncReply));
		}
		
		public function onNetworkGameReady(playerIndex:int, setting:GameSetting, seed:XorShift128, delay:int):void
		{
			trace("onNetworkGameReady", playerIndex, _peerID);
			dispatchEvent(new NetworkGameReadyEvent(NetworkGameReadyEvent.networkGameReady, playerIndex, setting, seed, delay));
		}
		
		public function get peerID():String { return _peerID; }
		public function get enable():Boolean { return _enable; }
		public function set enable(value:Boolean):void { _enable = value; };
		
		public function initialize(gameModel:GameModel):void 
		{
			this.gameModel = gameModel;
			commandRecord = new Vector.<GameCommand>();
			hashRecord = new Vector.<uint>();
			currentCommandSequence = 0;
		}
		
		public function setMaterialization(index:int):void
		{
			return;
		}
		
		public function issueGameCommand():GameCommand 
		{
			if (commandRecord.length <= currentCommandSequence ) return null;
			if (gameModel.hash() != hashRecord[currentCommandSequence])
			{
				trace("hash not equal", currentCommandSequence, gameModel.hash(), hashRecord[currentCommandSequence], _peerID);
				dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.notEqualHash, "ゲームモデルのハッシュ値が一致しませんでした。"));
				currentCommandSequence = int.MAX_VALUE;
				return null;
			}
			var ret:GameCommand = commandRecord[currentCommandSequence];
			if (ret != null) currentCommandSequence++;
			return ret;
		}
		
		public function obtainState(gameModel:GameModel):void
		{
			this.gameModel = gameModel;
			commandRecord = new Vector.<GameCommand>();
			hashRecord = new Vector.<uint>();
			currentCommandSequence = gameModel.record.gameTime + 1;
			selfControl.sendRequestCommand();
		}
		
		private function reconnectTimerListener(e:TimerEvent):void
		{
			if (!networkManager.isConnected) return;
			initStream();
		}
		
		private function netConnectionListener(e:NetStatusEvent):void
		{
			if (e.info.stream != netStream) return;
			switch (e.info.code)
			{
				case "NetStream.Connect.Closed":
					_isConnected = false;
					streamDispose();
					reconnectTimer.reset();
					reconnectTimer.start();
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
					reconnectTimer.stop();
					selfControl.sendRequestCommand();
					dispatchEvent(new KuzurisEvent(KuzurisEvent.connectSuccess));
					break;
			}
		}
		
		private function netStreamListener(e:NetStatusEvent):void
		{
			trace(e.info.code, _peerID, "remote");
			switch (e.info.code)
			{
				case "NetStream.Failed":
					break;
				case "NetStream.Play.Failed":
					break;
				case "NetStream.Play.FileStructureInvalid":
					break;
				case "NetStream.Play.StreamNotFound":
					break;
			}
		}
		
		private function asyncErrorListener(e:AsyncErrorEvent):void
		{
			trace(e.text, e.error, e.errorID, _peerID, "remote");
			dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.asyncError, "Flash playerにエラーが発生しました。\n\n" + e.text));
		}
		
		private function ioErrorListener(e:IOErrorEvent):void
		{
			trace(e.text, e.errorID, _peerID, "remote");
			dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.ioError, "インターネット接続にエラーがあります。\n接続状況を確認してから再度接続して下さい。\n\n" + e.text));
		}
		
		private function mediaTypeDataListener(e:NetDataEvent):void
		{
			if (e.info.handler == "onGameCommnad") return;
			trace(e.info.handler, _peerID, "remote");
		}
	}
}