package model 
{
	import events.ObstacleEvent;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="addObstacle", type="event.ObstacleEvent")]
	[Event(name="materializationNotice", type="event.ObstacleEvent")]
	[Event(name="preMaterializationNotice", type="event.ObstacleEvent")]
	public class ObstacleManager extends EventDispatcher
	{
		public var notice:int;
		private var noticeSave:Vector.<Object>;
		private var additionSequence:Vector.<uint>;
		private var materializationSequence:Vector.<uint>;
		private var trialLastAddition:int;
		
		private const trialKey:String = "trial";
		
		public function ObstacleManager()
		{
			noticeSave = new Vector.<Object>();
			additionSequence = new Vector.<uint>(9);
			materializationSequence = new Vector.<uint>(9);
		}
		
		public function getNoticeSaveCount():int
		{
			var ret:int;
			for (var i:int = 0; i < noticeSave.length; i++)
			{
				var n:Object = noticeSave[i];
				if (n == null) continue;
				ret += n.count;
			}
			return ret;
		}
		
		public function getNextObstacleTime(gameTime:int, setting:GameSetting):int
		{
			return (trialLastAddition + setting.obstacleInterval) - gameTime;
		}
		
		public function addObstacleAt(gameTime:int, index:int , count:int):void
		{
			var seqKey:String = String(index) + "@" + String(additionSequence[index]);
			addObstacle(gameTime, seqKey, count);
		}
		
		public function addObstacle(gameTime:int, key:String, count:int):void
		{
			var ns:Object = findKey(key);
			if (ns == null)
			{
				ns = { key:key, count:count, preMaterialization:false };
				noticeSave.push(ns);
			}
			else
			{
				ns.count += count;
			}
			dispatchEvent(new ObstacleEvent(ObstacleEvent.addObstacle, gameTime, 0, count));
		}
		
		public function breakConboNotice(gameTime:int, index:int):void
		{
			additionSequence[index]++;
			dispatchEvent(new ObstacleEvent(ObstacleEvent.breakConboNotice, gameTime, 0, 0));
		}
		
		public function preMaterializationNoticeAt(gameTime:int, index:int):void
		{
			var seqKey:String = String(index) + "@" + String(materializationSequence[index]++);
			preMaterializationNotice(gameTime, seqKey);
		}
		
		public function preMaterializationNotice(gameTime:int, key:String):void
		{
			var ns:Object = findKey(key);
			if (ns == null) return;
			ns.lastAddition = gameTime;
			ns.preMaterialization = true;
			dispatchEvent(new ObstacleEvent(ObstacleEvent.preMaterializationNotice, gameTime, 0, ns.count));
		}
		
		public function materializationNotice(gameTime:int, key:String):void
		{
			var ns:Object = findKey(key);
			if (ns == null) return;
			notice += ns.count;
			dispatchEvent(new ObstacleEvent(ObstacleEvent.materializationNotice, gameTime, 0, ns.count));
			var i:int = noticeSave.indexOf(ns);
			noticeSave.splice(i, 1);
		}
		
		private function findKey(key:String):Object
		{
			for (var i:int = 0; i < noticeSave.length; i++)
			{
				if (noticeSave[i].key == key) return noticeSave[i];
			}
			return null;
		}
		
		public function counterbalance(count:int):void
		{
			var ncb:int = Math.min(count, notice);
			count -= ncb;
			notice -= ncb;
			while (count > 0 && noticeSave.length > 0)
			{
				var nscb:int = Math.min(count, noticeSave[0].count);
				count -= nscb;
				noticeSave[0].count -= nscb;
				if (noticeSave[0].count <= 0) noticeSave.shift();
			}
		}
		
		public function trialAddition(gameTime:int, setting:GameSetting):void
		{
			if (trialLastAddition == 0)
			{
				addObstacle(gameTime, trialKey, setting.obstacleAdditionCount);
				materializationNotice(gameTime, trialKey);
				trialLastAddition = gameTime;
			}
			if (gameTime >= trialLastAddition + setting.obstacleInterval)
			{
				addObstacle(gameTime, trialKey, setting.obstacleAdditionCount);
				preMaterializationNotice(gameTime, trialKey);
				trialLastAddition = gameTime;
			}
			for (var i:int = 0; i < noticeSave.length; i++)
			{
				if (noticeSave[i].preMaterialization == false) continue;
				if (gameTime >= noticeSave[i].lastAddition + setting.obstacleSaveTime)
				{
					materializationNotice(gameTime, noticeSave[i].key);
				}
			}
		}
	}
}