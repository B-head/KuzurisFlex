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
		
		public function Rect(left:int, top:int, right:int, bottom:int)
		{
			this.left = left;
			this.top = top;
			this.right = right;
			this.bottom = bottom;
		}
		
		public function get width():int
		{
			return right - left + 1;
		}
		
		public function get height():int
		{
			return bottom - top + 1;
		}
		
		public function get centerX():int
		{
			return (right + left) / 2;
		}
		
		public function get centerY():int
		{
			return (bottom + top) / 2;
		}
	}

}