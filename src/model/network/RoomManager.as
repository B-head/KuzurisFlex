package model.network {
	import events.*;
	import flash.events.*;
	import flash.utils.*;
	import model.*;
	import model.ai.*;
	import mx.collections.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="agreePassword", type="events.KuzurisEvent")]
	[Event(name="roomConnectSuccess", type="events.KuzurisEvent")]
	[Event(name="differPassword", type="events.KuzurisErrorEvent")]
	[Event(name="roomConnectFailed", type="events.KuzurisErrorEvent")]
	public class RoomManager extends EventDispatcher
	{
		private static const collectRoom:String = "collectRoom";
		private static const offerRoom:String = "offerRoom";
		private static const connectRoom:String = "connectRoom";
		private static const permitRoom:String = "permitRoom";
		private static const rejectRoom:String = "rejectRoom";
		private static const playerUpdate:String = "playerUpdate";
		
		private var networkManager:NetworkManager;
		private var loungeGroup:NetworkGroupManager;
		private var roomPassword:String;
		private var playerIndex:int;
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
			selfPlayerInfo = new PlayerInformation(networkManager.selfPeerID, "", false);
			selfInput = SharedObjectHelper.input;
			this.networkManager = networkManager;
			networkManager.addEventListener(KuzurisEvent.roomConnectSuccess, roomConnectSuccessListener);
			networkManager.addEventListener(KuzurisErrorEvent.roomConnectFailed, roomConnectFailedListener);
			loungeGroup = networkManager.loungeGroup;
			loungeGroup.addEventListener(KuzurisEvent.firstConnectNeighbor, connectNeighborListener);
			loungeGroup.addEventListener(KuzurisEvent.announceClock, announceClockListener);
			loungeGroup.addEventListener(UpdateUserEvent.removedUser, removedUserListener);
			loungeGroup.addEventListener(NotifyEvent.notify, notifyListener);
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
		
		public function quickEnterRoom(multi:Boolean):void
		{
			var quicks:Vector.<RoomInformation> = getQuickRooms();
			for (var i:int = 0; i < quicks.length; i++)
			{
				var q:RoomInformation = quicks[i];
				if (q.multi != multi) continue;
				var playerIndex:int = q.getEnterableIndex();
				if (playerIndex == -1) continue;
				selfEnterRoom(q, playerIndex);
				return;
			}
			var name:String = makeDefaultName(true);
			createRoom(name, true, multi);
		}
		
		public function createRoom(name:String, quick:Boolean, multi:Boolean, password:String = ""):void
		{
			networkManager.createRoomGroup();
			var room:RoomInformation = new RoomInformation(name, quick, multi);
			rooms.addItem(room);
			currentRoom = room;
			playerIndex = 0;
			roomPassword = password;
			dispatchEvent(new KuzurisEvent(KuzurisEvent.roomConnectSuccess));
		}
		
		public function selfEnterRoom(room:RoomInformation, index:int, password:String = ""):void
		{
			currentRoom = room;
			playerIndex = index;
			loungeGroup.post(connectRoom, { room:currentRoom, player:selfPlayerInfo, password:password } );
		}
		
		private function selfConnectedEnterRoom():void
		{
			selfPlayerInfo.currentRoomID = currentRoom.id;
			if (playerIndex >= 0) 
			{	
				selfEnterBattle(playerIndex);
			}
			else
			{
				selfPlayerInfo.currentBattleIndex = RoomInformation.watchIndex;
				currentRoom.updatePlayer(selfPlayerInfo);
				loungeGroup.post(playerUpdate, { room:currentRoom, player:selfPlayerInfo } );
			}
		}
		
		public function selfLeaveRoom():void
		{
			networkManager.disconnectRoomGroup();
			selfPlayerInfo.currentRoomID = null;
			currentRoom.updatePlayer(selfPlayerInfo);
			loungeGroup.post(playerUpdate, { room:currentRoom, player:selfPlayerInfo } );
			if (currentRoom.isEmpty()) removeRoom(currentRoom);
			currentRoom = null;
		}
		
		public function selfEnterBattle(index:int):void
		{
			selfPlayerInfo.currentBattleIndex = index;
			currentRoom.updatePlayer(selfPlayerInfo);
			loungeGroup.post(playerUpdate, { room:currentRoom, player:selfPlayerInfo } );
		}
		
		public function selfLeaveBattle():void
		{
			selfPlayerInfo.currentBattleIndex = RoomInformation.watchIndex;
			currentRoom.updatePlayer(selfPlayerInfo);
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
			for (var i:int = 0; i < rooms.length; i++)
			{
				var r:RoomInformation = rooms[i];
				if (r.name == name) return r;
			}
			return null;
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
		
		private function connectNeighborListener(e:KuzurisEvent):void
		{
			loungeGroup.post(collectRoom, {} );
		}
		
		private function announceClockListener(e:KuzurisEvent):void
		{
			loungeGroup.post(playerUpdate, { room:currentRoom, player:selfPlayerInfo } );
		}
		
		private function removedUserListener(e:UpdateUserEvent):void
		{
			var p:PlayerInformation = new PlayerInformation(e.peerID);
			for (var i:int = 0; i < rooms.length; i++)
			{
				var r:RoomInformation = rooms[i];
				r.updatePlayer(p);
				if (r.isEmpty()) removeRoom(r);
			}
		}
		
		private function notifyListener(e:NotifyEvent):void
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
					networkManager.connectRoomGroup(e.message.obj.specifier);
					break;
				case rejectRoom:
					if (currentRoom != temp) break;
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.differPassword, "パスワードが違います。"));
					currentRoom == null;
					break;
				case playerUpdate:
					if (temp == null)
					{	
						if (room == null) break;
						rooms.addItem(room);
						temp = room;
					}
					temp.updatePlayer(player);
					if (temp.isEmpty()) removeRoom(temp);
					break;
			}
		}
	}

}