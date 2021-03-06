package common {
	import flash.net.*;
	import model.*;
	import network.*;
	import presentation.*;
	
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
		public static var normalRanking:Object;
		public static var endlessRanking:Object;
		public static var battleRecords:BattleRecords;
		
		public static function init():void
		{
			registerClass();
			transferSharedObject();
			shared = SharedObject.getLocal("kuzuris", "/");
			initInput();
			initRanking();
			initBattleReplays();
			shared.flush(100000000);
		}
		
		public static function registerClass():void
		{
			registerClassAlias("UserInput", UserInput);
			registerClassAlias("GameModel", GameModel);
			registerClassAlias("MainField", MainField);
			registerClassAlias("OminoField", OminoField);
			registerClassAlias("BlockState", BlockState);
			registerClassAlias("ObstacleManager", ObstacleManager);
			registerClassAlias("ObstacleRecord", ObstacleRecord);
			registerClassAlias("GameRaking", GameRanking);
			registerClassAlias("BattleRecords", BattleRecords);
			registerClassAlias("GameRecord", GameRecord);
			registerClassAlias("GameReplayContainer", GameReplayContainer);
			registerClassAlias("GameReplayControl", GameReplayControl);
			registerClassAlias("GameCommand", GameCommand);
			registerClassAlias("GameSetting", GameSetting);
			registerClassAlias("XorShift128", XorShift128);
			registerClassAlias("MessageObject", MessageObject);
			registerClassAlias("RoomInformation", RoomInformation);
			registerClassAlias("PlayerInformation", PlayerInformation);
			registerClassAlias("Utterance", Utterance);	
		}
		
		private static function transferSharedObject():void
		{
			var to:SharedObject = SharedObject.getLocal("kuzuris", "/");
			var from:SharedObject = SharedObject.getLocal("kuzuris");
			for (var s:String in from.data)
			{
				to.data[s] = from.data[s];
			}
			to.flush();
			from.clear();
		}

		private static function initInput():void
		{
			if (shared.data.input == null)
			{
				shared.data.input = UserInput.createOnePlayer();
			}
			if (shared.data.inputVersus1 == null)
			{
				shared.data.inputVersus1 = UserInput.createVersusPlayer1();
			}
			if (shared.data.inputVersus2 == null)
			{
				shared.data.inputVersus2 = UserInput.createVersusPlayer2();
			}
			input = shared.data.input;
			inputVersus1 = shared.data.inputVersus1;
			inputVersus2 = shared.data.inputVersus2;
		}
		
		private static function initRanking():void
		{
			if (shared.data.normalRanking == null)
			{
				shared.data.normalRanking = new Object();
			}
			if (shared.data.endlessRanking == null)
			{
				shared.data.endlessRanking = new Object();
			}
			normalRanking = shared.data.normalRanking;
			endlessRanking = shared.data.endlessRanking;
		}
		
		private static function initBattleReplays():void
		{
			if (shared.data.battleRecords == null)
			{
				shared.data.battleRecords = new BattleRecords();
			}
			battleRecords = shared.data.battleRecords;
		}
		
		public static function getRanking(gameMode:String, endless:Boolean):GameRanking
		{
			var dic:Object = endless ? endlessRanking : normalRanking;
			if (dic[gameMode] == null)
			{
				dic[gameMode] = new GameRanking(gameMode, endless);
			}
			return dic[gameMode];
		}
	}

}