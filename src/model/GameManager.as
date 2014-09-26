package model 
{
	import event.*;
	import flash.events.*;
	import model.ai.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="gameStart", type="event.GameManagerEvent")]
	[Event(name="gameEnd", type="event.GameManagerEvent")]
	[Event(name="changePlayer", type="event.GameManagerEvent")]
	public class GameManager extends EventDispatcher
	{
		private var maxPlayer:int;
		private var control:Vector.<GameControl>;
		private var replay:Vector.<GameReplay>;
		private var gameModel:Vector.<GameModel>;
		private var execution:Boolean;
		private var isReplayMode:Boolean;
		
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
		
		public function setPlayer(index:int, control:GameControl):void
		{
			this.control[index] = control;
			dispatchEvent(new GameManagerEvent(GameManagerEvent.changePlayer));
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
				gameModel[i].addEventListener(ControlEvent.setOmino, createUpdateModelListener(i), false);
				gameModel[i].addEventListener(ControlEvent.setOmino, createChangePhaseListener(i, true));
				gameModel[i].addEventListener(ControlEvent.fixOmino, createChangePhaseListener(i, false));
				gameModel[i].addEventListener(ObstacleEvent.occurObstacle, createOccurObstacleListener(i));
				gameModel[i].addEventListener(GameEvent.breakConbo, createBreakComboListener(i));
			}
		}
		
		public function startGame(setting:GameSetting):void
		{
			var seed:XorShift128 = new XorShift128();
			seed.RandomSeed();
			for (var i:int = 0; i < maxPlayer; i++)
			{
				replay[i] = new GameReplay(setting, seed);
				gameModel[i].startGame(setting, seed);
				control[i].reset();
				control[i].enable = true;
			}
			isReplayMode = false;
			execution = true;
			dispatchEvent(new GameManagerEvent(GameManagerEvent.gameStart));
		}
		
		public function startReplay():void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				var r:GameReplay = isReplayMode ? control[i] as GameReplay : replay[i];
				replay[i] = null;
				gameModel[i].startGame(r.setting, r.seed);
				control[i] = r;
				control[i].reset();
				control[i].enable = true;
			}
			isReplayMode = true;
			execution = true;
			dispatchEvent(new GameManagerEvent(GameManagerEvent.gameStart));
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
				control[i].enable = false;
			}
			execution = false;
		}
		
		public function resumeGame():void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				control[i].enable = true;
			}
			execution = true;
		}
		
		public function forwardGame():void
		{
			if (execution == false) return;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				var command:GameCommand = control[i].issueGameCommand();
				if (replay[i] != null)
				{
					replay[i].recordCommand(command);
				}
				gameModel[i].forwardGame(command);
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
				dispatchEvent(new GameManagerEvent(GameManagerEvent.gameEnd));
			}
		}
		
		private function createChangePhaseListener(self:int, phase:Boolean):Function
		{
			return function(e:ControlEvent):void
			{
				control[self].changePhase(phase);
			}
		}
		
		private function createUpdateModelListener(self:int):Function
		{
			return function(e:GameEvent):void
			{
				var ai:GameAIManager = control[self] as GameAIManager;
				if (ai == null) return;
				ai.updateModel(gameModel[self].getLightModel());
				ai.updateNotice(gameModel[self].obstacleNotice + gameModel[self].obstacleNoticeSave);
			}
		}
		
		private function createOccurObstacleListener(self:int):Function
		{
			return function(e:ObstacleEvent):void
			{
				for (var i:int = 0; i < maxPlayer; i++)
				{
					if (i == self) continue;
					gameModel[i].addObstacle(self, e.count);
					var ai:GameAIManager = control[i] as GameAIManager;
					if (ai == null) return;
					ai.updateNotice(gameModel[self].obstacleNotice + gameModel[self].obstacleNoticeSave);
				}
			}
		}
		
		private function createBreakComboListener(self:int):Function
		{
			return function(e:GameEvent):void
			{
				for (var i:int = 0; i < maxPlayer; i++)
				{
					if (i != self) gameModel[i].materializationNotice(self);
				}
			}
		}
	}

}