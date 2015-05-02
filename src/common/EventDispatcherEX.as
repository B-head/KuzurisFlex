package common {
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class EventDispatcherEX extends EventDispatcher 
	{
		private var listeners:Vector.<Object>;
		
		public function EventDispatcherEX(target:IEventDispatcher = null) 
		{
			super(target);
			listeners = new Vector.<Object>();
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			listeners.push( { type: type, listener:listener, useCapture:useCapture } );
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
		{
			super.removeEventListener(type, listener, useCapture);
			for (var i:int = 0; i < listeners.length; i++)
			{
				var v:Object = listeners[i];
				if (v.type === type && v.listener === listener && v.useCapture === useCapture)
				{
					break;
				}
			}
			if (i < listeners.length)
			{
				listeners.splice(i, 1);
			}
		}
		
		public function removeAll():void
		{
			for (var i:int = 0; i < listeners.length; i++)
			{
				var v:Object = listeners[i];
				super.removeEventListener(v.type, v.listener, v.useCapture);
			}
			listeners.splice(0, listeners.length);
		}
		
		public function addTerget(type:String, listener:Function, useWeakReference:Boolean = true, priority:int = 0):void
		{
			addEventListener(type, listener, false, priority, useWeakReference);
		}
		
		public function addCapture(type:String, listener:Function, useWeakReference:Boolean = true, priority:int = 0):void
		{
			addEventListener(type, listener, true, priority, useWeakReference);
		}
		
		public function removeTerget(type:String, listener:Function):void
		{
			removeEventListener(type, listener, false);
		}
		
		public function removeCapture(type:String, listener:Function):void
		{
			removeEventListener(type, listener, true);
		}
	}

}