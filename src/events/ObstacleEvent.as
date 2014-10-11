package events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class ObstacleEvent extends GameEvent 
	{
		public var count:int;
		
		public static const addObstacle:String = "addObstacle";
		public static const breakConboNotice:String = "breakConboNotice";
		public static const materializationNotice:String = "materializationNotice";
		public static const preMaterializationNotice:String = "preMaterializationNotice";
		public static const occurObstacle:String = "occurObstacle";
		public static const counterbalanceObstacle:String = "counterbalanceObstacle";
		public static const obstacleFall:String = "obstacleFall";
		
		public function ObstacleEvent(type:String, gameTime:int, plusScore:int, count:int) 
		{ 
			super(type, gameTime, plusScore);
			this.count = count;
		} 
		
		public override function clone():Event 
		{ 
			return new ObstacleEvent(type, gameTime, plusScore, count);
		} 
	}
	
}