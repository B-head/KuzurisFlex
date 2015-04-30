package model 
{
	import events.*;
	import flash.events.*;
	import flash.utils.*;
	import model.ai.*;
	import model.network.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="gameReady", type="events.KuzurisEvent")]
	[Event(name="gameStart", type="events.KuzurisEvent")]
	[Event(name="gameEnd", type="events.KuzurisEvent")]
	[Event(name="gameClear", type="events.KuzurisEvent")]
	[Event(name="gameOvar", type="events.KuzurisEvent")]
	[Event(name="gamePause", type="events.KuzurisEvent")]
	[Event(name="gameResume", type="events.KuzurisEvent")]
	[Event(name="gameHurryUp", type="events.KuzurisEvent")]
	[Event(name="playerKnockout", type="events.KuzurisEvent")]
	[Event(name="playerKnockoutOneself", type="events.KuzurisEvent")]
	[Event(name="initializeGameModel", type="events.KuzurisEvent")]
	[Event(name="playerUpdate", type="events.KuzurisEvent")]
	public class GameManager extends EventDispatcherEX
	{
		protected var maxPlayer:int;
		protected var playerInfo:Vector.<PlayerInformation>;
		protected var handicap:Vector.<Number>;
		protected var control:Vector.<GameControl>;
		protected var gameModel:Vector.<GameModel>;
		protected var replay:Vector.<GameReplayControl>;
		protected var seed:XorShift128;
		protected var execution:Boolean;
		private var startTimeStamp:Date;
		private var replayMode:Boolean;
		private var readyDelay:int;
		private var prevFrameCount:int;
		
		public function GameManager(maxPlayer:int) 
		{
			this.maxPlayer = maxPlayer;
			playerInfo = new Vector.<PlayerInformation>(maxPlayer);
			handicap = new Vector.<Number>(maxPlayer);
			control = new Vector.<GameControl>(maxPlayer);
			gameModel = new Vector.<GameModel>(maxPlayer);
			replay = new Vector.<GameReplayControl>(maxPlayer);
			for (var i:int = 0; i < maxPlayer; i++)
			{
				handicap[i] = 0;
			}
			initialize();
		}
		
		public function dispose():void
		{
			removeAll();
		}
		
		public function isBattle():Boolean
		{
			return maxPlayer > 1;
		}
		
		public function isExecution():Boolean
		{
			return execution;
		}
		
		public function isReplayMode():Boolean
		{
			return replayMode;
		}
		
		public function setPlayer(index:int, control:GameControl, playerInfo:PlayerInformation = null):void
		{
			this.control[index] = control;
			this.playerInfo[index] = playerInfo;
			dispatchEvent(new KuzurisEvent(KuzurisEvent.playerUpdate));
		}
		
		public function setPlayerInfo(index:int, playerInfo:PlayerInformation):void
		{
			this.playerInfo[index] = playerInfo;
			dispatchEvent(new KuzurisEvent(KuzurisEvent.playerUpdate));
		}
		
		public function setHandicap(index:int, handi:Number):void
		{
			handicap[index] = handi; 
		}
		
		public function setAILevel(index:int, level:int):void
		{
			var ai:GameAIManager = control[index] as GameAIManager;
			if (ai == null) return;
			ai.setAILevel(level);
		}
		
		[Bindable(event="initializeGameModel")]
		public function getGameModel(index:int):GameModel
		{
			return gameModel[index];
		}
		
		[Bindable(event="initializeGameModel")]
		public function getRecord(index:int):GameRecord
		{
			if (gameModel[index] == null) return null;
			return gameModel[index].record;
		}
		
		[Bindable(event="playerUpdate")]
		public function getRank(index:int):int
		{
			if (!gameModel[index].isGameOver) return 1;
			var st:int = gameModel[index].record.gameTime;
			var vt:Vector.<int> = new Vector.<int>();
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (gameModel[i] == null) continue;
				if (gameModel[i].isGameOver)
				{
					vt.push(gameModel[i].record.gameTime);
				}
				else
				{
					vt.push(int.MAX_VALUE);
				}
			}
			vt = vt.sort(function(x:int, y:int):Number { return y - x; } );
			return vt.lastIndexOf(st) + 1;
		}
		
		[Bindable(event="playerUpdate")]
		public function getPlayerInfo(index:int):PlayerInformation
		{
			return playerInfo[index];
		}
		
		[Bindable(event="playerUpdate")]
		public function isPlayerGameEnd(index:int):Boolean
		{
			if (isIndexEmpty(index)) return false;
			if (gameModel[index].record.gameTime == 0) return false;
			if (isGameEnd()) return true;
			return gameModel[index].isGameOver;
		}
		
		[Bindable(event="playerUpdate")]
		public function isIndexEmpty(index:int):Boolean
		{
			return gameModel[index] == null;
		}
		
		public function initialize():void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				registerGameModel(i, new GameModel());
			}
			for (i = 0; i < maxPlayer; i++)
			{
				appendOutsideManager(i);
			}
			dispatchEvent(new KuzurisEvent(KuzurisEvent.initializeGameModel));
		}
		
		protected function registerGameModel(index:int, gm:GameModel):void
		{
			if (gameModel[index] != null)
			{
				gameModel[index].dispose();
			}
			gameModel[index] = gm;
			gameModel[index].addTerget(GameEvent.gameOver, gameEndListener);
			gameModel[index].addTerget(GameEvent.gameClear, gameEndListener);
			gameModel[index].addTerget(GameEvent.beginHurryUp, gameEndListener);
			gameModel[index].obstacleManager.addTerget(GameEvent.enabledObstacle, createOccurObstacleListener(index), false);
		}
		
		protected function appendOutsideManager(index:int):void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				var om:ObstacleManager = gameModel[i].obstacleManager;
				gameModel[index].obstacleManager.appendOutsideManager(i, om);
			}
		}
		
		public function startGame(setting:GameSetting = null, seed:XorShift128 = null, delay:int = 120):void
		{
			if (setting == null)
			{
				setting = new GameSetting();
			}
			if (seed == null)
			{
				seed = new XorShift128();
				seed.RandomSeed();
			}
			this.seed = seed;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null) continue;
				replay[i] = new GameReplayControl();
				setting.handicap = handicap[i];
				gameModel[i].startGame(setting, seed);
				control[i].initialize(gameModel[i]);
				control[i].enable = true;
			}
			startTimeStamp = new Date();
			replayMode = false;
			readyDelay = delay;
			execution = true;
			resetFrameCount();
			dispatchEvent(new KuzurisEvent(KuzurisEvent.gameReady));
		}
		
		public function startReplay(replayContainer:GameReplayContainer):void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				playerInfo[i] = replayContainer.playerInfo[i];
				control[i] = replayContainer.replayControl[i];
				replay[i] = null;
				gameModel[i].startGame(replayContainer.setting[i], replayContainer.seed);
				control[i].initialize(gameModel[i]);
				control[i].enable = true;
			}
			replayMode = true;
			readyDelay = 1;
			execution = true;
			resetFrameCount();
		}
		
		public function makeReplayContainer():GameReplayContainer
		{
			var ret:GameReplayContainer = new GameReplayContainer();
			ret.timeStamp = startTimeStamp;
			ret.roomName = "ローカル対戦";
			ret.seed = seed.clone();
			for (var i:int = 0; i < maxPlayer; i++)
			{
				var pi:PlayerInformation = playerInfo[i] == null ? null : playerInfo[i].clone();
				ret.playerInfo.push(pi);
				var rc:GameReplayControl = replay[i] == null ? null : replay[i].clone();
				ret.replayControl.push(rc);
				ret.setting.push(gameModel[i].setting);
				ret.record.push(gameModel[i].record);
			}
			return ret;
		}
		
		public function endGame():void
		{
			if (execution == false) return;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null) continue;
				control[i].enable = false;
				if (playerInfo[i] == null) continue;
				playerInfo[i].appendRate(gameModel[i].record);
			}
			execution = false;
		}
		
		public function phaseGame():void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null) continue;
				control[i].enable = false;
			}
			execution = false;
			dispatchEvent(new KuzurisEvent(KuzurisEvent.gamePause));
		}
		
		public function resumeGame():void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null) continue;
				control[i].enable = true;
			}
			execution = true;
			resetFrameCount();
			dispatchEvent(new KuzurisEvent(KuzurisEvent.gameResume));
		}
		
		private function resetFrameCount():void
		{
			prevFrameCount = getTimer() * 60 / 1000;
		}
		
		public function forwardGame():void
		{
			if (execution == false) return;
			var currentFrameCount:int = getTimer() * 60 / 1000;
			for (var i:int = 0; i < 4; i++)
			{
				if (prevFrameCount + i >= currentFrameCount) break;
				forwardGamePart();
			}
			prevFrameCount = currentFrameCount;
		}
		
		private function forwardGamePart():void
		{
			dispatchEvent(new KuzurisEvent(KuzurisEvent.forwardGame));
			readyDelay--;
			if (readyDelay > 0) return;
			if (readyDelay == 0)
			{
				dispatchEvent(new KuzurisEvent(KuzurisEvent.gameStart));
			}
			var limitTime:int = getMinGameTime() + 120;
			var minGameOverTime:int = getMinGameOverTime();
			for (var i:int = 0; i < maxPlayer; i++)
			{
				forwordGamePlayer(i, limitTime, minGameOverTime);
				if (control[i] is NetworkRemoteControl)
				{
					forwordGamePlayer(i, limitTime, minGameOverTime);
				}
			}
			checkGameEnd();
		}
		
		private function forwordGamePlayer(index:int, limitTime:int, minGameOverTime:int):void
		{
			if (control[index] == null) return;
			if (gameModel[index].isGameOver) return;
			if (gameModel[index].obstacleManager.isStandOutsideEnabled()) return;
			if (gameModel[index].record.gameTime >= limitTime)
			{
				control[index].enable = false;
				return;
			}
			else
			{
				control[index].enable = true;
			}
			var command:GameCommand = control[index].issueGameCommand();
			if (command == null) return;
			if (replay[index] != null)
			{
				replay[index].recordCommand(command);
			}
			gameModel[index].harryUp(minGameOverTime);
			gameModel[index].forwardGame(command);
		}
		
		private function getMinGameTime():int
		{
			var ret:int = int.MAX_VALUE;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null) continue;
				if (gameModel[i].isGameOver) continue;
				ret = Math.min(ret, gameModel[i].record.gameTime);
			}
			return ret;
		}
		
		private function getMinGameOverTime():int
		{
			var ret:int = int.MAX_VALUE;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null) continue;
				if (!gameModel[i].isGameOver) continue;
				ret = Math.min(ret, gameModel[i].record.gameTime);
			}
			return ret;
		}
		
		protected function checkGameEnd():void
		{
			if (isGameEnd())
			{
				endGame();
				dispatchEvent(new KuzurisEvent(KuzurisEvent.gameEnd));
				dispatchEvent(new KuzurisEvent(KuzurisEvent.playerUpdate));
			}
		}
		
		private function isGameEnd():Boolean
		{
			var count:int = 0;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null || gameModel[i].isGameOver) continue;
				count++;
			}
			return count <= (isBattle() ? 1 : 0);
		}
		
		private function gameEndListener(e:GameEvent):void
		{
			dispatchEvent(new KuzurisEvent(KuzurisEvent.playerUpdate));
			if (e.type == GameEvent.gameClear)
			{
				dispatchEvent(new KuzurisEvent(KuzurisEvent.gameClear));
			}
			else
			{
				dispatchEvent(new KuzurisEvent(KuzurisEvent.gameOvar));
			}
		}
		
		private function hurryUpListener(e:GameEvent):void
		{
			dispatchEvent(new KuzurisEvent(KuzurisEvent.gameHurryUp));
		}
		
		private function createOccurObstacleListener(self:int):Function
		{
			return function(e:GameEvent):void
			{
				for (var i:int = 0; i < maxPlayer; i++)
				{
					if (control[i] == null) return;
					if (gameModel[i].isGameOver) continue;
					control[i].setMaterialization(self);
				}
			}
		}
	}

}