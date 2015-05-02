package network {
	import events.KuzurisEvent;
	import common.EventDispatcherEX;
	import model.GameRecord;
	/**
	 * ...
	 * @author B_head
	 */ 
	public class PlayerInformation extends EventDispatcherEX
	{
		public var peerID:String;
		[Bindable]
		public var name:String;
		public var isAI:Boolean;
		public var recentRate:Vector.<Number>;
		[Bindable]
		public var winCount:int;
		public var currentRoomID:String;
		public var currentBattleIndex:int;
		public var hostPriority:int;
		
		private static const gradeList:Vector.<String> = new <String>[
			"十級", "十級", "九級", "八級", "七級", "六級", "五級", "四級", "三級", "二級", "一級", 
			"初段", "二段", "三段", "四段", "五段", "六段", "七段", "八段", "九段", "十段"
		]; 
		
		public function PlayerInformation(peerID:String = "", name:String = "", isAI:Boolean = false) 
		{
			this.peerID = peerID;
			this.name = name;
			this.isAI = isAI;
			recentRate = new Vector.<Number>();
		}
		
		public static function containPlayer(p1:PlayerInformation, p2:PlayerInformation):Boolean
		{
			if (p1 == null)
			{
				if (p2 == null) return true;
				return false;
			}
			if (p2 == null) return false;
			return p1.peerID == p2.peerID;
		}
		
		public function clone():PlayerInformation
		{
			return new PlayerInformation(peerID, name, isAI);
		}
		
		public function getName():String
		{
			if (name == null || name == "")
			{
				return makeDefaultName();
			}
			else
			{
				return name;
			}
		}
		
		public function makeDefaultName():String
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
		
		public function appendRate(record:GameRecord):void
		{
			var rate:Number = 0;
			rate += record.ominoPerControlMinute() * 10;
			rate += record.occurPerControlMinute();
			rate /= 150;
			recentRate.push(rate);
			if (recentRate.length > 10) recentRate.shift();
			dispatchEvent(new KuzurisEvent("updateRate"));
		}
		
		[Bindable(event="updateRate")]
		public function get grade():String
		{
			var rate:Number = 0;
			for (var i:int = 0; i < recentRate.length; i++)
			{
				rate = Math.max(rate, recentRate[i]);
			}
			var a:int = Math.max(0, Math.min(rate, 20));
			return gradeList[a];
		}
	}

}