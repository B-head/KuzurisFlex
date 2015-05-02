package common {
	import model.*;
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
		
		public function Rect(left:int = int.MAX_VALUE, top:int = int.MAX_VALUE, right:int = int.MIN_VALUE, bottom:int = int.MIN_VALUE)
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
		
		public static function getRotate(rect:Rect, rotation:int, size:int):Rect
		{
			var ret:Rect = new Rect();
			var s:int = size - 1;
			if (rotation == GameCommand.left)
			{
				ret.top = s - rect.right;
				ret.left = rect.top;
				ret.bottom = s - rect.left;
				ret.right = rect.bottom;
			}
			else if (rotation == GameCommand.right)
			{
				ret.top = rect.left;
				ret.left = s - rect.bottom;
				ret.bottom = rect.right;
				ret.right = s - rect.top;
			}
			else
			{
				throw new Error();
			}
			return ret;
		}
	}

}