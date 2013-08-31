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
		
		public static function readOmino(quantity:int, num:int, ominoSise:int):OminoField
		{
			var omino:OminoField = new OminoField(ominoSise);
			for (var i:int = 0; i < quantity; i++)
			{
				num += ominoQuantity[i];
			}
			for (var x:int = 0; x < ominoSise; x++)
			{
				for (var y:int = 0; y < ominoSise; y++)
				{
					if (blockSet[num * 100 + x + y * 10])
					{
						omino.value[x][y] = new BlockState();
					}
				}
			}
			return omino;
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
		
		public function coloringOmino():uint
		{
			var returnColor:uint = Color.lightgray;
			var pointSymmetry:Boolean = true;
			var verticalLineSymmetry:Boolean = true;
			var horizontalLineSymmetry:Boolean = true;
			var slantingLineSymmetry1:Boolean = true;
			var slantingLineSymmetry2:Boolean = true;
			var horizontalLineBlockCount:Vector.<int> = new Vector.<int>(_height);
			
			var rect:Rect = getRect();
			for (var y:int = 0; y <= rect.bottom; y++)
			{
				for (var x:int = 0; x <= rect.right; x++)
				{
					if (value[x][y] == null) continue;
					horizontalLineBlockCount[y]++;
					if (value[rect.right -x ][rect.bottom - y] == null) pointSymmetry = false;
					if (value[rect.right-x][y] == null) verticalLineSymmetry = false;
					if (value[x][rect.bottom-y] == null) horizontalLineSymmetry = false;
					if (rect.bottom == rect.right)
					{
						if (value[-y + rect.bottom][-x + rect.right] == null) slantingLineSymmetry1 = false;
						if (value[y][x] == null) slantingLineSymmetry2 = false;
					}
					else
					{
						slantingLineSymmetry1 = false;
						slantingLineSymmetry2 = false;
					}
				}
			}
			
			var toTheLeft:Boolean;
			var toTheRight:Boolean;
			tolr:
			for (y = rect.bottom; y >= 0; y--)
			{
				for (x = rect.right / 2; x >= 0; x--)
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