package event 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author B_head
	 */
	public class LevelClearEvent extends GameEvent
	{
		[Bindable] 
		public var clearTime:int;
		[Bindable] 
		public var upLevel:int;
		
		public static const levelClear:String = "levelClear";
		public static const stageClear:String = "stageClear";
		
		public function LevelClearEvent(type:String, gameTime:int, plusScore:int, clearTime:int, upLevel:int) 
		{ 
			super(type, gameTime, plusScore);
			this.clearTime = clearTime;
			this.upLevel = upLevel;
		} 
		
		public override function clone():Event 
		{ 
			return new LevelClearEvent(type, gameTime, plusScore, clearTime, upLevel);
		} 
	}

}