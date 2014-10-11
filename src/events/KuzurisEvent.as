package events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class KuzurisEvent extends Event 
	{
		public static const gameReady:String = "gameReady";
		public static const gameStart:String = "gameStart";
		public static const gameEnd:String = "gameEnd";
		public static const gamePause:String = "gamePause";
		public static const gameResume:String = "gameResume";
		public static const initializeGameModel:String = "initializeGameModel";
		public static const loungeConnectSuccess:String = "loungeConnectSuccess";
		public static const connectClosed:String = "connectClosed";
		public static const connectIdleTimeout:String = "connectIdleTimeout";
		public static const agreePassword:String = "agreePassword";
		public static const roomConnectSuccess:String = "roomConnectSuccess";
		public static const playerUpdate:String = "playerUpdate";
		public static const connectNeighbor:String = "connectNeighbor";
		public static const disconnectNeighbor:String = "disconnectNeighbor";
		public static const gameSync:String = "gameSync";
		public static const gameSyncReply:String = "gameSyncReply";
		public static const navigateBack:String = "navigateBack";
		public static const pressPauseKey:String = "pressPauseKey";
		
		public function KuzurisEvent(type:String) 
		{ 
			super(type, false, false);
		} 
		
		public override function clone():Event 
		{ 
			return new KuzurisEvent(type);
		}
		
	}
	
}