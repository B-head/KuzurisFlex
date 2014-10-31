package model 
{
	import events.GameEvent;
	import flash.events.EventDispatcher;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="updateObstacle", type="events.GameEvent")]
	[Event(name="enabledObstacle", type="events.GameEvent")]
	public class ObstacleManager extends EventDispatcher implements IExternalizable
	{
		private var setting:GameSetting;
		private var records:Vector.<ObstacleRecord>;
		private var outsideManager:Vector.<ObstacleManager>;
		private var trialLastAddition:int;
		private var trialSequence:int;
		private var _decisionSequence:int;
		private var outsideEnabledSequence:Vector.<int>;
		private var noticePrintCount:int;
		private var noticePrintReady:Boolean;
		
		public function ObstacleManager()
		{
			records = new Vector.<ObstacleRecord>();
			outsideManager = new Vector.<ObstacleManager>(8);
			outsideEnabledSequence = new Vector.<int>(8);
		}
		
		public function get decisionSequence():int
		{
			return _decisionSequence;
		}
		
		public function get noticeCount():int
		{
			var self:int = getOccurCount(_decisionSequence, true);
			var otherMax:int = 0;
			for (var i:int = 0; i < outsideManager.length; i++)
			{
				if (outsideManager[i] == null) continue;
				if (outsideManager[i] == this) continue;
				var seq:int = outsideEnabledSequence[i];
				otherMax = Math.max(otherMax, outsideManager[i].getOccurCount(seq, false));
			}
			return Math.max(0, otherMax - self);
		}
		
		public function get noticeSaveCount():int
		{
			var self:int = getOccurSaveCount(_decisionSequence, true);
			var otherMax:int = 0;
			for (var i:int = 0; i < outsideManager.length; i++)
			{
				if (outsideManager[i] == null) continue;
				if (outsideManager[i] == this) continue;
				var seq:int = outsideEnabledSequence[i];
				otherMax = Math.max(otherMax, outsideManager[i].getOccurSaveCount(seq, false));
			}
			return Math.max(0, otherMax - self);
		}
		
		public function getOccurCount(sequence:int, self:Boolean):int
		{
			var ret:int = 0;
			for (var i:int = 0; i < records.length; i++)
			{
				ret += getNoticeCountAt(i, false, self, sequence);
			}
			return ret;
		}
		
		public function getOccurSaveCount(sequence:int, self:Boolean):int
		{
			var ret:int = 0;
			for (var i:int = 0; i < records.length; i++)
			{
				ret += getNoticeCountAt(i, true, self, sequence);
			}
			return ret;
		}
		
		private function getNoticeCountAt(index:int, save:Boolean, self:Boolean, sequence:int):int
		{
			var t:ObstacleRecord = records[index];
			switch (t.type)
			{
				case ObstacleRecord.occur:
					if (!self && !save && t.sequence >= sequence) return 0;
					return t.count;
				case ObstacleRecord.received:
					return t.count;
				case ObstacleRecord.trialObstacle:
					if (!save && t.sequence >= trialSequence) return 0;
					return -t.count;
				default:
					throw new Error();
			}
		}
		
		public function getNextTrialObstacleTime(gameTime:int):int
		{
			return (trialLastAddition + setting.obstacleInterval) - gameTime;
		}
		
		public function getTrialObstacleEnableTime(gameTime:int):int
		{
			return (trialLastAddition + setting.obstacleSaveTime) - gameTime;
		}
		
		public function isActiveNotice():Boolean
		{
			//return noticeCount > 0;
			return noticePrintCount > 0;
		}
		
		public function isStandOutsideEnabled():Boolean
		{
			if (!noticePrintReady) return false;
			for (var i:int = 0; i < outsideManager.length; i++)
			{
				if (outsideManager[i] == null) continue;
				if (outsideManager[i].decisionSequence < outsideEnabledSequence[i])
				{
					return true;
				}
			}
			return false;
		}
		
		public function setSetting(setting:GameSetting):void
		{
			this.setting = setting;
		}
		
		public function appendOutsideManager(index:int, manager:ObstacleManager):void
		{
			outsideManager[index] = manager;
			manager.addEventListener(GameEvent.updateObstacle, outsideUpdateListener);
		}
		
		private function outsideUpdateListener(e:GameEvent):void
		{
			dispatchEvent(new GameEvent(GameEvent.outsideUpdateObstacle, e.gameTime, 0));
		}
		
		public function checkEnabledObstacle(gameTime:int, enabledObstacle:Vector.<Boolean>):void
		{
			var isUpdate:Boolean = false;
			for (var i:int = 0; i < outsideEnabledSequence.length; i++)
			{
				if (!enabledObstacle[i]) continue;
				outsideEnabledSequence[i]++;
				isUpdate = true;
			}
			if (isUpdate)
			{
				dispatchEvent(new GameEvent(GameEvent.updateObstacle, gameTime, 0));
			}
		}
		
		private function appendRecord(type:int, count:int, gameTime:int, sequence:int = 0):ObstacleRecord
		{
			var ret:ObstacleRecord = new ObstacleRecord(type, count, gameTime, sequence);
			records.push(ret);
			return ret;
		}
		
		public function occurObstacle(gameTime:int, lineCount:int, comboCount:int):int
		{
			var r:ObstacleRecord = getOccurRecord(gameTime);
			var count:int = setting.occurObstacleCount(lineCount, comboCount);
			var ret:int = count - r.count;
			r.count += ret;
			dispatchEvent(new GameEvent(GameEvent.updateObstacle, gameTime, 0));
			return ret;
		}
		
		public function blockAllClear(gameTime:int):int
		{
			var count:int = setting.blockAllClearBonusObstacle;
			var r:ObstacleRecord = getOccurRecord(gameTime);
			r.count += count;
			dispatchEvent(new GameEvent(GameEvent.updateObstacle, gameTime, 0));
			return count;
		}
		
		private function getOccurRecord(gameTime:int):ObstacleRecord
		{
			for (var i:int = records.length - 1; i >= 0; i--)
			{
				if (records[i].type != ObstacleRecord.occur) continue;
				if (records[i].sequence == _decisionSequence) return records[i];
				break;
			}
			return appendRecord(ObstacleRecord.occur, 0, gameTime, _decisionSequence);
		}
		
		public function noticePrint():void
		{
			noticePrintReady = true;
		}
		
		public function breakCombo(gameTime:int):void
		{
			_decisionSequence++;
			dispatchEvent(new GameEvent(GameEvent.enabledObstacle, gameTime, 0));
		}
		
		public function receivedNotice(gameTime:int):int
		{
			var count:int = Math.min(setting.receiveObstacleCount(), noticePrintCount);
			appendRecord(ObstacleRecord.received, count, gameTime);
			dispatchEvent(new GameEvent(GameEvent.updateObstacle, gameTime, 0));
			return count;
		}
		
		public function noticeAddition(gameTime:int):void
		{
			if (noticePrintReady)
			{
				noticePrintReady = false;
				noticePrintCount = noticeCount;
				dispatchEvent(new GameEvent(GameEvent.updateObstacle, gameTime, 0));
			}
			if (setting.isObstacleAddition())
			{
				trialAddition(gameTime);
			}
		}
		
		private function trialAddition(gameTime:int):void
		{
			if (trialLastAddition == 0)
			{
				appendRecord(ObstacleRecord.trialObstacle, setting.obstacleAdditionCount, int.MIN_VALUE, int.MIN_VALUE);
				trialLastAddition = gameTime;
				dispatchEvent(new GameEvent(GameEvent.updateObstacle, gameTime, 0));
			}
			if (getNextTrialObstacleTime(gameTime) == 0)
			{
				appendRecord(ObstacleRecord.trialObstacle, setting.obstacleAdditionCount, gameTime, trialSequence);
				trialLastAddition = gameTime;
				dispatchEvent(new GameEvent(GameEvent.updateObstacle, gameTime, 0));
			}
			if (getTrialObstacleEnableTime(gameTime) == 0)
			{
				trialSequence++;
				dispatchEvent(new GameEvent(GameEvent.updateObstacle, gameTime, 0));
			}
		}
		
		public function writeExternal(output:IDataOutput):void 
		{
			output.writeObject(setting);
			output.writeObject(records);
			output.writeInt(trialLastAddition);
			output.writeInt(trialSequence);
			output.writeInt(_decisionSequence);
			output.writeObject(outsideEnabledSequence);
			output.writeInt(noticePrintCount);
			output.writeBoolean(noticePrintReady);
		}
		
		public function readExternal(input:IDataInput):void 
		{
			setting = input.readObject();
			records = input.readObject();
			trialLastAddition = input.readInt();
			trialSequence = input.readInt();
			_decisionSequence = input.readInt();
			outsideEnabledSequence = input.readObject();
			noticePrintCount = input.readInt();
			noticePrintReady = input.readBoolean();
		}
	}
}