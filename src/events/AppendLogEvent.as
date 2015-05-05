package events 
{
	import flash.events.Event;
	import flash.events.TextEvent;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class AppendLogEvent extends TextEvent 
	{
		public static const appendLog:String = "appendLog";
		
		public function AppendLogEvent(type:String, text:String) 
		{ 
			super(type, false, false, text);
		} 
		
		public override function clone():Event 
		{ 
			return new AppendLogEvent(type, text);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("appendLogEvent", "type", "bubbles", "cancelable", "text", "eventPhase"); 
		}
		
	}
	
}