package model 
{
	import event.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class GameModel extends GameModelBase 
	{
		private var setting:GameSetting;
		private var record:GameRecord;
		private var nextPRNG:XorShift128;
		private var obstaclePRNG:XorShift128;
		
		private var controlPhase:Boolean;
		private var gameOverFlag:Boolean;
		private var firstShock:Boolean;
		private var _shockSave:Boolean;
		private var obstacleSettled:Boolean;
		
		private var fallSpeed:Number = 0;
		private var startFall:Number = 0;
		private var playRest:int;
		private var playLimit:int;
		
		private var comboCount:int;
		private var totalDamage:Number = 0;
		
		private var quantityOdds:Vector.<int>;
		private var ominoOdds:Vector.<Vector.<int>>;
		
		private var _cox:Number = 0;
		private var _coy:Number = 0;
		private var _ffy:Number = 0;
		
		private const lineScore:int = 100;
		
		public function GameModel(setting:GameSetting) 
		{
			super(true);
			this.setting = setting;
			record = new GameRecord();
			nextPRNG = new XorShift128();
			nextPRNG.RandomSeed();
			obstaclePRNG = new XorShift128();
			obstaclePRNG.RandomSeed();
			quantityOdds = new <int>[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
			ominoOdds = new Vector.<Vector.<int>>(11);
			for (var x:String in ominoOdds)
			{
				ominoOdds[x] = new Vector.<int>(OminoField.ominoQuantity[x]);
				for (var y:String in ominoOdds[x])
				{
					ominoOdds[x][y] = 1;
				}
			}
		}
		
		public function get goy():Number
		{
			for (var i:int = coy; i < fieldHeight; i++)
			{
				var a:int = _controlOmino.blocksHitChack(_mainField, cox, i + 1, true);
				if (a > 0) break;
			}
			return i;
		}
		
		public function get cox():Number 
		{
			return _cox;
		}
		
		public function get coy():Number 
		{
			return _coy;
		}
		
		public function get ffy():Number 
		{
			return _ffy;
		}
		
		public function get shockSave():Boolean 
		{
			return _shockSave;
		}
		
		public function getLightModel():GameLightModel
		{
			var result:GameLightModel = new GameLightModel();
			result.mainField = _mainField.clone();
			result.fallField = _fallField.clone();
			result.controlOmino = _controlOmino.clone();
			result.nextOmino = new Vector.<OminoField>(nextLength, true);
			for (var i:int = 0; i < nextLength; i++)
			{
				result.nextOmino[i] = _nextOmino[i].clone();
			}
			return result;
		}
		
		public function forwardStep(command:GameCommand):void
		{
			if (gameOverFlag) return;
			record.gameTime++;
			if (!controlPhase)
			{
				fallingField();
				if (_fallField.countBlock() > 0) return;
				var line:int = breakLines();
				extractFallBlocks();
				dispatchEvent(new GameEvent(GameEvent.extractFall, record.gameTime, 0));
				_ffy = 0;
				fallSpeed = 0;
				if (_fallField.countBlock() > 0) return;
				var totalLineScore:int = comboCount * comboCount * lineScore;
				dispatchEvent(new BreakLineEvent(BreakLineEvent.totalBreakLine, record.gameTime, totalLineScore, comboCount, int.MIN_VALUE, null));
				dispatchEvent(new ShockBlockEvent(ShockBlockEvent.totalDamage, record.gameTime, totalDamage, totalDamage, int.MIN_VALUE, int.MIN_VALUE));
				_mainField.clearSpecialUnion();
				setNextOmino();
				var rect:Rect = _controlOmino.getRect();
				_cox = fieldWidth / 2 - 1 - rect.left - int((rect.right - rect.left) / 2);
				_coy = fieldHeight / 2 - 1 - rect.bottom;
				dispatchEvent(new GameEvent(GameEvent.setOmino, record.gameTime, 0));
				if (_controlOmino.blocksHitChack(_mainField, _cox, _coy, true) > 0)
				{
					gameOverFlag = true;
					dispatchEvent(new GameEvent(GameEvent.gameOver, record.gameTime, 0));
					return;
				}
				comboCount = 0;
				totalDamage = 0;
				startFall = _coy;
				playRest = setting.playTime;
				playLimit = 0;
				firstShock = true;
				controlPhase = true;
			}
			if (controlPhase)
			{
				rotationOmino(command.rotation);
				moveOmino(command.move);
				fallingOmino(command.falling, command.fix, command.noDamege);
				if(playRest <= 0 || playRest <= playLimit)
				{
					_mainField.fix(_controlOmino, _cox, _coy);
					dispatchEvent(new GameEvent(GameEvent.fixOmino, record.gameTime, 0));
					record.fixOmino++;
					controlPhase = false;
				}
			}
		}
		
		override protected function onBreakLine(y:int, colors:Vector.<uint>):void 
		{
			record.breakLine++;
			comboCount++;
			var plus:int = (2 * comboCount - 1) * lineScore;
			record.gameScore += plus;
			dispatchEvent(new BreakLineEvent(BreakLineEvent.breakLine, record.gameTime, plus, comboCount, y, colors));
		}
		
		override protected function onBlockDamage(x:int, y:int, damage:Number):void 
		{
			dispatchEvent(new ShockBlockEvent(ShockBlockEvent.shockDamage, record.gameTime, 0, damage, x, y));
		}
		
		private function onSectionDamage(damage:Number):void
		{
			var plus:int = totalDamage % 1 + damage;
			totalDamage += damage;
			dispatchEvent(new ShockBlockEvent(ShockBlockEvent.sectionDamage, record.gameTime, plus, damage, int.MIN_VALUE, int.MIN_VALUE));
		}
		
		private function rotationOmino(rotation:int):void
		{
			if (rotation != GameCommand.left && rotation != GameCommand.right)
			{
				return;
			}
			var cacheOmino:OminoField = new OminoField(ominoSize);
			if (rotation == GameCommand.left)
			{
				_controlOmino.rotationLeft(cacheOmino);
			}
			else
			{
				_controlOmino.rotationRight(cacheOmino);
			}
			var controlRect:Rect = _controlOmino.getRect();
			var cacheRect:Rect = cacheOmino.getRect();
			var sx:int = int((controlRect.right - cacheRect.right + controlRect.left - cacheRect.left) / 2);
			var sy:int = controlRect.bottom - cacheRect.bottom;
			var a:int;
			for (var i:int = 0; i < ominoSize; i++)
			{
				if (i == 0)
				{
					if (rotationChack(cacheOmino, sx, sy, 0, 0, controlRect, cacheRect)) return;
					continue;
				}
				if (rotation == GameCommand.left)
				{
					a = -1;
				}
				else
				{
					a = 1;
				}
				var j:int;
				for (j = 0; j < i; j++)
				{
					if (rotationChack(cacheOmino, sx, sy, i * a, j, controlRect, cacheRect)) return;
					if (rotationChack(cacheOmino, sx, sy, -i * a, j, controlRect, cacheRect)) return;
					if (j > 0)
					{
						if (rotationChack(cacheOmino, sx, sy, i * a, -j, controlRect, cacheRect)) return;
						if (rotationChack(cacheOmino, sx, sy, -i * a, -j, controlRect, cacheRect)) return;
					}
				}
				for (j = 0; j <= i; j++)
				{
					if (rotationChack(cacheOmino, sx, sy, i, j * a, controlRect, cacheRect)) return;
					if (j > 0)
					{
						if (rotationChack(cacheOmino, sx, sy, i, -j * a, controlRect, cacheRect)) return;
					}
				}
				for (j = 0; j <= i; j++)
				{
					if (rotationChack(cacheOmino, sx, sy, -i, j * a, controlRect, cacheRect)) return;
					if (j > 0)
					{
						if (rotationChack(cacheOmino, sx, sy, -i, -j * a, controlRect, cacheRect)) return;
					}
				}
			}
			dispatchEvent(new ControlEvent(ControlEvent.rotationNG, record.gameTime, 0, _cox, _coy));
		}
		
		private function rotationChack(cacheOmino:OminoField, sx:int, sy:int, dx:int, dy:int, controlRect:Rect, cacheRect:Rect):Boolean
		{
			if (controlRect.left > cacheRect.right + sx + dx || controlRect.right < cacheRect.left + sx + dx)
			{
				return false;
			}
			if (controlRect.top > cacheRect.bottom + sy + dy || controlRect.bottom < cacheRect.top + sy + dy)
			{
				return false;
			}
			if (cacheOmino.blocksHitChack(_mainField, _cox + sx + dx, _coy + sy + dy, true) > 0)
			{
				return false;
			}
			dispatchEvent(new ControlEvent(ControlEvent.rotationOK, record.gameTime, 0, _cox, _coy));
			if (cacheOmino.blocksHitChack(_mainField, _cox + sx + dx, Math.ceil(_coy) + sy + dy, true) > 0)
			{
				_coy = Math.floor(_coy);
			}
			_controlOmino = cacheOmino;
			_cox += sx + dx;
			_coy += sy + dy;
			playLimit = 0;
			return true;
		}
		
		private function moveOmino(move:int):void
		{
			if (move == GameCommand.left)
			{
				if (_controlOmino.blocksHitChack(_mainField, _cox - 1, _coy, true) <= 0)
				{
					dispatchEvent(new ControlEvent(ControlEvent.moveOK, record.gameTime, 0, _cox, _coy));
					_cox -= 1;
				}
				else
				{
					dispatchEvent(new ControlEvent(ControlEvent.moveNG, record.gameTime, 0, _cox, _coy));
					return;
				}
			}
			else if (move == GameCommand.right)
			{
				if (_controlOmino.blocksHitChack(_mainField, _cox + 1, _coy, true) <= 0)
				{
					dispatchEvent(new ControlEvent(ControlEvent.moveOK, record.gameTime, 0, _cox, _coy));
					_cox += 1;
				}
				else
				{
					dispatchEvent(new ControlEvent(ControlEvent.moveNG, record.gameTime, 0, _cox, _coy));
					return;
				}
			}
			else
			{
				return;
			}
			playLimit = 0;
		}
		
		private function fallingOmino(falling:int, fix:Boolean, noDamage:Boolean):void
		{
			switch(falling)
			{
				case GameCommand.fast:
					fallSpeed = setting.fastFallSpeed > setting.naturalFallSpeed ? setting.fastFallSpeed : setting.naturalFallSpeed;
					break;
				case GameCommand.earth:
					fallSpeed = fieldHeight;
					break;
				default:
					fallSpeed = setting.naturalFallSpeed;
					startFall = _coy;
					break;
			}
			if (!noDamage && _shockSave)
			{
				_shockSave = false;
				dispatchEvent(new ControlEvent(ControlEvent.shockSaveOFF, record.gameTime, 0, _cox, _coy));
			}
			else if (noDamage && !_shockSave)
			{
				_shockSave = true;
				dispatchEvent(new ControlEvent(ControlEvent.shockSaveON, record.gameTime, 0, _cox, _coy));
			}
			for (var i:int = 0; i < Math.ceil(fallSpeed + _coy % 1); i++)
			{
				if (_controlOmino.blocksHitChack(_mainField, _cox, _coy + i + 1, true) == 0)
				{
					continue;
				}
				if (falling == GameCommand.nothing)
				{
					playRest -= 1;
					_coy = int(_coy + i);
					startFall = _coy
					return;
				}
				if (firstShock)
				{
					if (_shockSave)
					{
						dispatchEvent(new ControlEvent(ControlEvent.fallingShockSave, record.gameTime, 0, _cox, _coy));
					}
					else
					{
						onSectionDamage(shockDamage(_controlOmino, _cox, _coy + i, 1));
						dispatchEvent(new ControlEvent(ControlEvent.fallingShock, record.gameTime, 0, _cox, _coy));
					}
					firstShock = false;
				}
				else if (startFall < _coy + i)
				{
					if (_shockSave)
					{
						dispatchEvent(new ControlEvent(ControlEvent.fallingShockSave, record.gameTime, 0, _cox, _coy));
					}
					else
					{
						onSectionDamage(shockDamage(_controlOmino, _cox, _coy + i, getNaturalShockDamage(Math.ceil(_coy - startFall) + i)));
						dispatchEvent(new ControlEvent(ControlEvent.fallingShock, record.gameTime, 0, _cox, _coy));
					}
				}
				if (fix)
				{
					playRest = 0;
				}
				else
				{
					playRest -= 1;
				}
				if (playLimit < playRest - setting.playFastTime)
				{
					playLimit = playRest - setting.playFastTime;
				}
				_coy = int(_coy + i);
				startFall = _coy
				return;
			}
			_coy += fallSpeed;
		}
		
		//FIXME いつか衝突ダメージの処理をちゃんとしたい。
		private function fallingField():void
		{
			var tempField:MainField = new MainField(fieldWidth, fieldHeight);
			fallSpeed += setting.fallAcceleration;
			for (var i:int = int(_ffy); i <= int(_ffy + fallSpeed); i++)
			{
				collideFallingBlocks(i, tempField);
				onSectionDamage(shockDamage(tempField, 0, i, getNaturalShockDamage(i)));
				_mainField.fix(tempField, 0, i);
			}
			_ffy += fallSpeed;
		}
		
		private function setNextOmino():void
		{
			var omino:OminoField = randomReadOmino(nextPRNG.genUint(), nextPRNG.genUint());
			var color:uint = omino.coloringOmino();
			omino.allSetState(setting.hitPointMax, color, true);
			
			_controlOmino = _nextOmino[0];
			for (var i:int = 0; i < nextLength - 1; i++)
			{
				_nextOmino[i] = _nextOmino[i + 1];
			}
			_nextOmino[nextLength - 1] = omino;
			
			if (_controlOmino == null)
			{
				setNextOmino();
			}
		}
		
		private function randomReadOmino(rand1:uint, rand2:uint):OminoField
		{
			var a:int = 0;
			var t:int = 0;
			for (var q:int = 0; q < OminoField.ominoQuantity.length; q++)
			{
				if (setting.quantityOddsBasis[q] == 0) continue;
				t += quantityOdds[q];
			}
			rand1 %= t;
			for (q = 0; rand1 >= quantityOdds[q] || setting.quantityOddsBasis[q] == 0; q++)
			{
				if (setting.quantityOddsBasis[q] == 0) continue;
				rand1 -= quantityOdds[q];
			}
			if (quantityOdds[q] == 1)
			{
				for (var i:String in quantityOdds)
				{
					quantityOdds[i] <<= setting.quantityOddsBasis[i];
				}
			}
			quantityOdds[q] >>= 1;
			
			a = 0;
			t = 0;
			var op:Vector.<int> = ominoOdds[q];
			for (var o:int = 0; o < op.length; o++)
			{
				t += op[o];
			}
			rand2 %= t;
			for (o = 0; rand2 >= op[o]; o++)
			{
				rand2 -= op[o];
			}
			if (op[o] == 1)
			{
				for (var j:String in op)
				{
					op[j] <<= 1;
				}
			}
			op[o] >>= 1;
			
			return OminoField.readOmino(q, o, ominoSize);
		}
	}

}