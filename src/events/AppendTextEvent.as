package events 
{
	import flash.events.Event;
	import flash.events.TextEvent;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class AppendTextEvent extends TextEvent 
	{
		public static const appendLog:String = "appendLog";
		public static const appendChat:String = "appendChat";
		
		public function AppendTextEvent(type:String, text:String) 
		{ 
			super(type, false, false, text);
		} 
		
		public override function clone():Event 
		{ 
			return new AppendTextEvent(type, text);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("appendLogEvent", "type", "bubbles", "cancelable", "text", "eventPhase"); 
		}
		
	}
	
}