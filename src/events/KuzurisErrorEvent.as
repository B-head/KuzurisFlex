package events {
	import flash.events.*;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class KuzurisErrorEvent extends ErrorEvent
	{
		public static const ioError:String = "ioError";
		public static const loungeConnectFailed:String = "loungeConnectFailed";
		public static const roomConnectFailed:String = "roomConnectFailed";
		public static const streamError:String = "streamError";
		public static const differPassword:String = "differPassword";
		
		public function KuzurisErrorEvent(type:String, text:String = "") 
		{ 
			super(type, false, false, text, 0);
			
		} 
		
		public override function clone():Event 
		{ 
			return new KuzurisErrorEvent(type, text);
		} 
	}
	
}