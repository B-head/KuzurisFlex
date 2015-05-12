package network_rewrite 
{
	import common.*;
	import events.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import model.*;
	import view.Main;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="connectClosed", type="events.NetworkEvent")]
	[Event(name="connectSuccess", type="events.NetworkEvent")]
	[Event(name="disposed", type="events.NetworkEvent")]
	[Event(name="connectFailed", type="events.NetworkErrorEvent")]
	[Event(name="connectRejected", type="events.NetworkErrorEvent")]
	[Event(name="asyncError", type="events.NetworkErrorEvent")]
	[Event(name="ioError", type="events.NetworkErrorEvent")]
	[Event(name="gameSync", type="events.GameSyncEvent")]
	[Event(name="networkGameReady", type="events.GameReadyEvent")]
	[Event(name="deficiencyCommnad", type="events.NetworkEvent")]
	[Event(name="differHashCommnad", type="events.NetworkEvent")]
	[Event(name="differHashGameModel", type="events.NetworkEvent")]
	[Event(name="receiveGameModel", type="events.ReceiveGameModelEvent")]
	[Event(name="appendChat", type="events.AppendTextEvent")]
	public class RemoteControl extends EventDispatcherEX 
	{
		private var connectionManager:ConnectionManager;
		private var netStream:NetStream;
		private var _isConnected:Boolean;
		private var _peerID:String;
		private var _enable:Boolean;
		private var commandRecord:Vector.<GameCommand>;
		private var hashRecord:Vector.<uint>;
		private var currentCommandSequence:int;
		private var reconnectTimer:Timer;
		
		private const reconnectPeriod:int = 2000;
		private const reconnectRepeat:int = 5;
		
		public function RemoteControl(connectionManager:ConnectionManager, peerID:String) 
		{
			this.connectionManager = connectionManager;
			_peerID = peerID;
			commandRecord = new Vector.<GameCommand>();
			hashRecord = new Vector.<uint>();
		}
		
		public function connect():void
		{
			netStream = connectionManager.createNetStream(peerID, netConnectionListener);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, netStreamListener, false, 0, true);
			netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorListener, false, 0, true);
			netStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorListener, false, 0, true);
			netStream.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, mediaTypeDataListener, false, 0, true);
			netStream.client = this;
			netStream.dataReliable = true;
			netStream.play(_peerID);
			Debug.trace("init remote " + _peerID);
		}
		
		public function dispose():void
		{
			streamDispose();
			dispatchEvent(new NetworkEvent(NetworkEvent.disposed));
		}
		
		private function streamDispose():void
		{
			if (netStream == null) return;
			netStream.close();
			netStream.dispose();
			netStream = null;
		}
		
		public function get isConnected():Boolean { return _isConnected; }
		public function get peerID():String { return _peerID; }
		public function get enable():Boolean { return _enable; }
		public function set enable(value:Boolean):void { _enable = value; };
		
		public function initialize(gameModel:GameModel):void
		{
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
			if (Main.unstableNetworkTest)
			{
				if (Math.random() < 0.0003) streamDispose();
				if (Math.random() < 0.5) return null;
			}
			if (commandRecord.length <= currentCommandSequence) return null;
			return commandRecord[currentCommandSequence++];
		}
		
		public function onSignal(type:String):void
		{
			dispatchEvent(new NetworkEvent(type));
		}
		
		public function onSync(localTime:uint, delayTime:uint):void
		{
			dispatchEvent(new GameSyncEvent(GameSyncEvent.gameSync, localTime, delayTime));
		}
		
		public function onGameReady(peerID:String, setting:GameSetting, seed:XorShift128, delay:int):void
		{
			if (peerID != _peerID) return;
			dispatchEvent(new GameReadyEvent(GameReadyEvent.networkGameReady, int.MIN_VALUE, setting, seed, delay));
		}
		
		public function onGameCommand(startIndex:int, sliceCommandRecord:Vector.<GameCommand>, sliceHashRecord:Vector.<uint>, receiveHash:uint):void
		{
			if (commandRecord.length < startIndex)
			{
				Debug.trace("deficiency onGameCommnad");
				dispatchEvent(new NetworkEvent(NetworkEvent.deficiencyCommnad));
				return;
			}
			var hash:uint = Utility.makeSendHash(sliceCommandRecord, sliceHashRecord);
			if (hash != receiveHash)
			{
				Debug.trace("differ hash onGameCommnad");
				dispatchEvent(new NetworkEvent(NetworkEvent.differHashCommnad));
				return;
			}
			commandRecord.length = Math.max(commandRecord.length, startIndex);
			hashRecord.length = Math.max(hashRecord.length, startIndex);
			Utility.copyTo(sliceCommandRecord, commandRecord, startIndex);
			Utility.copyTo(sliceHashRecord, hashRecord, startIndex);
		}
		
		public function onGameModel(model:GameModel, receiveHash:uint):void
		{
			if (model.hash() != receiveHash)
			{
				Debug.trace("differ hash onGameModel");
				dispatchEvent(new NetworkEvent(NetworkEvent.differHashGameModel));
				return;
			}
			currentCommandSequence = model.record.gameTime;
			commandRecord.length = currentCommandSequence;
			hashRecord.length = currentCommandSequence;
			dispatchEvent(new ReceiveGameModelEvent(ReceiveGameModelEvent.receiveGameModel, model));
		}
		
		public function onChat(text:String):void
		{
			dispatchEvent(new AppendTextEvent(AppendTextEvent.appendChat, text));
		}
		
		private function reconnectTimerListener(e:TimerEvent):void
		{
			return;
		}
		
		private function reconnectTimerCompleteListener(e:TimerEvent):void
		{
			return;
		}
		
		private function netConnectionListener(e:NetStatusEvent):void
		{
			if (e.info.stream != netStream) return;
			switch (e.info.code)
			{
				case "NetStream.Connect.Closed":
					_isConnected = false;
					dispatchEvent(new NetworkEvent(NetworkEvent.connectClosed));
					break;
				case "NetStream.Connect.Failed":
					dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.connectFailed, "ストリームに接続できませんでした。"));
					break;
				case "NetStream.Connect.Rejected":
					dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.connectRejected, "ストリームへの接続が拒否されました。"));
					break;
				case "NetStream.Connect.Success":
					_isConnected = true;
					dispatchEvent(new NetworkEvent(NetworkEvent.connectSuccess));
					break;
			}
		}
		
		private function netStreamListener(e:NetStatusEvent):void
		{
			Debug.trace(e.info.code, "remote");
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
			Debug.trace(e.text, e.error, e.errorID, "remote");
			dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.asyncError, "Flash playerで非同期エラーが発生しました。\n\n" + e.text));
		}
		
		private function ioErrorListener(e:IOErrorEvent):void
		{
			Debug.trace(e.text, e.errorID, "remote");
			dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.ioError, "インターネット接続にエラーがあります。\n接続状況を確認してから再度接続して下さい。\n\n" + e.text));
		}
		
		private function mediaTypeDataListener(e:NetDataEvent):void
		{
			if (e.info.handler == "onGameCommand") return;
			Debug.trace(e.info.handler, "remote");
		}	
	}
}