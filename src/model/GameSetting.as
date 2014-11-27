package model 
{
	import view.GameSoundEffect;
	/**
	 * ...
	 * @author B_head
	 */
	public final class GameSetting 
	{
		public static const alpha1:uint = 1;
		
		public static const axelSpeed:String = "axelSpeed";
		public static const overSpeed:String = "overSpeed";
		public static const obstacleAttack:String = "obstacleAttack";
		public static const obstacleFight:String = "obstacleFight";
		public static const polyOmino:String = "polyOmino";
		public static const bigOmino:String = "bigOmino";
		public static const free:String = "free";
		public static const classicBattle:String = "classicBattle";
		public static const digBattle:String = "digBattle";
		
		public const levelUpCoefficient:int = 4000;
		public const levelTimeCoefficient:int = 6000;
		public const breakLineCoefficient:int = 1000;
		public const blockAllClearBonusScore:int = 25000;
		public const blockAllClearBonusObstacle:int = 100;
		public const excellentBonusScore:int = 25000;
		public const excellentBonusObstacle:int = 20;
		public const obstacleLineMax:int = 10;
		public const obstacleLineBlockMax:int = 5;
		public const towerLineBlockMax:int = 6;
		public const obstacleColor1:uint = Color.toIndex(Color.lightgray);
		public const obstacleColor2:uint = Color.toIndex(Color.gray);
		
		public var version:uint = alpha1;
		public var gameMode:String = free;
		public var startLevel:int = 1;
		public var endless:Boolean = true;
		public var levelClearLine:int = int.MIN_VALUE;
		public var gameClearLevel:int = 20;
		public var handicap:Number;
		
		public const hitPointMax:Number = 10;
		public var naturalFallSpeed:Number;
		public var fastFallSpeed:Number;
		public var fallAcceleration:Number;
		public var playTime:int;
		public const playFastTime:int = 15;
		public const breakLineDelay:int = 0;
		
		public var quantityOddsBasis:Vector.<int>;
		public var bigOminoCountMax:int;
		public var bigOminoCountAddition:Number;
		
		public const obstacleSaveTime:int = 120;
		public var obstacleInterval:int;
		public var obstacleAdditionCount:Number;
		public var obstacleInitialCoefficient:int;
		public var obstacleDivisor:int;
		
		public static function modeToText(mode:String):String
		{
			switch(mode)
			{
				case axelSpeed: return "アクセルスピード";
				case overSpeed: return "オーバースピード";
				case obstacleAttack: return "おじゃまアタック";
				case obstacleFight: return "おじゃまファイト";
				case polyOmino: return "ポリオミノ";
				case bigOmino: return "ビッグミノ";
				case free: return "レベルフリー";
				case classicBattle: return "対戦";
				default: return null;
			}
		}
		
		public static function createTrialSetting(gameMode:String, startLevel:int, endless:Boolean):GameSetting
		{
			var ret:GameSetting = new GameSetting();
			ret.gameMode = gameMode;
			ret.startLevel = startLevel;
			ret.endless = endless;
			ret.levelClearLine = 10;
			return ret;
		}
		
		public static function createBattleSetting(gameModeIndex:int):GameSetting
		{
			var ret:GameSetting = new GameSetting();
			switch (gameModeIndex)
			{
				case 0:
					ret.gameMode = classicBattle;
					break;
				case 1:
					ret.gameMode = digBattle;
					break;
				default: 
					throw new Error();
			}
			return ret;
		}
		
		public function clone():GameSetting
		{
			var ret:GameSetting = new GameSetting();
			ret.gameMode = gameMode;
			ret.startLevel = startLevel;
			ret.endless = endless;
			ret.levelClearLine = levelClearLine;
			ret.gameClearLevel = gameClearLevel;
			ret.handicap = handicap;
			return ret;
		}
		
		public function isBattle():Boolean
		{
			return gameMode == classicBattle || gameMode == digBattle;
		}
		
		public function isObstacleAddition():Boolean
		{
			return gameMode == obstacleAttack || gameMode == obstacleFight;
		}
		
		public function isTowerAddition():Boolean
		{
			return gameMode == axelSpeed || gameMode == overSpeed || gameMode == digBattle;
		}
		
		public function isGameClear(level:int):Boolean
		{
			return !endless && level >= (startLevel + gameClearLevel);
		}
		
		public function isLevelUp(level:int, breakLine:int):Boolean
		{
			return levelUpCount(level, breakLine) > 0;
		}
		
		public function levelUpCount(level:int, breakLine:int):int
		{
			if (levelClearLine == int.MIN_VALUE) return 0;
			var up:int = int(breakLine / levelClearLine) - (level - startLevel);
			return endless ? up : Math.min(up, (startLevel + gameClearLevel) - level);
		}
		
		public function timeBonus(clearTime:int, upCount:int):int
		{
			var basis:int = levelUpCoefficient * levelClearLine;
			var bonus:int = basis * (1 - clearTime / levelTimeCoefficient);
			return (bonus > 0 ? bonus : 0) + (upCount - 1) * basis;
		}
		
		public function powerLevel(comboTotalLine:int, comboCount:int):int
		{
			return comboTotalLine - comboCount;
		}
		
		public function powerScale(comboTotalLine:int, comboCount:int):Number
		{
			return (powerLevel(comboTotalLine, comboCount) + obstacleInitialCoefficient) / obstacleDivisor;
		}
		
		public function breakLineScore(comboTotalLine:int, comboCount:int):int
		{
			return comboTotalLine * powerLevel(comboTotalLine, comboCount) * breakLineCoefficient;
		}
		
		public function occurObstacleCount(comboTotalLine:int, comboCount:int):int
		{
			return 10 * comboTotalLine * powerScale(comboTotalLine, comboCount);
		}
		
		public function receiveObstacleCount():int
		{
			return obstacleLineMax * obstacleLineBlockMax;
		}
		
		public function setLevelParameter(level:int):void
		{
			if (level > 20) level = 20;
			setSpeed(level);
			setObstacleAddition(level);
			setQuantityOdds(level);
			obstacleInitialCoefficient = 3;
			obstacleDivisor = (gameMode == digBattle ? 20 : 4)
		}
		
		private function linerLeveling(level:int, low:Number, high:Number):Number
		{
			if (low < high)
			{
				return low + (high - low) * (level - 1) / 19
			}
			else
			{
				return high + (low - high) * (20 - level) / 19;
			}
		}
		
		private function exponentLeveling(level:int, low:Number, high:Number, u:Number):Number
		{
			var ret:Number;
			var l:Number = (level - 1) / 19;
			if (low < high)
			{
				ret = low + (high - low) * (Math.pow(u, l) - 1) / (u - 1);
			}
			else
			{
				ret = high + (low - high) * (Math.pow(u, 1 - l) - 1) / (u - 1);
			}
			return ret;
		}
		
		private function setSpeed(level:int):void
		{
			if (gameMode == axelSpeed)
			{
				naturalFallSpeed = 20 / exponentLeveling(level, 1200, 1, 100);
				fastFallSpeed = (naturalFallSpeed > 1 ? naturalFallSpeed : 1);
				fallAcceleration = 10 / 400;
				playTime = 60;
			}
			else if (gameMode == overSpeed)
			{
				naturalFallSpeed = 20;
				fastFallSpeed = 20;
				fallAcceleration = 10 / exponentLeveling(level, 400, 1, 100);
				playTime = linerLeveling(level, 60, 20);
			}
			else
			{
				naturalFallSpeed = 20 / 1200;
				fastFallSpeed = 1;
				fallAcceleration = 10 / 400;
				playTime = 60;
			}
		}
		
		private function setObstacleAddition(level:int):void
		{	
			if (gameMode == obstacleAttack)
			{
				obstacleInterval = 900;
				obstacleAdditionCount = linerLeveling(level, 10, 50);
			}
			else if (gameMode == obstacleFight)
			{
				obstacleInterval = linerLeveling(level, 900, 450);
				obstacleAdditionCount = 50;
			}
			else
			{
				obstacleInterval = 0;
				obstacleAdditionCount = 0;
			}
		}
		
		private function setQuantityOdds(level:int):void
		{
			if (gameMode == polyOmino)
			{
				quantityOddsBasis = new Vector.<int>(11);
				for (var i:int = 4; i <= 10; i++)
				{
					var qpc:int;
					if (level < 16)
					{
						qpc = 14 + level - i * 3;
						if (qpc > 3) qpc = 3;
					}
					else
					{
						qpc = 24 + level - i * 4;
						if (qpc > 4) qpc = 4;
					}
					quantityOddsBasis[i] = (qpc <= 0 ? 0 : 1 << (qpc - 1));
				}
				bigOminoCountMax = 0;
				bigOminoCountAddition = 0;
			}
			else if (gameMode == bigOmino)
			{
				quantityOddsBasis = new <int>[0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1];
				bigOminoCountMax = level * 2;
				bigOminoCountAddition = level / 5;
			}
			else
			{
				quantityOddsBasis = new <int>[0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0];
				bigOminoCountMax = 0;
				bigOminoCountAddition = 0;
			}
		}
	}
}