package events 
{
	import flash.events.Event;
	import flash.events.TextEvent;
	import network.Utterance;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class UpdateChatEvent extends Event 
	{	
		public static const appendChat:String = "appendChat";
		
		public var utterance:Utterance;
		
		public function UpdateChatEvent(type:String, utterance:Utterance) 
		{
			super(type, false, false);
			this.utterance = utterance;
		}
		
		public override function clone():Event 
		{ 
			return new UpdateChatEvent(type, utterance);
		} 
		
	}

}