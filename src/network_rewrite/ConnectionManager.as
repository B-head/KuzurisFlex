package network_rewrite 
{
	import common.*;
	import events.*;
	import flash.events.*;
	import flash.net.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="connectClosed", type="events.NetworkEvent")]
	[Event(name="idleTimeout", type="events.NetworkEvent")]
	[Event(name="networkChange", type="events.NetworkEvent")]
	[Event(name="connectSuccess", type="events.NetworkEvent")]
	[Event(name="connectFailed", type="events.NetworkErrorEvent")]
	[Event(name="connectRejected", type="events.NetworkErrorEvent")]
	[Event(name="asyncError", type="events.NetworkErrorEvent")]
	[Event(name="ioError", type="events.NetworkErrorEvent")]
	public class ConnectionManager extends EventDispatcherEX
	{
		private const ServerAddress:String = "rtmfp://p2p.rtmfp.net/";
		private const DeveloperKey:String = "89a898b4b7869bbd1232dabe-41cb09d77e52";
		
		private var netConnection:NetConnection;
		private var _isConnected:Boolean;
		
		public function ConnectionManager()
		{
			return;
		}
		
		public function connect():void
		{
			netConnection = new NetConnection();
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, netConnectionListener, false, 0, true);
			netConnection.addEventListener(IOErrorEvent.IO_ERROR, ioErrorLintener, false, 0, true);
			netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorListener, false, 0, true);
			netConnection.connect(ServerAddress + DeveloperKey);	
		}
		
		public function dispose():void
		{
			if (netConnection == null) return;
			netConnection.close();
			netConnection = null;
		}
		
		public function createNetGroup(specifier:String, listener:Function):NetGroup
		{
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, listener, false, 0, true);
			return new NetGroup(netConnection, specifier);
		}
		
		public function createNetStream(peerID:String, listener:Function):NetStream
		{
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, listener, false, 0, true);
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
			if (!isConnected) return null;
			return netConnection.unconnectedPeerStreams;
		}
		
		private function netConnectionListener(e:NetStatusEvent):void
		{
			Debug.trace(e.info.code);
			switch (e.info.code)
			{
				case "NetConnection.Connect.AppShutdown":
					dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.connectFailed, "サーバーがシャットダウンしているため、接続できませんでした。"));
					break;
				case "NetConnection.Connect.Failed":
					dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.connectFailed, "サーバーに接続できませんでした。\nしばらくしてから再度接続して下さい。"));
					break;
				case "NetConnection.Connect.InvalidApp":
					dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.connectFailed, "崩リスのバグにより接続できませんでした。\nお手数ですが、製作者にお問い合わせ下さい。"));
					break;
				case "NetConnection.Connect.Rejected":
					dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.connectRejected, "P2P接続が拒否されました。\nP2P接続を許可して下さい。"));
					break;
				case "NetConnection.Connect.Closed":
					_isConnected = false;
					dispatchEvent(new NetworkEvent(NetworkEvent.connectClosed));
					break;
				case "NetConnection.Connect.IdleTimeout":
					dispatchEvent(new NetworkEvent(NetworkEvent.idleTimeout));
					break;
				case "NetConnection.Connect.NetworkChange":
					dispatchEvent(new NetworkEvent(NetworkEvent.networkChange));
					break;
				case "NetConnection.Connect.Success":
					_isConnected = true;
					dispatchEvent(new NetworkEvent(NetworkEvent.connectSuccess));
					break;
			}
		}
		
		private function asyncErrorListener(e:AsyncErrorEvent):void
		{
			Debug.trace(e.text, e.error, e.errorID);
			dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.asyncError, "Flash playerで非同期エラーが発生しました。\n\n" + e.text));
		}
		
		private function ioErrorLintener(e:IOErrorEvent):void
		{
			Debug.trace(e.text, e.errorID);
			dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.ioError, "インターネット接続にエラーがあります。\n接続状況を確認してから再度接続して下さい。\n\n" + e.text));
		}
		
	}

}