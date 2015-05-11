package common 
{
	import events.AppendTextEvent;
	
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="appendLog", type="events.AppendLogEvent")]
	public class Debug extends EventDispatcherEX
	{
		private static var dispatcher:Debug = new Debug();
		
		public static function trace(...args):void
		{
			var text:String = args.join(" ");
			dispatch(text);
			Utility.global_trace(text);
		}
		
		public static function assert(cond:*, msg:String = null):void
		{
			if (Boolean(cond)) return;
			fail(msg);
		}
		
		public static function fail(msg:String = null):void
		{
			if (msg == null) msg = "assertion failed";
			var error:Error = new Error(msg);
			var stackTrace:String = error.getStackTrace();
			if (stackTrace == null) stackTrace = error.toString();
			trace(stackTrace);
			throw error;
		}
		
		public static function addListener(listener:Function, useWeakReference:Boolean = true):void
		{
			dispatcher.addTerget(AppendTextEvent.appendLog, listener, useWeakReference);
		}
		
		public static function removeListener(listener:Function):void
		{
			dispatcher.removeTerget(AppendTextEvent.appendLog, listener);
		}
		
		private static function dispatch(text:String):void
		{
			dispatcher.dispatchEvent(new AppendTextEvent(AppendTextEvent.appendLog, text));
		}
	}
}