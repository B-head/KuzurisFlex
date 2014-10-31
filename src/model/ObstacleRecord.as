package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class ObstacleRecord
	{
		public static const occur:int = 0;
		public static const received:int = 1;
		public static const trialObstacle:int = 2;
		
		public var type:int;
		public var count:int;
		public var gameTime:int;
		public var sequence:int;
		
		public function ObstacleRecord(type:int = 0, count:int = 0, gameTime:int = 0, sequence:int = 0)
		{
			this.type = type;
			this.count = count;
			this.gameTime = gameTime;
			this.sequence = sequence;
		}
	}

}