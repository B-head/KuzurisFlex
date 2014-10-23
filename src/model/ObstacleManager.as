package model 
{
	import events.GameEvent;
	import events.ObstacleEvent;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="updateObstacle", type="events.GameEvent")]
	[Event(name="enabledObstacle", type="events.GameEvent")]
	public class ObstacleManager extends EventDispatcher
	{
		private var setting:GameSetting;
		private var records:Vector.<ObstacleRecord>;
		private var outsideManager:Vector.<ObstacleManager>;
		private var trialLastAddition:int;
		private var trialSequence:int;
		private var decisionSequence:int;
		private var outsideEnabledSequence:Vector.<int>;
		
		public function ObstacleManager()
		{
			records = new Vector.<ObstacleRecord>();
			outsideManager = new Vector.<ObstacleManager>();
			outsideDecisionSequence = new Vector.<int>();
		}
		
		public function get noticeCount():int
		{
			
		}
		
		public function get noticeSaveCount():int
		{
			
		}
		
		public function getNextTrialObstacleTime(gameTime:int):int
		{
			return (trialLastAddition + setting.obstacleInterval) - gameTime;
		}
		
		public function setSetting(setting:GameSetting):void
		{
			this.setting = setting;
		}
		
		public function appendOutsideManager(manager:ObstacleManager):void
		{
			outsideManager.push(manager);
		}
		
		public function checkEnabledObstacle(enabledObstacle:Vector.<Boolean>):void
		{
			for (var i:int = 0; i < enabledObstacle.length; i++)
			{
				if (!enabledObstacle[i]) continue;
				outsideEnabledSequence[i]++;
			}
		}
		
		private function appendRecord(type:int, count:int, gameTime:int, sequence:int = 0):void
		{
			records.push(new ObstacleRecord(type, count, gameTime, sequence));
			dispatchEvent(new GameEvent(GameEvent.updateObstacle, gameTime, 0));
		}
		
		public function occurObstacle(comboCount:int):void
		{
			var count:int = setting.getOccurObstacleCount(comboCount);
			appendRecord(ObstacleRecord.occur, count, gameTime, decisionSequence);
		}
		
		public function receivedNotice(gameTime:int):int
		{
			var count:int = Math.min(setting.getReceiveObstacleCount(), notice);
			appendRecord(ObstacleRecord.received, count, gameTime);
			return count;
		}
		
		public function noticeAddition(gameTime:int):void
		{
			trialAddition(gameTime);
			enableObstacle(gameTime);
		}
		
		private function trialAddition(gameTime:int):void
		{
			if (trialLastAddition == 0)
			{
				appendRecord(ObstacleRecord.trialObstacle, setting.obstacleAdditionCount, int.MIN_VALUE, int.MIN_VALUE);
				trialLastAddition = gameTime;
			}
			if (getNextTrialObstacleTime(gameTime) == 0)
			{
				appendRecord(ObstacleRecord.trialObstacle, setting.obstacleAdditionCount, gameTime, trialSequence++);
				trialLastAddition = gameTime;
			}
		}
		
		private function enableObstacle(gameTime:int):void
		{
			
		}
	}
	
	internal class ObstacleRecord
	{
		public static const occur:int = 0;
		public static const received:int = 1;
		public static const trialObstacle:int = 2;
		
		public var type:int;
		public var count:int;
		public var gameTime:int;
		public var sequence:int;
		
		public function ObstacleRecord(type:int = 0, count:int = 0, gameTime:int = 0, sequence:int = 0)
		{
			this.type = type;
			this.count = count;
			this.gameTime = gameTime;
			this.sequence = sequence;
		}
	}
}