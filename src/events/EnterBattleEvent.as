package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class EnterBattleEvent extends Event 
	{
		public static const enterBattle:String = "enterBattle";
		
		public var playerIndex:int;
		
		public function EnterBattleEvent(type:String, playerIndex:int) 
		{ 
			super(type, false, false);
			this.playerIndex = playerIndex;
		} 
		
		public override function clone():Event 
		{ 
			return new EnterBattleEvent(type, playerIndex);
		} 
	}
	
}