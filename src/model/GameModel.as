package model 
{
	import events.*;
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
	[Event(name="gameOver", type="events.GameEvent")]
	[Event(name="gameClear", type="events.GameEvent")]
	[Event(name="breakConbo", type="events.GameEvent")]
	[Event(name="extractFall", type="events.GameEvent")]
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
	[Event(name="addObstacle", type="events.ObstacleEvent")]
	[Event(name="materializationNotice", type="events.ObstacleEvent")]
	[Event(name="preMaterializationNotice", type="events.ObstacleEvent")]
	[Event(name="occurObstacle", type="events.ObstacleEvent")]
	[Event(name="counterbalanceObstacle", type="events.ObstacleEvent")]
	[Event(name="obstacleFall", type="events.ObstacleEvent")]
	public class GameModel extends GameModelBase 
	{
		private var setting:GameSetting;
		private var _record:GameRecord;
		private var obstacleManager:ObstacleManager;
		private var nextPRNG:XorShift128;
		private var bigNextPRNG:XorShift128;
		private var obstaclePRNG:XorShift128;
		
		private var _isGameOver:Boolean;
		private var controlPhase:Boolean;
		private var controlFalling:Boolean;
		private var firstShock:Boolean;
		private var _shockSave:Boolean;
		private var completedObstacle:Boolean;
		
		private var fallSpeed:Number = 0;
		private var startFall:Number = 0;
		private var playRest:int;
		private var playLimit:int;
		
		private var comboCount:int;
		private var totalDamage:Number = 0;
		private var levelStartTime:int;
		
		private var quantityOdds:Vector.<int>;
		private var ominoOdds:Vector.<Vector.<int>>;
		private var bigOminoCount:Number = 0;
		
		private var _cox:Number = 0;
		private var _coy:Number = 0;
		private var _ffy:Number = 0;
		
		private const obstacleLineMax:int = 5;
		private const obstacleColor1:uint = Color.lightgray;
		private const obstacleColor2:uint = Color.gray;
		
		public function GameModel() 
		{
			super(true);
			_record = new GameRecord();
			setting = new GameSetting();
			_isGameOver = true;
			obstacleManager = new ObstacleManager();
			obstacleManager.addEventListener(ObstacleEvent.addObstacle, function(e:ObstacleEvent):void { dispatchEvent(e); });
			obstacleManager.addEventListener(ObstacleEvent.preMaterializationNotice, function(e:ObstacleEvent):void { dispatchEvent(e); });
			obstacleManager.addEventListener(ObstacleEvent.materializationNotice, function(e:ObstacleEvent):void { dispatchEvent(e); });
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
		public function get cox():Number 
		{
			return _cox;
		}
		
		[Bindable(event="forwardGame")]
		public function get coy():Number 
		{
			return _coy;
		}
		
		[Bindable(event="forwardGame")]
		public function get ffy():Number 
		{
			return _ffy;
		}
		
		[Bindable(event="forwardGame")]
		public function get rfvy():Number
		{
			var rect:Rect = _mainField.getRect();
			return rect.top;
		}
		
		[Bindable(event="forwardGame")]
		public function get shockSave():Boolean 
		{
			return _shockSave;
		}
		
		[Bindable(event="forwardGame")]
		public function get isGameOver():Boolean
		{
			return _isGameOver;
		}
		
		[Bindable(event="forwardGame")]
		public function get isObstacleAddition():Boolean
		{
			return setting.isObstacleAddition();
		}
		
		[Bindable(event="forwardGame")]
		public function get record():GameRecord
		{
			return _record;
		}
		
		[Bindable(event="forwardGame")]
		public function get obstacleNotice():int
		{
			return obstacleManager.notice;
		}
		
		[Bindable(event="forwardGame")]
		public function get obstacleNoticeSave():int
		{
			return obstacleManager.getNoticeSaveCount();
		}
		
		[Bindable(event="forwardGame")]
		public function get nextObstacleTime():int
		{
			return obstacleManager.getNextObstacleTime(_record.gameTime, setting);
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
			return result;
		}
		
		public function getMainField():MainField
		{
			if (_mainField == null) return null;
			return _mainField.clone();
		}
		
		public function getFallField():MainField
		{
			if (_fallField == null) return null;
			return _fallField.clone();
		}
		
		public function getControlOmino():OminoField
		{
			if (_controlOmino == null) return null;
			return _controlOmino.clone();
		}
		
		public function getNextOmino():Vector.<OminoField>
		{
			var ret:Vector.<OminoField> = new Vector.<OminoField>(nextLength, true);
			for (var i:int = 0; i < nextLength; i++)
			{
				if (_nextOmino[i] == null) continue;
				ret[i] = _nextOmino[i].clone();
			}
			return ret;
		}
		
		public function startGame(setting:GameSetting, seed:XorShift128):void
		{
			this.setting = setting.clone();
			_record = new GameRecord();
			_record.level = setting.startLevel;
			this.setting.setLevelParameter(_record.level);
			_isGameOver = false;
			nextPRNG = seed.clone();
			bigNextPRNG = seed.clone();
			obstaclePRNG = seed.clone();
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
			obstacleManager.trialAddition(_record.gameTime, setting);
			materializationNotice(command.materialization);
			if (!controlPhase)
			{
				forwardNonControl();
			}
			if (controlPhase)
			{
				_record.controlTime++;
				forwardControl(command);
			}
			dispatchEvent(new GameEvent(GameEvent.forwardGame, _record.gameTime, 0));
		}
		
		private function forwardNonControl():void
		{
			fallSpeed += setting.fallAcceleration;
			if (fallSpeed > setting.fastFallSpeed) fallSpeed = setting.fastFallSpeed;
			fallingField(int(_ffy), int(_ffy + fallSpeed));
			_ffy += fallSpeed;
			dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
			if (_fallField.countBlock() > 0) return;
			_ffy = 0;
			fallSpeed = 0;
			breakLines();
			levelUp();
			extractFallBlocks();
			if (_fallField.countBlock() > 0)
			{
				dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
				dispatchEvent(new GameEvent(GameEvent.extractFall, _record.gameTime, 0));
				return;
			}
			_mainField.clearSpecialUnion();
			var totalLineScore:int = setting.totalBreakLineScore(comboCount);
			dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
			dispatchEvent(new GameEvent(GameEvent.breakConbo, _record.gameTime, 0));
			if (comboCount > 0) dispatchEvent(new BreakLineEvent(BreakLineEvent.totalBreakLine, _record.gameTime, totalLineScore, comboCount, int.MIN_VALUE, null));
			if (totalDamage > 0) dispatchEvent(new ShockBlockEvent(ShockBlockEvent.totalDamage, _record.gameTime, totalDamage, totalDamage, totalDamage, Number.NaN, int.MIN_VALUE, int.MIN_VALUE));
			if (comboCount > 0) completedObstacle = true;
			_record.comboLines[comboCount]++;
			_record.blockDamage += totalDamage;
			comboCount = 0;
			totalDamage = 0;
			if (!completedObstacle && obstacleManager.notice > 0)
			{
				var oc:int = appendObstacleBlocks();
				fallSpeed = setting.fastFallSpeed;
				completedObstacle = true;
				dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
				dispatchEvent(new ObstacleEvent(ObstacleEvent.obstacleFall, _record.gameTime, 0, oc));
				_record.receivedObstacle += oc;
				return;
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
			startFall = _coy;
			playRest = setting.playTime;
			playLimit = 0;
			firstShock = true;
			completedObstacle = false;
			controlPhase = true;
		}
		
		private function forwardControl(command:GameCommand):void
		{
			rotationOmino(command.rotation);
			moveOmino(command.move);
			fallingOmino(command.falling, command.fix, command.noDamege);
			if(playRest <= 0 || playRest <= playLimit)
			{
				_mainField.fix(_controlOmino, _cox, _coy);
				dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
				dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
				dispatchEvent(new ControlEvent(ControlEvent.fixOmino, _record.gameTime, 0, _cox, _coy));
				_record.fixOmino++;
				controlPhase = false;
			}
		}
		
		public function addObstacle(player:int, count:int):void
		{
			obstacleManager.addObstacleAt(_record.gameTime, player, count);
		}
		
		public function breakConboNotice(player:int):void
		{
			obstacleManager.breakConboNotice(_record.gameTime, player);
		}
		
		private function materializationNotice(materialization:Vector.<Boolean>):void
		{
			for (var i:int = 0; i < materialization.length; i++)
			{
				if (!materialization[i]) continue;
				obstacleManager.preMaterializationNoticeAt(_record.gameTime, i);
			}
		}
		
		override protected function onBreakLine(y:int, colors:Vector.<uint>):void 
		{
			_record.breakLine++;
			comboCount++;
			var plus:int = setting.breakLineScore(comboCount);
			_record.gameScore += plus;
			dispatchEvent(new BreakLineEvent(BreakLineEvent.breakLine, _record.gameTime, plus, comboCount, y, colors));
			if (setting.gameMode == GameSetting.battle)
			{
				var obs:int = setting.occurObstacle(comboCount);
				_record.occurObstacle += obs;
				var cb:int = Math.min(obs, obstacleManager.notice + obstacleManager.getNoticeSaveCount());
				if (cb > 0)
				{
					obs -= cb;
					obstacleManager.counterbalance(cb);
					_record.counterbalance += cb;
					dispatchEvent(new ObstacleEvent(ObstacleEvent.counterbalanceObstacle, _record.gameTime, 0, cb));
				}
				if (obs > 0) dispatchEvent(new ObstacleEvent(ObstacleEvent.occurObstacle, _record.gameTime, 0, obs));
			}
		}
		
		override protected function onSectionBreakLine(count:int):void 
		{
			if (count == 0) return;
			var a:int = comboCount - count;
			var b:int = setting.totalBreakLineScore(a);
			var c:int = setting.totalBreakLineScore(comboCount);
			var plus:int = c - b;
			dispatchEvent(new BreakLineEvent(BreakLineEvent.sectionBreakLine, _record.gameTime, plus, comboCount, int.MIN_VALUE, null));
		}
		
		override protected function onBlockDamage(x:int, y:int, damage:Number, coefficient:Number):void 
		{
			dispatchEvent(new ShockBlockEvent(ShockBlockEvent.shockDamage, _record.gameTime, 0, damage, Number.NaN, coefficient, x, y));
		}
		
		override protected function onSectionDamage(damage:Number, coefficient:Number):void
		{
			if (damage == 0) return;
			var plus:int = totalDamage % 1 + damage;
			_record.gameScore += plus;
			totalDamage += damage;
			dispatchEvent(new ShockBlockEvent(ShockBlockEvent.sectionDamage, _record.gameTime, plus, damage, totalDamage, coefficient, int.MIN_VALUE, int.MIN_VALUE));
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
			var sx:int = rotateReviseX(controlRect, cacheRect);
			var sy:int = rotateReviseY(controlRect, cacheRect);
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
			dispatchEvent(new ControlEvent(ControlEvent.rotationNG, _record.gameTime, 0, _cox, _coy));
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
			_controlOmino = cacheOmino;
			dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
			dispatchEvent(new ControlEvent(ControlEvent.rotationOK, _record.gameTime, 0, _cox, _coy));
			if (cacheOmino.blocksHitChack(_mainField, _cox + sx + dx, Math.ceil(_coy) + sy + dy, true) > 0)
			{
				_coy = Math.floor(_coy);
			}
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
				if (firstShock)
				{
					if (_shockSave)
					{
						dispatchEvent(new ControlEvent(ControlEvent.fallShockSave, _record.gameTime, 0, _cox, _coy));
					}
					else
					{
						coefficient = 1;
						damage = shockDamage(_controlOmino, _cox, _coy + i, coefficient);
						onSectionDamage(damage, coefficient);
						dispatchEvent(new GameEvent(GameEvent.updateField, _record.gameTime, 0));
						dispatchEvent(new GameEvent(GameEvent.updateControl, _record.gameTime, 0));
						dispatchEvent(new ControlEvent(ControlEvent.fallShock, _record.gameTime, 0, _cox, _coy));
					}
					firstShock = false;
				}
				else if (startFall < _coy + i)
				{
					if (_shockSave)
					{
						dispatchEvent(new ControlEvent(ControlEvent.fallShockSave, _record.gameTime, 0, _cox, _coy));
					}
					else
					{
						coefficient = getNaturalShockDamage(Math.ceil(_coy - startFall) + i);
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
			omino.allSetState(setting.hitPointMax, color, true);
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
		
		private function appendObstacleBlocks():int
		{
			var ret:int = Math.min(100, obstacleManager.notice);
			var rest:int = ret;
			obstacleManager.notice -= rest;
			for (var y:int = fieldHeight / 2 - 1; y >= 0 && rest > 0; y--)
			{
				if (rest < obstacleLineMax)
				{
					_fallField.setObstacleLine(y, rest, setting.hitPointMax, obstacleColor1, obstaclePRNG);
					rest = 0;
				}
				else
				{
					_fallField.setObstacleLine(y, obstacleLineMax, setting.hitPointMax, obstacleColor1, obstaclePRNG);
					rest -= obstacleLineMax;
				}
			}
			return ret;
		}
		
		private function appendTowerBlocks():void
		{
			
		}
	}

}