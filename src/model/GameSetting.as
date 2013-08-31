package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public final class GameSetting 
	{
		public static const free:String = "free";
		public static const axelSpeed:String = "axelSpeed";
		public static const overSpeed:String = "overSpeed";
		public static const obstacleAttack:String = "obstacleAttack";
		public static const obstacleFight:String = "obstacleFight";
		public static const polyOmino:String = "polyOmino";
		public static const bigOmino:String = "bigOmino";
		public static const extreme:String = "extreme";
		public static const anotherExtreme:String = "anotherExtreme";
		
		public var gameMode:String = free;
		public var startLevel:int = 1;
		public var endless:Boolean = false;
		public var levelClearLine:int = 10;
		public var gameClearLevel:int = 20;
		
		public var hitPointMax:Number = 10;
		public var fastFallSpeed:Number = 1;
		public var naturalFallSpeed:Number = 20 / 1200;
		public var fallAcceleration:Number = 10 / 400;
		public var playTime:int = 60;
		public var playFastTime:int = 15;
		public var quantityOddsBasis:Vector.<int> = new <int>[0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0];
	}

}