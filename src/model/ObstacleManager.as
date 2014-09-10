package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class ObstacleManager 
	{
		public var notice:int;
		private var noticeSave:Array;
		
		private var lastAddition:int;
		private var trialNoticeSave:Object;
		
		public function ObstacleManager()
		{
			noticeSave = new Array();
		}
		
		public function getNoticeSaveCount():int
		{
			var ret:int;
			for (var a:String in noticeSave)
			{
				var n:Object = noticeSave[a];
				if (n == null) continue;
				ret += n.count;
			}
			return ret;
		}
		
		public function getNextObstacleTime(gameTime:int, setting:GameSetting):int
		{
			return (lastAddition + setting.obstacleInterval) - gameTime;
		}
		
		public function trialAddition(gameTime:int, setting:GameSetting):void
		{
			if (lastAddition == 0)
			{
				notice += setting.obstacleAdditionCount;
				lastAddition = gameTime;
			}
			if (gameTime >= lastAddition + setting.obstacleInterval)
			{
				trialNoticeSave = { count:setting.obstacleAdditionCount };
				noticeSave["trial"] = trialNoticeSave;
				lastAddition = gameTime;
			}
			if (gameTime >= lastAddition + setting.obstacleSaveTime && trialNoticeSave != null)
			{
				notice += trialNoticeSave.count;
				trialNoticeSave = null;
				noticeSave["trial"] = null;
			}
		}
	}
}