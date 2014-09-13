package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public interface GameControl
	{
		function changePhase(controlPhase:Boolean):void;
		function updateModel(gameModel:GameLightModel):void;
		function issueGameCommand():GameCommand;
	}
	
}