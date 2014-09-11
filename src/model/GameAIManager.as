package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class GameAIManager implements GameControl 
	{
		
		public function GameAIManager() 
		{
			
		}
		
		public function changePhase(controlPhase:Boolean):void 
		{
			
		}
		
		public function issueGameCommand():GameCommand 
		{
			return new GameCommand();
		}
		
	}

}