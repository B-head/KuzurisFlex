package events {
	import flash.events.Event;
	/**
	 * ...
	 * @author B_head
	 */
	public class BreakLineEvent extends GameEvent
	{
		[Bindable]
		public var comboTotalLine:int;
		[Bindable]
		public var comboCount:int;
		public var position:int;
		public var colors:Vector.<uint>;
		
		public static const breakLine:String = "breakLine";
		public static const sectionBreakLine:String = "sectionBreakLine";
		public static const totalBreakLine:String = "totalBreakLine";
		
		public function BreakLineEvent(type:String, gameTime:int, plusScore:int, comboTotalLine:int, comboCount:int, position:int = int.MIN_VALUE, colors:Vector.<uint> = null) 
		{ 
			super(type, gameTime, plusScore);
			this.comboTotalLine = comboTotalLine;
			this.comboCount = comboCount;
			this.position = position;
			this.colors = colors;
		} 
		
		public override function clone():Event 
		{ 
			return new BreakLineEvent(type, gameTime, plusScore, comboTotalLine, comboCount, position, colors)
		}
		
		public function powerLevel():int
		{
			return comboTotalLine - comboCount;
		}
		
		public function powerScale():Number
		{
			return (powerLevel() + 3) / 4;
		}
		
		public function occurObstacle():int
		{
			return 10 * comboTotalLine * powerScale();
		}
	}

}