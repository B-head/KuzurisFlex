package model.network {
	import events.*;
	import flash.utils.*;
	import model.*;
	import model.ai.*;
	import mx.events.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="playerUpdate", type="events.KuzurisEvent")]
	[Event(name="networkGameReady", type="events.NetworkGameReadyEvent")]
	public class NetworkGameManager extends GameManager 
	{
		private var networkManager:NetworkManager;
		private var roomManager:RoomManager;
		private var roomGroup:NetworkGroupManager;
		private var selfControl:NetworkSelfControl;
		private var currentRoom:RoomInformation;
		private var selfPlayerInfo:PlayerInformation;
		private var selfPlayerIndex:int;
		private var syncTime:int;
		private var sendDelayTimes:Vector.<int>;
		
		public function NetworkGameManager(maxPlayer:int, networkManager:NetworkManager, roomManager:RoomManager) 
		{
			super(maxPlayer);
			this.networkManager = networkManager;
			this.roomManager = roomManager;
			roomGroup = networkManager.roomGroup;
			//selfControl = networkManager.getSelfGameControl(roomManager.selfInput);
			selfControl = networkManager.getSelfGameControl(GameAIManager.createDefaultAI());
			currentRoom = roomManager.currentRoom;
			selfPlayerInfo = roomManager.selfPlayerInfo;
			roomGroup.addEventListener(KuzurisEvent.disposed, disposedListener);
			currentRoom.entrant.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeListener);
			setPlayers();
		}
		
		private function setPlayers():void
		{
			selfPlayerIndex = -1;
			var maxPlayer:int = currentRoom.entrant.length;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				var playerInfo:PlayerInformation = currentRoom.entrant.getItemAt(i) as PlayerInformation;
				var control:GameControl = createGameControl(playerInfo, i);
				if(control == selfControl) selfPlayerIndex = i;
				setPlayer(i, control);
			}
			dispatchEvent(new KuzurisEvent(KuzurisEvent.playerUpdate));
			if (isExecution()) checkGameEnd();
		}
		
		private function createGameControl(playerInfo:PlayerInformation, index:int):GameControl
		{
			if (playerInfo == null) return null;
			if (playerInfo == selfPlayerInfo) return selfControl;
			if (playerInfo.isAI) return GameAIManager.createDefaultAI();
			var ret:NetworkRemoteControl = networkManager.getRemoteGameControl(index, playerInfo.peerID);
			if (ret == null) return null;
			if (!ret.hasEventListener(NetworkGameReadyEvent.networkGameReady))
			{
				ret.addEventListener(KuzurisEvent.gameSync, createGameSyncListener(index));
				ret.addEventListener(KuzurisEvent.gameSyncReply, createGameSyncReplayListener(index));
				ret.addEventListener(NetworkGameReadyEvent.networkGameReady, networkGameReadyListener);
				ret.addEventListener(KuzurisErrorEvent.streamDrop, createStreamDropListener(index));
			}
			return ret;
		}
		
		[Bindable(event="playerUpdate")]
		public function isEnter():Boolean
		{
			return currentRoom.entrant.getItemIndex(selfPlayerInfo) >= 0;
		}
		
		[Bindable(event="playerUpdate")]
		public function isStand():Boolean
		{
			if (isExecution())
			{
				return isGameOver(selfPlayerIndex);
			}
			var count:int;
			var maxPlayer:int = currentRoom.entrant.length;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (currentRoom.entrant.getItemAt(i) != null) count++;
			}
			return count <= 1;
		}
		
		[Bindable(event="playerUpdate")]
		public function transPlayerIndex(index:int):int
		{
			if (selfPlayerIndex == -1) return index;
			if (index == 0) return selfPlayerIndex;
			if (index <= selfPlayerIndex) return index - 1;
			return index;
		}
		
		[Bindable(event="playerUpdate")]
		public function getPlayerInfo(index:int):PlayerInformation
		{
			return currentRoom.entrant.getItemAt(index) as PlayerInformation;
		}
		
		[Bindable(event="playerUpdate")]
		public function isIndexEmpty(index:int):Boolean
		{
			return currentRoom.entrant.getItemAt(index) == null;
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
		
		public function gameSync():void
		{
			syncTime = getTimer();
			sendDelayTimes = new Vector.<int>(currentRoom.entrant.length);
			selfControl.sendSync();
		}
		
		private function collectionChangeListener(e:CollectionEvent):void
		{
			if (isExecution()) return;
			setPlayers();
		}
		
		private function disposedListener(e:KuzurisEvent):void
		{
			roomGroup.removeEventListener(KuzurisEvent.disposed, disposedListener);
			currentRoom.entrant.removeEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeListener);
		}
		
		private function createGameSyncListener(playerIndex:int):Function
		{
			return function(e:KuzurisEvent):void
			{
				sendDelayTimes = null;
				selfControl.sendSyncReply();
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
					if (i == selfPlayerIndex) continue;
					if (currentRoom.entrant.getItemAt(i) == null) continue;
					if (sendDelayTimes[i] == 0) return;
				}
				var seed:XorShift128 = new XorShift128();
				seed.RandomSeed();
				for (i = 0; i < maxPlayer; i++)
				{
					if (i == selfPlayerIndex)
					{
						selfControl.sendReady(-1, null, seed, 120);
						dispatchEvent(new NetworkGameReadyEvent(NetworkGameReadyEvent.networkGameReady, i, null, seed, 120));
					}
					else
					{
						if (currentRoom.entrant.getItemAt(i) == null) continue;
						var delay:int = 120 - sendDelayTimes[i] * 60 / 1000;
						selfControl.sendReady(i, null, seed, delay);
					}
				}
			}
		}
		
		private function networkGameReadyListener(e:NetworkGameReadyEvent):void
		{
			if (e.playerIndex != selfPlayerIndex) return;
			dispatchEvent(e);
		}
		
		private function createStreamDropListener(playerIndex:int):Function
		{
			return function(e:KuzurisErrorEvent):void
			{
				setPlayer(playerIndex, null);
				checkGameEnd();
			}
		}
		
	}

}