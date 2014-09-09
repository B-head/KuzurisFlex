package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class Rect 
	{
		public var left:int;
		public var top:int;
		public var right:int;
		public var bottom:int;
		
		public function get width():int
		{
			return right - left + 1;
		}
		
		public function get height():int
		{
			return bottom - top + 1;
		}
	}

}