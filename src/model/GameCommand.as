package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class GameCommand
	{
		public static const nothing:int = 0;
		public static const up:int = 1;
		public static const down:int = 2;
		public static const right:int = 3;
		public static const left:int = 4;
		public static const half:int = 5;
		public static const natural:int = 6;
		public static const fast:int = 7;
		public static const accelerate:int = 8;
		public static const earth:int = 9;
		
		public var rotation:int;
		public var move:int;
		public var falling:int;
		public var fix:Boolean;
		public var noDamege:Boolean;
	}

}