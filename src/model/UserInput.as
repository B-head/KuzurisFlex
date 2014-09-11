package model 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author B_head
	 */
	public class UserInput extends EventDispatcher implements GameControl 
	{
		public static const pauseEvent:String = "pause";
		private const primaryMoveDelay:int = 8;
		private const secondaryMoveDelay:int = 4;
		
		public var rightRotation:Vector.<uint>;
		public var leftRotation:Vector.<uint>;
		public var rightMove:Vector.<uint>;
		public var leftMove:Vector.<uint>;
		public var fastFalling:Vector.<uint>;
		public var earthFalling:Vector.<uint>;
		public var noDamage:Vector.<uint>;
		public var pause:Vector.<uint>;
		public var oneFrameMove:Boolean;
		public var replaceFixCommand:Boolean;
		
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
			pause = new <uint>[Keyboard.ENTER, Keyboard.BACKSPACE, Keyboard.ESCAPE];
			
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
			if (pause.indexOf(keyCode) != -1)
			{
				dispatchEvent(new Event(pauseEvent));
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
		
		public function changePhase(controlPhase:Boolean):void
		{
			if (controlPhase)
			{
				if (!oneFrameMove && moveDelay <= 0)
				{
					moveDelay = secondaryMoveDelay;
				}
				this.controlPhase = true;
			}
			else
			{
				moveDelay = primaryMoveDelay;
				this.controlPhase = false
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