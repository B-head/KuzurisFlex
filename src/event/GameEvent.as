package event 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class GameEvent extends Event 
	{
		public var gameTime:int;
		public var plusScore:int;
		
		public static const forwardGame:String = "forwardGame";
		public static const gameOver:String = "gameOver";
		public static const gameClear:String = "gameClear";
		public static const fixOmino:String = "fixOmino"; 
		public static const setOmino:String = "setOmino";
		public static const breakConbo:String = "breakConbo";
		public static const extractFall:String = "extractFall";
		public static const obstacleFall:String = "obstacleFall";
		
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