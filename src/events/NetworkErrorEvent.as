package events {
	import flash.events.*;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class NetworkErrorEvent extends ErrorEvent
	{
		public static const connectFailed:String = "connectFailed";
		public static const connectRejected:String = "connectRejected";
		public static const ioError:String = "ioError";
		public static const asyncError:String = "asyncError";
		public static const gameAbort:String = "gameAbort";
		public static const differPassword:String = "differPassword";
		
		public function NetworkErrorEvent(type:String, text:String = "") 
		{ 
			super(type, false, false, text, 0);
		} 
		
		public override function clone():Event 
		{ 
			return new NetworkErrorEvent(type, text);
		} 
	}
	
}