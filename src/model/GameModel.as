package model 
{
	import events.*;
	import flash.utils.*;
	import model.ai.FragmentGameModel;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="forwardGame", type="events.GameEvent")]
	[Event(name="updateField", type="events.GameEvent")]
	[Event(name="updateControl", type="events.GameEvent")]
	[Event(name="updateNext", type="events.GameEvent")]
	[Event(name="firstUpdateNext", type="events.GameEvent")]
	[Event(name="updateObstacle", type="events.GameEvent")]
	[Event(name="gameOver", type="events.GameEvent")]
	[Event(name="gameClear", type="events.GameEvent")]
	[Event(name="breakConbo", type="events.GameEvent")]
	[Event(name="extractFall", type="events.GameEvent")]
	[Event(name="obstacleFall", type="events.GameEvent")]
	[Event(name="appendTower", type="events.GameEvent")]
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
	public class GameModel extends GameModelBase implements IExternalizable
	{
		private var setting:GameSetting;
		private var _record:GameRecord;
		private var _obstacleManager:ObstacleManager;
		private var nextPRNG:XorShift128;
		private var bigNextPRNG:XorShift128;
		private var obstaclePRNG:XorShift128;
		
		private var _isGameOver:Boolean;
		private var controlPhase:Boolean;
		private var completedObstacle:Boolean;
		private var completedTower:Boolean;
		private var appendTowerCount:int;
		
		private var _cox:Number = 0;
		private var _coy:Number = 0;
		private var _ffy:Number = 0;
		
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
		private var comboTotalLine:int;
		private var comboCount:int;
		private var blockAllClearCount:int;
		private var excellentCount:int;
		private var levelStartTime:int;
		
		private var quantityOdds:Vector.<int>;
		private var ominoOdds:Vector.<Vector.<Boolean>>;
		private var bigOminoCount:Number = 0;
		
		public function GameModel() 
		{
			super(true);
			_record = new GameRecord();
			setting = new GameSetting();
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
		}
		
		[Bindable(event="forwardGame")]
		public function get goy():Number
		{
			for (var i:int = coy; i < fieldHeight; i++)
			{
				var a:int = _controlOmino.blocksHitChack(_mainField, cox, i + 1, true);
				if (a > 0) break;
			}
			return i;
		}
		
		[Bindable(event="forwardGame")]
		public function get rfvy():Number
		{
			var rect:Rect = _mainField.getRect();
			return rect.top;
		}
		
		[Bindable(event="forwardGame")]
		public function get cox():Number { return _cox; }
		
		[Bindable(event="forwardGame")]
		public function get coy():Number { return _coy; }
		
		[Bindable(event="forwardGame")]
		public function get ffy():Number { return _ffy; }
		
		[Bindable(event="forwardGame")]
		public function get shockSave():Boolean { return _shockSave; }
		
		[Bindable(event="forwardGame")]
		public function get isGameOver():Boolean { return _isGameOver; }
		
		[Bindable(event="forwardGame")]
		public function get isObstacleAddition():Boolean { return setting.isObstacleAddition(); }
		
		[Bindable(event="forwardGame")]
		public function get record():GameRecord { return _record; }
		
		[Bindable(event="forwardGame")]
		public function get obstacleManager():ObstacleManager { return _obstacleManager; }
		
		[Bindable(event="forwardGame")]
		public function get nextObstacleTime():int { return _obstacleManager.getNextTrialObstacleTime(_record.gameTime); }
		
		public function hash():uint
		{
			return _mainField.hash();
		}
		
		public function getLightModel():FragmentGameModel
		{
			var result:FragmentGameModel = new FragmentGameModel();
			result.mainField = _mainField.clone();
			result.fallField = _fallField.clone();
			result.controlOmino = _controlOmino.clone();
			result.nextOmino = new Vector.<OminoField>(nextLength, true);
			for (var i:int = 0; i < nextLength; i++)
			{
				result.nextOmino[i] = _nextOmino[i].clone();
			}
			result.comboCount = comboCount;
			result.comboTotalLine = comboTotalLine;
			return result;
		}
		
		public function startGame(setting:GameSetting, seed:XorShift128):void
		{
			this.setting = setting.clone();
			_record = new GameRecord();
			_record.level = setting.startLevel;
			this.setting.setLevelParameter(_record.level);
			_obstacleManager.setSetting(this.setting);
			_isGameOver = false;
			nextPRNG = seed.clone();
			bigNextPRNG = seed.clone();
			obstaclePRNG = seed.clone();
			setNextOmino(true);
			_controlOmino = new OminoField(ominoSize);
			dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
			dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
			dispatchEvent(new GameEvent(GameEvent.firstUpdateNext, _record.gameTime, 0));
		}
		
		public function forwardGame(command:GameCommand):void
		{
			if (_isGameOver || setting == null) return;
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
			fallSpeed += setting.fallAcceleration;
			if (fallSpeed > setting.fastFallSpeed) fallSpeed = setting.fastFallSpeed;
			fallingField(int(_ffy), int(_ffy + fallSpeed), fastFall);
			_ffy += fallSpeed;
			dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
			if (_fallField.countBlock() > 0) return;
			_ffy = 0;
			fallSpeed = 0;
			fastFall = false;
			var bl:int = breakLines();
			if (bl > 0) delayRest = setting.breakLineDelay;
			if (technicalSpinFlag && firstBreakLine)
			{
				chainLine += bl;
				comboTotalLine += bl;
				var tsps:int = setting.breakLineScore(comboTotalLine + 1, comboCount) - setting.breakLineScore(comboTotalLine, comboCount);
				_record.gameScore += tsps;
				var tsoc:int = obstacleManager.occurObstacle(_record.gameTime, comboTotalLine, comboCount, blockAllClearCount, excellentCount);
				_record.occurObstacle += tsoc;
				dispatchEvent(new BreakLineEvent(BreakLineEvent.technicalSpin, _record.gameTime, tsps, setting, bl, comboCount));
			}
			firstBreakLine = false;
			levelUp();
			if (!completedTower && setting.isTowerAddition() && _mainField.getColorHeight(setting.obstacleColor2) == GameModelBase.fieldHeight)
			{
				appendTowerCount = getAppendTowerCount();
				completedTower = true;
				excellentCount++;
				var ecs:int = setting.excellentBonusScore;
				_record.gameScore += ecs;
				var ecoc:int = obstacleManager.occurObstacle(_record.gameTime, comboTotalLine, comboCount, blockAllClearCount, excellentCount);
				_record.occurObstacle += ecoc;
				dispatchEvent(new GameEvent(GameEvent.excellent, _record.gameTime, ecs));
				dispatchEvent(new GameEvent(GameEvent.appendTower, _record.gameTime, 0));
				return;
			}
			extractFallBlocks();
			if (_fallField.countBlock() > 0)
			{
				dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
				dispatchEvent(new GameEvent(GameEvent.extractFall, _record.gameTime, 0));
				return;
			}
			if (_mainField.countBlock() == 0 && _record.gameTime > 1)
			{
				blockAllClearCount++;
				var acs:int = setting.blockAllClearBonusScore;
				_record.gameScore += acs;
				var acoc:int = obstacleManager.occurObstacle(_record.gameTime, comboTotalLine, comboCount, blockAllClearCount, excellentCount);
				_record.occurObstacle += acoc;
				dispatchEvent(new GameEvent(GameEvent.blockAllClear, _record.gameTime, acs));
			}
			_mainField.clearSpecialUnion(onClearSpecialUnion);
			dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
			dispatchEvent(new GameEvent(GameEvent.breakChain, _record.gameTime, 0));
			if (chainDamage > 0)
			{
				_record.blockDamage += chainDamage;
				dispatchEvent(new ShockBlockEvent(ShockBlockEvent.totalDamage, _record.gameTime, chainDamage, chainDamage, chainDamage));
			}
			if (chainLine > 0 || technicalSpinFlag)
			{
				dispatchEvent(new BreakLineEvent(BreakLineEvent.totalBreakLine, _record.gameTime, setting.breakLineScore(comboTotalLine, comboCount), setting, comboTotalLine, comboCount));
				completedObstacle = true;
				completedTower = true;
				technicalSpinFlag = false;
				comboCount++;
			}
			else
			{
				_record.chainLines[Math.min(20, comboTotalLine)]++;
				comboTotalLine = 0;
				comboCount = 0;
				blockAllClearCount = 0;
				excellentCount = 0;
				obstacleManager.breakCombo(_record.gameTime);
				dispatchEvent(new GameEvent(GameEvent.breakCombo, _record.gameTime, 0));
			}
			chainLine = 0;
			chainDamage = 0;
			if (!completedObstacle && _obstacleManager.noticeCount > 0)
			{
				var oc:int = appendObstacleBlocks();
				fallSpeed = setting.fastFallSpeed;
				fastFall = true;
				completedObstacle = true;
				completedTower = true;
				dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
				dispatchEvent(new GameEvent(GameEvent.obstacleFall, _record.gameTime, 0));
				_record.receivedObstacle += oc;
				return;
			}
			if (!completedTower && setting.isTowerAddition())
			{
				appendTowerCount = getAppendTowerCount();
				if (appendTowerCount > 0)
				{
					completedTower = true;
					dispatchEvent(new GameEvent(GameEvent.appendTower, _record.gameTime, 0));
					return;
				}
			}
			if (setting.isGameClear(_record.level))
			{
				_isGameOver = true;
				_record.gameClear = true;
				dispatchEvent(new GameEvent(GameEvent.gameClear, _record.gameTime, 0));
				return;
			}
			setNextOmino(false);
			dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
			dispatchEvent(new GameEvent(GameEvent.updateNext, _record.gameTime, 0));
			dispatchEvent(new ControlEvent(ControlEvent.setOmino, _record.gameTime, 0, _cox, _coy));
			if (_controlOmino.blocksHitChack(_mainField, _cox, _coy, true) > 0)
			{
				_isGameOver = true;
				dispatchEvent(new GameEvent(GameEvent.gameOver, _record.gameTime, 0));
				return;
			}
			obstacleManager.noticePrint();
			startFall = _coy;
			playRest = setting.playTime;
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
				_mainField.fix(_controlOmino, _cox, _coy);
				_record.fixOmino++;
				dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
				dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
				dispatchEvent(new ControlEvent(ControlEvent.fixOmino, _record.gameTime, 0, _cox, _coy));
				controlPhase = false;
			}
		}
		
		override protected function onBreakLine(y:int, colors:Vector.<uint>):void 
		{
			var plus:int = setting.breakLineScore(comboTotalLine + 1, comboCount) - setting.breakLineScore(comboTotalLine, comboCount);
			_record.gameScore += plus;
			_record.breakLine++;
			chainLine++;
			comboTotalLine++;
			dispatchEvent(new BreakLineEvent(BreakLineEvent.breakLine, _record.gameTime, plus, setting, comboTotalLine, comboCount, y, colors));
			var obs:int = obstacleManager.occurObstacle(_record.gameTime, comboTotalLine, comboCount, blockAllClearCount, excellentCount);
			_record.occurObstacle += obs;
		}
		
		override protected function onSectionBreakLine(count:int):void 
		{
			if (count == 0) return;
			var plus:int = setting.breakLineScore(comboTotalLine, comboCount);
			dispatchEvent(new BreakLineEvent(BreakLineEvent.sectionBreakLine, _record.gameTime, plus, setting, comboTotalLine, comboCount));
		}
		
		override protected function onBlockDamage(damage:Number, newState:BlockState, oldState:BlockState):void 
		{
			dispatchEvent(new ShockBlockEvent(ShockBlockEvent.shockDamage, _record.gameTime, 0, damage, Number.NaN, Number.NaN, newState, oldState));
		}
		
		override protected function onSectionDamage(damage:Number, coefficient:Number):void
		{
			if (damage == 0) return;
			var plus:int = chainDamage % 1 + damage;
			_record.gameScore += plus;
			chainDamage += damage;
			dispatchEvent(new ShockBlockEvent(ShockBlockEvent.sectionDamage, _record.gameTime, plus, damage, chainDamage, coefficient));
		}
		
		private function onClearSpecialUnion(newState:BlockState, oldState:BlockState):void
		{
			dispatchEvent(new ShockBlockEvent(ShockBlockEvent.shockDamage, _record.gameTime, 0, 0, Number.NaN, Number.NaN, newState, oldState));
		}
		
		private function rotationOmino(rotation:int):void
		{
			if (rotation != GameCommand.left && rotation != GameCommand.right) return;
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
			var sx:int = rotateReviseX(controlRect, cacheRect);
			var sy:int = rotateReviseY(controlRect, cacheRect);
			var dir:int;
			if (lastMoveDir == GameCommand.nothing)
			{
				dir = rotation;
			}
			else
			{
				dir = lastMoveDir;
			}
			for (var i:int = 0; i < ominoSize; i++)
			{
				if (i == 0)
				{
					if (rotationChack(cacheOmino, controlRect, cacheRect, sx, sy)) return;
					continue;
				}
				for (var m:int = 0; m < i; m++)
				{
					var b:int = (dir == GameCommand.left ? m * -1 : m);
					if (rotationChack(cacheOmino, controlRect, cacheRect, sx + b, sy + i)) return;
					if (rotationChack(cacheOmino, controlRect, cacheRect, sx + b, sy - i)) return;
					if (m > 0)
					{
						if (rotationChack(cacheOmino, controlRect, cacheRect, sx - b, sy + i)) return;
						if (rotationChack(cacheOmino, controlRect, cacheRect, sx - b, sy - i)) return;
					}
				}
				for (var k:int = 0; k <= i; k++)
				{
					var a:int = (dir == GameCommand.left ? i * -1 : i);
					if (rotationChack(cacheOmino, controlRect, cacheRect, sx + a, sy + k)) return;
					if (rotationChack(cacheOmino, controlRect, cacheRect, sx - a, sy + k)) return;
					if (k > 0)
					{
						if (rotationChack(cacheOmino, controlRect, cacheRect, sx + a, sy - k)) return;
						if (rotationChack(cacheOmino, controlRect, cacheRect, sx - a, sy - k)) return;
					}
				}
			}
			dispatchEvent(new ControlEvent(ControlEvent.rotationNG, _record.gameTime, 0, _cox, _coy));
		}
		
		private function rotationChack(cacheOmino:OminoField, controlRect:Rect, cacheRect:Rect, x:int, y:int):Boolean
		{
			if (controlRect.left > cacheRect.right + x || controlRect.right < cacheRect.left + x) return false;
			if (controlRect.top > cacheRect.bottom + y || controlRect.bottom < cacheRect.top + y) return false;
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
				}
				else
				{
					dispatchEvent(new ControlEvent(ControlEvent.moveNG, _record.gameTime, 0, _cox, _coy));
					return;
				}
			}
			else if (move == GameCommand.right)
			{
				if (_controlOmino.blocksHitChack(_mainField, _cox + 1, _coy, true) <= 0)
				{
					dispatchEvent(new ControlEvent(ControlEvent.moveOK, _record.gameTime, 0, _cox, _coy));
					_cox += 1;
				}
				else
				{
					dispatchEvent(new ControlEvent(ControlEvent.moveNG, _record.gameTime, 0, _cox, _coy));
					return;
				}
			}
			else
			{
				return;
			}
			lastMoveDir = move;
			playLimit = 0;
		}
		
		private function fallingOmino(falling:int, fix:Boolean, noDamage:Boolean):void
		{
			switch(falling)
			{
				case GameCommand.fast:
					fallSpeed = setting.fastFallSpeed > setting.naturalFallSpeed ? setting.fastFallSpeed : setting.naturalFallSpeed;
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
					fallSpeed = setting.naturalFallSpeed;
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
		
		private function isTechnicalSpin():Boolean
		{
			if (_controlOmino.blocksHitChack(_mainField, _cox + 1, _coy, true) <= 0) return false;
			if (_controlOmino.blocksHitChack(_mainField, _cox - 1, _coy, true) <= 0) return false;
			if (_controlOmino.blocksHitChack(_mainField, _cox, _coy + 1, true) <= 0) return false;
			if (_controlOmino.blocksHitChack(_mainField, _cox, _coy - 1, true) <= 0) return false;
			return true;
		}
		
		private function levelUp():void
		{
			if (setting.isLevelUp(_record.level, _record.breakLine))
			{
				var upLevel:int = setting.levelUpCount(_record.level, _record.breakLine);
				var clearTime:int = _record.gameTime - levelStartTime;
				var timeBonus:int = setting.timeBonus(clearTime, upLevel);
				levelStartTime = _record.gameTime;
				_record.level += upLevel;
				_record.gameScore += timeBonus;
				setting.setLevelParameter(_record.level);
				dispatchEvent(new LevelClearEvent(LevelClearEvent.levelClear, _record.gameTime, timeBonus, clearTime, upLevel));
			}
		}
		
		private function setNextOmino(init:Boolean):void
		{
			bigOminoCount += setting.bigOminoCountAddition;
			var omino:OminoField;
			if (int(bigOminoCount) > setting.bigOminoCountMax * bigNextPRNG.genNumber())
			{
				omino = OminoField.createBigOmino(bigOminoCount + 10, ominoSize, bigNextPRNG);
				bigOminoCount = 0;
			}
			else
			{
				omino = randomReadOmino(nextPRNG.genUint(), nextPRNG.genUint());
			}
			var color:uint = omino.coloringOmino();
			omino.allSetState(BlockState.normal, color, setting.hitPointMax, true);
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
		
		private function appendObstacleBlocks():int
		{
			var ret:int = obstacleManager.receivedNotice(_record.gameTime);
			var rest:int = ret;
			for (var i:int = 0; i < setting.obstacleLineMax && rest > 0; i++)
			{
				var y:int = GameModelBase.gameOverHeight - i;
				if (rest < setting.obstacleLineBlockMax)
				{
					rest -= setObstacleLine(_fallField, y, rest, setting.obstacleColor1);
				}
				else
				{
					rest -= setObstacleLine(_fallField, y, setting.obstacleLineBlockMax, setting.obstacleColor1);
				}
			}
			return ret - rest;
		}
		
		private function getAppendTowerCount():int
		{
			var a:int = Math.max(0, _mainField.getColorHeight(setting.obstacleColor2) - 30);
			var b:int = Math.max(0, _mainField.getHeight() - 20);
			return Math.min(a, b);
		}
		
		private function appendTowerBlocks():void
		{
			var y:int = GameModelBase.fieldHeight - 1;
			_mainField.shiftUp(y);
			setObstacleLine(_mainField, y, setting.towerLineBlockMax, setting.obstacleColor2);
		}
		
		private function setObstacleLine(field:MainField, y:int, blockCount:int, color:uint):int
		{
			var width:int = GameModelBase.fieldWidth;
			var sb:Vector.<BlockState> = new Vector.<BlockState>(width);
			for (var i:int = 0; i < blockCount; i++)
			{
				var block:BlockState = new BlockState(BlockState.normal, color, setting.hitPointMax, false);
				sb[i] = block;
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
				if (sb[i] == null) continue;
				if (!_mainField.isExistBlock(i, y))
				{
					ret++;
					continue;
				}
				sb[i] = null;
			} 
			field.setLine(y, sb);
			return ret;
		}
		
		public function writeExternal(output:IDataOutput):void 
		{
			output.writeObject(_mainField);
			output.writeObject(_fallField);
			output.writeObject(_controlOmino);
			output.writeObject(_nextOmino);
			
			output.writeObject(setting);
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
			
			setting = input.readObject();
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