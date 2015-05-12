package network_rewrite 
{
	import common.*;
	import events.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import model.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class NetworkGameManager extends GameManager 
	{
		private var selfPlayerInfo:PlayerInformation;
		
		public function NetworkGameManager(maxPlayer:int, selfPlayerInfo:PlayerInformation) 
		{
			super(maxPlayer);
			this.selfPlayerInfo = selfPlayerInfo;
		}
		
		override public function initialize():void 
		{
			lastGameForwardTime = getTimer();
			super.initialize();
		}
		
		override public function makeReplayContainer():GameReplayContainer 
		{
			var ret:GameReplayContainer = super.makeReplayContainer();
			ret.roomName = currentRoom.name;
			return ret;
		}
		
		override protected function checkGameEnd():void 
		{
			var count:int = 0;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (control[i] == null || gameModel[i].isGameOver) continue;
				if (control[i].enable == false)
				{
					count++;
				}
			}
			if (count > 0)
			{
				if (lastGameForwardTime + gameStopLimit < getTimer())
				{
					endGame();
					dispatchEvent(new KuzurisErrorEvent(KuzurisErrorEvent.gameAbort, "10秒以上停止したため、ゲームを終了しました。"));
					return;
				}
			}
			else
			{
				lastGameForwardTime = getTimer();
			}
			super.checkGameEnd();
		}
		
		[Bindable(event="playerUpdate")]
		public function isEnter():Boolean
		{
			return currentRoom.entrant.getItemIndex(selfPlayerInfo) >= 0;
		}
		
		[Bindable(event="playerUpdate")]
		public function isStand():Boolean
		{
			if (isExecution())
			{
				if (selfPlayerIndex == RoomInformation.watchIndex) return true;
				return isPlayerGameEnd(selfPlayerIndex);
			}
			return isOnePlayer();
		}
		
		[Bindable(event="playerUpdate")]
		public function isOnePlayer():Boolean
		{
			var count:int;
			var maxPlayer:int = currentRoom.entrant.length;
			for (var i:int = 0; i < maxPlayer; i++)
			{
				if (currentRoom.entrant.getItemAt(i) != null) count++;
			}
			return count <= 1;
		}
		
		[Bindable(event="playerUpdate")]
		public function transPlayerIndex(index:int):int
		{
			if (selfPlayerIndex == -1) return index;
			if (index == 0) return selfPlayerIndex;
			if (index <= selfPlayerIndex) return index - 1;
			return index;
		}
		
		[Bindable(event="playerUpdate")]
		public override function isIndexEmpty(index:int):Boolean
		{
			return currentRoom.entrant.getItemAt(index) == null;
		}
		
		[Bindable(event="playerUpdate")]
		public function transFlip(flip:Boolean):Boolean
		{
			if (selfPlayerIndex == 0)
			{
				return flip;
			}
			else
			{
				return !flip;
			}
		}
		
	}

}