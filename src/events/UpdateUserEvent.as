package events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class UpdateUserEvent extends Event 
	{
		public static const addedUser:String = "addedUser";
		public static const removedUser:String = "removedUser";
		
		public var peerID:String;
		
		public function UpdateUserEvent(type:String, peerID:String) 
		{ 
			super(type, false, false);
			this.peerID = peerID;
		} 
		
		public override function clone():Event 
		{ 
			return new UpdateUserEvent(type, peerID);
		} 
		
	}
	
}