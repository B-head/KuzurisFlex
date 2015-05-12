package events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class GameSyncEvent extends Event 
	{
		public var localTime:uint;
		public var delayTime:uint;
		
		public static const gameSync:String = "gameSync";
		
		public function GameSyncEvent(type:String, localTime:uint, delayTime:uint) 
		{ 
			super(type, false, false);
			this.localTime = localTime;
			this.delayTime = delayTime;
		} 
		
		public override function clone():Event 
		{ 
			return new GameSyncEvent(type, localTime, delayTime);
		}
		
	}
	
}