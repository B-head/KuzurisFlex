package model 
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	/**
	 * ...
	 * @author B_head
	 */
	public class GameReplayControl implements GameControl, IExternalizable
	{
		private var _enable:Boolean;
		private var commands:Vector.<GameCommand>;
		private var time:int;
		
		public function GameReplayControl() 
		{
			commands = new Vector.<GameCommand>();
		}
		
		public function clone():GameReplayControl
		{
			var ret:GameReplayControl = new GameReplayControl();
			ret.commands = commands.slice();
			return ret;
		}
		
		public function recordCommand(command:GameCommand):void
		{
			commands.push(command);
		}
		
		public function isReplayEnd():Boolean
		{
			return time >= commands.length;
		}
		
		public function get enable():Boolean { return _enable; }
		public function set enable(value:Boolean):void { _enable = value; };
		
		public function initialize(gameModel:GameModel):void
		{
			time = 0;
		}
		
		public function setMaterialization(index:int):void
		{
			return;
		}
		
		public function issueGameCommand():GameCommand 
		{
			if (isReplayEnd()) return null;
			return commands[time++];
		}
		
		public function writeExternal(output:IDataOutput):void 
		{
			output.writeInt(commands.length);
			for (var i:int = 0; i < commands.length; i++)
			{
				commands[i].writeExternal(output);
			}
		}
		
		public function readExternal(input:IDataInput):void 
		{
			var length:int = input.readInt();
			commands = new Vector.<GameCommand>(length);
			for (var i:int = 0; i < commands.length; i++)
			{
				var gc:GameCommand = new GameCommand();
				gc.readExternal(input);
				commands[i] = gc;
			}
		}
	}

}