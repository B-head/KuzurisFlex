package model 
{
	import flash.events.EventDispatcher;
	import model.ai.FragmentGameModel;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class GameModelBase extends EventDispatcherEX 
	{
		public static const fieldWidth:int = 10;
		public static const fieldHeight:int = 40;
		public static const gameOverHeight:int = 19;
		public static const ominoSize:int = 10;
		public static const nextLength:int = 6;
		public const distanceDamageCoefficient:Vector.<Number> = generateDistanceDamageCoefficient();
		public const fallingLossTime:Vector.<int> = generateFallingLossTime();
		
		protected var _mainField:MainField;
		protected var _fallField:MainField;
		protected var _tempField:MainField;
		protected var _controlOmino:OminoField;
		protected var _nextOmino:Vector.<OminoField>;
		
		public function GameModelBase() 
		{
			_mainField = new MainField(fieldWidth, fieldHeight);
			_fallField = new MainField(fieldWidth, fieldHeight);
			_tempField = new MainField(fieldWidth, fieldHeight);
			_nextOmino = new Vector.<OminoField>(nextLength, true);
		}
			
		public function copyTo(to:GameModelBase):void
		{
			_mainField.copyTo(to._mainField);
			_fallField.copyTo(to._fallField);
			_controlOmino.copyTo(to._controlOmino);
			for (var i:int = 0; i < nextLength; i++)
			{
				_nextOmino[i].copyTo(to._nextOmino[i]);
			}
		}
		
		public function getMainField():MainField
		{
			if (_mainField == null) return null;
			return _mainField;
		}
		
		public function getFallField():MainField
		{
			if (_fallField == null) return null;
			return _fallField;
		}
		
		public function getControlOmino():OminoField
		{
			if (_controlOmino == null) return null;
			return _controlOmino;
		}
		
		public function getNextOmino():Vector.<OminoField>
		{
			var ret:Vector.<OminoField> = new Vector.<OminoField>(nextLength, true);
			for (var i:int = 0; i < nextLength; i++)
			{
				if (_nextOmino[i] == null) continue;
				ret[i] = _nextOmino[i];
			}
			return ret;
		}
		
		public function dispose():void
		{
			removeAll();
		}
		
		protected function onBreakLine(y:int, blocks:Vector.<BlockState>):void
		{
			return;
		}
		
		protected function onSectionBreakLine(count:int):void
		{
			return;
		}
		
		protected function onBlockDamage(damage:Number, distance:int, id:uint, toSplit:Boolean):void
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
			for (var y:int = _mainField.bottom; y >= _mainField.top; y--)
			{
				if (_mainField.isBreakLine(y))
				{
					count++;
					var blocks:Vector.<BlockState>;
					blocks = _mainField.clearLine(y);
					onBreakLine(y, blocks);
				}
			}
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
		
		protected function fallingField(from:int, to:int, fast:Boolean):int
		{
			var blockscCount:int = _fallField.blockCount;
			if (blockscCount <= 0) return fallingLossTime[0];
			for (var i:int = from; i <= to; i++)
			{
				blockscCount -= collideFallingBlocks(i, _tempField);
				var coefficient:Number = getNaturalShockDamage(i, fast);
				var damage:Number = shockDamage(_tempField, 0, i, coefficient)
				onSectionDamage(damage, GameSetting.shockDamageCoefficient * coefficient);
				_tempField.fix(_mainField, 0, i);
				if (blockscCount <= 0) break;
			}
			return fallingLossTime[i];
		}
		
		protected function collideFallingBlocks(dy:int, to:MainField):int
		{
			var count:int = 0;
			for (var y:int = _fallField.top; y <= _fallField.bottom; y++)
			{
				var ty:int = y + dy + 1;
				if (ty > fieldHeight) break;
				for (var x:int = _fallField.left; x <= _fallField.right; x++)
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
			var area:int = field.blocksHitChack(_mainField, dx, dy + 1, true);
			var blockCount:int = field.blockCount;
			var shockDamage:Number = GameSetting.shockDamageCoefficient * damageCoefficient * blockCount / area;
			var indirectShockDamage:Number = GameSetting.indirectShockDamageCoefficient * damageCoefficient * blockCount / area;
			var result:Number = 0;
			for (var x:int = field.left; x <= field.right; x++)
			{
				for (var y:int = field.top; y <= field.bottom; y++)
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
					result += field.verticalShock(x, y, shockDamage, indirectShockDamage, onBlockDamage, true);
					result += _mainField.verticalShock(tx, ty, shockDamage, indirectShockDamage, onBlockDamage, false);
				}
			}
			return result;
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
		
		protected function getNaturalShockDamage(n:int, fast:Boolean):Number
		{
			if (fast) n = distanceDamageCoefficient.length - 1;
			if (n >= distanceDamageCoefficient.length) n = distanceDamageCoefficient.length - 1;
			return GameSetting.naturalShockDamageCoefficient * distanceDamageCoefficient[n];
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
		
		private function generateDistanceDamageCoefficient():Vector.<Number>
		{
			var vec:Vector.<Number> = new Vector.<Number>(41, true);
			var g:Number = 1 / 40;
			for (var i:int = 0; i < vec.length; i++)
			{
				if (i <= 20)
				{
					vec[i] = Math.sqrt(2 * g * i);
				}
				else
				{
					vec[i] = Math.sqrt(40 * g);
				}
				//trace(i, vec[i]);
			}
			return vec;
		}
		
		private function generateFallingLossTime():Vector.<int>
		{
			var vec:Vector.<int> = new Vector.<int>(41, true);
			var g:Number = GameSetting.basicAccelerationDividend / GameSetting.basicAccelerationDivisor;
			var fs:Number = 0;
			var time:int = 0;
			for (var i:Number = 0; i < 40; i += fs)
			{
				vec[int(i) + 1] = time;
				if (vec[int(i)] == 0)
				{
					vec[int(i)] = time;
				}
				fs += g;
				time++;
			}
			vec[0] = 0;
			for (var k:int = 0; k < vec.length; k++)
			{
				//trace(k, vec[k]);
			}
			return vec;
		}
	}
}