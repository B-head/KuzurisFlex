package events {
	import flash.events.*;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class KuzurisErrorEvent extends ErrorEvent
	{
		public static const ioError:String = "ioError";
		public static const asyncError:String = "asyncError";
		public static const connectFailed:String = "connectFailed";
		public static const loungeConnectFailed:String = "loungeConnectFailed";
		public static const roomConnectFailed:String = "roomConnectFailed";
		public static const notEqualHash:String = "notEqualHash";
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