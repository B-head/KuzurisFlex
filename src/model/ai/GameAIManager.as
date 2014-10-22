package model.ai {
	import events.*;
	import model.*;
	import model.ai.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class GameAIManager implements GameControl 
	{
		private const primaryMoveDelay:int = 8;
		private const secondaryMoveDelay:int = 4;
		
		private var ai:GameAI;
		private var appendDelay:int;
		private var choiceDelay:Boolean;
		private var separateDelay:Boolean;
		private var fallDelay:Boolean;
		private var moveDelay:int;
		
		private var _enable:Boolean;
		private var materialization:Vector.<Boolean>;
		private var gameModel:GameModel;
		private var currentModel:FragmentGameModel;
		private var controlPhase:Boolean;
		private var notice:int;
		private var currentWay:ControlWay;
		private var targetWay:ControlWay;
		private var verge:Boolean;
		private var restDelay:int;
		private var primaryMove:Boolean;
		private var completedMove:Boolean;
		private var completedSeparate:Boolean;
		private var pressShift:Boolean;
		private var pressFall:Boolean;
		
		public function GameAIManager(ai:GameAI):void
		{
			this.ai = ai;
			setAILevel(20);
		}
		
		public static function createDefaultAI():GameAIManager
		{
			return new GameAIManager(new GreedyAI);
		}
		
		public function get enable():Boolean { return _enable; }
		public function set enable(value:Boolean):void { _enable = value; };
		
		public function setAILevel(level:int):void
		{
			ai.level = level;
			appendDelay = 480 / level - 24;
			choiceDelay = level != 20;
			if (appendDelay >= 60)
			{
				fallDelay = true;
				appendDelay -= 25;
			}
			else
			{
				fallDelay = false;
			}
			if (appendDelay >= 20)
			{
				separateDelay = true;
				appendDelay -= 6;
			}
			else
			{
				separateDelay = false;
			}
			if (appendDelay >= 8)
			{
				var a:int = appendDelay / 8;
				moveDelay = 7 + a;
				appendDelay -= a * 3;
			}
			else
			{
				moveDelay = 0;
			}
		}
		
		public function isFastMove():Boolean
		{
			if (moveDelay == 0) return true;
			if (!completedMove) return false;
			return verge;
		}
		
		public function isSeparateDelay():Boolean
		{
			if (!separateDelay) return false;
			return completedSeparate;
		}
		
		public function initialize(gameModel:GameModel):void
		{
			this.gameModel = gameModel;
			gameModel.addEventListener(ControlEvent.setOmino, setOminoListener);
			gameModel.addEventListener(ControlEvent.fixOmino, fixOminoListener);
			gameModel.addEventListener(ControlEvent.setOmino, updateModelListener);
			gameModel.addEventListener(ObstacleEvent.occurObstacle, updateNoticeListener);
			materialization = new Vector.<Boolean>(GameCommand.materializationLength);
			currentModel = null;
			notice = 0;
			currentWay = null;
			targetWay = null;
			restDelay = 0;
			primaryMove = false;
			controlPhase = false;
			pressShift = false;
			pressFall = false;
		}
		
		private function setOminoListener(e:ControlEvent):void
		{
			controlPhase = true;
			primaryMove = true;
			pressFall = false;
			restDelay = primaryMoveDelay + appendDelay;
			//if (choiceDelay) restDelay += choices.length - 1;
		}
		
		private function fixOminoListener(e:ControlEvent):void
		{
			controlPhase = false;
		}
		
		private function updateModelListener(e:ControlEvent):void
		{
			currentModel = gameModel.getLightModel();
			notice = gameModel.obstacleNotice + gameModel.obstacleNoticeSave;
			currentWay = ControlWay.getCurrent(currentModel);
			currentWay.shift = pressShift;
			targetWay = null;
			ai.setCurrentModel(currentModel);
		}
		
		private function updateNoticeListener(e:ObstacleEvent):void
		{
			notice = gameModel.obstacleNotice + gameModel.obstacleNoticeSave;
		}
		
		public function setMaterialization(index:int):void
		{
			materialization[index] = true;
		}
		
		public function issueGameCommand():GameCommand 
		{
			var ret:GameCommand = new GameCommand(materialization);
			materialization = new Vector.<Boolean>(GameCommand.materializationLength);
			ret.noDamege = pressShift;
			if (pressFall) ret.falling = GameCommand.fast;
			restDelay--;
			if (restDelay > 0) return ret;
			if (!controlPhase) return ret;
			if (targetWay == null)
			{
				ai.consider();
				var choices:Vector.<AppraiseTree> = ai.getChoices(notice);
				if (choices.length > 0)
				{
					var index:int = Math.random() * choices.length;
					targetWay = choices[index].way;
					verge = choices[index].fr.verge;
				}
				else
				{
					targetWay = new ControlWay();
					verge = false;
				}
			}
			if (currentWay.dir == targetWay.dir && currentWay.lx == targetWay.lx && currentWay.shift == targetWay.shift)
			{
				if (fallDelay)
				{
					ret.falling = GameCommand.fast;
					pressFall = true;
				}
				else
				{
					ret.falling = GameCommand.earth;
					ret.fix = true;
				}
			}
			completedSeparate = false;
			completedMove = false;
			if (currentWay.dir != targetWay.dir && !isSeparateDelay())
			{
				completedSeparate = true;
				ret.rotation = targetWay.dir == 3 ? GameCommand.right : GameCommand.left;
				currentWay = ControlWay.getRotate(currentWay, currentModel, ret.rotation);
			}
			var slx:int = currentWay.lx - targetWay.lx;
			if (slx != 0 && !isSeparateDelay())
			{
				completedMove = true;
				completedSeparate = true;
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
			}
			if (currentWay.shift != targetWay.shift && !isSeparateDelay())
			{
				completedSeparate = true;
				pressShift = !pressShift;
				currentWay.shift = pressShift;
				ret.noDamege = pressShift;
			}
			if (primaryMove)
			{
				restDelay = isFastMove() ? primaryMoveDelay : moveDelay;
				if (completedMove)
				{
					primaryMove = false;
				}
			}
			else if (currentWay.lx == targetWay.lx)
			{
				restDelay = moveDelay == 0 ? secondaryMoveDelay : moveDelay;
			}
			else
			{
				restDelay = isFastMove() ? secondaryMoveDelay : moveDelay;
			}
			return ret;
		}	
	}
}