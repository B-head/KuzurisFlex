package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class MainField extends BlockField 
	{
		public function MainField(w:int, h:int) 
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
		
		public function clearSpecialUnion():void
		{
			for (var x:int = 0; x < _width; x++)
			{
				for (var y:int = 0; y < _height; y++)
				{
					var v:BlockState = value[x][y];
					if (v == null)
					{
						continue;
					}
					value[x][y] = new BlockState(v.hitPoint, v.color, false);
				}
			}
		}
		
		public function extractConnection(to:MainField, x:int, y:int, 
			upperConnect:Boolean, specialUnion:Boolean = false, first:Boolean = true):void
		{
			if (x < 0) return;
			if (x >= _width) return;
			if (y < 0) return;
			if (y >= _height) return;
			var v:BlockState = value[x][y];
			if (v == null) return;
			if (first == true)
			{
				specialUnion = v.specialUnion;
			}
			
			if (v.hitPoint > 0 && specialUnion == v.specialUnion)
			{
				to.value[x][y] = v;
				value[x][y] = null;
				extractConnection(to, x + 1, y, upperConnect, specialUnion, false);
				extractConnection(to, x - 1, y, upperConnect, specialUnion, false);
				extractConnection(to, x, y + 1, upperConnect, specialUnion, false);
				extractConnection(to, x, y - 1, upperConnect, specialUnion, upperConnect ? true : false);
			}
			else
			{
				if (first == false) return;
				to.value[x][y] = v;
				value[x][y] = null;
				if (upperConnect == true)
				{
					extractConnection(to, x, y - 1, upperConnect, specialUnion, true);
				}
			}
		}
		
		public function setObstacleLine(line:int, blockCount:int, hitPointMax:Number, blockColor:uint, prng:XorShift128):void
		{
			var sb:Vector.<BlockState> = new Vector.<BlockState>(width);
			for (var i:int = 0; i < blockCount; i++)
			{
				var block:BlockState = new BlockState();
				with (block)
				{
					kind = BlockState.normal;
					hitPoint = hitPointMax;
					color = blockColor;
					specialUnion = false;
				}
				sb[i] = block;
			}
			for (i = 0; i < width; i++)
			{
				var r:int = prng.genUint() % (width - i) + i;
				var t:BlockState = sb[i];
				sb[i] = sb[r];
				sb[r] = t;
			}
			for (i = 0; i < width; i++)
			{
				value[i][line] = sb[i];
			}
		}
	}

}