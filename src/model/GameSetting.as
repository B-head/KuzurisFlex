package model 
{
	import view.GameModelSoundEffect;
	/**
	 * ...
	 * @author B_head
	 */
	public final class GameSetting 
	{
		public static const develop:uint = uint.MAX_VALUE;
		public static const alpha:uint = 1;
		public static const beta1:uint = 2;
		public static const beta2:uint = 3;
		
		public static const axelSpeed:String = "axelSpeed";
		public static const overSpeed:String = "overSpeed";
		public static const obstacleAttack:String = "obstacleAttack";
		public static const obstacleFight:String = "obstacleFight";
		public static const polyOmino:String = "polyOmino";
		public static const bigOmino:String = "bigOmino";
		public static const free:String = "free";
		public static const classicBattle:String = "classicBattle";
		public static const digBattle:String = "digBattle";
		
		public var version:uint = develop;
		public var gameMode:String = free;
		public var startLevel:int = 1;
		public var endless:Boolean = true;
		public var levelClearLine:int = int.MIN_VALUE;
		public var gameClearLevel:int = 20;
		public var handicap:Number;
		
		public const levelUpCoefficient:int = 5000;
		public const levelTimeCoefficient:int = 6000;
		public const breakLineCoefficient:int = 1000;
		public const blockAllClearBonusScore:int = 25000;
		public const blockAllClearBonusObstacle:int = 100;
		public const excellentBonusScore:int = 0;
		
		public static const shockDamageCoefficient:Number = 2.5;
		public static const indirectShockDamageCoefficient:Number = 1;
		public static const naturalShockDamageCoefficient:Number = 0.5;
		
		public static const hitPointMax:Number = 10;
		public var compelFallSpeed:Number;
		public var fastFallSpeed:Number;
		public var maxNaturalFallSpeed:Number;
		public var fallAcceleration:Number;
		public static const basicAccelerationDividend:Number = 20;
		public static const basicAccelerationDivisor:Number = 1200;
		public var playTime:int;
		public const playFastTime:int = 15;
		public const breakLineDelay:int = 0;
		public const appendTowerDelay:int = 1;
		
		public var quantityOddsBasis:Vector.<int>;
		public var bigOminoCountMax:int;
		public var bigOminoCountAddition:Number;
		
		public const obstacleSaveTime:int = 0;
		public var obstacleInterval:int;
		public var obstacleAdditionCount:Number;
		public var obstacleInitialCoefficient:int;
		public var obstacleDivisor:int;
		public var obstacleLineMax:int;
		public const obstacleLineBlockMax:int = 5;
		public const towerLineBlockMax:int = 6;
		public const obstacleColor:uint = Color.toIndex(Color.lightgray);
		
		public const alwaysHurryUp:Boolean = false;
		public const hurryUpStartMargin:int = 1800;
		public const hurryUpMargin:int = 180;
		
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
			ret.gameMode = indexToGameMode(gameModeIndex);
			return ret;
		}
		
		public static function indexToGameMode(gameModeIndex:int):String
		{
			switch (gameModeIndex)
			{
				case 0:
					return classicBattle;
				case 1:
					return digBattle;
				default: 
					throw new Error();
			}
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
			if (version >= beta2)
			{
				return Math.min(21, comboTotalLine - comboCount);
			}
			else
			{
				return comboTotalLine - comboCount;
			}
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
		
		public function getJewelColor(rand:Number):uint
		{
			switch(int(7 * rand))
			{
				case 0: return Color.toIndex(Color.red);
				case 1: return Color.toIndex(Color.orange);
				case 2: return Color.toIndex(Color.yellow);
				case 3: return Color.toIndex(Color.green);
				case 4: return Color.toIndex(Color.skyblue);
				case 5: return Color.toIndex(Color.blue);
				case 6: return Color.toIndex(Color.purple);
				default: throw new Error();
			}
		}
		
		public function setLevelParameter(level:int):void
		{
			if (level > 20) level = 20;
			setSpeed(level);
			setObstacleAddition(level);
			setQuantityOdds(level);
			obstacleInitialCoefficient = 3;
			if (isTowerAddition())
			{
				obstacleDivisor = 20;
				obstacleLineMax = 5;
			}
			else
			{
				obstacleDivisor = 4;
				obstacleLineMax = 10;
			}
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
				compelFallSpeed = 20 / exponentLeveling(level, 1200, 1, 100);
				fastFallSpeed = (compelFallSpeed > 1 ? compelFallSpeed : 1);
				fallAcceleration = basicAccelerationDividend / basicAccelerationDivisor;
				playTime = 60;
			}
			else if (gameMode == overSpeed)
			{
				compelFallSpeed = 20;
				fastFallSpeed = 20;
				fallAcceleration = basicAccelerationDividend / exponentLeveling(level, basicAccelerationDivisor, 1, 100);
				playTime = linerLeveling(level, 60, 20);
			}
			else
			{
				compelFallSpeed = 20 / 1200;
				fastFallSpeed = 1;
				fallAcceleration = basicAccelerationDividend / basicAccelerationDivisor;
				playTime = 60;
			}
			maxNaturalFallSpeed = Math.sqrt(40 * fallAcceleration);
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