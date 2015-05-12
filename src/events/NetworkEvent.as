package events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class NetworkEvent extends Event 
	{
		public static const connectSuccess:String = "connectSuccess";
		public static const connectClosed:String = "connectClosed";
		public static const idleTimeout:String = "idleTimeout";
		public static const networkChange:String = "networkChange";
		public static const firstConnectNeighbor:String = "firstConnectNeighbor";
		public static const disposed:String = "disposed";
		public static const announceClock:String = "announceClock";
		public static const deficiencyCommnad:String = "deficiencyCommnad";
		public static const differHashCommnad:String = "differHashCommnad";
		public static const differHashGameModel:String = "differHashGameModel";
		public static const agreePassword:String = "agreePassword";
		public static const beginSync:String = "beginSync";
		
		public function NetworkEvent(type:String) 
		{ 
			super(type, false, false);
		} 
		
		public override function clone():Event 
		{ 
			return new NetworkEvent(type);
		}
		
	}
	
}