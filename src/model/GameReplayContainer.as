package model 
{
	import common.*;
	import network.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class GameReplayContainer 
	{
		public var timeStamp:Date;
		public var roomName:String;
		public var seed:XorShift128;
		public var setting:Vector.<GameSetting>;
		public var replayControl:Vector.<GameReplayControl>;
		public var playerInfo:Vector.<PlayerInformation>;
		public var record:Vector.<GameRecord>;
		public var log:String;
		
		public function GameReplayContainer() 
		{
			setting = new Vector.<GameSetting>();
			replayControl = new Vector.<GameReplayControl>();
			playerInfo = new Vector.<PlayerInformation>();
			record = new Vector.<GameRecord>();
			log = new String();
		}
		
		public function get playerCount():int
		{
			return replayControl.length;
		}
		
		public function isGameClear():Boolean
		{
			return setting[0].isGameClear(record[0].level);
		}
		
		public function get trialGameScore():int
		{
			return record[0].gameScore;
		}
		
		public function get trialGameTime():int
		{
			return record[0].gameTime;
		}
		
		public function get trialLevel():int
		{
			return record[0].level;
		}
		
		public function get trialBreakLine():int
		{
			return record[0].breakLine;
		}
		
		public function appendLog(text:String):void
		{
			log += text + "\r";
		}
	}

}