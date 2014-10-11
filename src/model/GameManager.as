package model 
{
	import events.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import model.ai.*;
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
	public class GameManager extends EventDispatcher
	{
		private var maxPlayer:int;
		private var control:Vector.<GameControl>;
		private var replay:Vector.<GameReplay>;
		private var gameModel:Vector.<GameModel>;
		private var execution:Boolean;
		private var replayMode:Boolean;
		private var readyDelay:int;
		private var prevFrameCount:int;
		
		public function GameManager(maxPlayer:int) 
		{
			this.maxPlayer = maxPlayer;
			control = new Vector.<GameControl>(maxPlayer);
			replay = new Vector.<GameReplay>(maxPlayer);
			gameModel = new Vector.<GameModel>(maxPlayer);
			initialize();
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
		
		public function setPlayer(index:int, control:GameControl):void
		{
			this.control[index] = control;
		}
		
		public function setAILevel(index:int, level:int):void
		{
			var ai:GameAIManager = control[index] as GameAIManager;
			if (ai == null) return;
			ai.setAILevel(level);
		}
		
		public function getGameModel(index:int):GameModel
		{
			return gameModel[index];
		}
		
		public function getRecord(index:int):GameRecord
		{
			var ret:GameRecord = gameModel[index].record;
			ret.replay = replay[index];
			return ret;
		}
		
		public function initialize():void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				gameModel[i] = new GameModel();
				gameModel[i].addEventListener(GameEvent.gameOver, GameEndListener);
				gameModel[i].addEventListener(GameEvent.gameClear, GameEndListener);
				gameModel[i].addEventListener(ObstacleEvent.occurObstacle, createOccurObstacleListener(i));
				gameModel[i].addEventListener(GameEvent.breakConbo, createBreakComboListener(i));
			}
			dispatchEvent(new KuzurisEvent(KuzurisEvent.initializeGameModel));
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
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null) continue;
				replay[i] = new GameReplay(setting, seed);
				gameModel[i].startGame(setting, seed);
				control[i].initialize(gameModel[i]);
				control[i].enable = true;
			}
			replayMode = false;
			readyDelay = delay;
			execution = true;
			resetFrameCount();
			dispatchEvent(new KuzurisEvent(KuzurisEvent.gameReady));
		}
		
		public function startReplay():void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null) continue;
				var r:GameReplay = control[i] as GameReplay;
				if (r == null) r = replay[i];
				replay[i] = null;
				gameModel[i].startGame(r.setting, r.seed);
				control[i] = r;
				control[i].initialize(gameModel[i]);
				control[i].enable = true;
			}
			replayMode = true;
			execution = true;
			resetFrameCount();
		}
		
		public function endGame():void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null) continue;
				control[i].enable = false;
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
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null) continue;
				forwordGamePert(i);
				if (control[i] is RemoteGameControl)
				{
					forwordGamePert(i);
				}
			}
		}
		
		private function forwordGamePert(index:int):void
		{
			var command:GameCommand = control[index].issueGameCommand();
			if (command == null) return;
			if (replay[index] != null)
			{
				replay[index].recordCommand(command);
			}
			gameModel[index].forwardGame(command);
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
		}
		
		private function GameEndListener(e:GameEvent):void
		{
			var count:int = 0;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (gameModel[i].isGameOver) count++;
			}
			if (count >= maxPlayer - 1)
			{
				endGame();
				dispatchEvent(new KuzurisEvent(KuzurisEvent.gameEnd));
			}
		}
		
		private function createOccurObstacleListener(self:int):Function
		{
			return function(e:ObstacleEvent):void
			{
				for (var i:int = 0; i < maxPlayer; i++)
				{
					if (i == self) continue;
					if (gameModel[i].isGameOver) continue;
					gameModel[i].addObstacle(self, e.count);
				}
			}
		}
		
		private function createBreakComboListener(self:int):Function
		{
			return function(e:GameEvent):void
			{
				for (var i:int = 0; i < maxPlayer; i++)
				{
					if (control[i] == null) continue;
					if (i == self) continue;
					control[i].setMaterialization(self);
					gameModel[i].breakConboNotice(self);
				}
			}
		}
	}

}