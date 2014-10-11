package model 
{
	import mx.collections.*;
	/**
	 * ...
	 * @author B_head
	 */
	public final class GameRecord 
	{
		[Bindable] 
		public var level:int;
		[Bindable] 
		public var breakLine:int;
		[Bindable] 
		public var comboLines:ArrayCollection;
		[Bindable] 
		public var blockDamage:int;
		[Bindable] 
		public var fixOmino:int;
		[Bindable] 
		public var occurObstacle:int;
		[Bindable] 
		public var counterbalance:int;
		[Bindable] 
		public var receivedObstacle:int;
		[Bindable] 
		public var gameScore:int;
		[Bindable] 
		public var gameTime:int;
		[Bindable] 
		public var controlTime:int;
		
		[Bindable] 
		public var playerName:String;
		[Bindable] 
		public var replay:GameReplay;
		public var gameClear:Boolean;
		
		private const minuteFrame:int = 3600;
		
		public function GameRecord()
		{
			var arr:Array = new Array();
			for (var i:int = 0; i < 21; i++)
			{
				arr.push(0);
			}
			comboLines = new ArrayCollection(arr);
		}
		
		public function ominoPerMinute():Number
		{
			return fixOmino * minuteFrame / gameTime;
		}
		
		public function ominoPerControlMinute():Number
		{
			return fixOmino * minuteFrame / controlTime;
		}
		
		public function occurPerMinute():Number
		{
			return occurObstacle * minuteFrame / gameTime;
		}
		
		public function occurPerControlMinute():Number
		{
			return occurObstacle * minuteFrame / controlTime;
		}
	}
}