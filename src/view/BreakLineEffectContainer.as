package view 
{
	import events.BreakLineEvent;
	import events.GameEvent;
	import model.GameModel;
	import mx.core.UIComponent;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class BreakLineEffectContainer extends UIComponent 
	{
		[Bindable]
		public var breakLineGraphics:BreakLineGraphics;
		[Bindable]
		public var breakBlockGraphics:BreakBlockGraphics;
		private var _gameModel:GameModel;
		private var effects:Vector.<BreakLineEffect>;
		private var ready:Vector.<BreakLineEffect>;
		
		public function BreakLineEffectContainer() 
		{
			effects = new Vector.<BreakLineEffect>();
			ready = new Vector.<BreakLineEffect>();
		}
		
		public function get gameModel():GameModel
		{
			return _gameModel;
		}
		public function set gameModel(value:GameModel):void
		{
			_gameModel = value;
			_gameModel.addTerget(BreakLineEvent.breakLine, breakLineListener);
			_gameModel.addTerget(BreakLineEvent.sectionBreakLine, sectionBreakLineListener);
			for (var i:int = 0; i < effects.length; i++)
			{
				effects[i].reset();
			}
		}
		
		public function update():void
		{
			for (var i:int = 0; i < effects.length; i++)
			{
				effects[i].update();
			}
		}
		
		public function incrementFrame():void
		{
			for (var i:int = 0; i < effects.length; i++)
			{
				effects[i].count++;
			}
		}
		
		private function breakLineListener(e:BreakLineEvent):void
		{
			var ble:BreakLineEffect = getFreeEfeect();
			ble.start();
			ble.y = e.line * breakLineGraphics.height;
			ble.blockStates = e.blocks;
			ready.push(ble);
		}
		
		private function sectionBreakLineListener(e:BreakLineEvent):void
		{
			var powerLevel:int = Math.min(20, e.powerLevel());
			for (var i:int = 0; i < ready.length; i++)
			{
				ready[i].powerLevel = powerLevel;
			}
			ready.splice(0, ready.length);
		}
		
		private function getFreeEfeect():BreakLineEffect
		{
			for (var i:int = 0; i < effects.length; i++)
			{
				if (effects[i].isFree)
				{
					return effects[i];
				}
			}
			var ret:BreakLineEffect = new BreakLineEffect();
			ret.reset();
			ret.breakLineGraphics = breakLineGraphics;
			ret.breakBlockGraphics = breakBlockGraphics;
			effects.push(ret);
			addChild(ret);
			return ret;
		}
		
	}

}