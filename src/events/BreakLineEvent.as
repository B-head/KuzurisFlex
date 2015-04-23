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
		public var line:int;
		public var total:int;
		public var technicalSpin:int;
		public var combo:int;
		
		public static const breakLine:String = "breakLine";
		public static const sectionBreakLine:String = "sectionBreakLine";
		public static const totalBreakLine:String = "totalBreakLine";
		public static const breakTechnicalSpin:String = "breakTechnicalSpin";
		public static const endCombo:String = "endCombo";
		
		public function BreakLineEvent(type:String, gameTime:int, plusScore:int, setting:GameSetting, line:int, total:int, technicalSpin:int, combo:int) 
		{ 
			super(type, gameTime, plusScore);
			this.setting = setting;
			this.line = line;
			this.total = total;
			this.technicalSpin = technicalSpin;
			this.combo = combo;
		} 
		
		public override function clone():Event 
		{ 
			return new BreakLineEvent(type, gameTime, plusScore, setting, line, total, technicalSpin, combo)
		}
		
		public function powerLevel():int
		{
			return setting.powerLevel(total + technicalSpin, combo);
		}
		
		public function powerScale():Number
		{
			return setting.powerScale(total + technicalSpin, combo);;
		}
		
		public function occurObstacle():int
		{
			return setting.occurObstacleCount(total + technicalSpin, combo);;
		}
		
		public function totalPlusScore():int
		{
			return setting.breakLineScore(total + technicalSpin, combo)
		}
	}

}