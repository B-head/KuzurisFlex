package events {
	import flash.events.Event;
	import model.GameReplayContainer;
	import model.GameReplayControl;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class RequestReplayEvent extends Event 
	{
		public var data:GameReplayContainer;
		
		public static const requestReplay:String = "requestReplay";
		
		public function RequestReplayEvent(type:String, data:GameReplayContainer) 
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