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
	public class SelfControl extends EventDispatcherEX 
	{
		private var bindControl:GameControl;
		private var connectionManager:ConnectionManager;
		private var netStream:NetStream;
		private var _isConnected:Boolean;
		private var _peerID:String;
		private var commandRecord:Vector.<GameCommand>;
		private var hashRecord:Vector.<uint>;
		private var reconnectTimer:Timer;
		
		private const sendCommandLength:int = 10;
		private const reconnectPeriod:int = 2000;
		private const reconnectRepeat:int = 5;
		
		public function SelfControl(connectionManager:ConnectionManager, bindControl:GameControl) 
		{
			this.bindControl = bindControl;
			this.connectionManager = connectionManager;
			_peerID = connectionManager.selfPeerID;
			commandRecord = new Vector.<GameCommand>();
			hashRecord = new Vector.<uint>();
		}
		
		public function connect():void
		{
			netStream = connectionManager.createNetStream(NetStream.DIRECT_CONNECTIONS, netConnectionListener);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, netStreamListener, false, 0, true);
			netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorListener, false, 0, true);
			netStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorListener, false, 0, true);
			netStream.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, mediaTypeDataListener, false, 0, true);
			netStream.client = this;
			netStream.dataReliable = true;
			netStream.publish(_peerID);
			Debug.trace("init self " + _peerID);
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
			control.initialize(gameModel);
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
			if (Main.unstableNetworkTest)
			{
				if (Math.random() < 0.0003) streamDispose();
				if (Math.random() < 0.9) return command;
			}
			sendGameCommand(false);
			return command;
		}
		
		public function sendSignal(type:String):void
		{
			netStream.send("onSignal", type);
		}
		
		public function sendSync(localTime:uint, delayTime:uint):void
		{
			netStream.send("onSync", localTime, delayTime);
		}
		
		public function sendGameReady(peerID:String, setting:GameSetting, seed:XorShift128, delay:int):void
		{
			netStream.send("onGameReady", peerID, setting, seed, delay);
		}
		
		public function sendGameCommand(startindex:int):void
		{
			var sliceCommandRecord:Vector.<GameCommand> = commandRecord.slice(startIndex, commandRecord.length);
			var sliceHashRecord:Vector.<uint> = hashRecord.slice(startIndex, hashRecord.length);
			var hash:uint = Utility.makeSendHash(sliceCommandRecord, sliceHashRecord);
			netStream.send("onGameCommand", startIndex, sliceCommandRecord, sliceHashRecord, hash);
		}
		
		public function sendGameModel(model:GameModel):void
		{
			netStream.send("onGameModel", model, model.hash());
			sendGameCommand(model.record.gameTime);
		}
		
		public function sendChat(text:String):void
		{
			netStream.send("onChat", text);
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
			Debug.trace(e.info.code, "self");
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
			Debug.trace(e.text, e.error, e.errorID, "self");
			dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.asyncError, "Flash playerで非同期エラーが発生しました。\n\n" + e.text));
		}
		
		private function ioErrorListener(e:IOErrorEvent):void
		{
			Debug.trace(e.text, e.errorID, "self");
			dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.ioError, "インターネット接続にエラーがあります。\n接続状況を確認してから再度接続して下さい。\n\n" + e.text));
		}
		
		private function mediaTypeDataListener(e:NetDataEvent):void
		{
			if (e.info.handler == "onGameCommand") return;
			Debug.trace(e.info.handler, "self");
		}
	}
}