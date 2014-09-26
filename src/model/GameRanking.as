package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class GameRanking 
	{
		public static const recordsLength:int = 100;
		
		public var gameMode:String;
		public var endless:Boolean;
		public var records:Vector.<GameRecord>;
		
		public function GameRanking(gameMode:String = null, endless:Boolean = false) 
		{
			this.gameMode = gameMode;
			this.endless = endless;
			records = new Vector.<GameRecord>();
		}
		
		public function entry(record:GameRecord):void
		{
			records.push(record);
			sortScore();
			var a:Vector.<GameRecord> = records.slice(recordsLength);
			sortTime();
			var b:Vector.<GameRecord> = records.slice(recordsLength);
			var c:Vector.<GameRecord> = product(a, b);
			removeRange(records, c);
		}
		
		public function sortScore():void
		{
			records.sort(function(a:GameRecord, b:GameRecord):Number { return b.gameScore - a.gameScore; } );
		}
		
		public function sortTime():void
		{
			records.sort(function(a:GameRecord, b:GameRecord):Number { return a.gameTime - b.gameTime; } );
		}
		
		private function product(a:Vector.<GameRecord>, b:Vector.<GameRecord>):Vector.<GameRecord>
		{
			var ret:Vector.<GameRecord> = new Vector.<GameRecord>();
			for (var i:int = 0; i < a.length; i++)
			{
				var k:int = b.indexOf(a[i]);
				if (k == -1) continue;
				ret.push(a[i]);
			}
			return ret;
		}
		
		private function removeRange(self:Vector.<GameRecord>, values:Vector.<GameRecord>):void
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