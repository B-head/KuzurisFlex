package model.network {
	import events.*;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author B_head
	 */
	[Event(name="updateChat", type="events.KuzurisEvent")]
	public class TextChat extends EventDispatcher
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
			netGroup.addEventListener(KuzurisEvent.firstConnectNeighbor, connectNeighborListener);
			netGroup.addEventListener(NotifyEvent.notify, notifyListener);
		}
		
		public function utter(text:String):void
		{
			var u:Utterance = new Utterance();
			u.text = text;
			u.playerInfo = selfPlayerInfo;
			u.date = new Date();
			netGroup.post(chatUtter, { utterance:u } );
			utterances.push(u);
			dispatchEvent(new KuzurisEvent(KuzurisEvent.updateChat));
		}
		
		public function toText():String
		{
			var ret:String = "";
			for (var i:int = 0; i < utterances.length; i++)
			{
				if (i > 0) ret += "\r\n";
				ret += utterances[i].playerInfo.name + ":" +
					utterances[i].text;
			}
			return ret;
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
					dispatchEvent(new KuzurisEvent(KuzurisEvent.updateChat));
					break;
			}
		}
	}

}