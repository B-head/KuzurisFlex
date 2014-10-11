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
		
		public function entry(record:GameRecord):void
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
			records.sort(function(a:GameRecord, b:GameRecord):Number { return b.gameScore - a.gameScore; } );
		}
		
		public function sortTime():void
		{
			records.sort(compTime);
		}
		
		private function compTime(a:GameRecord, b:GameRecord):Number
		{
			if (a.gameClear && b.gameClear)
			{
				return a.gameTime - b.gameTime;
			}
			else
			{
				return b.breakLine - a.breakLine;
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