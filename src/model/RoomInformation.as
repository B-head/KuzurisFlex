package model 
{
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
		public var multi:Boolean;
		[Bindable]
		public var entrant:ArrayCollection;
		[Bindable]
		public var watch:ArrayCollection;
		
		public function RoomInformation(name:String = "", multi:Boolean = false) 
		{
			this.id = makeID();
			this.name = name;
			this.multi = multi;
			entrant = new ArrayCollection(new Array());
			for (var i:int = 0; i < (multi ? 8 : 2); i++)
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
		
		public function enterRoom(player:PlayerInformation):void
		{
			removeWatchPlayer(player);
			watch.addItem(player);
		}
		
		public function leaveRoom(player:PlayerInformation):void
		{
			removeWatchPlayer(player);
			removeEntrantPlayer(player);
		}
		
		public function enterBattle(player:PlayerInformation, index:int):void
		{
			removeWatchPlayer(player);
			removeEntrantPlayer(player);
			entrant.setItemAt(player, index);
		}
		
		public function leaveBattle(player:PlayerInformation):void
		{
			removeWatchPlayer(player);
			removeEntrantPlayer(player);
			watch.addItem(player);
		}
		
		private function removeWatchPlayer(player:PlayerInformation):void
		{
			for (var i:int = 0; i < watch.length; i++)
			{
				var temp:PlayerInformation = watch.getItemAt(i) as PlayerInformation;
				if (temp == null) continue;
				if (temp.peerID == player.peerID) break;
			}
			if (i == watch.length) return;
			watch.removeItemAt(i);
		}
		
		private function removeEntrantPlayer(player:PlayerInformation):void
		{
			for (var i:int = 0; i < entrant.length; i++)
			{
				var temp:PlayerInformation = entrant.getItemAt(i) as PlayerInformation;
				if (temp == null) continue;
				if (temp.peerID == player.peerID) break;
			}
			if (i == entrant.length) return;
			entrant.setItemAt(null, i);
		}
	}

}