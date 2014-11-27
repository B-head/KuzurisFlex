package model 
{
	import flash.events.Event;
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	/**
	 * ...
	 * @author B_head
	 */
	public class GameRanking
	{
		public static const recordsLength:int = 100;
		
		public var gameMode:String;
		public var endless:Boolean;
		public var records:Array;
		
		public function GameRanking(gameMode:String = null, endless:Boolean = false) 
		{
			this.gameMode = gameMode;
			this.endless = endless;
			records = new Array();
		}
		
		public function entry(record:GameReplayContainer):void
		{
			records.push(record);
			sortScore();
			var a:Array = records.slice(recordsLength);
			sortTime();
			var b:Array = records.slice(recordsLength);
			var c:Array = product(a, b);
			removeRange(records, c);
		}
		
		public function sortScore():void
		{
			records.sort(compScore);
		}
		
		private function compScore(a:GameReplayContainer, b:GameReplayContainer):Number
		{
			return b.record[0].gameScore - a.record[0].gameScore;
		}
		
		public function sortTime():void
		{
			records.sort(compTime);
		}
		
		private function compTime(a:GameReplayContainer, b:GameReplayContainer):Number
		{
			if (a.isGameClear() && b.isGameClear())
			{
				return a.record[0].gameTime - b.record[0].gameTime;
			}
			else
			{
				return b.record[0].breakLine - a.record[0].breakLine;
			}
		}
		
		private function product(a:Array, b:Array):Array
		{
			var ret:Array = new Array();
			for (var i:int = 0; i < a.length; i++)
			{
				var k:int = b.indexOf(a[i]);
				if (k == -1) continue;
				ret.push(a[i]);
			}
			return ret;
		}
		
		private function removeRange(self:Array, values:Array):void
		{
			for (var i:int = 0; i < values.length; i++)
			{
				var k:int = self.indexOf(values[i]);
				if (k == -1) continue;
				self.splice(k, 1);
			}
		}
	}
}