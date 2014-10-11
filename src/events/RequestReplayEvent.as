package events {
	import flash.events.Event;
	import model.GameReplay;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class RequestReplayEvent extends Event 
	{
		public var data:GameReplay;
		
		public static const requestReplay:String = "requestReplay";
		
		public function RequestReplayEvent(type:String, data:GameReplay) 
		{ 
			super(type, false, false);
			this.data = data;
		} 
		
		public override function clone():Event 
		{ 
			return new RequestReplayEvent(type, data);
		} 
	}
}