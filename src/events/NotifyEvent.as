package events {
	import flash.events.Event;
	import model.network.MessageObject;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class NotifyEvent extends Event 
	{
		public static const notify:String = "notify";
		
		public var message:MessageObject;
		
		public function NotifyEvent(type:String, message:MessageObject) 
		{ 
			super(type, false, false);
			this.message = message;
		} 
		
		public override function clone():Event 
		{ 
			return new NotifyEvent(type, message);
		} 
		
	}
	
}