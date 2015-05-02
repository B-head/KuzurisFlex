package network {
	import ai.*;
	import common.*;
	import events.*;
	import flash.events.*;
	import flash.utils.*;
	import model.*;
	import mx.collections.*;
	import presentation.*;
	import view.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="agreePassword", type="events.KuzurisEvent")]
	[Event(name="roomConnectSuccess", type="events.KuzurisEvent")]
	[Event(name="differPassword", type="events.KuzurisErrorEvent")]
	[Event(name="roomConnectFailed", type="events.KuzurisErrorEvent")]
	public class RoomManager extends EventDispatcherEX
	{
		private static const collectRoom:String = "collectRoom";
		private static const offerRoom:String = "offerRoom";
		private static const requestConnectRoom:String = "requestConnectRoom";
		private static const permitConnectRoom:String = "permitConnectRoom";
		private static const rejectConnectRoom:String = "rejectConnectRoom";
		private static const playerUpdate:String = "playerUpdate";
		
		private var networkManager:NetworkManager;
		private var loungeGroup:NetworkGroupManager;
		private var timeoutTimer:Timer;
		private var roomPassword:String;
		private var filterGameMode:String;
		[Bindable]
		public var rooms:ArrayCollection;
		[Bindable]
		public var currentRoom:RoomInformation;
		[Bindable]
		public var selfPlayerInfo:PlayerInformation;
		[Bindable]
		public var selfInput:UserInput;
		
		private const timeoutPeriod:int = 10000;
		
		public function RoomManager(networkManager:NetworkManager) 
		{
			rooms = new ArrayCollection(new Array());
			rooms.filterFunction = roomFilterFunction;
			selfPlayerInfo = new PlayerInformation(networkManager.selfPeerID, "", false);
			selfInput = SharedObjectHelper.input;
			timeoutTimer = new Timer(timeoutPeriod, 1);
			timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timeoutListener);
			this.networkManager = networkManager;
			networkManager.addTerget(KuzurisEvent.roomConnectSuccess, roomConnectSuccessListener);
			networkManager.addTerget(KuzurisErrorEvent.roomConnectFailed, roomConnectFailedListener);
			loungeGroup = networkManager.loungeGroup;
			loungeGroup.addTerget(KuzurisEvent.firstConnectNeighbor, connectNeighborListener);
			loungeGroup.addTerget(KuzurisEvent.announceClock, announceClockListener);
			loungeGroup.addTerget(UpdateUserEvent.removedUser, removedUserListener);
			loungeGroup.addTerget(NotifyEvent.notify, notifyListener);
		}
		
		public function dispose():void
		{
			networkManager.removeTerget(KuzurisEvent.roomConnectSuccess, roomConnectSuccessListener);
			networkManager.removeTerget(KuzurisErrorEvent.roomConnectFailed, roomConnectFailedListener);
			loungeGroup.removeTerget(KuzurisEvent.firstConnectNeighbor, connectNeighborListener);
			loungeGroup.removeTerget(KuzurisEvent.announceClock, announceClockListener);
			loungeGroup.removeTerget(UpdateUserEvent.removedUser, removedUserListener);
			loungeGroup.removeTerget(NotifyEvent.notify, notifyListener);
			removeAll();
		}
		
		public function setRoomFilter(gameModeIndex:int):void
		{
			filterGameMode = GameSetting.indexToGameMode(gameModeIndex);
			rooms.refresh();
		}
		
		private function roomFilterFunction(item:RoomInformation):Boolean
		{
			return item.setting.gameMode == filterGameMode;
		}
		
		public function isHostSelfPlayer():Boolean
		{
			if (currentRoom == null) return false;
			return selfPlayerInfo.peerID == currentRoom.getHostPlayer().peerID;
		}
		
		public function hasCurrentRoom(room:RoomInformation):Boolean
		{
			if (currentRoom == null) return false;
			return currentRoom.id == room.id;
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
		
		public function quickEnterRoom(multi:Boolean, gameModeIndex:int):void
		{
			var quicks:Vector.<RoomInformation> = getQuickRooms();
			var gameMode:String = GameSetting.indexToGameMode(gameModeIndex);
			for (var i:int = 0; i < quicks.length; i++)
			{
				var q:RoomInformation = quicks[i];
				if (q.multi != multi) continue;
				if (q.setting.gameMode != gameMode) continue;
				var playerIndex:int = q.getEnterableIndex();
				if (playerIndex == -1) continue;
				selfEnterRoom(q, playerIndex);
				return;
			}
			var name:String = makeDefaultName(true);
			createRoom(name, true, multi, gameModeIndex);
		}
		
		public function createRoom(name:String, quick:Boolean, multi:Boolean, gameModeIndex:int, password:String = ""):void
		{
			networkManager.createRoomGroup();
			var setting:GameSetting = GameSetting.createBattleSetting(gameModeIndex);
			var room:RoomInformation = new RoomInformation(name, quick, multi, setting);
			rooms.addItem(room);
			currentRoom = room;
			roomPassword = password;
			selfConnectedEnterRoom(currentRoom, selfPlayerInfo, 0, 0);
		}
		
		public function selfEnterRoom(room:RoomInformation, battleIndex:int, password:String = ""):void
		{
			currentRoom = room;
			roomPassword = password;
			var host:PlayerInformation = currentRoom.getHostPlayer();
			loungeGroup.sendPeer(host.peerID, requestConnectRoom, { room:currentRoom, player:selfPlayerInfo, battleIndex:battleIndex, password:password } );
			timeoutTimer.reset();
			timeoutTimer.start();
		}
		
		private function selfConnectedEnterRoom(room:RoomInformation, player:PlayerInformation, hostPriority:int, battleIndex:int):void
		{
			if (!hasCurrentRoom(room) || player.peerID != selfPlayerInfo.peerID)
			{
				Main.appendLog("ignore connected");
				return;
			}
			timeoutTimer.stop();
			selfPlayerInfo.currentRoomID = currentRoom.id;
			selfPlayerInfo.hostPriority = hostPriority;
			selfPlayerInfo.currentBattleIndex = battleIndex;
			selfPlayerInfo.winCount = 0;
			if (battleIndex >= 0) 
			{	
				selfEnterBattle(battleIndex);
			}
			else
			{
				selfPlayerInfo.currentBattleIndex = RoomInformation.watchIndex;
				updatePlayer(selfPlayerInfo);
				loungeGroup.post(playerUpdate, { room:currentRoom, player:selfPlayerInfo } );
			}
		}
		
		private function requestConnectReply(room:RoomInformation, player:PlayerInformation, battleIndex:int, password:String):void
		{
			if (!hasCurrentRoom(room) || !isHostSelfPlayer())
			{
				var host:PlayerInformation = currentRoom.getHostPlayer();
				loungeGroup.sendPeer(host.peerID, requestConnectRoom, { room:currentRoom, player:player, battleIndex:battleIndex, password:password } );
				Main.appendLog("relay request connect");
				return;
			}
			if (password != roomPassword)
			{
				loungeGroup.sendPeer(player.peerID, rejectConnectRoom, { room:currentRoom } );
				return;
			}
			var hostPriority:int = currentRoom.getNextHostPriority();
			if (battleIndex >= 0 && currentRoom.entrant.getItemAt(battleIndex) != null)
			{
				battleIndex = currentRoom.getEnterableIndex();
			}
			player.currentRoomID = currentRoom.id;
			player.hostPriority = hostPriority;
			player.currentBattleIndex = battleIndex;
			selfPlayerInfo.winCount = 0;
			updatePlayer(player);
			loungeGroup.sendPeer(player.peerID, permitConnectRoom, { room:currentRoom, player:player, hostPriority:hostPriority, battleIndex:battleIndex, specifier:networkManager.roomGroupSpecifier });
		}
		
		public function selfLeaveRoom():void
		{
			networkManager.disconnectRoomGroup();
			selfPlayerInfo.currentRoomID = null;
			currentRoom.updatePlayer(selfPlayerInfo);
			loungeGroup.post(playerUpdate, { room:currentRoom, player:selfPlayerInfo } );
			updatePlayer(selfPlayerInfo);
			currentRoom = null;
		}
		
		public function selfEnterBattle(index:int):void
		{
			selfPlayerInfo.currentBattleIndex = index;
			updatePlayer(selfPlayerInfo);
			loungeGroup.post(playerUpdate, { room:currentRoom, player:selfPlayerInfo } );
		}
		
		public function selfLeaveBattle():void
		{
			selfPlayerInfo.currentBattleIndex = RoomInformation.watchIndex;
			updatePlayer(selfPlayerInfo);
			loungeGroup.post(playerUpdate, { room:currentRoom, player:selfPlayerInfo } );
		}
		
		public function createGameManager():NetworkGameManager
		{
			var maxPlayer:int = currentRoom.entrant.length;
			return new NetworkGameManager(maxPlayer, networkManager, this);
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
		
		private function findRoom(room:RoomInformation):RoomInformation
		{
			if (room == null) return null;
			var source:Array = rooms.source;
			for (var i:int = 0; i < source.length; i++)
			{
				var r:RoomInformation = source[i];
				if (r.id == room.id) return r;
			}
			return null;
		}
		
		//TODO パフォーマンス改善が必須。
		private function updatePlayer(player:PlayerInformation):void
		{
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
		
		private function roomConnectSuccessListener(e:KuzurisEvent):void
		{
			dispatchEvent(e);
		}
		
		private function roomConnectFailedListener(e:KuzurisErrorEvent):void
		{
			selfLeaveRoom()
			dispatchEvent(e);
		}
		
		private function connectNeighborListener(e:KuzurisEvent):void
		{
			loungeGroup.post(collectRoom);
		}
		
		private function announceClockListener(e:KuzurisEvent):void
		{
			loungeGroup.post(playerUpdate, { room:currentRoom, player:selfPlayerInfo } );
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
		
		private function timeoutListener(e:TimerEvent):void
		{
			selfLeaveRoom()
			dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.roomConnectFailed, "ルームへの接続がタイムアウトしました。"));
		}
		
		private function removedUserListener(e:UpdateUserEvent):void
		{
			var player:PlayerInformation = new PlayerInformation(e.peerID);
			updatePlayer(player);
		}
		
		private function notifyListener(e:NotifyEvent):void
		{
			var player:PlayerInformation = e.message.obj.player as PlayerInformation;
			var room:RoomInformation = e.message.obj.room as RoomInformation;
			var temp:RoomInformation = findRoom(room);
			switch (e.message.type)
			{
				case collectRoom:
					if (currentRoom != null) loungeGroup.sendPeer(e.message.peerID, offerRoom, { room:currentRoom } );
					break;
				case offerRoom:
					if (temp == null)
					{
						rooms.addItem(room);
					}
					break;
				case requestConnectRoom:
					requestConnectReply(e.message.obj.room, e.message.obj.player, e.message.obj.battleIndex, e.message.obj.password);
					break;
				case permitConnectRoom:
					dispatchEvent(new KuzurisEvent(KuzurisEvent.agreePassword));
					selfConnectedEnterRoom(e.message.obj.room, e.message.obj.player, e.message.obj.hostPriority, e.message.obj.battleIndex);
					networkManager.connectRoomGroup(e.message.obj.specifier);
					break;
				case rejectConnectRoom:
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.differPassword, "パスワードが違います。"));
					selfLeaveRoom()
					break;
				case playerUpdate:
					if (temp == null)
					{
						if (room == null) break;
						rooms.addItem(room);
						temp = room;
					}
					updatePlayer(player);
					break;
			}
		}
	}

}