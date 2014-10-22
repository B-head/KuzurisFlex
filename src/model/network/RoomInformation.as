package model.network {
	import flash.crypto.generateRandomBytes;
	import flash.utils.ByteArray;
	import mx.collections.ArrayCollection;
	/**
	 * ...
	 * @author B_head
	 */
	public class RoomInformation 
	{
		public var id:String;
		[Bindable]
		public var name:String;
		[Bindable]
		public var quick:Boolean;
		[Bindable]
		public var multi:Boolean;
		[Bindable]
		public var entrant:ArrayCollection;
		[Bindable]
		public var watch:ArrayCollection;
		
		public static const watchIndex:int = -1;
		
		public function RoomInformation(name:String = "", quick:Boolean = false, multi:Boolean = false) 
		{
			this.id = makeID();
			this.name = name;
			this.quick = quick;
			this.multi = multi;
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
			if (player.currentRoomID == null)
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