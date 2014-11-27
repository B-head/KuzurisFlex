package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class BattleRecords 
	{
		public static const recordsLength:int = 1000;
		
		public var records:Array;
		
		public function BattleRecords() 
		{
			records = new Array();
		}
		
		public function entry(record:GameReplayContainer):void
		{
			records.unshift(record);
			if (records.length >= recordsLength) records.pop();
		}
		
	}

}