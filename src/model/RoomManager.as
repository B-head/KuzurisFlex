package model 
{
	import events.*;
	import flash.events.*;
	import flash.utils.*;
	import model.ai.*;
	import mx.collections.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="agreePassword", type="events.KuzurisEvent")]
	[Event(name="roomConnectSuccess", type="events.KuzurisEvent")]
	[Event(name="playerUpdate", type="events.KuzurisEvent")]
	[Event(name="differPassword", type="events.KuzurisErrorEvent")]
	[Event(name="roomConnectFailed", type="events.KuzurisErrorEvent")]
	[Event(name="networkGameReady", type="events.NetworkGameReadyEvent")]
	public class RoomManager extends EventDispatcher
	{
		private static const collectRoom:String = "collectRoom";
		private static const offerRoom:String = "offerRoom";
		private static const connectRoom:String = "connectRoom";
		private static const permitRoom:String = "permitRoom";
		private static const rejectRoom:String = "rejectRoom";
		private static const enterRoom:String = "enterRoom";
		private static const leaveRoom:String = "leaveRoom";
		private static const enterBattle:String = "enterBattle";
		private static const leaveBattle:String = "leaveBattle";
		
		private var networkManager:NetworkManager;
		private var loungeGroup:NetworkGroupManager;
		private var roomGroup:NetworkGroupManager;
		private var roomPassword:String;
		private var gameManager:GameManager;
		private var selfPlayerIndex:int;
		private var syncTime:int;
		private var sendDelayTimes:Vector.<int>;
		[Bindable]
		public var rooms:ArrayCollection;
		[Bindable]
		public var currentRoom:RoomInformation;
		[Bindable]
		public var selfPlayerInfo:PlayerInformation;
		[Bindable]
		public var selfInput:UserInput;
		
		public function RoomManager(networkManager:NetworkManager) 
		{
			rooms = new ArrayCollection(new Array());
			selfPlayerInfo = new PlayerInformation();
			selfPlayerInfo.peerID = networkManager.selfPeerID;
			selfInput = SharedObjectHelper.input;
			this.networkManager = networkManager;
			networkManager.addEventListener(KuzurisEvent.roomConnectSuccess, roomConnectSuccessListener);
			networkManager.addEventListener(KuzurisErrorEvent.roomConnectFailed, roomConnectFailedListener);
			loungeGroup = networkManager.loungeGroup;
			loungeGroup.addEventListener(KuzurisEvent.connectNeighbor, connectNeighborListener);
			loungeGroup.addEventListener(NotifyEvent.notify, loungeNotifyListener);
		}
			
		public function makeDefaultName():String
		{
			return "ルーム名";
		}
		
		public function createRoom(name:String, multi:Boolean, password:String):void
		{
			networkManager.createRoomGroup();
			roomGroup = networkManager.roomGroup;
			roomGroup.addEventListener(NotifyEvent.notify, roomNotifyListener);
			var room:RoomInformation = new RoomInformation(name, multi);
			room.enterBattle(selfPlayerInfo, 0);
			rooms.addItem(room);
			currentRoom = room;
			roomPassword = password;
			loungeGroup.post(enterRoom, { room:currentRoom, player:selfPlayerInfo } );
			loungeGroup.post(enterBattle, { room:currentRoom, player:selfPlayerInfo, index:0 } );
		}
		
		public function selfEnterRoom(room:RoomInformation, password:String):void
		{
			currentRoom = room;
			loungeGroup.post(connectRoom, { room:currentRoom, player:selfPlayerInfo, password:password } );
		}
		
		private function selfConnectingEnterRoom(specifier:String):void
		{
			networkManager.connectRoomGroup(specifier);
			roomGroup = networkManager.roomGroup;
			roomGroup.addEventListener(NotifyEvent.notify, roomNotifyListener);
		}
		
		private function selfConnectedEnterRoom():void
		{
			currentRoom.enterRoom(selfPlayerInfo);
			loungeGroup.post(enterRoom, { room:currentRoom, player:selfPlayerInfo } );
		}
		
		public function selfLeaveRoom():void
		{
			currentRoom.leaveRoom(selfPlayerInfo);
			loungeGroup.post(leaveRoom, { room:currentRoom, player:selfPlayerInfo } );
			networkManager.disconnectRoomGroup();
			roomGroup = null;
			if (currentRoom.isEmpty()) removeRoom(currentRoom);
			currentRoom = null;
			gameManager = null;
		}
		
		public function selfEnterBattle(index:int):void
		{
			currentRoom.enterBattle(selfPlayerInfo, index);
			setPlayers();
			loungeGroup.post(enterBattle, { room:currentRoom, player:selfPlayerInfo, index:index } );
			dispatchEvent(new KuzurisEvent(KuzurisEvent.playerUpdate));
		}
		
		public function selfLeaveBattle():void
		{
			currentRoom.leaveBattle(selfPlayerInfo);
			setPlayers();
			loungeGroup.post(leaveBattle, { room:currentRoom, player:selfPlayerInfo } );
			dispatchEvent(new KuzurisEvent(KuzurisEvent.playerUpdate));
		}
		
		public function createGameManager():GameManager
		{
			var maxPlayer:int = currentRoom.entrant.length;
			gameManager = new GameManager(maxPlayer);
			setPlayers();
			return gameManager;
		}
		
		private function setPlayers():void
		{
			if (gameManager == null) return;
			selfPlayerIndex = -1;
			var maxPlayer:int = currentRoom.entrant.length;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				var playerInfo:PlayerInformation = currentRoom.entrant.getItemAt(i) as PlayerInformation;
				var control:GameControl = createGameControl(playerInfo, i);
				gameManager.setPlayer(i, control);
			}
		}
		
		private function createGameControl(playerInfo:PlayerInformation, index:int):GameControl
		{
			if (playerInfo == null) return null;
			if (playerInfo == selfPlayerInfo)
			{
				selfPlayerIndex = index;
				//return new SendGameControl(selfInput, networkManager);
				return new SendGameControl(GameAIManager.createDefaultAIManager(), networkManager);
			}
			if (playerInfo.isAI) return GameAIManager.createDefaultAIManager();
			var ret:RemoteGameControl = networkManager.getRemoteGameControl(index, playerInfo.peerID);
			ret.addEventListener(KuzurisEvent.gameSync, createGameSyncListener(index));
			ret.addEventListener(KuzurisEvent.gameSyncReply, createGameSyncReplayListener(index));
			ret.addEventListener(NetworkGameReadyEvent.networkGameReady, networkGameReadyListener);
			return ret;
		}
		
		public function gameSync():void
		{
			syncTime = getTimer();
			sendDelayTimes = new Vector.<int>(currentRoom.entrant.length);
			sendDelayTimes[selfPlayerIndex] = int.MIN_VALUE;
			networkManager.sendSync();
		}
		
		[Bindable(event="playerUpdate")]
		public function isEnter():Boolean
		{
			return currentRoom.entrant.getItemIndex(selfPlayerInfo) >= 0;
		}
		
		[Bindable(event="playerUpdate")]
		public function isStand():Boolean
		{
			var count:int;
			var maxPlayer:int = currentRoom.entrant.length;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (currentRoom.entrant[i] != null) count++;
			}
			return count <= 1;
		}
		
		[Bindable(event="playerUpdate")]
		public function transPlayerIndex(index:int):int
		{
			if (selfPlayerIndex == -1) return index;
			if (index == selfPlayerIndex) return 0;
			if (index < selfPlayerIndex) return index + 1;
			return index;
		}
		
		[Bindable(event="playerUpdate")]
		public function getPlayerInfo(index:int):PlayerInformation
		{
			return currentRoom.entrant.getItemAt(index) as PlayerInformation;
		}
		
		[Bindable(event="playerUpdate")]
		public function transFlip(flip:Boolean):Boolean
		{
			if (selfPlayerIndex == 0)
			{
				return flip;
			}
			else
			{
				return !flip;
			}
		}
		
		private function findRoom(room:RoomInformation):RoomInformation
		{
			if (room == null) return null;
			for (var i:int = 0; i < rooms.length; i++)
			{
				var r:RoomInformation = rooms[i];
				if (r.id == room.id) return r;
			}
			return null;
		}
		
		private function removeRoom(room:RoomInformation):void
		{
			var i:int = rooms.getItemIndex(room);
			rooms.removeItemAt(i);
		}
		
		private function connectNeighborListener(e:KuzurisEvent):void
		{
			loungeGroup.post(collectRoom, {} );
		}
		
		private function roomConnectSuccessListener(e:KuzurisEvent):void
		{
			selfConnectedEnterRoom();
			dispatchEvent(e);
		}
		
		private function roomConnectFailedListener(e:KuzurisErrorEvent):void
		{
			currentRoom = null;
			dispatchEvent(e);
		}
		
		private function createGameSyncListener(playerIndex:int):Function
		{
			return function(e:KuzurisEvent):void
			{
				sendDelayTimes = null;
				networkManager.sendSyncReply();
			}
		}
		
		private function createGameSyncReplayListener(playerIndex:int):Function
		{
			return function(e:KuzurisEvent):void
			{
				if (sendDelayTimes == null) return;
				sendDelayTimes[playerIndex] = (getTimer() - syncTime) / 2;
				var maxPlayer:int = currentRoom.entrant.length;
				for (var i:int = 0; i < maxPlayer; i++)
				{
					if (sendDelayTimes[i] == 0) return;
				}
				var seed:XorShift128 = new XorShift128();
				seed.RandomSeed();
				for (i = 0; i < maxPlayer; i++)
				{
					if (i == selfPlayerIndex)
					{
						networkManager.sendReady(-1, null, seed, 120);
						dispatchEvent(new NetworkGameReadyEvent(NetworkGameReadyEvent.networkGameReady, i, null, seed, 120));
					}
					else
					{
						var delay:int = 120 - sendDelayTimes[i] * 60 / 1000;
						networkManager.sendReady(playerIndex, null, seed, delay);
					}
				}
			}
		}
		
		private function networkGameReadyListener(e:NetworkGameReadyEvent):void
		{
			if (e.playerIndex != selfPlayerIndex) return;
			dispatchEvent(e);
		}
		
		private function loungeNotifyListener(e:NotifyEvent):void
		{
			var player:PlayerInformation = e.message.obj.player as PlayerInformation;
			var room:RoomInformation = e.message.obj.room as RoomInformation;
			var temp:RoomInformation = findRoom(room);
			switch (e.message.type)
			{
				case collectRoom:
					if (currentRoom != null) loungeGroup.post(offerRoom, { room:currentRoom } );
					break;
				case offerRoom:
					if (temp == null) rooms.addItem(room);
					break;
				case connectRoom:
					if (currentRoom != temp) break;
					loungeGroup.post(permitRoom, { room:currentRoom, specifier:networkManager.roomGroupSpecifier });
					break;
				case permitRoom:
					if (currentRoom != temp) break;
					dispatchEvent(new KuzurisEvent(KuzurisEvent.agreePassword));
					selfConnectingEnterRoom(e.message.obj.specifier);
					break;
				case rejectRoom:
					if (currentRoom != temp) break;
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.differPassword, "パスワードが違います。"));
					currentRoom == null;
					break;
				case enterRoom:
					if (temp == null)
					{	
						rooms.addItem(room);
						temp = room;
					}
					temp.enterRoom(player);
					dispatchEvent(new KuzurisEvent(KuzurisEvent.playerUpdate));
					break;
				case leaveRoom:
					if (temp == null)
					{	
						rooms.addItem(room);
						temp = room;
					}
					temp.leaveRoom(player);
					if (temp.isEmpty()) removeRoom(temp);
					dispatchEvent(new KuzurisEvent(KuzurisEvent.playerUpdate));
					break;
				case enterBattle:
					if (temp == null)
					{	
						rooms.addItem(room);
						temp = room;
					}
					temp.enterBattle(player, e.message.obj.index);
					if(temp == currentRoom) setPlayers();
					dispatchEvent(new KuzurisEvent(KuzurisEvent.playerUpdate));
					break;
				case leaveBattle:
					if (temp == null)
					{	
						rooms.addItem(room);
						temp = room;
					}
					temp.leaveBattle(player);
					if(temp == currentRoom) setPlayers();
					dispatchEvent(new KuzurisEvent(KuzurisEvent.playerUpdate));
					break;
			}
		}
		
		private function roomNotifyListener(e:NotifyEvent):void
		{
		}
	}

}