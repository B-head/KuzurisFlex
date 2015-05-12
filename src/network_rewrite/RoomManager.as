package network_rewrite 
{
	import ai.*;
	import common.*;
	import events.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import mx.collections.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class RoomManager extends EventDispatcherEX 
	{
		private var connectionManager:ConnectionManager;
		private var selfControl:SelfControl;
		private var remoteControls:Vector.<RemoteControl>;
		private var networkGameManager:NetworkGameManager;
		private var selfPlayerInfo:PlayerInformation;
		private var currentRoom:RoomInformation;
		private var battleIndex:int;
		private var password:String;
		private var lastSyncTimes:Dictionary;
		private var selfSyncTimes:Dictionary;
		private var remoteSyncTimes:Dictionary;
		
		public function RoomManager(connectionManager:ConnectionManager, selfPlayerInfo:PlayerInformation, currentRoom:RoomInformation, battleIndex:int, password:String) 
		{
			this.connectionManager = connectionManager;
			remoteControls = new Vector.<RemoteControl>();
			selfPlayerInfo = selfPlayerInfo;
			this.currentRoom = currentRoom;
			this.battleIndex = battleIndex;
			this.password = password;
			lastSyncTimes = new Dictionary();
			selfSyncTimes = new Dictionary();
			remoteSyncTimes = new Dictionary();
		}
		
		public function connect():void
		{
			//selfControl = new SelfControl(connectionManager, SharedObjectHelper.input);
			selfControl = new SelfControl(connectionManager, GameAIManager.createDefaultAI());
			selfControl.connect();
			initRemotes();
		}
		
		public function dispose():void
		{
			selfControl.dispose();
			for (var i:int = 0; i < remoteControls.length; ++i)
			{
				remoteControls[i].dispose();
			}
			dispatchEvent(new KuzurisEvent(KuzurisEvent.disposed));
		}
		
		private function initRemotes():void
		{
			var entrant:ArrayCollection = currentRoom.entrant;
			for (var i:int = 0; i < entrant.length; ++i)
			{
				appendRemote(connectionManager, entrant[i].peerID);
			}
			var watch:ArrayCollection = currentRoom.watch;
			for (var k:int = 0; k < watch.length; ++k)
			{
				appendRemote(connectionManager, watch[k].peerID);
			}
		}
		
		private function appendRemote(connectionManager:ConnectionManager, peerID:String):void
		{
			var remote:RemoteControl = new RemoteControl(connectionManager, peerID);
			remote.connect();
			remoteControls.push(remote);
		}
		
		private function findRemote(peerID:String):RemoteControl
		{
			for (var i:int = 0; i < remoteControls.length; ++i)
			{
				var rc:RemoteControl = remoteControls[i];
				if (rc.peerID == peerID) return rc;
			}
			return null;
		}
		
		private function isHost():Boolean
		{
			return hasHost(selfPlayerInfo);
		}
		
		private function hasHost(player:PlayerInformation):Boolean
		{
			return currentRoom.getHostPlayer == player;
		}
		
		public function createNetworkGameManager():NetworkGameManager
		{
			networkGameManager = new NetworkGameManager(currentRoom.multi ? 6 : 2, selfPlayerInfo);
			var entrant:ArrayCollection = currentRoom.entrant;
			for (var i:int = 0; i < entrant.length; ++i)
			{
				var control:RemoteControl = findRemote(entrant[i].peerID);
				networkGameManager.setPlayer(i, control, entrant[i]);
			}
			return networkGameManager;
		}
		
		public function gameReady():void
		{
			selfControl.sendSignal(NetworkEvent.beginSync);
			beginSync();
		}
		
		private function beginSync():void
		{
			lastSyncTimes = new Dictionary();
			selfSyncTimes = new Dictionary();
			remoteSyncTimes = new Dictionary();
			if (!isHost()) return;
			for (var i:int = 0; i < remoteControls.length; ++i)
			{
				var rc:RemoteControl = remoteControls[i];
				sendSync(rc.peerID, uint.MAX_VALUE);
			}
		}
		
		private function endSync():void
		{
			var setting:GameSetting = currentRoom.setting;
			var seed:XorShift128 = new XorShift128();
			seed.RandomSeed();
			var derayMax:uint = 0;
			for (var i:int = 0; i < remoteControls.length; ++i)
			{
				var peerID:String = remoteControls[i].peerID;
				derayMax = Math.max(derayMax, selfSyncTimes[peerID]);
			}
			for (var i:int = 0; i < remoteControls.length; ++i)
			{
				var peerID:String = remoteControls[i].peerID;
				selfControl.sendGameReady(peerID, setting, seed, 120 + derayMax - selfSyncTimes[peerID]);
			}
			networkGameManager.startGame(setting, seed, 120 + derayMax);
		}
		
		private function sendSync(peerID:String, remoteDeray:uint):void
		{
			var time:uint = getTimer();
			selfSyncTimes[peerID] = time - lastSyncTime[peerID];
			remoteSyncTimes[peerID] = remoteDeray;
			lastSyncTime[peerID] = time;
			if (isHost() && selfSyncTimes[peerID] == remoteSyncTimes[peerID])
			{
				if (chackCompleteSync())
				{
					endSync();
				}
				return;
			}
			selfControl.sendSync(time, syncDerayTime);
		}
		
		private function chackCompleteSync():Boolean
		{
			for (var i:int = 0; i < remoteControls.length; ++i)
			{
				var peerID:String = remoteControls[i].peerID;
				if (selfSyncTimes[peerID] != remoteSyncTimes[peerID]) return false;
			}
			return true;
		}
		
		private function beginSyncListener(e:NetworkEvent):void
		{
			beginSync();
		}
		
		private function createGameSyncListener(peerID:String):void
		{
			return function (e:GameSyncEvent):void
			{
				if (!isHost() && !hasHost(peerID)) return;
				sendSync(peerID, e.delayTime);
			};
		}
		
		private function networkGameReadyListener(e:GameReadyEvent):void
		{
			networkGameManager.startGame(e.setting, e.seed, e.delay);
		}
	}

}