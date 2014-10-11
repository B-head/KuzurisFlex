package model
{
	import events.*;
	import flash.events.*;
	import flash.net.*;
	
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="loungeConnectSuccess", type="events.KuzurisEvent")]
	[Event(name="roomConnectSuccess", type="events.KuzurisEvent")]
	[Event(name="connectClosed", type="events.KuzurisEvent")]
	[Event(name="connectIdleTimeout", type="events.KuzurisEvent")]
	[Event(name="ioError", type="events.KuzurisErrorEvent")]
	[Event(name="loungeConnectFailed", type="events.KuzurisErrorEvent")]
	[Event(name="roomConnectFailed", type="events.KuzurisErrorEvent")]
	public class NetworkManager extends EventDispatcher
	{
		private const CirrusAddress:String = "rtmfp://p2p.rtmfp.net";
		private const DeveloperKey:String = "89a898b4b7869bbd1232dabe-41cb09d77e52";
		private var netConnection:NetConnection;
		private var _loungeGroup:NetworkGroupManager;
		private var _roomGroup:NetworkGroupManager;
		private var selfControlStream:NetStream;
		private var controlStream:Vector.<RemoteGameControl>;
		private var _roomGroupSpecifier:String;
		
		public function NetworkManager()
		{
			netConnection = new NetConnection();
			controlStream = new Vector.<RemoteGameControl>(8);
		}
		
		public function connect():void
		{
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, netConnectionListener);
			netConnection.addEventListener(IOErrorEvent.IO_ERROR, ioErrorLintener);
			netConnection.connect(CirrusAddress, DeveloperKey);
		}
		
		public function disconnect():void
		{
			netConnection.close();
		}
		
		private function connectLoungeGroup():void
		{
			var specifier:GroupSpecifier = new GroupSpecifier("lounge");
			specifier.postingEnabled = true;
			specifier.routingEnabled = true;
			specifier.serverChannelEnabled = true;
			_loungeGroup = new NetworkGroupManager(netConnection, specifier.toString());
		}
		
		public function createRoomGroup():void
		{
			var specifier:GroupSpecifier = new GroupSpecifier("room");
			specifier.postingEnabled = true;
			specifier.routingEnabled = true;
			specifier.serverChannelEnabled = true;
			specifier.makeUnique();
			connectRoomGroup(specifier.toString());
		}
		
		public function connectRoomGroup(specifier:String):void
		{
			_roomGroupSpecifier = specifier;
			_roomGroup = new NetworkGroupManager(netConnection, _roomGroupSpecifier);
			selfControlStream = new NetStream(netConnection, NetStream.DIRECT_CONNECTIONS);
			selfControlStream.dataReliable = false;
			selfControlStream.publish(selfPeerID, _roomGroupSpecifier);
		}
		
		public function disconnectRoomGroup():void
		{
			for (var i:int = 0; i < controlStream.length; i++)
			{
				if (controlStream[i] == null) continue;
				controlStream[i].dispose();
				controlStream[i] = null;
			}
			selfControlStream.dispose();
			selfControlStream = null;
			_roomGroup.dispose();
			_roomGroup = null;
		}
		
		public function getRemoteGameControl(index:int, peerID:String):RemoteGameControl
		{
			if (controlStream[index] == null)
			{
				controlStream[index] = new RemoteGameControl(netConnection, peerID);
			}
			else if (controlStream[index].peerID != peerID)
			{
				controlStream[index].dispose();
				controlStream[index] = new RemoteGameControl(netConnection, peerID);
			}
			return controlStream[index];
		}
		
		public function sendSync():void
		{
			selfControlStream.send(RemoteGameControl.gameSyncHandlerName);
		}
		
		public function sendSyncReply():void
		{
			selfControlStream.send(RemoteGameControl.gameSyncReplyHandlerName);
		}
		
		public function sendReady(playerIndex:int, setting:GameSetting, seed:XorShift128, delay:int):void
		{
			selfControlStream.send(RemoteGameControl.networkGameReadyHandlerName, playerIndex, setting, seed, delay);
		}
		
		public function sendCommand(command:GameCommand):void
		{
			selfControlStream.send(RemoteGameControl.gameCommnadHandlerName, command);
		}
		
		public function get selfPeerID():String
		{
			return netConnection.nearID;
		}
		
		public function get loungeGroup():NetworkGroupManager
		{
			return _loungeGroup;
		}
		
		public function get roomGroup():NetworkGroupManager
		{
			return _roomGroup;
		}
		
		public function get roomGroupSpecifier():String
		{
			return _roomGroupSpecifier;
		}
		
		private function netConnectionListener(e:NetStatusEvent):void
		{
			switch (e.info.code)
			{
				case "NetConnection.Connect.AppShutdown":
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.loungeConnectFailed, "サーバーがシャットダウンしているため、接続できませんでした。"));
					break;
				case "NetConnection.Connect.Failed":
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.loungeConnectFailed, "サーバーに接続できませんでした。\nしばらくしてから再度接続して下さい。"));
					break;
				case "NetConnection.Connect.InvalidApp":
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.loungeConnectFailed, "崩リスのバグにより接続できませんでした。\nお手数ですが、製作者にお問い合わせ下さい。"));
					break;
				case "NetConnection.Connect.Rejected":
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.loungeConnectFailed, "P2P接続が拒否されました。\nP2P接続を許可して下さい。"));
					break;
				case "NetConnection.Connect.Closed":
					trace("NetConnection.Connect.Closed");
					dispatchEvent(new KuzurisEvent(KuzurisEvent.connectClosed));
					break;
				case "NetConnection.Connect.IdleTimeout":
					trace("NetConnection.Connect.IdleTimeout");
					dispatchEvent(new KuzurisEvent(KuzurisEvent.connectIdleTimeout));
					break;
				case "NetConnection.Connect.NetworkChange":
					trace("NetConnection.Connect.NetworkChange");
					break;
				case "NetConnection.Connect.Success":
					connectLoungeGroup();
					break;
				case "NetGroup.Connect.Failed":
					if (e.info.group == _loungeGroup.getNetGroup())
					{
						dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.loungeConnectFailed, "ラウンジに接続できませんでした。\nしばらくしてから再度接続して下さい。"));
					}
					else if (e.info.group == _roomGroup.getNetGroup())
					{
						dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.roomConnectFailed, "ルームに接続できませんでした。"));
					}
					break;
				case "NetGroup.Connect.Rejected":
					if (e.info.group == _loungeGroup.getNetGroup())
					{
						dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.loungeConnectFailed, "ラウンジへの接続が拒否されました。\nお手数ですが、製作者にお問い合わせ下さい。"));
					}
					else if (e.info.group == _roomGroup.getNetGroup())
					{
						dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.roomConnectFailed, "ルームへの接続が拒否されました。"));
					}
					break;
				case "NetGroup.Connect.Success":
					if (e.info.group == _loungeGroup.getNetGroup())
					{
						dispatchEvent(new KuzurisEvent(KuzurisEvent.loungeConnectSuccess));
					}
					else if (e.info.group == _roomGroup.getNetGroup())
					{
						dispatchEvent(new KuzurisEvent(KuzurisEvent.roomConnectSuccess));
					}
					break;
				case "NetStream.Connect.Closed":
					trace("NetStream.Connect.Closed");
					if (e.info.stream != selfControlStream) return;
					if (netConnection != null)
					{
						selfControlStream.attach(netConnection);
						selfControlStream.publish(selfPeerID, _roomGroupSpecifier);
					}
					break;
				case "NetStream.Connect.Failed":
					trace("NetStream.Connect.Failed");
					break;
				case "NetStream.Connect.Rejected":
					trace("NetStream.Connect.Rejected");
					break;
				case "NetStream.Connect.Success":
					trace("NetStream.Connect.Success");
					break;
			}
		}
		
		private function ioErrorLintener(e:IOErrorEvent):void
		{
			dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.ioError, "インターネット接続にエラーがあります。\n接続状況を確認してから再度接続して下さい。\n\n" + e.text));
		}
	
	}
}