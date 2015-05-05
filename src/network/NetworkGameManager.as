package network {
	import ai.*;
	import common.*;
	import events.*;
	import flash.utils.*;
	import model.*;
	import mx.events.*;
	import view.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="completedSyncState", type="events.KuzurisEvent")]
	[Event(name="gameAbort", type="events.KuzurisErrorEvent")]
	[Event(name="networkGameReady", type="events.NetworkGameReadyEvent")]
	public class NetworkGameManager extends GameManager 
	{
		private static const requestState:String = "requestState";
		private static const replyState:String = "replyState";
		
		private var networkManager:NetworkManager;
		private var roomManager:RoomManager;
		private var roomGroup:NetworkGroupManager;
		private var selfControl:NetworkSelfControl;
		private var currentRoom:RoomInformation;
		private var selfPlayerInfo:PlayerInformation;
		private var selfPlayerIndex:int;
		private var lastGameForwardTime:int;
		private var syncTime:int;
		private var sendDelayTimes:Vector.<int>;
		
		private const gameStopLimit:int = 10000;
		
		public function NetworkGameManager(maxPlayer:int, networkManager:NetworkManager, roomManager:RoomManager) 
		{
			super(maxPlayer);
			this.networkManager = networkManager;
			this.roomManager = roomManager;
			roomGroup = networkManager.roomGroup;
			roomGroup.addTerget(NotifyEvent.notify, notifyListener);
			roomGroup.addTerget(KuzurisEvent.disposed, disposedListener);
			currentRoom = roomManager.currentRoom;
			currentRoom.entrant.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeListener, false, 0, true);
			selfControl = networkManager.getSelfGameControl(roomManager.selfInput);
			//selfControl = networkManager.getSelfGameControl(GameAIManager.createDefaultAI());
			selfPlayerInfo = roomManager.selfPlayerInfo;
		}
		
		override public function dispose():void 
		{
			super.dispose();
			roomGroup.removeTerget(NotifyEvent.notify, notifyListener);
			roomGroup.removeTerget(KuzurisEvent.disposed, disposedListener);
			currentRoom.entrant.removeEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeListener);
		}
		
		public function syncState():void
		{
			setPlayers();
			if (!isOnePlayer())
			{
				roomGroup.sendDecreasing(requestState);
			}
			else
			{
				dispatchEvent(new KuzurisEvent(KuzurisEvent.completedSyncState));
			}
		}
		
		private function setReplyState(execution:Boolean, gameModel:Vector.<GameModel>, replay:Vector.<GameReplayControl>):void
		{
			this.execution = execution;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (i == selfPlayerIndex) continue;
				registerGameModel(i, gameModel[i]);
				this.replay[i] = replay[i];
			}
			for (i = 0; i < maxPlayer; i++)
			{
				appendOutsideManager(i);
				var nrc:NetworkRemoteControl = control[i] as NetworkRemoteControl;
				if (nrc != null)
				{
					nrc.obtainState(gameModel[i]);
				}
			}
			dispatchEvent(new KuzurisEvent(KuzurisEvent.initializeGameModel));
			dispatchEvent(new KuzurisEvent(KuzurisEvent.completedSyncState));
		}
		
		private function setPlayers():void
		{
			selfPlayerIndex = -1;
			var maxPlayer:int = currentRoom.entrant.length;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				var pi:PlayerInformation = currentRoom.entrant.getItemAt(i) as PlayerInformation;
				if (!PlayerInformation.containPlayer(pi, playerInfo[i]))
				{
					//registerGameModel(i, new GameModel());
				}
				var c:GameControl = createGameControl(pi, i);
				if(c == selfControl) selfPlayerIndex = i;
				if (!isExecution())
				{
					setPlayer(i, c, pi);
				}
				else
				{
					setPlayerInfo(i, pi);
				}
			}
		}
		
		private function createGameControl(playerInfo:PlayerInformation, index:int):GameControl
		{
			if (playerInfo == null) return null;
			if (playerInfo == selfPlayerInfo)
			{
				selfControl.removeAll();
				selfControl.addTerget(KuzurisErrorEvent.streamDrop, createStreamDropListener(index), false);
				return selfControl;
			}
			if (playerInfo.isAI) return GameAIManager.createDefaultAI();
			var ret:NetworkRemoteControl = networkManager.getRemoteGameControl(index, playerInfo.peerID);
			if (ret == null) return null;
			ret.removeAll();
			ret.addTerget(KuzurisEvent.gameSync, createGameSyncListener(index), false);
			ret.addTerget(KuzurisEvent.gameSyncReply, createGameSyncReplayListener(index), false);
			ret.addTerget(NetworkGameReadyEvent.networkGameReady, networkGameReadyListener);
			ret.addTerget(KuzurisErrorEvent.notEqualHash, createNotEqualHashListener(index), false);
			ret.addTerget(KuzurisErrorEvent.streamDrop, createStreamDropListener(index), false);
			return ret;
		}
		
		override public function initialize():void 
		{
			lastGameForwardTime = getTimer();
			super.initialize();
		}
		
		override public function makeReplayContainer():GameReplayContainer 
		{
			var ret:GameReplayContainer = super.makeReplayContainer();
			ret.roomName = currentRoom.name;
			//TODO ret.traceLog = Main.getTraceLog();
			return ret;
		}
		
		override protected function checkGameEnd():void 
		{
			var count:int = 0;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null || gameModel[i].isGameOver) continue;
				if (control[i].enable == false)
				{
					count++;
				}
			}
			if (count > 0)
			{
				if (lastGameForwardTime + gameStopLimit < getTimer())
				{
					endGame();
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.gameAbort, "10秒以上停止したため、ゲームを終了しました。"));
					return;
				}
			}
			else
			{
				lastGameForwardTime = getTimer();
			}
			super.checkGameEnd();
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
				if (selfPlayerIndex == RoomInformation.watchIndex) return true;
				return isPlayerGameEnd(selfPlayerIndex);
			}
			return isOnePlayer();
		}
		
		[Bindable(event="playerUpdate")]
		public function isOnePlayer():Boolean
		{
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
		public override function isIndexEmpty(index:int):Boolean
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
		
		public function syncReady():void
		{
			if (isExecution()) return;
			syncTime = getTimer();
			sendDelayTimes = new Vector.<int>(currentRoom.entrant.length);
			selfControl.sendSync();
		}
		
		private function collectionChangeListener(e:CollectionEvent):void
		{
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
				var setting:GameSetting = currentRoom.setting;
				var seed:XorShift128 = new XorShift128();
				seed.RandomSeed();
				for (i = 0; i < maxPlayer; i++)
				{
					if (i == selfPlayerIndex)
					{
						selfControl.sendReady(-1, null, seed, 120);
						dispatchEvent(new NetworkGameReadyEvent(NetworkGameReadyEvent.networkGameReady, i, setting, seed, 120));
					}
					else
					{
						if (currentRoom.entrant.getItemAt(i) == null) continue;
						var delay:int = 120 - sendDelayTimes[i] * 60 / 1000;
						selfControl.sendReady(i, setting, seed, delay);
					}
				}
			}
		}
		
		private function networkGameReadyListener(e:NetworkGameReadyEvent):void
		{
			if (e.playerIndex != selfPlayerIndex) return;
			dispatchEvent(e);
		}
		
		private function createNotEqualHashListener(playerIndex:int):Function
		{
			return function(e:KuzurisErrorEvent):void
			{
				control[playerIndex] = null;
				playerInfo[playerIndex] = null;
				endGame();
				dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.gameAbort, "ゲームデータの不整合が起きたため、ゲームを終了しました。"));
			}
		}
		
		private function createStreamDropListener(playerIndex:int):Function
		{
			return function(e:KuzurisErrorEvent):void
			{
				control[playerIndex] = null;
				playerInfo[playerIndex] = null;
				endGame();
				dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.gameAbort, "ネットワークが切断されたため、ゲームを終了しました。"));
			}
		}
		
		private function notifyListener(e:NotifyEvent):void
		{
			switch (e.message.type)
			{
				case requestState:
					roomGroup.sendPeer(e.message.peerID, replyState, { execution:execution, gameModel:gameModel, replay:replay } );
					break;
				case replyState:
					setReplyState(e.message.obj.execution, e.message.obj.gameModel, e.message.obj.replay);
					break;
			}
		}
		
	}

}