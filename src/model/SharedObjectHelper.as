package model 
{
	import flash.net.*;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class SharedObjectHelper 
	{
		public static var shared:SharedObject;
		public static var input:UserInput;
		public static var inputVersus1:UserInput;
		public static var inputVersus2:UserInput;
		public static var normalRanking:Dictionary;
		public static var endlessRanking:Dictionary;
		
		public static function init():void
		{
			registerClassAlias("UserInput", UserInput);
			registerClassAlias("GameRaking", GameRanking);
			registerClassAlias("GameRecord", GameRecord);
			registerClassAlias("GameReplay", GameReplay);
			registerClassAlias("GameCommand", GameCommand);
			registerClassAlias("GameSetting", GameSetting);
			registerClassAlias("XorShift128", XorShift128);
			shared = SharedObject.getLocal("main");
			initInput();
			initRanking();
			initBattleReplays();
		}
		
		private static function initInput():void
		{
			if (!(shared.data.input is UserInput))
			{
				shared.data.input = UserInput.createOnePlayer();
			}
			if (!(shared.data.inputVersus1 is UserInput))
			{
				shared.data.inputVersus1 = UserInput.createVersusPlayer1();
			}
			if (!(shared.data.inputVersus2 is UserInput))
			{
				shared.data.inputVersus2 = UserInput.createVersusPlayer2();
			}
			input = shared.data.input;
			inputVersus1 = shared.data.inputVersus1;
			inputVersus2 = shared.data.inputVersus2;
		}
		
		private static function initRanking():void
		{
			if (!(shared.data.normalRanking is Dictionary))
			{
				shared.data.normalRanking = new Dictionary();
			}
			if (!(shared.data.endlessRanking is Dictionary))
			{
				shared.data.endlessRanking = new Dictionary();
			}
			normalRanking = shared.data.normalRanking;
			endlessRanking = shared.data.endlessRanking;
		}
		
		private static function initBattleReplays():void
		{
			
		}
		
		public static function getRanking(gameMode:String, endless:Boolean):GameRanking
		{
			var dic:Dictionary = endless ? endlessRanking : normalRanking;
			if (dic[gameMode] == null)
			{
				dic[gameMode] = new GameRanking(gameMode, endless);
			}
			return dic[gameMode];
		}
	}

}