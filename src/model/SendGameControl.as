package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class SendGameControl implements GameControl 
	{
		private var control:GameControl;
		private var networkManager:NetworkManager;
		
		public function SendGameControl(input:GameControl, networkManager:NetworkManager) 
		{
			this.control = input;
			this.networkManager = networkManager;
		}
		
		public function get enable():Boolean { return control.enable; }
		public function set enable(value:Boolean):void { control.enable = value; };
		
		public function initialize(gameModel:GameModel):void 
		{
			control.initialize(gameModel);
		}
		
		public function setMaterialization(index:int):void
		{
			control.setMaterialization(index);
		}
		
		public function issueGameCommand():GameCommand 
		{
			var command:GameCommand = control.issueGameCommand();
			networkManager.sendCommand(command);
			return command;
		}
		
	}

}