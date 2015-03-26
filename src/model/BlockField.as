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
		protected var _verticalBlockCount:Vector.<int>;
		protected var _horizontalBlockCount:Vector.<int>;
		protected var _blockCount:int;
		protected var _left:int;
		protected var _top:int;
		protected var _right:int;
		protected var _bottom:int;
		protected var _maxWidth:int;
		protected var _maxHeight:int;
		
		public function BlockField(w:int = 0, h:int = 0)
		{
			value = generateValue(w, h);
			_verticalBlockCount = new Vector.<int>(w);
			_horizontalBlockCount = new Vector.<int>(h);
			_blockCount = 0;
			_left = w;
			_top = h;
			_right = -1;
			_bottom = -1;
			_maxWidth = w;
			_maxHeight = h;
		}
		
		private static function generateValue(w:int, h:int):Vector.<Vector.<BlockState>>
		{
			var result:Vector.<Vector.<BlockState>> = new Vector.<Vector.<BlockState>>(w, true);
			for (var x:int = 0; x < w; x++)
			{
				result[x] = new Vector.<BlockState>(h, true);
				for (var y:int = 0; y < h; y++)
				{
					result[x][y] = new BlockState();
				}
			}
			return result;
		}
		
		public final function get verticalBlockCount():Vector.<int>
		{
			return _verticalBlockCount.slice();
		}
		
		public final function get horizontalBlockCount():Vector.<int>
		{
			return _horizontalBlockCount.slice();
		}
		
		public final function get blockCount():int
		{
			return _blockCount;
		}
		
		public final function get left():int
		{
			return _left;
		}
		
		public final function get top():int
		{
			return _top;
		}
		
		public final function get right():int
		{
			return _right;
		}
		
		public final function get bottom():int
		{
			return _bottom;
		}
		
		public final function get maxWidth():int
		{
			return _maxWidth;
		}
		
		public final function get maxHeight():int
		{
			return _maxHeight;
		}
		
		public final function get blockWidth():int
		{
			return _right - _left + 1;
		}
		
		public final function get blockHeight():int
		{
			return _bottom - _top + 1;
		}
		
		public final function get centerX():int
		{
			return (_right + _left) / 2;
		}
		
		public final function get centerY():int
		{
			return (_bottom + _top) / 2;
		}
		
		protected final function setState(x:int, y:int, state:BlockState):void
		{
			var v:BlockState = value[x][y];
			if (v.isEmpty() && !state.isEmpty())
			{
				_verticalBlockCount[x]++;
				_horizontalBlockCount[y]++;
				_blockCount++;
			}
			else if (!v.isEmpty() && state.isEmpty())
			{
				_verticalBlockCount[x]--;
				_horizontalBlockCount[y]--;
				_blockCount--;
			}
			v.type = state.type;
			v.hitPoint = state.hitPoint;
			v.color = state.color;
			v.specialUnion = state.specialUnion;
			v.id = state.id;
		}
		
		protected final function clearState(x:int, y:int):void
		{
			var v:BlockState = value[x][y];
			if (!v.isEmpty())
			{
				_verticalBlockCount[x]--;
				_horizontalBlockCount[y]--;
				_blockCount--;
				v.type = BlockState.empty;
			}
		}
		
		protected final function setRect():void
		{
			for (_left = 0; _left < _maxWidth; _left++)
			{
				if (_verticalBlockCount[_left] > 0) break;
			}
			for (_right = _maxWidth - 1; _right >= 0; _right--)
			{
				if (_verticalBlockCount[_right] > 0) break;
			}
			for (_top = 0; _top < _maxHeight; _top++)
			{
				if (_horizontalBlockCount[_top] > 0) break;
			}
			for (_bottom = _maxHeight - 1; _bottom >= 0; _bottom--)
			{
				if (_horizontalBlockCount[_bottom] > 0) break;
			}
		}
		
		public final function getType(x:int, y:int):Number
		{
			return value[x][y].type;
		}
		
		public final function getHitPoint(x:int, y:int):Number
		{
			return value[x][y].hitPoint;
		}
		
		public final function getColor(x:int, y:int):uint
		{
			return value[x][y].color;
		}
		
		public final function getSpecialUnion(x:int, y:int):Boolean
		{
			return value[x][y].specialUnion;
		}
		
		public final function getId(x:int, y:int):uint
		{
			return value[x][y].id;
		}
		
		public final function isExistBlock(x:int, y:int):Boolean
		{
			return !value[x][y].isEmpty();
		}
		
		public final function isUnionSideBlock(x:int, y:int):Boolean
		{
			var px:int = x + 1;
			if (px < _maxWidth && !value[px][y].isEmpty() && value[px][y].hitPoint > 0) return true;
			var mx:int = x - 1;
			if (mx >= 0 && !value[mx][y].isEmpty() && value[mx][y].hitPoint > 0) return true;
			return false;
		}
		
		public function copyTo(to:BlockField):void
		{
			to.clearAll();
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					to.setState(x, y, value[x][y]);
				}
			}
			to.setRect();
		}
		
		public function clearAll():void
		{
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					clearState(x, y);
				}
			}
			setRect();
		}
		
		public function hash():uint
		{
			var ret:uint = 0;
			var s:int = 0;
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
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
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					var v:BlockState = value[x][y];
					if (v.isEmpty())
					{
						continue;
					}
					from.setState(rx + x, ry + y, v);
					clearState(x, y);
				}
			}
			setRect();
			from.setRect();
		}
		
		public function blocksHitChack(field:BlockField, rx:int, ry:int, wallChack:Boolean):int
		{
			var count:int = 0;
			var w:int = field._maxWidth;
			var h:int = field._maxHeight;
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					if (value[x][y].isEmpty())
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
					if (field.value[tx][ty].isEmpty())
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
			for (var i:int = y; i >= _top && i <= _bottom; up ? i-- : i++)
			{
				if (value[x][i].isEmpty())
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
			var v:BlockState = value[x][y];
			if (v.isNonBreak()) return 0;
			var hitPoint:Number = v.hitPoint;
			var result:Number = (hitPoint <= pureDamage ? hitPoint : pureDamage);
			var toSplit:Boolean = (hitPoint > 0 && hitPoint <= pureDamage);
			hitPoint -= pureDamage;
			v.hitPoint = hitPoint;
			onBlockDamageDelegate(pureDamage, v.id, toSplit);
			return result;
		}
		
		public function getRect():Rect
		{
			return new Rect(_left, _top, _right, _bottom);
		}
		
		public function writeExternal(output:IDataOutput):void 
		{
			output.writeInt(_maxWidth);
			output.writeInt(_maxHeight);
			for (var x:int = 0; x < _maxWidth; x++)
			{
				for (var y:int = 0; y < _maxHeight; y++)
				{
					if (value[x][y].isEmpty())
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
			_maxWidth = input.readInt();
			_maxHeight = input.readInt();
			value = generateValue(_maxWidth, _maxHeight);
			_verticalBlockCount = new Vector.<int>(_maxWidth);
			_horizontalBlockCount = new Vector.<int>(_maxHeight);
			for (var x:int = 0; x < _maxWidth; x++)
			{
				for (var y:int = 0; y < _maxHeight; y++)
				{
					value[x][y] = new BlockState();
					if (input.readBoolean())
					{
						value[x][y].readExternal(input);
					}
				}
			}
			setRect();
		}
	}
}