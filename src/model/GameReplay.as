package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class GameReplay implements GameControl 
	{
		private var _enable:Boolean;
		
		public function GameReplay() 
		{
			
		}
		
		public function recordCommand(command:GameCommand):void
		{
			
		}
		
		public function get enable():Boolean { return _enable; }
		public function set enable(value:Boolean):void { _enable = value; };
		
		public function reset():void
		{
			return;
		}
		
		public function changePhase(controlPhase:Boolean):void 
		{
			return;
		}
		
		public function issueGameCommand():GameCommand 
		{
			return null;
		}
		
	}

}