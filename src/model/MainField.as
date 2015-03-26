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
			var ret:MainField = new MainField(_maxWidth, _maxHeight);
			copyTo(ret);
			return ret;
		}
		
		public function isBreakLine(y:int):Boolean
		{
			if (_left != 0 || _right != maxWidth - 1) return false;
			for (var x:int = _left; x <= _right; x++)
			{
				if (value[x][y].isNonBreak())
				{
					return false;
				}
			}
			return true;
		}
		
		public function clearLine(y:int):Vector.<uint>
		{
			var colors:Vector.<uint> = new Vector.<uint>(_maxWidth, true);
			for (var x:int = _left; x <= _right; x++)
			{
				colors[x] = value[x][y].color;
				clearState(x, y);
			}
			return colors;
		}
		
		public function clearSpecialUnion():void
		{
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					var v:BlockState = value[x][y];
					if (v.isEmpty() || v.specialUnion == false)
					{
						continue;
					}
					v.specialUnion = false;
				}
			}
		}
		
		public function extractConnection(to:MainField, x:int, y:int, upperConnect:Boolean):int
		{
			var ret:int = extractConnectionPart(to, x, y, upperConnect, false, true)
			setRect();
			to.setRect();
			return ret;
		}
		
		public function extractConnectionPart(to:MainField, x:int, y:int, 
			upperConnect:Boolean, specialUnion:Boolean, first:Boolean):int
		{
			if (x < 0) return 0;
			if (x >= _maxWidth) return 0;
			if (y < 0) return 0;
			if (y >= _maxHeight) return 0;
			var v:BlockState = value[x][y];
			if (v.isEmpty()) return 0;
			if (first == true)
			{
				specialUnion = v.specialUnion;
			}
			var count:int = 1;
			if (v.hitPoint > 0 && specialUnion == v.specialUnion)
			{
				to.setState(x, y, v);
				clearState(x, y);
				count += extractConnectionPart(to, x + 1, y, upperConnect, specialUnion, false);
				count += extractConnectionPart(to, x - 1, y, upperConnect, specialUnion, false);
				count += extractConnectionPart(to, x, y + 1, upperConnect, specialUnion, false);
				count += extractConnectionPart(to, x, y - 1, upperConnect, specialUnion, upperConnect ? true : false);
			}
			else
			{
				if (first == false) return 0;
				to.setState(x, y, v);
				clearState(x, y);
				if (upperConnect == true)
				{
					count += extractConnectionPart(to, x, y - 1, upperConnect, specialUnion, true);
				}
			}
			return count;
		}
		
		public function setNewBlock(x:int, y:int, block:BlockState):void
		{
			block.setId();
			setState(x, y, block);
			setRect();
		}
		
		public function isEmptyLine(y:int):Boolean
		{
			for (var x:int = 0; x < _maxWidth; x++)
			{
				if (!value[x][y].isEmpty()) return false;
			}
			return true;
		}
		
		public function setLine(line:int, blocks:Vector.<BlockState>):void
		{
			for (var i:int = 0; i < maxWidth; i++)
			{
				if (blocks[i].isEmpty()) continue;
				blocks[i].setId();
				setState(i, line, blocks[i]);
			}
			setRect();
		}
		
		public function shiftUp(line:int):void
		{
			for (var y:int = 1; y <= line; y++)
			{
				for (var x:int = 0; x < _maxWidth; x++)
				{
					setState(x, y - 1, value[x][y]);
				}
			}
			for (x = 0; x < _maxWidth; x++)
			{
				clearState(x, line);
			}
			setRect();
		}
		
		public function getHeight():int
		{
			for (var y:int = 0; y < _maxHeight; y++)
			{
				for (var x:int = 0; x < _maxWidth; x++)
				{
					if (!value[x][y].isEmpty()) return y;
				}
			}
			return _maxHeight;
		}
		
		public function getTypeHeight(type:int):int
		{
			for (var y:int = 0; y < _maxHeight; y++)
			{
				for (var x:int = 0; x < _maxWidth; x++)
				{
					if (value[x][y].isEmpty()) continue;
					if (value[x][y].type == type) return y;
				}
			}
			return _maxHeight;
		}
		
		public function getTypeCount(type:uint):int
		{
			var count:int = 0;
			for (var y:int = 0; y < _maxHeight; y++)
			{
				for (var x:int = 0; x < _maxWidth; x++)
				{
					if (value[x][y].isEmpty()) continue;
					if (value[x][y].type == type) count++;
				}
			}
			return count;
		}
	}

}