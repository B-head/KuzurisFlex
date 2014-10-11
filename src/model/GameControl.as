package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public interface GameControl
	{
		function get enable():Boolean;
		function set enable(value:Boolean):void;
		function initialize(gameModel:GameModel):void;
		function setMaterialization(index:int):void;
		function issueGameCommand():GameCommand;
	}
	
}