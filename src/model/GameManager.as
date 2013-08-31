package model 
{
	import event.GameEvent;
	/**
	 * ...
	 * @author B_head
	 */
	public class GameManager 
	{
		private var versus:Boolean;
		private var maxPlayer:int;
		private var control:Vector.<GameControl>;
		private var replay:Vector.<GameReplay>;
		private var gameModel:Vector.<GameModel>;
		
		public function GameManager(maxPlayer:int, versus:Boolean) 
		{
			this.versus = versus;
			this.maxPlayer = maxPlayer;
			control = new Vector.<GameControl>(maxPlayer);
			replay = new Vector.<GameReplay>(maxPlayer);
			gameModel = new Vector.<GameModel>(maxPlayer);
		}
		
		public function setPlayer(index:int, control:GameControl):void
		{
			this.control[index] = control;
		}
		
		public function getGameModel(index:int):GameModel
		{
			return gameModel[index];
		}
		
		//FIXME 古いリスナーの後始末をしない。
		public function initializeGame(setting:GameSetting):void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null)
				{
					continue;
				}
				replay[i] = new GameReplay();
				gameModel[i] = new GameModel(setting);
				gameModel[i].addEventListener(GameEvent.setOmino, createChangePhaseListener(i, true));
				gameModel[i].addEventListener(GameEvent.fixOmino, createChangePhaseListener(i, false));
			}
		}
		
		private function createChangePhaseListener(index:int, phase:Boolean):Function
		{
			return function(e:GameEvent):void
			{
				control[index].changePhase(phase);
			}
		}
		
		public function forwardStep():void
		{
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null)
				{
					continue;
				}
				var command:GameCommand = control[i].issueGameCommand();
				replay[i].recordCommand(command);
				gameModel[i].forwardStep(command);
			}
		}
	}

}