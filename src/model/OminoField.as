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
		
		public function OminoField(s:int) 
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
						omino.value[x][y] = new BlockState();
					}
				}
			}
			return omino;
		}
		
		public static function createBigOmino(blockCount:int, ominoSize:int, prng:XorShift128):OminoField
		{
			var omino:OminoField = new OminoField(ominoSize * 2);
			var blocks:Vector.<Vector.<BlockState>> = omino.value;
			var nextList:Vector.<Object> = new Vector.<Object>();
			
			var rx:int = ominoSize;
			var ry:int = ominoSize;
			blocks[rx][ry] = new BlockState();
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
					if (blocks[n.x][n.y] != null) throw Error("assert");
					blocks[n.x][n.y] = new BlockState();
					outList(j);
					inList(n.x - 1, n.y, j);
					inList(n.x, n.y - 1, j);
					inList(n.x + 1, n.y, j);
					inList(n.x, n.y + 1, j);
					break;
				}
			}
			var rect:Rect = omino.getRect();
			var ret:OminoField = new OminoField(ominoSize);
			for (var x:int = 0; x < rect.width; x++)
			{
				for (var y:int = 0; y < rect.height; y++)
				{
					ret.value[x][y] = blocks[x + rect.left][y + rect.top];
				}
			}
			return ret;
			
			function inList(x:int, y:int, value:int):void
			{
				var rect:Rect = omino.getRect();
				if (rect.right - rect.left >= ominoSize - 1 && (x < rect.right || x > rect.left)) return;
				if (rect.bottom - rect.top >= ominoSize - 1 && (y < rect.top || y > rect.bottom)) return;
				if (blocks[x][y] != null) return;
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
			var ret:OminoField = new OminoField(_width);
			copyTo(ret);
			return ret;
		}
		
		public function allSetState(hitPoint:Number, color:uint, specialUnion:Boolean):void
		{
			for (var x:int = 0; x < _width; x++)
			{
				for (var y:int = 0; y < _height; y++)
				{
					if (value[x][y] == null) continue;
					value[x][y] = new BlockState(hitPoint, color, specialUnion);
				}
			}
		}
		
		public function isPointSymmetry():Boolean
		{
			var rect:Rect = getRect();
			for (var y:int = 0; y <= rect.bottom; y++)
			{
				for (var x:int = 0; x <= rect.right; x++)
				{
					if (value[x][y] == null) continue;
					if (value[rect.right -x][rect.bottom - y] == null) return false;
				}
			}
			return true;
		}
		
		public function isPoint90Symmetry():Boolean
		{
			var rect:Rect = getRect();
			for (var y:int = 0; y <= rect.bottom; y++)
			{
				for (var x:int = 0; x <= rect.right; x++)
				{
					if (value[x][y] == null) continue;
					if (value[rect.right -x][rect.bottom - y] == null) return false;
					if (value[-y + rect.bottom][-x + rect.right] == null) return false;
					if (value[y][x] == null) return false;
				}
			}
			return true;
		}
		
		public function isVerticalLineSymmetry():Boolean
		{
			var rect:Rect = getRect();
			for (var y:int = 0; y <= rect.bottom; y++)
			{
				for (var x:int = 0; x <= rect.right; x++)
				{
					if (value[x][y] == null) continue;
					if (value[rect.right-x][y] == null) return false;
				}
			}
			return true;
			
		}
		
		public function isHorizontalLineSymmetry():Boolean
		{
			var rect:Rect = getRect();
			for (var y:int = 0; y <= rect.bottom; y++)
			{
				for (var x:int = 0; x <= rect.right; x++)
				{
					if (value[x][y] == null) continue;
					if (value[x][rect.bottom-y] == null) return false;
				}
			}
			return true;
			
		}
		
		public function isSlantingLineSymmetry1():Boolean
		{
			var rect:Rect = getRect();
			if (rect.bottom != rect.right) return false;
			for (var y:int = 0; y <= rect.bottom; y++)
			{
				for (var x:int = 0; x <= rect.right; x++)
				{
					if (value[x][y] == null) continue;
					if (value[-y + rect.bottom][-x + rect.right] == null) return false;
				}
			}
			return true;
			
		}
		
		public function isSlantingLineSymmetry2():Boolean
		{
			var rect:Rect = getRect();
			if (rect.bottom != rect.right) return false;
			for (var y:int = 0; y <= rect.bottom; y++)
			{
				for (var x:int = 0; x <= rect.right; x++)
				{
					if (value[x][y] == null) continue;
					if (value[y][x] == null) return false;
				}
			}
			return true;
			
		}
		
		public function horizontalLineBlockCount():Vector.<int>
		{
			var ret:Vector.<int> = new Vector.<int>(_height);
			for (var y:int = 0; y < _height; y++)
			{
				for (var x:int = 0; x < _width; x++)
				{
					if (value[x][y] == null) continue;
					ret[y]++;
				}
			}
			return ret;
		}
		
		public function coloringOmino():uint
		{
			var returnColor:uint = Color.lightgray;
			var pointSymmetry:Boolean = isPointSymmetry();
			var verticalLineSymmetry:Boolean = isVerticalLineSymmetry();
			var horizontalLineSymmetry:Boolean = isHorizontalLineSymmetry();
			var slantingLineSymmetry1:Boolean = isSlantingLineSymmetry1();
			var slantingLineSymmetry2:Boolean = isSlantingLineSymmetry2();
			var horizontalLineBlockCount:Vector.<int> = horizontalLineBlockCount();
			
			var rect:Rect = getRect();
			var toTheLeft:Boolean;
			var toTheRight:Boolean;
			tolr:
			for (var y:int = rect.bottom; y >= 0; y--)
			{
				for (var x:int = rect.right / 2; x >= 0; x--)
				{
					if (value[x][y] != null && value[rect.right - x][y] == null)
					{
						toTheLeft = true;
						break tolr;
					}
					else if (value[x][y] == null && value[rect.right - x][y] != null)
					{
						toTheRight = true;
						break tolr;
					}
				}
			}
			var bottomBlockCount:int = horizontalLineBlockCount[rect.bottom];
			var maxCount:int = 0;
			for (var i:int = rect.bottom - 1; i >= 0; i--)
			{
				if (maxCount < horizontalLineBlockCount[i])
				{
					maxCount = horizontalLineBlockCount[i];
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
			return returnColor;
		}
		
		public function rotationLeft(to:OminoField):void
		{
			for (var x:int = 0; x < _width; x++)
			{
				for (var y:int = 0; y < _height; y++)
				{
					to.value[y][-x + _height - 1] = value[x][y];
				}
			}
		}
		
		public function rotationRight(to:OminoField):void
		{
			for (var x:int = 0; x < _width; x++)
			{
				for (var y:int = 0; y < _height; y++)
				{
					to.value[-y + _width - 1][x] = value[x][y];
				}
			}
		}
	}

}