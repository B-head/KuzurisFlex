package events {
	import flash.events.Event;
	import model.GameSetting;
	/**
	 * ...
	 * @author B_head
	 */
	public class BreakLineEvent extends GameEvent
	{
		private var setting:GameSetting;
		[Bindable]
		public var line:int;
		[Bindable]
		public var comboCount:int;
		public var position:int;
		public var colors:Vector.<uint>;
		
		public static const breakLine:String = "breakLine";
		public static const sectionBreakLine:String = "sectionBreakLine";
		public static const totalBreakLine:String = "totalBreakLine";
		public static const technicalSpin:String = "technicalSpin";
		
		public function BreakLineEvent(type:String, gameTime:int, plusScore:int, setting:GameSetting, line:int, comboCount:int, position:int = int.MIN_VALUE, colors:Vector.<uint> = null) 
		{ 
			super(type, gameTime, plusScore);
			this.setting = setting;
			this.line = line;
			this.comboCount = comboCount;
			this.position = position;
			this.colors = colors;
		} 
		
		public override function clone():Event 
		{ 
			return new BreakLineEvent(type, gameTime, plusScore, setting, line, comboCount, position, colors)
		}
		
		public function powerLevel():int
		{
			return setting.powerLevel(line, comboCount);
		}
		
		public function powerScale():Number
		{
			return setting.powerScale(line, comboCount);;
		}
		
		public function occurObstacle():int
		{
			return setting.occurObstacleCount(line, comboCount);;
		}
	}

}