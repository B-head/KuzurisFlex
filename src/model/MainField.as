package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class MainField extends BlockField 
	{
		public function MainField(w:int = 0, h:int = 0) 
		{
			super(w, h);
		}
		
		public function clone():MainField
		{
			var ret:MainField = new MainField(_width, _height);
			copyTo(ret);
			return ret;
		}
		
		public function isFillLine(y:int):Boolean
		{
			for (var x:int = 0; x < _width; x++)
			{
				if (value[x][y] == null)
				{
					return false;
				}
			}
			return true;
		}
		
		public function clearLine(y:int):Vector.<uint>
		{
			var colors:Vector.<uint> = new Vector.<uint>(_width, true);
			for (var x:int = 0; x < _width; x++)
			{
				colors[x] = value[x][y].color;
				value[x][y] = null;
			}
			return colors;
		}
		
		public function clearSpecialUnion(onClearSpecialUnion:Function = null):void
		{
			for (var x:int = 0; x < _width; x++)
			{
				for (var y:int = 0; y < _height; y++)
				{
					var old:BlockState = value[x][y];
					if (old == null || old.specialUnion == false)
					{
						continue;
					}
					var v:BlockState = old.clone();
					v.specialUnion = false;
					value[x][y] = v;
					if (onClearSpecialUnion != null) onClearSpecialUnion(v, old);
				}
			}
		}
		
		public function extractConnection(to:MainField, x:int, y:int, 
			upperConnect:Boolean, specialUnion:Boolean = false, first:Boolean = true):int
		{
			if (x < 0) return 0;
			if (x >= _width) return 0;
			if (y < 0) return 0;
			if (y >= _height) return 0;
			var v:BlockState = value[x][y];
			if (v == null) return 0;
			if (first == true)
			{
				specialUnion = v.specialUnion;
			}
			var count:int = 1;
			if (v.hitPoint > 0 && specialUnion == v.specialUnion)
			{
				to.value[x][y] = v;
				value[x][y] = null;
				count += extractConnection(to, x + 1, y, upperConnect, specialUnion, false);
				count += extractConnection(to, x - 1, y, upperConnect, specialUnion, false);
				count += extractConnection(to, x, y + 1, upperConnect, specialUnion, false);
				count += extractConnection(to, x, y - 1, upperConnect, specialUnion, upperConnect ? true : false);
			}
			else
			{
				if (first == false) return 0;
				to.value[x][y] = v;
				value[x][y] = null;
				if (upperConnect == true)
				{
					count += extractConnection(to, x, y - 1, upperConnect, specialUnion, true);
				}
			}
			return count;
		}
		
		public function setLine(line:int, blocks:Vector.<BlockState>):void
		{
			for (var i:int = 0; i < width; i++)
			{
				value[i][line] = blocks[i];
			}
		}
		
		public function shiftUp(line:int):void
		{
			for (var y:int = 1; y <= line; y++)
			{
				for (var x:int = 0; x < _width; x++)
				{
					value[x][y - 1] = value[x][y];
				}
			}
			for (x = 0; x < _width; x++)
			{
				value[x][line] = null;
			}
		}
		
		public function getHeight():int
		{
			for (var y:int = 0; y < _height; y++)
			{
				for (var x:int = 0; x < _width; x++)
				{
					if (value[x][y] != null) return y;
				}
			}
			return _height;
		}
		
		public function getColorHeight(color:uint):int
		{
			for (var y:int = 0; y < _height; y++)
			{
				for (var x:int = 0; x < _width; x++)
				{
					if (value[x][y] == null) continue;
					if (value[x][y].color == color) return y;
				}
			}
			return _height;
		}
	}

}