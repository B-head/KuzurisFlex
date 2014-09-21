package event 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class GameManagerEvent extends Event 
	{
		public static const gameStart:String = "gameStart";
		public static const gameEnd:String = "gameEnd";
		public static const changePlayer:String = "changePlayer";
		
		public function GameManagerEvent(type:String) 
		{ 
			super(type, false, false);
			
		} 
		
		public override function clone():Event 
		{ 
			return new GameManagerEvent(type);
		}
		
	}
	
}