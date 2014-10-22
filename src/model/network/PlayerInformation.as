package model.network {
	/**
	 * ...
	 * @author B_head
	 */
	public class PlayerInformation 
	{
		public var peerID:String;
		public var name:String;
		public var isAI:Boolean;
		public var rate:Number;
		public var currentRoomID:String;
		public var currentBattleIndex:int;
		
		private static const gradeList:Vector.<String> = new <String>[
			"十級", "十級", "九級", "八級", "七級", "六級", "五級", "四級", "三級", "二級", "一級", 
			"初段", "二段", "三段", "四段", "五段", "六段", "七段", "八段", "九段", "十段"
		]; 
		
		public function PlayerInformation(peerID:String = "", name:String = "", isAI:Boolean = false) 
		{
			this.peerID = peerID;
			this.name = name;
			this.isAI = isAI;
		}
		
		public function getName():String
		{
			if (name == null || name == "")
			{
				if (isAI)
				{
					return "コンピューター";
				}
				else
				{
					return "ゲスト" + peerID.slice(0, 5);
				}
			}
			else
			{
				return name;
			}
		}
		
		public function get grade():String
		{
			var a:int = Math.max(0, Math.min(rate, 20));
			return gradeList[a];
		}
	}

}