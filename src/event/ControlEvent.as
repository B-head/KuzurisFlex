package event 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author B_head
	 */
	public class ControlEvent extends GameEvent 
	{
		public var fromX:Number;
		public var fromY:Number;
		
		public static const moveOK:String = "moveOK";
		public static const moveNG:String = "moveNG";
		public static const fallingShock:String = "fallingShock";
		public static const fallingShockSave:String = "fallingShockSave";
		public static const rotationOK:String = "rotationOK";
		public static const rotationNG:String = "rotationNG";
		public static const shockSaveON:String = "shockSaveON";
		public static const shockSaveOFF:String = "shockSaveOFF";
		
		public function ControlEvent(type:String, gameTime:int, plusScore:int, fromX:Number, fromY:Number) 
		{
			super(type, gameTime, plusScore);
			this.fromX = fromX;
			this.fromY = fromY;
		}
		
		public override function clone():Event
		{ 
			return new ControlEvent(type, gameTime, plusScore, fromX, fromY);
		} 
	}

}