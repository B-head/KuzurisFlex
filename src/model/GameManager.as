package model 
{
	import event.*;
	import flash.events.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class GameManager extends EventDispatcher
	{
		private var maxPlayer:int;
		private var control:Vector.<GameControl>;
		private var replay:Vector.<GameReplay>;
		private var gameModel:Vector.<GameModel>;
		
		public function GameManager(maxPlayer:int) 
		{
			this.maxPlayer = maxPlayer;
			control = new Vector.<GameControl>(maxPlayer);
			replay = new Vector.<GameReplay>(maxPlayer);
			gameModel = new Vector.<GameModel>(maxPlayer);
		}
		
		public function isBattle():Boolean
		{
			return maxPlayer > 1;
		}
		
		public function setPlayer(index:int, control:GameControl):void
		{
			this.control[index] = control;
		}
		
		public function getGameModel(index:int):GameModel
		{
			return gameModel[index];
		}
		
		public function initializeGame(setting:GameSetting):void
		{
			var seed:XorShift128 = new XorShift128();
			seed.RandomSeed();
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null)
				{
					continue;
				}
				replay[i] = new GameReplay();
				gameModel[i] = new GameModel(setting, seed);
				control[i].updateModel(gameModel[i].getLightModel());
				gameModel[i].addEventListener(GameEvent.gameOver, GameEndListener);
				gameModel[i].addEventListener(GameEvent.gameClear, GameEndListener);
				gameModel[i].addEventListener(ControlEvent.setOmino, createUpdateModelListener(i), false);
				gameModel[i].addEventListener(ControlEvent.setOmino, createChangePhaseListener(i, true));
				gameModel[i].addEventListener(ControlEvent.fixOmino, createChangePhaseListener(i, false));
				gameModel[i].addEventListener(ObstacleEvent.occurObstacle, createOccurObstacleListener(i));
				gameModel[i].addEventListener(GameEvent.breakConbo, createBreakComboListener(i));
			}
		}
		
		public function forwardGame():void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null)
				{
					continue;
				}
				var command:GameCommand = control[i].issueGameCommand();
				replay[i].recordCommand(command);
				gameModel[i].forwardGame(command);
			}
		}
		
		private function GameEndListener(e:GameEvent):void
		{
			var count:int = 0;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (gameModel[i].isGameOver()) count++;
			}
			if (count >= maxPlayer - 1)
			{
				dispatchEvent(new GameEvent(e.type, e.gameTime, 0));
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
				control[self].updateModel(gameModel[self].getLightModel());
			}
		}
		
		private function createOccurObstacleListener(self:int):Function
		{
			return function(e:ObstacleEvent):void
			{
				for (var i:int = 0; i < maxPlayer; i++)
				{
					if (i != self) gameModel[i].addObstacle(self, e.count);
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