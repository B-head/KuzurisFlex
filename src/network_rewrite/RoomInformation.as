package network_rewrite {
	import flash.crypto.generateRandomBytes;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import model.GameSetting;
	import mx.collections.ArrayCollection;
	/**
	 * ...
	 * @author B_head
	 */
	public class RoomInformation 
	{
		public var id:String;
		public var lastUpdateTime:int;
		[Bindable]
		public var name:String;
		[Bindable]
		public var isNeedPassword:Boolean;
		[Bindable]
		public var quick:Boolean;
		[Bindable]
		public var multi:Boolean;
		[Bindable]
		public var setting:GameSetting;
		[Bindable]
		public var entrant:ArrayCollection;
		[Bindable]
		public var watch:ArrayCollection;
		
		public static const watchIndex:int = -1;
		
		public function RoomInformation(name:String = "", quick:Boolean = false, multi:Boolean = false, setting:GameSetting = null) 
		{
			this.id = makeID();
			this.name = name;
			this.quick = quick;
			this.multi = multi;
			this.setting = setting;
			lastUpdateTime = getTimer();
			entrant = new ArrayCollection(new Array());
			for (var i:int = 0; i < (multi ? 6 : 2); i++)
			{
				entrant.addItem(null);
			}
			watch = new ArrayCollection(new Array());
		}
		
		private function makeID():String
		{
			var arr:ByteArray = generateRandomBytes(128);
			var ret:String = "";
			while (arr.bytesAvailable > 0)
			{
				ret += arr.readUnsignedInt().toString(16);
			}
			return ret;
		}
		
		public function isEmpty():Boolean
		{
			if (watch.length > 0) return false;
			for (var i:int = 0; i < entrant.length; i++)
			{
				if (entrant.getItemAt(i) != null) return false;
			}
			return true;
		}
		
		public function getEnterableIndex():int
		{
			for (var i:int = 0; i < entrant.length; i++)
			{
				if (entrant.getItemAt(i) == null) return i;
			}
			return -1;
		}
		
		public function updatePlayer(player:PlayerInformation):void
		{
			if (player.currentRoomID != id)
			{
				removeWatchPlayer(player);
				removeEntrantPlayer(player);
			}
			else if (player.currentBattleIndex == watchIndex)
			{
				removeEntrantPlayer(player);
				if (!hasWatch(player)) watch.addItem(player);
			}
			else
			{
				removeWatchPlayer(player);
				var i:int = getPlayerIndex(entrant, player);
				if (i != watchIndex && i != player.currentBattleIndex)
				{
					removeEntrantPlayer(player);
				}
				entrant.setItemAt(player, player.currentBattleIndex);
			}
		}
		
		public function getHostPlayer():PlayerInformation
		{
			var max:PlayerInformation;
			if (entrant.length > 0)
			{
				for (var i:int = 0; i < entrant.length; i++)
				{
					if (entrant[i] == null) continue;
					if (max == null)
					{
						max = entrant[i];
						continue;
					}
					if (max.hostPriority > entrant[i].hostPriority)
					{
						max = entrant[i];
						continue;
					}
				}
			}
			else
			{
				for (i = 0; i < watch.length; i++)
				{
					if (watch[i] == null) continue;
					if (max == null)
					{
						max = watch[i];
						continue;
					}
					if (max.hostPriority > watch[i].hostPriority)
					{
						max = watch[i];
						continue;
					}
				}
			}
			return max;
		}
		
		public function getNextHostPriority():int
		{
			var max:int = int.MIN_VALUE;
			for (var i:int = 0; i < entrant.length; i++)
			{
				if (entrant[i] == null) continue;
				if (max < entrant[i].hostPriority)
				{
					max = entrant[i].hostPriority;
				}
			}
			for (i = 0; i < watch.length; i++)
			{
				if (watch[i] == null) continue;
				if (max < watch[i].hostPriority)
				{
					max = watch[i].hostPriority;
				}
			}
			return max;
		}
		
		private function getPlayerIndex(collection:ArrayCollection, player:PlayerInformation):int
		{
			for (var i:int = 0; i < collection.length; i++)
			{
				var temp:PlayerInformation = collection.getItemAt(i) as PlayerInformation;
				if (temp == null) continue;
				if (temp.peerID == player.peerID) return i;
			}
			return -1;
		}
		
		private function hasWatch(player:PlayerInformation):Boolean
		{
			return getPlayerIndex(watch, player) != -1;
		}
		
		private function removeWatchPlayer(player:PlayerInformation):void
		{
			var i:int = getPlayerIndex(watch, player);
			if (i == -1) return;
			watch.removeItemAt(i);
		}
		
		private function removeEntrantPlayer(player:PlayerInformation):void
		{
			var i:int = getPlayerIndex(entrant, player);
			if (i == -1) return;
			entrant.setItemAt(null, i);
		}
	}

}