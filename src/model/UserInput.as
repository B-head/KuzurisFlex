package model 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author B_head
	 */
	public class UserInput implements GameControl 
	{
		private const primaryMoveDelay:int = 8;
		private const secondaryMoveDelay:int = 4;
		
		public var rightRotation:Vector.<uint>;
		public var leftRotation:Vector.<uint>;
		public var rightMove:Vector.<uint>;
		public var leftMove:Vector.<uint>;
		public var fastFalling:Vector.<uint>;
		public var earthFalling:Vector.<uint>;
		public var noDamage:Vector.<uint>;
		public var oneFrameMove:Boolean;
		public var replaceFixCommand:Boolean;
		
		private var _enable:Boolean;
		private var downKeyCodes:Vector.<uint>;
		private var lastControl:GameCommand;
		private var moveDelay:int;
		private var remainderMove:int;
		private var remainderRotation:int;
		private var remainderEarthFalling:int;
		private var controlPhase:Boolean;
		
		public function UserInput() 
		{
			rightRotation = new <uint>[Keyboard.X, Keyboard.C, Keyboard.K];
			leftRotation = new <uint>[Keyboard.Z, Keyboard.H, Keyboard.J];
			rightMove = new <uint>[Keyboard.RIGHT, Keyboard.D];
			leftMove = new <uint>[Keyboard.LEFT, Keyboard.A];
			fastFalling = new <uint>[Keyboard.DOWN, Keyboard.S];
			earthFalling = new <uint>[Keyboard.UP, Keyboard.W];
			noDamage = new <uint>[Keyboard.SHIFT, Keyboard.SPACE, Keyboard.L, Keyboard.SEMICOLON];
			
			downKeyCodes = new Vector.<uint>();
			lastControl = new GameCommand();
		}
		
		public function keyDown(keyCode:int):void
		{
			for (var i:int; i < downKeyCodes.length; i++)
			{
				if (downKeyCodes[i] == keyCode)
				{
					return;
				}
			}
			downKeyCodes[downKeyCodes.length] = keyCode;
			if (!_enable) return;
			if (rightRotation.indexOf(keyCode) != -1)
			{
				remainderRotation++;
			}
			if (leftRotation.indexOf(keyCode) != -1)
			{
				remainderRotation--;
			}
			if (rightMove.indexOf(keyCode) != -1)
			{
				remainderMove++;
			}
			if (leftMove.indexOf(keyCode) != -1)
			{
				remainderMove--;
			}
			if (earthFalling.indexOf(keyCode) != -1)
			{
				remainderEarthFalling++;
			}
		}
		
		public function keyUp(keyCode:int):void
		{
			for (var i:int; i < downKeyCodes.length; i++)
			{
				if (downKeyCodes[i] == keyCode)
				{
					downKeyCodes.splice(i, 1);
					break;
				}
			}
		}
		
	 	public function get enable():Boolean { return _enable; }
		public function set enable(value:Boolean):void { _enable = value; };
		
		public function reset():void
		{
			lastControl = new GameCommand();
			moveDelay = 0;
			remainderMove = 0;
			remainderRotation = 0;
			remainderEarthFalling = 0;
			controlPhase = false;
		}
		
		public function changePhase(controlPhase:Boolean):void
		{
			this.controlPhase = controlPhase;
			if (!controlPhase)
			{
				moveDelay = primaryMoveDelay;
			}
		}
		
		public function issueGameCommand():GameCommand 
		{
			var value:GameCommand = new GameCommand();
			for each(var key:uint in downKeyCodes)
			{
				if (rightMove.indexOf(key) != -1)
				{
					value.move = GameCommand.right;
				}
				if (leftMove.indexOf(key) != -1)
				{
					value.move = GameCommand.left;
				}
				if (fastFalling.indexOf(key) != -1)
				{
					value.falling = GameCommand.fast;
				}
				if (noDamage.indexOf(key) != -1)
				{
					value.noDamege = true;
				}
			}
			
			if (lastControl.move == value.move)
			{
				moveDelay--;
				if (moveDelay > 0)
				{
					value.move = GameCommand.nothing;
				}
				else if (controlPhase && !oneFrameMove)
				{
					moveDelay = secondaryMoveDelay;
				}
			}
			else
			{
				lastControl.move = value.move;
				moveDelay = primaryMoveDelay;
			}
			
			if (remainderRotation > 0)
			{
				remainderRotation--;
				value.rotation = GameCommand.right;
			}
			else if (remainderRotation < 0)
			{
				remainderRotation++;
				value.rotation = GameCommand.left;
			}
			if (remainderMove > 0)
			{
				remainderMove--;
				value.move = GameCommand.right;
			}
			else if (remainderMove < 0)
			{
				remainderMove++;
				value.move = GameCommand.left;
			}
			if (remainderEarthFalling > 0)
			{
				remainderEarthFalling--;
				value.falling = GameCommand.earth;
			}
			
			if (replaceFixCommand && value.falling == GameCommand.fast)
			{
				value.fix = true;
			}
			else if (!replaceFixCommand && value.falling == GameCommand.earth)
			{
				value.fix = true;
			}
			return value;
		}
	}
}