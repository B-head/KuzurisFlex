package event 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class GameEvent extends Event 
	{
		[Bindable]
		public var gameTime:int;
		[Bindable]
		public var plusScore:int;
		
		public static const forwardGame:String = "forwardGame";
		public static const updateField:String = "updateField";
		public static const updateControl:String = "updateControl";
		public static const updateNext:String = "updateNext";
		public static const firstUpdateNext:String = "firstUpdateNext";
		public static const gameOver:String = "gameOver";
		public static const gameClear:String = "gameClear";
		public static const breakConbo:String = "breakConbo";
		public static const extractFall:String = "extractFall";
		
		public function GameEvent(type:String, gameTime:int, plusScore:int) 
		{ 
			super(type, false, false);
			this.gameTime = gameTime;
			this.plusScore = plusScore;
		} 
		
		public override function clone():Event 
		{ 
			return new GameEvent(type, gameTime, plusScore);
		} 
	}
	
}