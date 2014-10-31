package events {
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
		public static const updateObstacle:String = "updateObstacle";
		public static const outsideUpdateObstacle:String = "outsideUpdateObstacle";
		public static const enabledObstacle:String = "enabledObstacle";
		public static const gameOver:String = "gameOver";
		public static const gameClear:String = "gameClear";
		public static const breakChain:String = "breakChain";
		public static const breakCombo:String = "breakCombo";
		public static const extractFall:String = "extractFall";
		public static const obstacleFall:String = "obstacleFall";
		public static const appendTower:String = "appendTower";
		public static const blockAllClear:String = "blockAllClear";
		
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