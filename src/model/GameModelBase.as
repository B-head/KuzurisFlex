package model 
{
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class GameModelBase extends EventDispatcher 
	{
		public static const fieldWidth:int = 10;
		public static const fieldHeight:int = 40;
		public static const ominoSize:int = 10;
		public static const nextLength:int = 7;
		
		private const shockDamageCoefficient:Number = 2.5;
		private const indirectShockDamageCoefficient:Number = 1;
		private const naturalShockDamageCoefficient:Number = 0.5;
		private const distanceDamageCoefficient:Vector.<Number> = generateDistanceDamageCoefficient();
		
		protected var _mainField:MainField;
		protected var _fallField:MainField;
		protected var _controlOmino:OminoField;
		protected var _nextOmino:Vector.<OminoField>;
		
		public function GameModelBase(create:Boolean) 
		{
			if (!create)
			{
				return;
			}
			_mainField = new MainField(fieldWidth, fieldHeight);
			_fallField = new MainField(fieldWidth, fieldHeight);
			_nextOmino = new Vector.<OminoField>(nextLength, true);
		}
		
		protected function breakLines():int
		{
			var count:int = 0;
			for (var y:int = 0; y < fieldHeight; y++)
			{
				if (_mainField.isFillLine(y))
				{
					var colors:Vector.<uint>;
					colors = _mainField.clearLine(y);
					onBreakLine(y, colors);
				}
			}
			return count;
		}
		
		protected function onBreakLine(y:int, colors:Vector.<uint>):void
		{
			
		}
		
		protected function extractFallBlocks():void
		{
			var temp:MainField = _mainField;
			_mainField = _fallField;
			_fallField = temp;
			for (var x:int = 0; x < fieldWidth; x++)
			{
				_fallField.extractConnection(_mainField, x, fieldHeight - 1, true);
			}
		}
		
		protected function collideFallingBlocks(dy:int, to:MainField):void
		{
			for (var y:int = 0; y < fieldHeight; y++)
			{
				var ty:int = y + dy + 1;
				if (ty > fieldHeight) break;
				for (var x:int = 0; x < fieldWidth; x++)
				{
					if (!_fallField.isExistBlock(x, y)) continue;
					if (ty < fieldHeight && !_mainField.isExistBlock(x, ty)) continue;
					_fallField.extractConnection(to, x, y, true);
				}
			}
		}
		
		protected function shockDamage(field:BlockField, dx:Number, dy:Number, damageCoefficient:Number):Number
		{
			var blockCount:int = field.countBlock();
			var area:int = field.blocksHitChack(_mainField, dx, dy + 1, true);
			var shockDamage:Number = shockDamageCoefficient * damageCoefficient * blockCount / area;
			var indirectShockDamage:Number = indirectShockDamageCoefficient * damageCoefficient * blockCount / area;
			var w:int = field.width;
			var h:int = field.height;
			var result:Number = 0;
			for (var x:int = 0; x < w; x++)
			{
				for (var y:int = 0; y < h; y++)
				{
					var tx:int = int(x + dx);
					var ty:int = int(y + dy + 1);
					if (!field.isExistBlock(x, y))
					{
						continue;
					}
					if (ty < fieldHeight && !_mainField.isExistBlock(tx, ty))
					{
						continue;
					}
					result += field.verticalShock(x, y, shockDamage, indirectShockDamage, onDifference, true);
					result += _mainField.verticalShock(tx, ty, shockDamage, indirectShockDamage, onBlockDamage, false);
				}
			}
			return result;
			
			function onDifference(ix:int, iy:int, damage:Number):void
			{ 
				onBlockDamage(ix + dx, iy + dy, damage);
			}
		}
		
		protected function onBlockDamage(x:int, y:int, damage:Number):void
		{
			
		}
		
		protected function getNaturalShockDamage(n:int):Number
		{
			return naturalShockDamageCoefficient * distanceDamageCoefficient[n];
		}
		
		private function generateDistanceDamageCoefficient():Vector.<Number>
		{
			var vec:Vector.<Number> = new Vector.<Number>(41, true);
			var g:Number = 1 / 40;
			for (var i:int = 0, l:int = vec.length; i < l; i++)
			{
				if (i <= 20)
				{
					vec[i] = Math.sqrt(2 * g * i);
				}
				else
				{
					vec[i] = 1;
				}
			}
			return vec;
		}
		
	}

}