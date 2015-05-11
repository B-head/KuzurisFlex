package model 
{
	import ai.*;
	import common.*;
	import events.*;
	import flash.utils.*;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="forwardGame", type="events.GameEvent")]
	[Event(name="updateNext", type="events.GameEvent")]
	[Event(name="firstUpdateNext", type="events.GameEvent")]
	[Event(name="gameOver", type="events.GameEvent")]
	[Event(name="gameClear", type="events.GameEvent")]
	[Event(name="breakChain", type="events.GameEvent")]
	[Event(name="breakConbo", type="events.GameEvent")]
	[Event(name="extractFall", type="events.GameEvent")]
	[Event(name="obstacleFall", type="events.GameEvent")]
	[Event(name="appendTower", type="events.GameEvent")]
	[Event(name="appendHurryUp", type="events.GameEvent")]
	[Event(name="beginHurryUp", type="events.GameEvent")]
	[Event(name="jewelAllClear", type="events.GameEvent")]
	[Event(name="blockAllClear", type="events.GameEvent")]
	[Event(name="fixOmino", type="events.ControlEvent")]
	[Event(name="setOmino", type="events.ControlEvent")]
	[Event(name="moveOK", type="events.ControlEvent")]
	[Event(name="moveNG", type="events.ControlEvent")]
	[Event(name="rotationOK", type="events.ControlEvent")]
	[Event(name="rotationNG", type="events.ControlEvent")]
	[Event(name="startFall", type="events.ControlEvent")]
	[Event(name="endFall", type="events.ControlEvent")]
	[Event(name="fallShock", type="events.ControlEvent")]
	[Event(name="fallShockSave", type="events.ControlEvent")]
	[Event(name="shockSaveON", type="events.ControlEvent")]
	[Event(name="shockSaveOFF", type="events.ControlEvent")]
	[Event(name="levelClear", type="events.LevelClearEvent")]
	[Event(name="stageClear", type="events.LevelClearEvent")]
	[Event(name="shockDamage", type="events.ShockBlockEvent")]
	[Event(name="sectionDamage", type="events.ShockBlockEvent")]
	[Event(name="totalDamage", type="events.ShockBlockEvent")]
	[Event(name="breakLine", type="events.BreakLineEvent")]
	[Event(name="sectionBreakLine", type="events.BreakLineEvent")]
	[Event(name="totalBreakLine", type="events.BreakLineEvent")]
	[Event(name="breakTechnicalSpin", type="events.BreakLineEvent")]
	public class GameModel extends GameModelBase implements IExternalizable
	{
		private var _setting:GameSetting;
		private var _record:GameRecord;
		private var _obstacleManager:ObstacleManager;
		private var nextPRNG:XorShift128;
		private var bigNextPRNG:XorShift128;
		private var obstaclePRNG:XorShift128;
		private var towerPRNG:XorShift128;
		
		private var _isGameOver:Boolean;
		private var controlPhase:Boolean;
		private var completedObstacle:Boolean;
		private var completedTower:Boolean;
		private var appendTowerCount:int;
		private var gemCount:int;
		private var beginHurryUpTime:int;
		private var appendHurryUpCount:int;
		
		private var _cox:Number = 0;
		private var _coy:Number = 0;
		private var _ffy:Number = 0;
		private var _cd:int = 0;
		
		private var fallSpeed:Number = 0;
		private var startFall:Number = 0;
		private var fastFall:Boolean;
		private var playRest:int;
		private var playLimit:int;
		private var controlFalling:Boolean;
		private var lastMoveDir:int;
		private var firstShock:Boolean;
		private var _shockSave:Boolean;
		private var useShockSave:Boolean;
		private var firstBreakLine:Boolean;
		private var delayRest:int;
		
		private var technicalSpinFlag:Boolean;
		private var chainLine:int;
		private var chainDamage:Number = 0;
		private var comboEraseLine:int;
		private var comboTechnicalSpin:int;
		private var comboCount:int;
		private var isEraseJewel:Boolean;
		private var blockAllClearCount:int;
		private var excellentCount:int;
		private var levelStartTime:int;
		
		private var quantityOdds:Vector.<int>;
		private var ominoOdds:Vector.<Vector.<Boolean>>;
		private var bigOminoCount:Number = 0;
		private var towerOdds:Vector.<int>;
		
		public function GameModel() 
		{
			super();
			_record = new GameRecord();
			_setting = new GameSetting();
			_isGameOver = true;
			_obstacleManager = new ObstacleManager();
			quantityOdds = new <int>[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
			ominoOdds = new Vector.<Vector.<Boolean>>(OminoField.ominoQuantity.length);
			for (var x:int = 0; x < ominoOdds.length; x++)
			{
				ominoOdds[x] = new Vector.<Boolean>(OminoField.ominoQuantity[x]);
				for (var y:int = 0; y < ominoOdds[x].length; y++)
				{
					ominoOdds[x][y] = true;
				}
			}
			towerOdds = new Vector.<int>(GameModelBase.fieldWidth);
			for (var i:int = 0; i < towerOdds.length; i++)
			{
				towerOdds[i] = 1;
			}
		}
		
		public function get goy():Number
		{
			if (_controlOmino == null) return 0;
			for (var i:int = coy; i < fieldHeight; i++)
			{
				var a:int = _controlOmino.blocksHitChack(_mainField, cox, i + 1, true);
				if (a > 0) break;
			}
			return i;
		}
		
		public function get rfvy():Number
		{
			var rect:Rect = _mainField.getRect();
			return rect.top;
		}
		
		public function get cox():Number { return _cox; }
		public function get coy():Number { return _coy; }
		public function get ffy():Number { return _ffy; }
		public function get cd():Number { return _cd; }
		public function get shockSave():Boolean { return _shockSave; }
		public function get isGameOver():Boolean { return _isGameOver; }
		public function get isObstacleAddition():Boolean { return _setting.isObstacleAddition(); }
		public function get record():GameRecord { return _record.clone(); }
		public function get setting():GameSetting { return _setting.clone(); }
		public function get obstacleManager():ObstacleManager { return _obstacleManager; }
		public function get nextObstacleTime():int { return _obstacleManager.getNextTrialObstacleTime(_record.gameTime); }
		
		private function comboLine():int
		{
			return comboEraseLine + comboTechnicalSpin;
		}
		
		public function hash():uint
		{
			return _mainField.hash();
		}
		
		public function copyToFragmentModel(to:FragmentGameModel):void
		{
			copyTo(to);
			to.comboCount = comboCount;
			to.comboTotalLine = comboEraseLine;
			to.isHurryUp = isHarryUp();
		}
		
		override public function dispose():void 
		{
			super.dispose();
			obstacleManager.dispose();
		}
		
		public function startGame(setting:GameSetting, seed:XorShift128):void
		{
			this._setting = setting.clone();
			_record = new GameRecord();
			_record.level = setting.startLevel;
			this._setting.setLevelParameter(_record.level);
			_obstacleManager.setSetting(this._setting);
			_isGameOver = false;
			nextPRNG = seed.clone();
			bigNextPRNG = seed.clone();
			obstaclePRNG = seed.clone();
			towerPRNG = seed.clone();
			beginHurryUpTime = (_setting.alwaysHurryUp ? 0 : int.MIN_VALUE);
			setNextOmino(true);
			_controlOmino = new OminoField(ominoSize);
			dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
			dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
			dispatchEvent(new GameEvent(GameEvent.firstUpdateNext, _record.gameTime, 0));
		}
		
		public function harryUp(minGameOverTime:int):void
		{
			if (beginHurryUpTime != int.MIN_VALUE) return;
			if (minGameOverTime + _setting.hurryUpStartMargin > _record.gameTime) return;
			beginHurryUpTime = _record.gameTime;
			dispatchEvent(new GameEvent(GameEvent.beginHurryUp, _record.gameTime, 0));
		}
		
		public function isHarryUp():Boolean
		{
			return beginHurryUpTime != int.MIN_VALUE;
		}
		
		public function forwardGame(command:GameCommand):void
		{
			if (_isGameOver || _setting == null) return;
			_record.gameTime++;
			_obstacleManager.noticeAddition(_record.gameTime);
			if (delayRest > 0)
			{
				delayRest--;
			}
			else if (appendTowerCount > 0)
			{
				appendTowerBlocks();
				appendTowerCount--;
				delayRest = _setting.appendTowerDelay;
				dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
			}
			else if (appendHurryUpCount > 0)
			{
				appendHurryUpBlocks();
				appendHurryUpCount--;
				delayRest = _setting.appendTowerDelay;
				dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
			}
			else if (!controlPhase)
			{
				forwardNonControl();
			}
			if (controlPhase)
			{
				_record.controlTime++;
				forwardControl(command);
			}
			_obstacleManager.checkEnabledObstacle(_record.gameTime, command.enabledObstacle);
			dispatchEvent(new GameEvent(GameEvent.forwardGame, _record.gameTime, 0));
		}
		
		private function forwardNonControl():void
		{
			fallSpeed += _setting.fallAcceleration;
			if (fallSpeed > _setting.maxNaturalFallSpeed) fallSpeed = _setting.maxNaturalFallSpeed;
			fallingField(int(_ffy), int(_ffy + fallSpeed), fastFall);
			_ffy += fallSpeed;
			dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
			if (_fallField.blockCount > 0) return;
			_ffy = 0;
			fallSpeed = 0;
			fastFall = false;
			var bl:int = breakLines();
			if (bl > 0) delayRest = _setting.breakLineDelay;
			checkTechnicalSpin(bl);
			onSectionBreakLine(bl);
			firstBreakLine = false;
			levelUp();
			if (checkJewelAllClear()) return;
			if (extractFallBlocks() > 0)
			{
				dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
				dispatchEvent(new GameEvent(GameEvent.extractFall, _record.gameTime, 0));
				return;
			}
			checkAllClear();
			if (alterAppendHurryUpCount()) return;
			_mainField.clearSpecialUnion();
			dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
			fixChainDamage();
			fixChainLine();
			if (checkGameClear()) return;
			if (_setting.version >= GameSetting.beta2)
			{
				if (appendObstacle())
				{
					completedTower = true;
					return;
				}
				if (alterAppendTowerCount()) return;
			}
			else
			{
				if (alterAppendTowerCount()) return;
				if (appendObstacle()) return;
			}
			setNextOmino(false);
			dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
			dispatchEvent(new GameEvent(GameEvent.updateNext, _record.gameTime, 0));
			dispatchEvent(new ControlEvent(ControlEvent.setOmino, _record.gameTime, 0, _cox, _coy));
			if (checkGameOver()) return;
			obstacleManager.noticePrint();
			startFall = _coy;
			playRest = _setting.playTime;
			playLimit = 0;
			lastMoveDir = GameCommand.nothing;
			firstShock = true;
			useShockSave = false;
			firstBreakLine = true;
			completedObstacle = false;
			completedTower = false;
			controlPhase = true;
		}
		
		private function forwardControl(command:GameCommand):void
		{
			rotationOmino(command.rotation);
			moveOmino(command.move);
			fallingOmino(command.falling, command.fix, command.noDamege);
			if(playRest <= 0 || playRest <= playLimit)
			{
				if (!useShockSave)
				{
					fallingOmino(GameCommand.earth, true, command.noDamege);
				}
				technicalSpinFlag = isTechnicalSpin();
				_controlOmino.fix(_mainField, _cox, _coy);
				_record.fixOmino++;
				dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
				dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
				dispatchEvent(new ControlEvent(ControlEvent.fixOmino, _record.gameTime, 0, _cox, _coy));
				controlPhase = false;
			}
		}
		
		private function rotationOmino(rotation:int):void
		{
			if (rotation != GameCommand.left && rotation != GameCommand.right) return;
			var cacheOmino:OminoField = new OminoField(ominoSize);
			if (rotation == GameCommand.left)
			{
				_controlOmino.rotationLeft(cacheOmino);
				if (++_cd > 3) _cd = 0;
			}
			else
			{
				_controlOmino.rotationRight(cacheOmino);
				if (--_cd < 0) _cd = 3;
			}
			var controlRect:Rect = _controlOmino.getRect();
			var cacheRect:Rect = cacheOmino.getRect();
			var sx:int = rotateReviseX(controlRect, cacheRect);
			var sy:int = rotateReviseY(controlRect, cacheRect);
			var dir:int = rotation;
			for (var i:int = 0; i < ominoSize; i++)
			{
				if (i == 0)
				{
					if (rotationChack(cacheOmino, controlRect, cacheRect, sx, sy)) return;
					continue;
				}
				var k:int = 0;
				var a:int = 0;
				for (k = 0; k < i; k++)
				{
					a = (dir == GameCommand.left ? k * -1 : k);
					if (rotationChack(cacheOmino, controlRect, cacheRect, sx + a, sy + i)) return;
					if (k > 0) if (rotationChack(cacheOmino, controlRect, cacheRect, sx - a, sy + i)) return;
				}
				for (k = 0; k <= i; k++)
				{
					a = (dir == GameCommand.left ? i * -1 : i);
					if (rotationChack(cacheOmino, controlRect, cacheRect, sx + a, sy + k)) return;
					if (rotationChack(cacheOmino, controlRect, cacheRect, sx - a, sy + k)) return;
				}
				for (k = 1; k < i; k++)
				{
					a = (dir == GameCommand.left ? i * -1 : i);
					if (rotationChack(cacheOmino, controlRect, cacheRect, sx + a, sy - k)) return;
					if (rotationChack(cacheOmino, controlRect, cacheRect, sx - a, sy - k)) return;
				}
				for (k = 0; k <= i; k++)
				{
					a = (dir == GameCommand.left ? k * -1 : k);
					if (rotationChack(cacheOmino, controlRect, cacheRect, sx + a, sy - i)) return;
					if (k > 0) if (rotationChack(cacheOmino, controlRect, cacheRect, sx - a, sy - i)) return;
				}
			}
			dispatchEvent(new ControlEvent(ControlEvent.rotationNG, _record.gameTime, 0, _cox, _coy));
		}
		
		private function rotationChack(cacheOmino:OminoField, controlRect:Rect, cacheRect:Rect, x:int, y:int):Boolean
		{
			//if (controlRect.left > cacheRect.right + x || controlRect.right < cacheRect.left + x) return false;
			//if (controlRect.top > cacheRect.bottom + y || controlRect.bottom < cacheRect.top + y) return false;
			if (cacheOmino.blocksHitChack(_controlOmino, x, y, false) == 0) return false;
			if (cacheOmino.blocksHitChack(_mainField, _cox + x, _coy + y, true) > 0) return false;
			_controlOmino = cacheOmino;
			dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
			dispatchEvent(new ControlEvent(ControlEvent.rotationOK, _record.gameTime, 0, _cox, _coy));
			if (cacheOmino.blocksHitChack(_mainField, _cox + x, Math.ceil(_coy) + y, true) > 0)
			{
				_coy = Math.floor(_coy);
			}
			_cox += x;
			_coy += y;
			playLimit = 0;
			return true;
		}
		
		private function moveOmino(move:int):void
		{
			if (move == GameCommand.left)
			{
				if (_controlOmino.blocksHitChack(_mainField, _cox - 1, _coy, true) <= 0)
				{
					dispatchEvent(new ControlEvent(ControlEvent.moveOK, _record.gameTime, 0, _cox, _coy));
					_cox -= 1;
					playLimit = 0;
				}
				else if (lastMoveDir == GameCommand.nothing)
				{
					dispatchEvent(new ControlEvent(ControlEvent.moveNG, _record.gameTime, 0, _cox, _coy));
				}
			}
			else if (move == GameCommand.right)
			{
				if (_controlOmino.blocksHitChack(_mainField, _cox + 1, _coy, true) <= 0)
				{
					dispatchEvent(new ControlEvent(ControlEvent.moveOK, _record.gameTime, 0, _cox, _coy));
					_cox += 1;
					playLimit = 0;
				}
				else if (lastMoveDir == GameCommand.nothing)
				{
					dispatchEvent(new ControlEvent(ControlEvent.moveNG, _record.gameTime, 0, _cox, _coy));
				}
			}
			lastMoveDir = move;
		}
		
		private function fallingOmino(falling:int, fix:Boolean, noDamage:Boolean):void
		{
			switch(falling)
			{
				case GameCommand.fast:
					fallSpeed = _setting.fastFallSpeed > _setting.compelFallSpeed ? _setting.fastFallSpeed : _setting.compelFallSpeed;
					if (!controlFalling)
					{
						controlFalling = true;
						dispatchEvent(new ControlEvent(ControlEvent.startFall, _record.gameTime, 0, _cox, _coy));
					}
					break;
				case GameCommand.earth:
					fallSpeed = fieldHeight;
					break;
				default:
					fallSpeed = _setting.compelFallSpeed;
					startFall = _coy;
					if (controlFalling)
					{
						controlFalling = false;
						dispatchEvent(new ControlEvent(ControlEvent.endFall, _record.gameTime, 0, _cox, _coy));
					}
					break;
			}
			if (!noDamage && _shockSave)
			{
				_shockSave = false;
				dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
				dispatchEvent(new ControlEvent(ControlEvent.shockSaveOFF, _record.gameTime, 0, _cox, _coy));
			}
			else if (noDamage && !_shockSave)
			{
				_shockSave = true;
				dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
				dispatchEvent(new ControlEvent(ControlEvent.shockSaveON, _record.gameTime, 0, _cox, _coy));
			}
			var coefficient:Number;
			var damage:Number;
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
				if (firstShock && !_shockSave)
				{
					firstShock = false;
					coefficient = 1;
					damage = shockDamage(_controlOmino, _cox, _coy + i, coefficient);
					onSectionDamage(damage, coefficient);
					dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
					dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
					dispatchEvent(new ControlEvent(ControlEvent.fallShock, _record.gameTime, 0, _cox, _coy));
				}
				else if (startFall < _coy + i)
				{
					if (_shockSave)
					{
						useShockSave = true;
						dispatchEvent(new ControlEvent(ControlEvent.fallShockSave, _record.gameTime, 0, _cox, _coy));
					}
					else
					{
						coefficient = getNaturalShockDamage(Math.ceil(_coy - startFall) + i, false);
						damage = shockDamage(_controlOmino, _cox, _coy + i, coefficient);
						onSectionDamage(damage, coefficient);
						dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
						dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
						dispatchEvent(new ControlEvent(ControlEvent.fallShock, _record.gameTime, 0, _cox, _coy));
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
				if (playLimit < playRest - _setting.playFastTime)
				{
					playLimit = playRest - _setting.playFastTime;
				}
				_coy = int(_coy + i);
				startFall = _coy
				return;
			}
			_coy += fallSpeed;
		}
		
		private function levelUp():void
		{
			if (_setting.isLevelUp(_record.level, _record.breakLine))
			{
				var upLevel:int = _setting.levelUpCount(_record.level, _record.breakLine);
				var clearTime:int = _record.gameTime - levelStartTime;
				var timeBonus:int = _setting.timeBonus(clearTime, upLevel);
				levelStartTime = _record.gameTime;
				_record.level += upLevel;
				_record.gameScore += timeBonus;
				_setting.setLevelParameter(_record.level);
				dispatchEvent(new LevelClearEvent(LevelClearEvent.levelClear, _record.gameTime, timeBonus, clearTime, upLevel));
			}
		}
		
		private function checkGameClear():Boolean 
		{
			if (_setting.isGameClear(_record.level) && comboCount == 0)
			{
				_isGameOver = true;
				dispatchEvent(new GameEvent(GameEvent.gameClear, _record.gameTime, 0));
				return true;
			}
			return false;
		}
		
		private function checkGameOver():Boolean 
		{
			if (_controlOmino.blocksHitChack(_mainField, _cox, _coy, true) > 0)
			{
				_isGameOver = true;
				dispatchEvent(new GameEvent(GameEvent.gameOver, _record.gameTime, 0));
				return true;
			}
			return false;
		}
		
		private function checkTechnicalSpin(bl:int):void 
		{
			if (technicalSpinFlag && firstBreakLine)
			{
				comboTechnicalSpin += bl;
				var tsps:int = _setting.breakLineScore(comboLine(), comboCount) - _setting.breakLineScore(comboLine() - bl, comboCount);
				_record.gameScore += tsps;
				var tsoc:int = obstacleManager.occurObstacle(_record.gameTime, comboLine(), comboCount, blockAllClearCount);
				_record.occurObstacle += tsoc;
				dispatchEvent(new BreakLineEvent(BreakLineEvent.breakTechnicalSpin, _record.gameTime, tsps, _setting, bl, comboEraseLine, comboTechnicalSpin, comboCount));
			}
		}
		
		private function isTechnicalSpin():Boolean
		{
			if (_controlOmino.blocksHitChack(_mainField, _cox + 1, _coy, true) <= 0) return false;
			if (_controlOmino.blocksHitChack(_mainField, _cox - 1, _coy, true) <= 0) return false;
			if (_controlOmino.blocksHitChack(_mainField, _cox, _coy + 1, true) <= 0) return false;
			if (_controlOmino.blocksHitChack(_mainField, _cox, _coy - 1, true) <= 0) return false;
			return true;
		}
		
		private function checkJewelAllClear():Boolean 
		{
			if (_setting.isTowerAddition() && gemCount > 0 && _mainField.getTypeCount(BlockState.jewel) == 0)
			{
				appendTowerCount = getAppendTowerCount();
				var prevGemCount:int = gemCount;
				gemCount = _mainField.getTypeCount(BlockState.jewel) + appendTowerCount;
				excellentCount++;
				var ecs:int = _setting.excellentBonusScore * prevGemCount;
				_record.gameScore += ecs;
				var ecoc:int = obstacleManager.occurObstacle(_record.gameTime, comboLine(), comboCount, blockAllClearCount);
				_record.occurObstacle += ecoc;
				dispatchEvent(new GameEvent(GameEvent.jewelAllClear, _record.gameTime, ecs));
				dispatchEvent(new GameEvent(GameEvent.appendTower, _record.gameTime, 0));
				return true;
			}
			return false;
		}
		
		private function checkAllClear():void 
		{
			if (_mainField.blockCount == 0 && _record.gameTime > 1)
			{
				blockAllClearCount++;
				var acs:int = _setting.blockAllClearBonusScore;
				_record.gameScore += acs;
				var acoc:int = obstacleManager.occurObstacle(_record.gameTime, comboLine(), comboCount, blockAllClearCount);
				_record.occurObstacle += acoc;
				dispatchEvent(new GameEvent(GameEvent.blockAllClear, _record.gameTime, acs));
			}
		}
		
		private function fixChainDamage():void 
		{
			if (chainDamage > 0)
			{
				_record.blockDamage += chainDamage;
				dispatchEvent(new ShockBlockEvent(ShockBlockEvent.totalDamage, _record.gameTime, chainDamage, chainDamage));
			}
			chainDamage = 0;
		}
		
		private function fixChainLine():void 
		{
			if (chainLine > 0)
			{
				var tps:int = _setting.breakLineScore(comboLine(), comboCount);
				dispatchEvent(new BreakLineEvent(BreakLineEvent.totalBreakLine, _record.gameTime, tps, _setting, comboLine(), comboEraseLine, comboTechnicalSpin, comboCount));
				completedObstacle = true;
				completedTower = true;
				technicalSpinFlag = false;
				if (comboCount > 0) _record.comboCount++;
				comboCount++;
			}
			else
			{
				if (comboEraseLine > 0 || technicalSpinFlag)
				{
					comboCount = Math.max(0, comboCount - 1);
					var ecps:int = _setting.breakLineScore(comboLine(), comboCount);
					dispatchEvent(new BreakLineEvent(BreakLineEvent.endCombo, _record.gameTime, ecps, _setting, comboLine(), comboEraseLine, comboTechnicalSpin, comboCount));
					_record.incrementChainLines(comboEraseLine);
					obstacleManager.breakCombo(_record.gameTime);
				}
				comboEraseLine = 0;
				comboTechnicalSpin = 0;
				comboCount = 0;
				blockAllClearCount = 0;
				excellentCount = 0;
			}
			chainLine = 0;
		}
		
		private function setNextOmino(init:Boolean):void
		{
			bigOminoCount += _setting.bigOminoCountAddition;
			var omino:OminoField;
			if (int(bigOminoCount) > _setting.bigOminoCountMax * bigNextPRNG.genNumber())
			{
				omino = OminoField.createBigOmino(bigOminoCount + 10, ominoSize, bigNextPRNG);
				bigOminoCount = 0;
			}
			else
			{
				omino = randomReadOmino(nextPRNG.genUint(), nextPRNG.genUint());
			}
			var color:uint = omino.coloringOmino();
			omino.allSetState(BlockState.normal, color, GameSetting.hitPointMax, true);
			rotateNext(omino);
			if (init ? _nextOmino[0] == null : _controlOmino == null)
			{
				setNextOmino(init);
			}
			else if (_controlOmino != null)
			{
				var rect:Rect = _controlOmino.getRect();
				_cox = init_cox(rect);
				_coy = init_coy(rect);
				_cd = 0;
			}
		}
		
		private function randomReadOmino(rand1:uint, rand2:uint):OminoField
		{
			var a:int = 0;
			var t:int = 0;
			for (var q:int = 0; q < OminoField.ominoQuantity.length; q++)
			{
				if (_setting.quantityOddsBasis[q] == 0) continue;
				t += quantityOdds[q];
			}
			rand1 %= t;
			for (q = 0; rand1 >= quantityOdds[q] || _setting.quantityOddsBasis[q] == 0; q++)
			{
				if (_setting.quantityOddsBasis[q] == 0) continue;
				rand1 -= quantityOdds[q];
			}
			if (quantityOdds[q] == 1)
			{
				for (var i:String in quantityOdds)
				{
					quantityOdds[i] <<= _setting.quantityOddsBasis[i];
				}
			}
			quantityOdds[q] >>>= 1;
			
			a = 0;
			t = 0;
			var op:Vector.<Boolean> = ominoOdds[q];
			for (var o:int = 0; o < op.length; o++)
			{
				if (op[o]) t++;
			}
			rand2 %= t;
			for (o = 0; o < op.length; o++)
			{
				if (!op[o]) continue;
				if (rand2 == 0) break;
				rand2--;
			}
			op[o] = false;
			if (op.every(function callback(item:Boolean, index:int, vector:Vector.<Boolean>):Boolean { return !item } ))
			{
				for (var j:String in op)
				{
					op[j] = true;
				}
			}
			return OminoField.readOmino(q, o, ominoSize);
		}
		
		private function appendObstacle():Boolean 
		{
			if (!completedObstacle && _obstacleManager.noticePrintCount > 0)
			{
				var oc:int = appendObstacleBlocks();
				fallSpeed = _setting.maxNaturalFallSpeed;
				fastFall = true;
				completedObstacle = true;
				dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
				dispatchEvent(new GameEvent(GameEvent.obstacleFall, _record.gameTime, 0));
				_record.receivedObstacle += oc;
				return true;
			}
			return false;
		}
		
		private function appendObstacleBlocks():int
		{
			var ret:int = obstacleManager.receivedNotice(_record.gameTime);
			var rest:int = ret;
			for (var i:int = 0; i < _setting.obstacleLineMax && rest > 0; i++)
			{
				var y:int = GameModelBase.gameOverHeight - i;
				if (rest < _setting.obstacleLineBlockMax)
				{
					rest -= setObstacleLine(y, rest, BlockState.normal, _setting.obstacleColor, GameSetting.hitPointMax);
				}
				else
				{
					rest -= setObstacleLine(y, _setting.obstacleLineBlockMax, BlockState.normal, _setting.obstacleColor, GameSetting.hitPointMax);
				}
			}
			return ret - rest;
		}
		
		private function alterAppendTowerCount():Boolean 
		{
			if (!completedTower && _setting.isTowerAddition())
			{
				appendTowerCount = getAppendTowerCount();
				gemCount = _mainField.getTypeCount(BlockState.jewel) + appendTowerCount;
				if (appendTowerCount > 0)
				{
					completedTower = true;
					dispatchEvent(new GameEvent(GameEvent.appendTower, _record.gameTime, 0));
					return true;
				}
			}
			return false;
		}
		
		private function getAppendTowerCount():int
		{
			var a:int = 10 - _mainField.getTypeCount(BlockState.jewel);
			var b:int = _mainField.getHeight() - (GameModelBase.gameOverHeight + 1);
			var c:int = (GameModelBase.fieldHeight - _mainField.getTypeHeight(BlockState.nonBreak)) / 2;
			return Math.max(0, Math.min(a - c, b));
		}
		
		private function alterAppendHurryUpCount():Boolean
		{
			if (beginHurryUpTime == int.MIN_VALUE) return false;
			var nbh:int = GameModelBase.fieldHeight - _mainField.getTypeHeight(BlockState.nonBreak);
			var tnbh:int = (_record.gameTime - beginHurryUpTime) / _setting.hurryUpMargin;
			appendHurryUpCount = Math.max(0, tnbh - nbh);
			if (appendHurryUpCount > 0) 
			{
				dispatchEvent(new GameEvent(GameEvent.appendHurryUp, _record.gameTime, 0));
				return true;
			}
			return false;
		}
		
		private function appendTowerBlocks():void
		{
			var y:int = _mainField.getTypeHeight(BlockState.nonBreak) - 1;
			_mainField.shiftUp(y);
			var rx:int = selectSetPosition();
			_mainField.setNewBlock(rx, y, new BlockState(BlockState.jewel, _setting.getJewelColor(towerPRNG.genNumber()), 0, false));
			setTowerLine(y, _setting.towerLineBlockMax, BlockState.normal, _setting.obstacleColor, GameSetting.hitPointMax);
		}
		
		private function appendHurryUpBlocks():void
		{
			var y:int = GameModelBase.fieldHeight - 1;
			_mainField.shiftUp(y);
			var state:BlockState = new BlockState(BlockState.nonBreak, _setting.obstacleColor, Number.POSITIVE_INFINITY);
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				_mainField.setNewBlock(x, y, state);
			}
		}
		
		private function setObstacleLine(y:int, blockCount:int, type:int, color:uint, hitPoint:Number):int
		{
			var width:int = GameModelBase.fieldWidth;
			var sb:Vector.<BlockState> = new Vector.<BlockState>(width);
			for (var i:int = 0; i < sb.length; i++)
			{
				if (i < blockCount)
				{
					sb[i] = new BlockState(type, color, hitPoint, false)
				}
				else
				{
					sb[i] = new BlockState()
				}
			}
			for (i = 0; i < width; i++)
			{
				var r:int = obstaclePRNG.genUint() % (width - i) + i;
				var t:BlockState = sb[i];
				sb[i] = sb[r];
				sb[r] = t;
			}
			var ret:int = 0;
			for (i = 0; i < width; i++)
			{
				if (sb[i].isEmpty()) continue;
				if (!_mainField.isExistBlock(i, y))
				{
					ret++;
					continue;
				}
				sb[i] = new BlockState();
			} 
			_fallField.setLine(y, sb);
			return ret;
		}
		
		private function setTowerLine(y:int, blockCount:int, type:int, color:uint, hitPoint:Number):void
		{
			_mainField.fix(_tempField, 0, 0);
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				_tempField.extractConnection(_mainField, x, y, true);
			}
			for (var i:int = 0; i < blockCount; i++)
			{
				var esp:Vector.<Boolean> = getEnableSetPosition(y, !_tempField.isEmptyLine(y - 1));
				var p:int = selectSetPosition(esp);
				_tempField.setNewBlock(p, y, new BlockState(type, color, hitPoint));
				_tempField.extractConnection(_mainField, p, y, true);
			}
			_tempField.fix(_mainField, 0, 0);
		}
		
		private function getEnableSetPosition(y:int, stay:Boolean):Vector.<Boolean>
		{
			var ret:Vector.<Boolean> = new Vector.<Boolean>(GameModelBase.fieldWidth);
			for (var i:int = 0; i < GameModelBase.fieldWidth; i++)
			{
				ret[i] = false;
				if (_mainField.isExistBlock(i, y)) continue;
				if (stay && !_tempField.isExistBlock(i, y - 1)) continue;
				ret[i] = true;
			}
			return ret;
		}
		
		private function selectSetPosition(esp:Vector.<Boolean> = null):int
		{
			if (esp == null)
			{
				esp = new <Boolean>[true,true,true,true,true,true,true,true,true,true];
			}
			var c:int = 0;
			for (var i:int = 0; i < esp.length; i++)
			{
				if (esp[i] == true)
				{
					c += towerOdds[i];
				}
			}
			var r:int = towerPRNG.genUint() % c;
			for (var k:int = 0; k < esp.length; k++)
			{
				if (esp[k] == false) continue;
				r -= towerOdds[k];
				if (r < 0)
				{
					alterTowerOdds(k);
					return k;
				}
			}
			throw Debug.fail();
		}
		
		private function alterTowerOdds(i:int):void
		{
			if (towerOdds[i] == 1)
			{
				for (var k:int = 0; k < towerOdds.length; ++k)
				{
					towerOdds[k] <<= 1;
				}
			}
			towerOdds[i] >>>= 1;
		}
		
		override protected function onBreakLine(y:int, blocks:Vector.<BlockState>):void 
		{
			var plus:int = _setting.breakLineScore(comboLine() + 1, comboCount) - _setting.breakLineScore(comboLine(), chainLine == 0 ? comboCount - 1 : comboCount);
			_record.gameScore += plus;
			_record.breakLine++;
			chainLine++;
			comboEraseLine++;
			dispatchEvent(new BreakLineEvent(BreakLineEvent.breakLine, _record.gameTime, plus, _setting, y, comboEraseLine, comboTechnicalSpin, comboCount, blocks));
			var obs:int = obstacleManager.occurObstacle(_record.gameTime, comboEraseLine, comboCount, blockAllClearCount);
			_record.occurObstacle += obs;
			for (var i:int = 0; i < blocks.length; ++i)
			{
				if (blocks[i].type == BlockState.jewel) isEraseJewel = true;
			}
		}
		
		override protected function onSectionBreakLine(count:int):void 
		{
			if (count == 0) return;
			var plus:int = _setting.breakLineScore(comboLine(), comboCount + 1) - _setting.breakLineScore(comboLine() - chainLine, comboCount);
			dispatchEvent(new BreakLineEvent(BreakLineEvent.sectionBreakLine, _record.gameTime, plus, _setting, chainLine, comboEraseLine, comboTechnicalSpin, comboCount));
			if (isEraseJewel == true)
			{
				dispatchEvent(new BreakLineEvent(BreakLineEvent.eraseJewel, _record.gameTime, 0, _setting, chainLine, comboEraseLine, comboTechnicalSpin, comboCount));
				isEraseJewel = false;
			}
		}
		
		override protected function onBlockDamage(damage:Number, distance:int, id:uint, toSplit:Boolean):void 
		{
			if (toSplit) _record.splitBlock++;
			dispatchEvent(new ShockBlockEvent(ShockBlockEvent.shockDamage, _record.gameTime, 0, damage, Number.NaN, distance, id, toSplit));
		}
		
		override protected function onSectionDamage(damage:Number, coefficient:Number):void
		{
			if (damage == 0) return;
			var plus:int = chainDamage % 1 + damage;
			_record.gameScore += plus;
			chainDamage += damage;
			dispatchEvent(new ShockBlockEvent(ShockBlockEvent.sectionDamage, _record.gameTime, plus, damage, coefficient));
		}
		
		public function writeExternal(output:IDataOutput):void 
		{
			output.writeObject(_mainField);
			output.writeObject(_fallField);
			output.writeObject(_controlOmino);
			output.writeObject(_nextOmino);
			
			output.writeObject(_setting);
			output.writeObject(_record);
			output.writeObject(_obstacleManager);
			output.writeObject(nextPRNG);
			output.writeObject(bigNextPRNG);
			output.writeObject(obstaclePRNG);
			
			output.writeBoolean(_isGameOver);
			output.writeBoolean(controlPhase);
			output.writeBoolean(completedObstacle);
			output.writeBoolean(completedTower);
			output.writeInt(appendTowerCount);
			
			output.writeDouble(_cox);
			output.writeDouble(_coy);
			output.writeDouble(_ffy);
			
			output.writeDouble(fallSpeed);
			output.writeDouble(startFall);
			output.writeInt(playRest);
			output.writeInt(playLimit);
			output.writeBoolean(controlFalling);
			output.writeInt(lastMoveDir);
			output.writeBoolean(firstShock);
			output.writeBoolean(_shockSave);
			output.writeBoolean(useShockSave);
			
			output.writeInt(chainLine);
			output.writeDouble(chainDamage);
			output.writeInt(levelStartTime);
			
			output.writeObject(quantityOdds);
			for (var x:int = 0; x < ominoOdds.length; x++)
			{
				for (var y:int = 0; y < ominoOdds[x].length; y++)
				{
					output.writeBoolean(ominoOdds[x][y]);
				}
			}
			output.writeInt(bigOminoCount);
		}
		
		public function readExternal(input:IDataInput):void 
		{
			_mainField = input.readObject();
			_fallField = input.readObject();
			_controlOmino = input.readObject();
			_nextOmino = input.readObject();
			
			_setting = input.readObject();
			_record = input.readObject();
			_obstacleManager = input.readObject();
			nextPRNG = input.readObject();
			bigNextPRNG = input.readObject();
			obstaclePRNG = input.readObject();
			
			_isGameOver = input.readBoolean();
			controlPhase = input.readBoolean();
			completedObstacle = input.readBoolean();
			completedTower = input.readBoolean();
			appendTowerCount = input.readInt();
			
			_cox = input.readDouble();
			_coy = input.readDouble();
			_ffy = input.readDouble();
			
			fallSpeed = input.readDouble();
			startFall = input.readDouble();
			playRest = input.readInt();
			playLimit = input.readInt();
			controlFalling = input.readBoolean();
			lastMoveDir = input.readInt();
			firstShock = input.readBoolean();
			_shockSave = input.readBoolean();
			useShockSave = input.readBoolean();
			
			chainLine = input.readInt();
			chainDamage = input.readDouble();
			levelStartTime = input.readInt();
			
			quantityOdds = input.readObject();
			ominoOdds = new Vector.<Vector.<Boolean>>(OminoField.ominoQuantity.length);
			for (var x:int = 0; x < ominoOdds.length; x++)
			{
				ominoOdds[x] = new Vector.<Boolean>(OminoField.ominoQuantity[x]);
				for (var y:int = 0; y < ominoOdds[x].length; y++)
				{
					ominoOdds[x][y] = input.readBoolean();
				}
			}
			bigOminoCount = input.readInt();
		}
	}

}