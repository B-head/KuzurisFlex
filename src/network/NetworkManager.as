package network {
	import common.*;
	import events.*;
	import flash.events.*;
	import flash.net.*;
	import model.*;
	import view.Main;
	
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="loungeConnectSuccess", type="events.KuzurisEvent")]
	[Event(name="roomConnectSuccess", type="events.KuzurisEvent")]
	[Event(name="connectClosed", type="events.KuzurisEvent")]
	[Event(name="connectIdleTimeout", type="events.KuzurisEvent")]
	[Event(name="ioError", type="events.KuzurisErrorEvent")]
	[Event(name="asyncError", type="events.KuzurisErrorEvent")]
	[Event(name="loungeConnectFailed", type="events.KuzurisErrorEvent")]
	[Event(name="roomConnectFailed", type="events.KuzurisErrorEvent")]
	[Event(name="NET_STATUS", type="flash.events..NetStatusEvent")]
	public class NetworkManager extends EventDispatcherEX
	{
		private const CirrusAddress:String = "rtmfp://p2p.rtmfp.net/";
		private const DeveloperKey:String = "89a898b4b7869bbd1232dabe-41cb09d77e52";
		private var _isConnected:Boolean;
		private var netConnection:NetConnection;
		private var _loungeGroup:NetworkGroupManager;
		private var _roomGroup:NetworkGroupManager;
		private var selfControl:NetworkSelfControl;
		private var controlStream:Vector.<NetworkRemoteControl>;
		
		public function NetworkManager()
		{
			controlStream = new Vector.<NetworkRemoteControl>(8);
		}
		
		public function connect():void
		{
			netConnection = new NetConnection();
			netConnection.maxPeerConnections = 1024;
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, netConnectionListener, false, 0, true);
			netConnection.addEventListener(IOErrorEvent.IO_ERROR, ioErrorLintener, false, 0, true);
			netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorListener, false, 0, true);
			netConnection.connect(CirrusAddress + DeveloperKey);
		}
		
		public function disconnect():void
		{
			netConnection.removeEventListener(NetStatusEvent.NET_STATUS, netConnectionListener);
			netConnection.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorLintener);
			netConnection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorListener);
			removeAll();
			disconnectRoomGroup();
			if (_loungeGroup != null)
			{
				_loungeGroup.dispose();
				_loungeGroup = null;
			}
			if (netConnection != null)
			{
				netConnection.close();
				netConnection = null;
			}
		}
		
		private function connectLoungeGroup():void
		{
			var specifier:GroupSpecifier = new GroupSpecifier("lounge");
			specifier.ipMulticastMemberUpdatesEnabled = true;
			specifier.multicastEnabled = true;
			specifier.postingEnabled = true;
			specifier.routingEnabled = true;
			specifier.serverChannelEnabled = true;
			specifier.objectReplicationEnabled = true;
			_loungeGroup = new NetworkGroupManager(this, specifier.toString());
		}
		
		public function createRoomGroup():void
		{
			var specifier:GroupSpecifier = new GroupSpecifier("room");
			specifier.ipMulticastMemberUpdatesEnabled = true;
			specifier.multicastEnabled = true;
			specifier.postingEnabled = true;
			specifier.routingEnabled = true;
			specifier.serverChannelEnabled = true;
			specifier.objectReplicationEnabled = true;
			specifier.makeUnique();
			connectRoomGroup(specifier.toString());
		}
		
		public function connectRoomGroup(specifier:String):void
		{
			if (_roomGroup != null) return;
			_roomGroup = new NetworkGroupManager(this, specifier);
			selfControl = new NetworkSelfControl(this);
		}
		
		public function disconnectRoomGroup():void
		{
			for (var i:int = 0; i < controlStream.length; i++)
			{
				if (controlStream[i] == null) continue;
				controlStream[i].dispose();
				controlStream[i] = null;
			}
			if (selfControl != null)
			{
				selfControl.dispose();
				selfControl = null;
			}
			if (_roomGroup != null)
			{
				_roomGroup.dispose();
				_roomGroup = null;
			}
		}
		
		public function getSelfGameControl(control:GameControl):NetworkSelfControl
		{
			selfControl.setControl(control);
			return selfControl;
		}
		
		public function getRemoteGameControl(index:int, peerID:String):NetworkRemoteControl
		{
			if (_roomGroup == null) return null;
			if (controlStream[index] == null)
			{
				controlStream[index] = new NetworkRemoteControl(this, selfControl, peerID);
			}
			else if (controlStream[index].peerID != peerID)
			{
				controlStream[index].dispose();
				controlStream[index] = new NetworkRemoteControl(this, selfControl, peerID);
			}
			return controlStream[index];
		}
		
		public function createNetGroup(specifier:String):NetGroup
		{
			return new NetGroup(netConnection, specifier);
		}
		
		public function createNetStream(peerID:String):NetStream
		{
			return new NetStream(netConnection, peerID);
		}
		
		public function get isConnected():Boolean
		{
			return _isConnected;
		}
		
		public function get selfPeerID():String
		{
			if (!isConnected) return null;
			return netConnection.nearID;
		}
		
		public function get unconnectedPeerStreams():Array
		{
			return netConnection.unconnectedPeerStreams;
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
			return _roomGroup.specifier;
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
					_isConnected = false;
					dispatchEvent(new KuzurisEvent(KuzurisEvent.connectClosed));
					break;
				case "NetConnection.Connect.IdleTimeout":
					dispatchEvent(new KuzurisEvent(KuzurisEvent.connectIdleTimeout));
					break;
				case "NetConnection.Connect.NetworkChange":
					break;
				case "NetConnection.Connect.Success":
					_isConnected = true;
					connectLoungeGroup();
					break;
				case "NetGroup.Connect.Failed":
					if (_loungeGroup.containGroup(e.info.group))
					{
						dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.loungeConnectFailed, "ラウンジに接続できませんでした。\nしばらくしてから再度接続して下さい。"));
					}
					else if (_roomGroup.containGroup(e.info.group))
					{
						dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.roomConnectFailed, "ルームに接続できませんでした。"));
					}
					break;
				case "NetGroup.Connect.Rejected":
					if (_loungeGroup.containGroup(e.info.group))
					{
						dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.loungeConnectFailed, "ラウンジへの接続が拒否されました。\nお手数ですが、製作者にお問い合わせ下さい。"));
					}
					else if (_roomGroup.containGroup(e.info.group))
					{
						dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.roomConnectFailed, "ルームへの接続が拒否されました。"));
					}
					break;
				case "NetGroup.Connect.Success":
					if (_loungeGroup.containGroup(e.info.group))
					{
						dispatchEvent(new KuzurisEvent(KuzurisEvent.loungeConnectSuccess));
					}
					else if (_roomGroup.containGroup(e.info.group))
					{
						dispatchEvent(new KuzurisEvent(KuzurisEvent.roomConnectSuccess));
					}
					break;
			}
			dispatchEvent(e);
			Main.appendLog(e.info.code);
		}
		
		private function asyncErrorListener(e:AsyncErrorEvent):void
		{
			Main.appendLog(e.text, e.error, e.errorID);
			dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.asyncError, "Flash playerにエラーが発生しました。\n\n" + e.text));
		}
		
		private function ioErrorLintener(e:IOErrorEvent):void
		{
			Main.appendLog(e.text, e.errorID);
			dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.ioError, "インターネット接続にエラーがあります。\n接続状況を確認してから再度接続して下さい。\n\n" + e.text));
		}
	}
}