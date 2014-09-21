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
		function reset():void;
		function changePhase(controlPhase:Boolean):void;
		function issueGameCommand():GameCommand;
	}
	
}