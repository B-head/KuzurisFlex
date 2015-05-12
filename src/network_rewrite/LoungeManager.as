package network_rewrite 
{
	import common.*;
	import events.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import model.*;
	import mx.collections.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="connectClosed", type="events.NetworkEvent")]
	[Event(name="connectSuccess", type="events.NetworkEvent")]
	[Event(name="disposed", type="events.NetworkEvent")]
	[Event(name="connectFailed", type="events.NetworkErrorEvent")]
	[Event(name="connectRejected", type="events.NetworkErrorEvent")]
	public class LoungeManager extends EventDispatcherEX 
	{
		private var connectionManager:ConnectionManager;
		private var groupManager:GroupManager;
		private var roomManager:RoomManager;
		[Bindable]
		public var players:ArrayCollection;
		[Bindable]
		public var rooms:ArrayCollection;
		[Bindable]
		public var selfPlayerInfo:PlayerInformation;
		
		private const updatePlayerInfo:String = "updatePlayerInfo";
		
		public function LoungeManager(connectionManager:ConnectionManager, selfPlayerInfo:PlayerInformation) 
		{
			this.connectionManager = connectionManager;
		}
		
		public function connect():void
		{
			this.selfPlayerInfo = selfPlayerInfo;
			groupManager = new GroupManager(connectionManager, makeSpecifier());
			groupManager.addTerget(NetworkEvent.connectSuccess, connectSuccessListener);
			groupManager.addTerget(NetworkEvent.connectClosed, connectClosedListener);
			groupManager.addTerget(NetworkErrorEvent.connectFailed, connectFailedListener);
			groupManager.addTerget(NetworkErrorEvent.connectRejected, connectRejectedListener);
			groupManager.addTerget(KuzurisEvent.firstConnectNeighbor, firstConnectNeighborListener);
			groupManager.addTerget(KuzurisEvent.announceClock, announceClockListener);
			groupManager.addTerget(UpdateUserEvent.addedUser, addedUserListener);
			groupManager.addTerget(UpdateUserEvent.removedUser, removedUserListener);
			groupManager.addTerget(NotifyEvent.notify, notifyListener);
			groupManager.connect();	
		}
		
		public function dispose():void
		{
			groupManager.dispose();
			if (roomManager != null)
			{
				roomManager.dispose();
			}
			dispatchEvent(new KuzurisEvent(KuzurisEvent.disposed));
		}
		
		private function makeSpecifier():GroupSpecifier
		{
			var specifier:GroupSpecifier = new GroupSpecifier("lounge");
			specifier.ipMulticastMemberUpdatesEnabled = true;
			specifier.multicastEnabled = true;
			specifier.postingEnabled = true;
			specifier.routingEnabled = true;
			specifier.serverChannelEnabled = true;
			specifier.objectReplicationEnabled = true;
			return specifier;
		}
			
		public function makeDefaultName(quick:Boolean):String
		{
			var name:String;
			var room:RoomInformation;
			var index:int = 1;
			do
			{
				name = (quick ? "おまかせルーム" : "ルーム") + String(index++);
				room = findRoomName(name);
			}
			while (room != null)
			return name;
		}
		
		public function quickEnterRoom(multi:Boolean, gameModeIndex:int):RoomManager
		{
			var quicks:Vector.<RoomInformation> = getQuickRooms();
			var gameMode:String = GameSetting.indexToGameMode(gameModeIndex);
			for (var i:int = 0; i < quicks.length; i++)
			{
				var q:RoomInformation = quicks[i];
				if (q.multi != multi) continue;
				if (q.setting.gameMode != gameMode) continue;
				var battleIndex:int = q.getEnterableIndex();
				if (battleIndex == -1) continue;
				return createRoomManager(q, battleIndex);
			}
			var name:String = makeDefaultName(true);
			return createRoom(name, true, multi, gameModeIndex);
		}
		
		public function createRoom(name:String, quick:Boolean, multi:Boolean, gameModeIndex:int, password:String = ""):RoomManager
		{
			networkManager.createRoomGroup();
			var setting:GameSetting = GameSetting.createBattleSetting(gameModeIndex);
			var room:RoomInformation = new RoomInformation(name, quick, multi, setting);
			rooms.addItem(room);
			return createRoomManager(room, 0, password);
		}
		
		public function createRoomManager(room:RoomInformation, battleIndex:int, password:String = ""):RoomManager
		{
			roomManager = new RoomManager(connectionManager, selfPlayerInfo, room, battleIndex, password);
			return roomManager;
		}
		
		//TODO パフォーマンス改善が必須。
		private function updatePlayer(player:PlayerInformation):void
		{
			if (player == null) return;
			var source:Array = rooms.source;
			for (var i:int = 0; i < source.length; i++)
			{
				var r:RoomInformation = source[i];
				r.updatePlayer(player);
				r.lastUpdateTime = getTimer();
				if (r.isEmpty())
				{
					source.splice(i, 1);
					i--;
				}
			}
			rooms.refresh();
		}
		
		private function getPlayer(dyPlayer:*):PlayerInformation
		{
			var player:PlayerInformation = dyPlayer as PlayerInformation;
			if (player == null) return null;
			var source:Array = player.source;
			for (var i:int = 0; i < source.length; i++)
			{
				var p:PlayerInformation = source[i];
				if (p.peerID== player.peerID) return p;
			}
			return null;
		}
		
		private function getRoom(dyRoom:*):RoomInformation
		{
			var room:RoomInformation = dyRoom as RoomInformation;
			if (room == null) return null;
			var source:Array = rooms.source;
			for (var i:int = 0; i < source.length; i++)
			{
				var r:RoomInformation = source[i];
				if (r.id == room.id) return r;
			}
			return null;
		}
		
		private function getQuickRooms():Vector.<RoomInformation>
		{
			var ret:Vector.<RoomInformation> = new Vector.<RoomInformation>();
			for (var i:int = 0; i < rooms.length; i++)
			{
				if (rooms[i].quick) ret.push(rooms[i]);
			}
			return ret;
		}
		
		private function findRoomName(name:String):RoomInformation
		{
			var source:Array = rooms.source;
			for (var i:int = 0; i < source.length; i++)
			{
				var r:RoomInformation = source[i];
				if (r.name == name) return r;
			}
			return null;
		}
		
		private function connectSuccessListener(e:KuzurisEvent):void
		{
			dispatchEvent(new NetworkEvent(NetworkEvent.connectSuccess));
		}
		
		private function connectClosedListener(e:KuzurisEvent):void
		{
			dispatchEvent(new NetworkEvent(NetworkEvent.connectClosed));
		}
		
		private function connectFailedListener(e:KuzurisErrorEvent):void
		{
			dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.connectFailed, "ラウンジに接続できませんでした。\nしばらくしてから再度接続して下さい。"));
		}
		
		private function connectRejectedListener(e:KuzurisErrorEvent):void
		{
			dispatchEvent(new NetworkErrorEvent(NetworkErrorEvent.connectRejected, "ラウンジへの接続が拒否されました。\nお手数ですが、製作者にお問い合わせ下さい。"));
		}
		
		private function firstConnectNeighborListener(e:KuzurisEvent):void
		{
			groupManager.post(updatePlayerInfo, { room:currentRoom, player:selfPlayerInfo } );
		}
		
		private function announceClockListener(e:KuzurisEvent):void
		{
			groupManager.post(updatePlayerInfo, { room:currentRoom, player:selfPlayerInfo } );
			var currentTime:int = getTimer();
			var source:Array = rooms.source;
			for (var i:int = 0; i < source.length; i++)
			{
				var r:RoomInformation = source[i];
				if (r.lastUpdateTime + timeoutPeriod < currentTime)
				{
					source.splice(i, 1);
					i--;
				}
			}
			rooms.refresh();
		}
		
		private function addedUserListener(e:UpdateUserEvent):void
		{
			groupManager.post(updatePlayerInfo, { room:currentRoom, player:selfPlayerInfo } );
		}
		
		private function removedUserListener(e:UpdateUserEvent):void
		{
			var player:PlayerInformation = new PlayerInformation(e.peerID);
			updatePlayer(player);
		}
		
		private function notifyListener(e:NotifyEvent):void
		{
			var player:PlayerInformation = getPlayer(e.message.obj.player);
			var room:RoomInformation = getRoom(e.message.obj.room);
			switch (e.message.type)
			{
				case updatePlayerInfo:
					updatePlayer(player);
					break;
			}
		}
	}

}