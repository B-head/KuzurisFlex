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
	[Event(name="gamePause", type="events.KuzurisEvent")]
	[Event(name="gameResume", type="events.KuzurisEvent")]
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
		
		public function isGameOver(index:int):Boolean
		{
			return gameModel[index].isGameOver;
		}
		
		public function setPlayer(index:int, control:GameControl, playerInfo:PlayerInformation = null):void
		{
			this.control[index] = control;
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
			return gameModel[index].record;
		}
		
		[Bindable(event="gameEnd")]
		public function getRank(index:int):int
		{
			var st:int = gameModel[index].record.gameTime;
			var vt:Vector.<int> = new Vector.<int>();
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (gameModel[i] == null) continue;
				vt.push(gameModel[i].record.gameTime);
			}
			vt = vt.sort(function(x:int, y:int):Number { return y - x; } );
			return vt.lastIndexOf(st) + 1;
		}
		
		[Bindable(event="playerUpdate")]
		public function getPlayerInfo(index:int):PlayerInformation
		{
			return playerInfo[index];
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
			gameModel[index].addTerget(GameEvent.gameOver, GameEndListener);
			gameModel[index].addTerget(GameEvent.gameClear, GameEndListener);
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
			readyDelay = 0;
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
				var pi:PlayerInformation = playerInfo[0] == null ? null : playerInfo[i].clone();
				ret.playerInfo.push(pi);
				ret.replayControl.push(replay[i].clone());
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
		
		private function forwardGame():void
		{
			var limitTime:int = getMinGameTime() + 120;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				forwordGamePert(i, limitTime);
				if (control[i] is NetworkRemoteControl)
				{
					forwordGamePert(i, limitTime);
				}
			}
		}
		
		private function forwordGamePert(index:int, limitTime:int):void
		{
			if (control[index] == null) return;
			if (gameModel[index].isGameOver) return;
			if (gameModel[index].obstacleManager.isStandOutsideEnabled()) return;
			if (gameModel[index].record.gameTime >= limitTime)
			{
				control[index].enable = false;
				return;
			}
			control[index].enable = true;
			var command:GameCommand = control[index].issueGameCommand();
			if (command == null) return;
			if (replay[index] != null)
			{
				replay[index].recordCommand(command);
			}
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
		
		private function resetFrameCount(delay:Boolean = false):void
		{
			prevFrameCount = getTimer() * 60 / 1000;
			if (delay) prevFrameCount -= 60;
		}
		
		public function frameConstructedListener():void
		{
			if (execution == false) return;
			if (prevFrameCount < getTimer() * 60 / 1000 - 60)
			{
				resetFrameCount(true);
			}
			var time:int = getTimer();
			while (time >= prevFrameCount * 1000 / 60)
			{
				prevFrameCount++;
				if (readyDelay == 0)
				{
					dispatchEvent(new KuzurisEvent(KuzurisEvent.gameStart));
				}
				if (readyDelay <= 0)
				{
					forwardGame();
				}
				readyDelay--;
			}
			checkGameEnd();
		}
		
		protected function checkGameEnd():void
		{
			var count:int = 0;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null || !control[i].enable) continue;
				if (gameModel[i].isGameOver) continue;
				count++;
			}
			if (count <= (isBattle() ? 1 : 0))
			{
				endGame();
				dispatchEvent(new KuzurisEvent(KuzurisEvent.gameEnd));
			}
		}
		
		private function GameEndListener(e:GameEvent):void
		{
			return;
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