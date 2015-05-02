package network {
	import events.*;
	import flash.events.EventDispatcher;
	import common.EventDispatcherEX;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="appendChat", type="events.UpdateChatEvent")]
	public class TextChat extends EventDispatcherEX
	{
		private static const chatUtter:String = "chatUtter";
		
		private var utterances:Vector.<Utterance>; 
		private var netGroup:NetworkGroupManager;
		private var selfPlayerInfo:PlayerInformation;
		
		public function TextChat(netGroup:NetworkGroupManager, selfPlayerInfo:PlayerInformation) 
		{
			utterances = new Vector.<Utterance>();
			this.netGroup = netGroup;
			this.selfPlayerInfo = selfPlayerInfo;
			netGroup.addTerget(KuzurisEvent.firstConnectNeighbor, connectNeighborListener);
			netGroup.addTerget(NotifyEvent.notify, notifyListener);
		}
		
		public function dispose():void
		{
			netGroup.removeTerget(KuzurisEvent.firstConnectNeighbor, connectNeighborListener);
			netGroup.removeTerget(NotifyEvent.notify, notifyListener);
			removeAll();
		}
		
		public function utter(text:String):void
		{
			var u:Utterance = new Utterance();
			u.text = text;
			u.playerInfo = selfPlayerInfo;
			u.date = new Date();
			netGroup.post(chatUtter, { utterance:u } );
			utterances.push(u);
			dispatchEvent(new UpdateChatEvent(UpdateChatEvent.appendChat, u));
		}
		
		private function connectNeighborListener(e:KuzurisEvent):void
		{
			
		}
		
		private function notifyListener(e:NotifyEvent):void
		{
			switch (e.message.type)
			{
				case chatUtter:
					utterances.push(e.message.obj.utterance as Utterance);
					dispatchEvent(new UpdateChatEvent(UpdateChatEvent.appendChat, e.message.obj.utterance));
					break;
			}
		}
	}

}