package model 
{
	import model.ai.GameAI;
	/**
	 * ...
	 * @author B_head
	 */
	public class GameAIManager implements GameControl 
	{
		private const primaryMoveDelay:int = 8;
		private const secondaryMoveDelay:int = 4;
		
		private var ai:GameAI;
		private var currentModel:GameLightModel;
		private var currentWay:ControlWay;
		private var targetWay:ControlWay;
		private var moveDelay:int;
		private var primaryMove:Boolean;
		private var controlPhase:Boolean;
		
		public function GameAIManager(ai:GameAI):void
		{
			this.ai = ai;
		}
		
		public function changePhase(controlPhase:Boolean):void 
		{
			this.controlPhase = controlPhase;
			if (controlPhase)
			{
				primaryMove = true;
				//moveDelay = secondaryMoveDelay * 3;
			}
		}
		
		public function updateModel(currentModel:GameLightModel):void
		{
			this.currentModel = currentModel;
			ai.setCurrentModel(currentModel);
			currentWay = ControlWay.getCurrent(currentModel);
			targetWay = ai.createTargetWay();
		}
		
		public function issueGameCommand():GameCommand 
		{
			var ret:GameCommand = new GameCommand();
			moveDelay--;
			if (moveDelay > 0) return ret;
			if (!controlPhase) return ret;
			moveDelay = primaryMove ? primaryMoveDelay : secondaryMoveDelay;
			primaryMove = false;
			if (currentWay.dir == targetWay.dir && currentWay.lx == targetWay.lx)
			{
				ret.falling = GameCommand.earth;
				ret.fix = true;
				var rect:Rect = currentModel.controlOmino.getRect();
				var cox:int = currentWay.lx - rect.left;
				if (targetWay.cox != cox) throw new Error();
			}
			if (currentWay.dir != targetWay.dir)
			{
				ret.rotation = targetWay.dir == 3 ? GameCommand.right : GameCommand.left;
				currentWay = ControlWay.getRotate(currentWay, currentModel, ret.rotation);
			}
			var slx:int = currentWay.lx - targetWay.lx;
			if (slx > 0)
			{
				ret.move = GameCommand.left;
				currentWay.lx--;
			}
			else if (slx < 0)
			{
				ret.move = GameCommand.right;
				currentWay.lx++;
			}
			return ret;
		}	
	}
}