package view 
{
	import mx.formatters.Formatter;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class FrameTimeFormatter extends Formatter 
	{
		public var frameRate:int;
		
		override public function format(value:Object):String
		{
			return frameToTimeString(int(value));
		}
		
		public function frameToTimeString(frame:int):String
		{
			var secondsRate:int = 60 * frameRate;
			var minutes:int = Math.floor(frame / secondsRate);
			var seconds:int = Math.floor(frame % secondsRate / frameRate);
			var milliseconds:int = Math.floor((frame % frameRate) * 100 / frameRate);
			var ret:String = "";
			if (frame >= secondsRate)
			{
				ret += String(minutes) + ":";
				ret += padLeft(String(seconds), 2, "0") + ".";
				ret += padLeft(String(milliseconds), 2, "0");
			}
			else
			{
				ret += String(seconds) + ".";
				ret += padLeft(String(milliseconds), 2, "0");
			}
			return ret;
		}
		
		private function padLeft(str:String, count:int, padChar:String):String
		{
			var ret:String = "";
			var add:int = count - str.length;
			if (add <= 0) return str;
			for (var i:int = 0; i < add; i++)
			{
				ret += padChar;
			}
			ret += str;
			return ret;
		}
		
	}

}