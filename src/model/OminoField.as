package model 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author B_head
	 */
	public class OminoField extends BlockField 
	{
		[Embed(source="./BlockData.dat", mimeType="application/octet-stream")]
		private static const blockSetAsset:Class;
		
		public static const ominoQuantity:Vector.<int> = new <int>[0, 1, 1, 2, 7, 18, 60, 196, 704, 2500, 9189];
		private static var blockSet:ByteArray = new blockSetAsset();
		
		public function OminoField(s:int = 0) 
		{
			super(s, s);
		}
		
		public static function readOmino(quantity:int, num:int, ominoSize:int):OminoField
		{
			var omino:OminoField = new OminoField(ominoSize);
			for (var i:int = 0; i < quantity; i++)
			{
				num += ominoQuantity[i];
			}
			for (var x:int = 0; x < ominoSize; x++)
			{
				for (var y:int = 0; y < ominoSize; y++)
				{
					if (blockSet[num * 100 + x + y * 10])
					{
						omino.setState(x, y, new BlockState(BlockState.normal));
					}
				}
			}
			omino.setRect();
			return omino;
		}
		
		public static function createBigOmino(blockCount:int, ominoSize:int, prng:XorShift128):OminoField
		{
			var omino:OminoField = new OminoField(ominoSize * 2);
			var blocks:Vector.<Vector.<BlockState>> = omino.value;
			var nextList:Vector.<Object> = new Vector.<Object>();
			
			var rx:int = ominoSize;
			var ry:int = ominoSize;
			//blocks.setState(rx, ry, new BlockState(BlockState.normal));
			inList(rx - 1, ry, 0);
			inList(rx, ry - 1, 0);
			inList(rx + 1, ry, 0);
			inList(rx, ry + 1, 0);
			
			var j:int = 0;
			for (var i:int = 1; i < blockCount; i++)
			{
				while (true)
				{
					j++;
					if (j >= nextList.length) 
					{
						j = 0;
					}
					var a:int = int(prng.genUint() % 2);
					if (a == 0) continue;
					var n:Object = nextList[j];
					if (!blocks[n.x][n.y].isEmpty()) throw Error("assert");
					//blocks.setState(n.x, n.y, new BlockState(BlockState.normal));
					outList(j);
					inList(n.x - 1, n.y, j);
					inList(n.x, n.y - 1, j);
					inList(n.x + 1, n.y, j);
					inList(n.x, n.y + 1, j);
					break;
				}
			}
			omino.setRect();
			var rect:Rect = omino.getRect();
			var ret:OminoField = new OminoField(ominoSize);
			for (var x:int = 0; x < rect.width; x++)
			{
				for (var y:int = 0; y < rect.height; y++)
				{
					ret.setState(x, y, blocks[x + rect.left][y + rect.top]);
				}
			}
			ret.setRect();
			return ret;
			
			function inList(x:int, y:int, value:int):void
			{
				omino.setRect();
				var rect:Rect = omino.getRect();
				if (rect.right - rect.left >= ominoSize - 1 && (x < rect.right || x > rect.left)) return;
				if (rect.bottom - rect.top >= ominoSize - 1 && (y < rect.top || y > rect.bottom)) return;
				if (!blocks[x][y].isEmpty()) return;
				if (nextList.some(tester) == true) return;
				nextList.splice(value, 0, { x:x, y:y } );
				
				function tester(item:Object, index:int, vector:Vector.<Object>):Boolean
				{
					if (item.x == x && item.y == y) return true; else return false;
				}
			}
			
			function outList(value:int):void
			{
				nextList.splice(value, 1);
			}
		}
		
		public function clone():OminoField
		{
			var ret:OminoField = new OminoField(_maxWidth);
			copyTo(ret);
			return ret;
		}
		
		public function allSetState(type:uint, color:uint, hitPoint:Number, specialUnion:Boolean):void
		{
			var v:BlockState = new BlockState(type, color, hitPoint, specialUnion);
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					if (value[x][y].isEmpty()) continue;
					v.setId();
					setState(x, y, v);
				}
			}
		}
		
		public function isPointSymmetry():Boolean
		{
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					if (value[x][y].isEmpty()) continue;
					if (value[_right -x][_bottom - y].isEmpty()) return false;
				}
			}
			return true;
		}
		
		public function isPoint90Symmetry():Boolean
		{
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					if (value[x][y].isEmpty()) continue;
					if (value[_right -x][_bottom - y].isEmpty()) return false;
					if (value[-y + _bottom][-x + _right].isEmpty()) return false;
					if (value[y][x].isEmpty()) return false;
				}
			}
			return true;
		}
		
		public function isVerticalLineSymmetry():Boolean
		{
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					if (value[x][y].isEmpty()) continue;
					if (value[_right-x][y].isEmpty()) return false;
				}
			}
			return true;
			
		}
		
		public function isHorizontalLineSymmetry():Boolean
		{
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					if (value[x][y].isEmpty()) continue;
					if (value[x][_bottom-y].isEmpty()) return false;
				}
			}
			return true;
			
		}
		
		public function isSlantingLineSymmetry1():Boolean
		{
			if (bottom != right) return false;
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					if (value[x][y].isEmpty()) continue;
					if (value[-y + _bottom][-x + _right].isEmpty()) return false;
				}
			}
			return true;
			
		}
		
		public function isSlantingLineSymmetry2():Boolean
		{
			if (_bottom != _right) return false;
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					if (value[x][y].isEmpty()) continue;
					if (value[y][x].isEmpty()) return false;
				}
			}
			return true;
			
		}
		
		public function coloringOmino():uint
		{
			var returnColor:uint = Color.lightgray;
			var pointSymmetry:Boolean = isPointSymmetry();
			var verticalLineSymmetry:Boolean = isVerticalLineSymmetry();
			var horizontalLineSymmetry:Boolean = isHorizontalLineSymmetry();
			var slantingLineSymmetry1:Boolean = isSlantingLineSymmetry1();
			var slantingLineSymmetry2:Boolean = isSlantingLineSymmetry2();
			
			var rect:Rect = getRect();
			var toTheLeft:Boolean;
			var toTheRight:Boolean;
			tolr:
			for (var y:int = rect.bottom; y >= 0; y--)
			{
				for (var x:int = rect.right / 2; x >= 0; x--)
				{
					if (!value[x][y].isEmpty() && value[rect.right - x][y].isEmpty())
					{
						toTheLeft = true;
						break tolr;
					}
					else if (value[x][y].isEmpty() && !value[rect.right - x][y].isEmpty())
					{
						toTheRight = true;
						break tolr;
					}
				}
			}
			var bottomBlockCount:int = _horizontalBlockCount[rect.bottom];
			var maxCount:int = 0;
			for (var i:int = rect.bottom - 1; i >= 0; i--)
			{
				if (maxCount < _horizontalBlockCount[i])
				{
					maxCount = _horizontalBlockCount[i];
				}
			}
			
			if (rect.bottom == 0)
			{
				if (rect.right == 10)
				{
					returnColor = Color.lightskyblue;
				}
				else
				{
					returnColor = Color.skyblue;
				}
			}
			else
			{
				if (verticalLineSymmetry == true || horizontalLineSymmetry == true ||
					slantingLineSymmetry1 == true || slantingLineSymmetry2 == true)
				{
					if (pointSymmetry == true)
					{
						returnColor = Color.yellow;
					}
					else
					{
						returnColor = Color.purple;
					}
				}
				else
				{
					if (pointSymmetry == true)
					{
						if (toTheRight == true)
						{
							returnColor = Color.red;
						}
						else if(toTheLeft == true)
						{
							returnColor = Color.green;
						}
					}
					else
					{
						if (bottomBlockCount > maxCount)
						{
							if (toTheRight == true)
							{
								returnColor = Color.orange;
							}
							else if(toTheLeft == true)
							{
								returnColor = Color.blue;
							}
						}
						else if (bottomBlockCount == maxCount)
						{
							if (toTheRight == true)
							{
								returnColor = Color.brown;
							}
							else if(toTheLeft == true)
							{
								returnColor = Color.pink;
							}
						}
						else 
						{
							if (toTheRight == true)
							{
								returnColor = Color.beige;
							}
							else if(toTheLeft == true)
							{
								returnColor = Color.lightpink;
							}
						}
					}
				}
			}
			return Color.toIndex(returnColor);
		}
		
		public function rotationLeft(to:OminoField):void
		{
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					to.setState(y, -x + _maxHeight - 1, value[x][y]);
				}
			}
			to.setRect();
		}
		
		public function rotationRight(to:OminoField):void
		{
			for (var x:int = _left; x <= _right; x++)
			{
				for (var y:int = _top; y <= _bottom; y++)
				{
					to.setState(-y + _maxWidth - 1, x, value[x][y]);
				}
			}
			to.setRect();
		}
	}

}