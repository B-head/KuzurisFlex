package events {
	import flash.events.Event;
	import model.GameModel;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class ReceiveGameModelEvent extends Event 
	{
		public var model:GameModel;
		
		public static const receiveGameModel:String = "receiveGameModelEvent";
		
		public function ReceiveGameModelEvent(type:String, model:GameModel) 
		{ 
			super(type, false, false);
			this.model = model;
		} 
		
		public override function clone():Event 
		{ 
			return new ReceiveGameModelEvent(type, model);
		}
		
	}
	
}