package common {
	/**
	 * ...
	 * @author B_head
	 */
	public class Utility 
	{
		public static function global_trace(...args):void
		{
			trace.apply(null, args);
		}
		
		public static function join(separator:String, ...args):String
		{
			var ret:String = new String();
			for (var i:int = 0; i < args.length; i++)
			{
				if (i > 0) ret += separator;
				ret += args[i].toString();
			}
			return ret;
		}
		
	}

}