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
		public var comboCount:int;
		[Bindable] 
		public var chainLines:Array;
		[Bindable] 
		public var blockDamage:int;
		[Bindable] 
		public var splitBlock:int;
		[Bindable] 
		public var fixOmino:int;
		[Bindable] 
		public var occurObstacle:int;
		[Bindable] 
		public var receivedObstacle:int;
		[Bindable] 
		public var gameScore:int;
		[Bindable] 
		public var gameTime:int;
		[Bindable] 
		public var controlTime:int;
		
		private const minuteFrame:int = 3600;
		
		public function GameRecord()
		{
			chainLines = new Array();
		}
		
		public function clone():GameRecord
		{
			var ret:GameRecord = new GameRecord();
			ret.level = level;
			ret.breakLine = breakLine;
			ret.comboCount = comboCount;
			ret.chainLines = chainLines.slice();
			ret.blockDamage = blockDamage;
			ret.splitBlock = splitBlock;
			ret.fixOmino = fixOmino;
			ret.occurObstacle = occurObstacle;
			ret.receivedObstacle = receivedObstacle;
			ret.gameScore = gameScore;
			ret.gameTime = gameTime;
			ret.controlTime = controlTime;
			return ret;
		}
		
		public function incrementChainLines(line:int):void
		{
			if (chainLines.length <= line)
			{
				chainLines.length = line + 1;
			}
			chainLines[line] = int(chainLines[line]) + 1;
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