package events 
{
	import flash.events.*;
	import model.*;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class NetworkGameReadyEvent extends Event 
	{
		public static const networkGameReady:String = "networkGameReady";
		
		public var playerIndex:int;
		public var setting:GameSetting;
		public var seed:XorShift128;
		public var delay:int;
		
		public function NetworkGameReadyEvent(type:String, playerIndex:int, setting:GameSetting, seed:XorShift128, delay:int) 
		{ 
			super(type);
			this.playerIndex = playerIndex;
			this.setting = setting;
			this.seed = seed;
			this.delay = delay;
		} 
		
		public override function clone():Event 
		{ 
			return new NetworkGameReadyEvent(type, playerIndex, setting, seed, delay);
		} 
	}
	
}