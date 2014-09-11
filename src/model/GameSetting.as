package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public final class GameSetting 
	{
		public static const axelSpeed:String = "axelSpeed";
		public static const overSpeed:String = "overSpeed";
		public static const obstacleAttack:String = "obstacleAttack";
		public static const obstacleFight:String = "obstacleFight";
		public static const polyOmino:String = "polyOmino";
		public static const bigOmino:String = "bigOmino";
		public static const free:String = "free";
		public static const battle:String = "battle";
		
		public var gameMode:String = battle;
		public var startLevel:int = 1;
		public var endless:Boolean = true;
		public var levelClearLine:int = int.MIN_VALUE;
		public var gameClearLevel:int = 20;
		
		public var naturalFallSpeed:Number;
		public var fastFallSpeed:Number;
		public var fallAcceleration:Number;
		public var playTime:int;
		public var playFastTime:int;
		
		public var hitPointMax:Number;
		public var quantityOddsBasis:Vector.<int>;
		public var bigOminoCountMax:int;
		public var bigOminoCountAddition:Number;
		public var obstacleSaveTime:int;
		public var obstacleInterval:int;
		public var obstacleAdditionCount:Number;
		
		public function isObstacleAddition():Boolean
		{
			return gameMode == obstacleAttack || gameMode == obstacleFight;
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
			return Math.min(up, (startLevel + gameClearLevel) - level);
		}
		
		public function timeBonus(clearTime:int, upCount:int):int
		{
			var basis:int = 400 * levelClearLine;
			var bonus:int = basis * (1 - clearTime / 3000);
			return (bonus > 0 ? bonus : 0) + (upCount - 1) * basis;
		}
		
		public function setLevelParameter(level:int):void
		{
			hitPointMax = 10;
			setSpeed(level);
			setObstacleAddition(level);
			setQuantityOdds(level);
		}
		
		private function setSpeed(level:int):void
		{
			if (gameMode == axelSpeed)
			{
				naturalFallSpeed = 20 / (1 + 1199 * (Math.pow(100, 1 - (level - 1) / 19) - 1) / 99);
				fastFallSpeed = (naturalFallSpeed > 1 ? naturalFallSpeed : 1);
				fallAcceleration = 10 / 400;
				playTime = 60;
			}
			else if (gameMode == overSpeed)
			{
				naturalFallSpeed = 20;
				fastFallSpeed = 20;
				fallAcceleration = 10 / Math.pow(400, 1 - (level - 1) / 19);
				playTime = int(20 * Math.pow(3, 1 - (level - 1) / 19));
			}
			else
			{
				naturalFallSpeed = 20 / 1200;
				fastFallSpeed = 1;
				fallAcceleration = 10 / 400;
				playTime = 60;
			}
			playFastTime = 15;
		}
		
		private function setObstacleAddition(level:int):void
		{	
			if (gameMode == obstacleAttack)
			{
				obstacleInterval = 900;
				obstacleAdditionCount = 10 + 40 * (level - 1) / 19;
			}
			else if (gameMode == obstacleFight)
			{
				obstacleInterval = int(450 * Math.pow(2, 1 - (level - 1) / 19));
				obstacleAdditionCount = 50;
			}
			else
			{
				obstacleInterval = 0;
				obstacleAdditionCount = 0;
			}
			obstacleSaveTime = 60;
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