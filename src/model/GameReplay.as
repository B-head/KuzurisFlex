package model 
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	/**
	 * ...
	 * @author B_head
	 */
	public class GameReplay implements GameControl, IExternalizable
	{
		private var _enable:Boolean;
		private var commands:Vector.<GameCommand>;
		private var time:int;
		public var setting:GameSetting;
		public var seed:XorShift128;
		
		public function GameReplay(setting:GameSetting = null, seed:XorShift128 = null) 
		{
			commands = new Vector.<GameCommand>();
			if (setting != null) this.setting = setting.clone();
			if (seed != null) this.seed = seed.clone();
		}
		
		public function recordCommand(command:GameCommand):void
		{
			commands.push(command);
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
			if (time >= commands.length) return null;
			return commands[time++];
		}
		
		public function writeExternal(output:IDataOutput):void 
		{
			output.writeObject(setting);
			output.writeObject(seed);
			output.writeInt(commands.length);
			for (var i:int = 0; i < commands.length; i++)
			{
				commands[i].writeExternal(output);
			}
		}
		
		public function readExternal(input:IDataInput):void 
		{
			setting = input.readObject();
			seed = input.readObject();
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