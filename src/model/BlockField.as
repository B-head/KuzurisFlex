package model 
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	/**
	 * ...
	 * @author B_head
	 */
	public class BlockField implements IExternalizable
	{
		protected var value:Vector.<Vector.<BlockState>>;
		protected var _width:int;
		protected var _height:int;
		
		public function BlockField(w:int = 0, h:int = 0)
		{
			value = generateValue(w, h);
			_width = w;
			_height = h;
		}
		
		private function generateValue(w:int, h:int):Vector.<Vector.<BlockState>>
		{
			var result:Vector.<Vector.<BlockState>> = new Vector.<Vector.<BlockState>>(w, true);
			for (var x:int = 0; x < w; x++)
			{
				result[x] = new Vector.<BlockState>(h, true);
			}
			return result;
		}
		
		public function get width():int
		{
			return _width;
		}
		
		public function get height():int
		{
			return _height;
		}
		
		public function getState(x:int, y:int):BlockState
		{
			return value[x][y];
		}
		
		public function getHitPoint(x:int, y:int):Number
		{
			return value[x][y].hitPoint;
		}
		
		public function getColor(x:int, y:int):uint
		{
			return value[x][y].color;
		}
		
		public function getSpecialUnion(x:int, y:int):Boolean
		{
			return value[x][y].specialUnion;
		}
		
		public function isExistBlock(x:int, y:int):Boolean
		{
			return value[x][y] != null;
		}
		
		public function isUnionSideBlock(x:int, y:int):Boolean
		{
			var px:int = x + 1;
			if (px < _width && value[px][y] != null && value[px][y].hitPoint > 0) return true;
			var mx:int = x - 1;
			if (mx >= 0 && value[mx][y] != null && value[mx][y].hitPoint > 0) return true;
			return false;
		}
		
		public function copyTo(to:BlockField):void
		{
			for (var x:int = 0; x < _width; x++)
			{
				for (var y:int = 0; y < _height; y++)
				{
					to.value[x][y] = value[x][y];
				}
			}
		}
		
		public function hash():uint
		{
			var ret:uint = 0;
			var s:int = 0;
			for (var x:int = 0; x < _width; x++)
			{
				for (var y:int = 0; y < _height; y++)
				{
					var v:BlockState = value[x][y];
					var t:uint = v == null ? 0 : v.hash();
					if (s == 0)
					{
						ret ^= t;
					}
					else
					{
						ret ^= t << s;
						ret ^= t >>> s;
					}
					s++;
				}
			}
			return ret;
		}
		
		public function fix(from:BlockField, rx:int, ry:int):void
		{
			var w:int = from._width;
			var h:int = from._height;
			for (var x:int = 0; x < w; x++)
			{
				for (var y:int = 0; y < h; y++)
				{
					var v:BlockState = from.value[x][y];
					if (v == null)
					{
						continue;
					}
					value[rx + x][ry + y] = v;
					from.value[x][y] = null;
				}
			}
		}
		
		public function blocksHitChack(field:BlockField, rx:int, ry:int, wallChack:Boolean):int
		{
			var count:int = 0;
			var w:int = field._width;
			var h:int = field._height;
			for (var x:int = 0; x < _width; x++)
			{
				for (var y:int = 0; y < _height; y++)
				{
					if (value[x][y] == null)
					{
						continue;
					}
					var tx:int = x + rx;
					var ty:int = y + ry;
					if (tx < 0 || tx >= w || ty < 0 || ty >= h)
					{ 
						if (wallChack == true)
						{
							count++;
						}
						continue; 
					}
					if (field.value[tx][ty] == null)
					{
						continue;
					}
					count++;
				}
			}
			return count;
		}
		
		public function verticalShock(x:int, y:int, shockDamage:Number, indirectShockDamage:Number, onBlockDamageDelegate:Function, up:Boolean):Number
		{
			var totalDamage:Number = 0;
			for (var i:int = y; i >= 0 && i < _height; up ? i-- : i++)
			{
				if (value[x][i] == null)
				{
					break;
				}
				var pureDamage:Number = i == y ? shockDamage : indirectShockDamage;
				var damage:Number = blockShock(x, i, pureDamage, onBlockDamageDelegate);
				totalDamage += damage;
			}
			return totalDamage;
		}
		
		private function blockShock(x:int, y:int, pureDamage:Number, onBlockDamageDelegate:Function):Number
		{
			var result:Number = 0;
			var hitPoint:Number = value[x][y].hitPoint;
			result = (hitPoint <= pureDamage ? hitPoint : pureDamage);
			hitPoint -= pureDamage;
			var old:BlockState = value[x][y];
			var v:BlockState = old.clone();
			v.hitPoint = hitPoint;
			value[x][y] = v;
			onBlockDamageDelegate(pureDamage, value[x][y], old);
			return result;
		}
		
		public function countBlock():int
		{
			var count:int = 0;
			for (var x:int = 0; x < _width; x++)
			{
				for (var y:int = 0; y < _height; y++)
				{
					if (isExistBlock(x, y))
					{
						count++;
					}
				}
			}
			return count;
		}
		
		public function getRect():Rect
		{
			var rect:Rect = new Rect();
			with (rect) { left = _width - 1; top = _height - 1; right = 0; bottom = 0; }
			for (var x:int = 0; x < _width; x++)
			{
				for (var y:int = 0; y < _height; y++)
				{
					if (value[x][y] == null)
					{
						continue;
					}
					rect.left = Math.min(rect.left, x);
					rect.top = Math.min(rect.top, y);
					rect.right = Math.max(rect.right, x);
					rect.bottom = Math.max(rect.bottom, y);
				}
			}
			return rect;
		}
		
		public function writeExternal(output:IDataOutput):void 
		{
			output.writeInt(_width);
			output.writeInt(_height);
			for (var x:int = 0; x < _width; x++)
			{
				for (var y:int = 0; y < _height; y++)
				{
					if (value[x][y] == null)
					{
						output.writeBoolean(false);
					}
					else
					{
						output.writeBoolean(true);
						value[x][y].writeExternal(output);
					}
				}
			}
		}
		
		public function readExternal(input:IDataInput):void 
		{
			_width = input.readInt();
			_height = input.readInt();
			value = generateValue(_width, _height);
			for (var x:int = 0; x < _width; x++)
			{
				for (var y:int = 0; y < _height; y++)
				{
					var b:Boolean = input.readBoolean();
					if (!b)
					{
						value[x][y] = null;
					}
					else
					{
						value[x][y] = new BlockState();
						value[x][y].readExternal(input);
					}
				}
			}
		}
	}
}