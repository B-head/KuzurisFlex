package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class GameReplay implements GameControl 
	{
		
		public function GameReplay() 
		{
			
		}
		
		public function recordCommand(command:GameCommand):void
		{
			
		}
		
		public function changePhase(controlPhase:Boolean):void 
		{
			return;
		}
		
		public function updateModel(currentModel:GameLightModel):void
		{
			return;
		}
		
		public function issueGameCommand():GameCommand 
		{
			return null;
		}
		
	}

}