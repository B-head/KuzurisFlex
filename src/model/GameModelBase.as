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
		public static const gameOverHeight:int = 19;
		public static const ominoSize:int = 10;
		public static const nextLength:int = 6;
		
		public static const shockDamageCoefficient:Number = 2.5;
		public static const indirectShockDamageCoefficient:Number = 1;
		public static const naturalShockDamageCoefficient:Number = 0.5;
		public const distanceDamageCoefficient:Vector.<Number> = generateDistanceDamageCoefficient();
		public const fallingLossTime:Vector.<int> = generateFallingLossTime();
		
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
		
		protected function onBreakLine(y:int, colors:Vector.<uint>):void
		{
			return;
		}
		
		protected function onSectionBreakLine(count:int):void
		{
			return;
		}
		
		protected function onBlockDamage(x:int, y:int, damage:Number, coefficient:Number):void
		{
			return;
		}
		
		protected function onSectionDamage(damage:Number, coefficient:Number):void
		{
			return;
		}
		
		protected function breakLines():int
		{
			var count:int = 0;
			for (var y:int = fieldHeight - 1; y >= 0; y--)
			{
				if (_mainField.isFillLine(y))
				{
					count++;
					var colors:Vector.<uint>;
					colors = _mainField.clearLine(y);
					onBreakLine(y, colors);
				}
			}
			onSectionBreakLine(count);
			return count;
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
		
		protected function fallingField(from:int, to:int):int
		{
			var tempField:MainField = new MainField(fieldWidth, fieldHeight);
			var blockscCount:int = _fallField.countBlock();
			if (blockscCount <= 0) return fallingLossTime[0];
			for (var i:int = from; i <= to; i++)
			{
				blockscCount -= collideFallingBlocks(i, tempField);
				var coefficient:Number = getNaturalShockDamage(i);
				var damage:Number = shockDamage(tempField, 0, i, coefficient)
				onSectionDamage(damage, shockDamageCoefficient * coefficient);
				_mainField.fix(tempField, 0, i);
				if (blockscCount <= 0) break;
			}
			return fallingLossTime[i];
		}
		
		protected function collideFallingBlocks(dy:int, to:MainField):int
		{
			var count:int = 0;
			for (var y:int = 0; y < fieldHeight; y++)
			{
				var ty:int = y + dy + 1;
				if (ty > fieldHeight) break;
				for (var x:int = 0; x < fieldWidth; x++)
				{
					if (!_fallField.isExistBlock(x, y)) continue;
					if (ty < fieldHeight && !_mainField.isExistBlock(x, ty)) continue;
					count += _fallField.extractConnection(to, x, y, true);
				}
			}
			return count;
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
			
			function onDifference(ix:int, iy:int, damage:Number, coefficient:Number):void
			{ 
				onBlockDamage(ix + dx, iy + dy, damage, coefficient);
			}
		}
		
		protected function rotateNext(replenish:OminoField):void
		{
			_controlOmino = _nextOmino[0];
			for (var i:int = 0; i < nextLength - 1; i++)
			{
				_nextOmino[i] = _nextOmino[i + 1];
			}
			_nextOmino[nextLength - 1] = replenish;
		}
		
		protected function getNaturalShockDamage(n:int):Number
		{
			if (n >= distanceDamageCoefficient.length) n = distanceDamageCoefficient.length - 1;
			return naturalShockDamageCoefficient * distanceDamageCoefficient[n];
		}
		
		private static function generateDistanceDamageCoefficient():Vector.<Number>
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
		
		private static function generateFallingLossTime():Vector.<int>
		{
			var vec:Vector.<int> = new Vector.<int>(41, true);
			var g:Number = 10 / 400;
			var fs:Number = 0;
			var time:int = 0;
			for (var i:Number = 0; i < GameModelBase.fieldHeight; i += fs)
			{
				vec[int(i) + 1] = time;
				if (vec[int(i)] == 0) vec[int(i)] = time;
				fs += g;
				time++;
			}
			vec[0] = 0;
			return vec;
		}
		
		public function init_cox(rect:Rect):int
		{
			return fieldWidth / 2 - (rect.left + rect.width / 2);
		}
		
		public function init_coy(rect:Rect):int
		{
			return gameOverHeight - rect.bottom;
		}
		
		public function rotateReviseX(from:Rect, to:Rect):int
		{
			return (from.right - to.right + from.left - to.left) / 2;
		}
		
		public function rotateReviseY(from:Rect, to:Rect):int
		{
			return from.bottom - to.bottom;
		}
	}
}