package presentation {
	import events.*;
	import flash.events.*;
	import flash.ui.*;
	import model.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class UserInput extends EventDispatcher implements GameControl 
	{
		private static const defaultKeyOnePlayer:String = "defaultKeyOnePlayer";
		private static const defaultVersusPlayer1:String = "defaultVersusPlayer1";
		private static const defaultVersusPlayer2:String = "defaultVersusPlayer2";
		
		private const primaryMoveDelay:int = 8;
		private const secondaryMoveDelay:int = 4;
		
		[Bindable]
		public var rightRotation:Vector.<uint>;
		[Bindable]
		public var leftRotation:Vector.<uint>;
		[Bindable]
		public var rightMove:Vector.<uint>;
		[Bindable]
		public var leftMove:Vector.<uint>;
		[Bindable]
		public var fastFalling:Vector.<uint>;
		[Bindable]
		public var earthFalling:Vector.<uint>;
		[Bindable]
		public var noDamage:Vector.<uint>;
		public var oneFrameMove:Boolean;
		public var replaceFixCommand:Boolean;
		public var defaultKeyTag:String;
		
		private var _enable:Boolean;
		private var materialization:Vector.<Boolean>;
		private var gameModel:GameModel;
		private var downKeyCodes:Vector.<uint>;
		private var lastControl:GameCommand;
		private var moveDelay:int;
		private var restrainFall:Boolean;
		private var remainderMove:int;
		private var remainderRotation:int;
		private var remainderEarthFalling:int;
		private var controlPhase:Boolean;
		
		public function UserInput() 
		{
			downKeyCodes = new Vector.<uint>();
			lastControl = new GameCommand();
		}
		
		public static function createOnePlayer():UserInput
		{
			var ret:UserInput = new UserInput();
			ret.setOnePlayerDefaultKeys();
			return ret;
		}
		
		public static function createVersusPlayer1():UserInput
		{
			var ret:UserInput = new UserInput();
			ret.setVersusPlayer1DefaultKeys();
			return ret;
		}
		
		public static function createVersusPlayer2():UserInput
		{
			var ret:UserInput = new UserInput();
			ret.setVersusPlayer2DefaultKeys();
			return ret;
		}
		
		public function setOnePlayerDefaultKeys():void
		{
			rightRotation = Vector.<uint>([Keyboard.X, Keyboard.C, Keyboard.K]);
			leftRotation = Vector.<uint>([Keyboard.Z, Keyboard.H, Keyboard.J]);
			rightMove = Vector.<uint>([Keyboard.RIGHT, Keyboard.D]);
			leftMove = Vector.<uint>([Keyboard.LEFT, Keyboard.A]);
			fastFalling = Vector.<uint>([Keyboard.DOWN, Keyboard.S]);
			earthFalling = Vector.<uint>([Keyboard.UP, Keyboard.W]);
			noDamage = Vector.<uint>([Keyboard.SHIFT, Keyboard.SPACE, Keyboard.L, Keyboard.SEMICOLON]);
			oneFrameMove = true;
			replaceFixCommand = false;
			defaultKeyTag = defaultKeyOnePlayer;
			dispatchEvent(new Event("changeOneFrameMove"));
			dispatchEvent(new Event("changeReplaceFixCommand"));
		}
		
		public function setVersusPlayer1DefaultKeys():void
		{
			rightRotation = Vector.<uint>([Keyboard.C]);
			leftRotation = Vector.<uint>([Keyboard.Z, Keyboard.X]);
			rightMove = Vector.<uint>([Keyboard.D]);
			leftMove = Vector.<uint>([Keyboard.A]);
			fastFalling = Vector.<uint>([Keyboard.S]);
			earthFalling = Vector.<uint>([Keyboard.W]);
			noDamage = Vector.<uint>([Keyboard.V]);
			oneFrameMove = true;
			replaceFixCommand = false;
			defaultKeyTag = defaultVersusPlayer1;
			dispatchEvent(new Event("changeOneFrameMove"));
			dispatchEvent(new Event("changeReplaceFixCommand"));
		}
		
		public function setVersusPlayer2DefaultKeys():void
		{
			rightRotation = Vector.<uint>([Keyboard.PERIOD]);
			leftRotation = Vector.<uint>([Keyboard.M, Keyboard.COMMA]);
			rightMove = Vector.<uint>([Keyboard.L]);
			leftMove = Vector.<uint>([Keyboard.J]);
			fastFalling = Vector.<uint>([Keyboard.K]);
			earthFalling = Vector.<uint>([Keyboard.I]);
			noDamage = Vector.<uint>([Keyboard.SLASH]);
			oneFrameMove = true;
			replaceFixCommand = false;
			defaultKeyTag = defaultVersusPlayer2;
			dispatchEvent(new Event("changeOneFrameMove"));
			dispatchEvent(new Event("changeReplaceFixCommand"));
		}
		
		public function setDefaultKeys():void
		{
			switch(defaultKeyTag)
			{
				case defaultKeyOnePlayer: setOnePlayerDefaultKeys(); break;
				case defaultVersusPlayer1: setVersusPlayer1DefaultKeys(); break;
				case defaultVersusPlayer2: setVersusPlayer2DefaultKeys(); break;
				default: throw new Error();
			}
		}
		
		public function removeKeyCode(keyCode:uint):void
		{
			var i:int;
			i = rightRotation.indexOf(keyCode);
			if (i != -1) rightRotation.splice(i, 1);
			i = leftRotation.indexOf(keyCode);
			if (i != -1) leftRotation.splice(i, 1);
			i = rightMove.indexOf(keyCode);
			if (i != -1) rightMove.splice(i, 1);
			i = leftMove.indexOf(keyCode);
			if (i != -1) leftMove.splice(i, 1);
			i = fastFalling.indexOf(keyCode);
			if (i != -1) fastFalling.splice(i, 1);
			i = earthFalling.indexOf(keyCode);
			if (i != -1) earthFalling.splice(i, 1);
			i = noDamage.indexOf(keyCode);
			if (i != -1) noDamage.splice(i, 1);
			
		}
		
	 	public function get enable():Boolean { return _enable; };
		public function set enable(value:Boolean):void { _enable = value; };

		[Bindable(event="changeOneFrameMove")]
		public function get indexOfOneFrameMove():int { return oneFrameMove ? 0 : 1; };
		[Bindable(event="changeOneFrameMove")]
		public function set indexOfOneFrameMove(value:int):void 
		{ 
			oneFrameMove = value == 0; 
			dispatchEvent(new Event("changeOneFrameMove"));
		};

		[Bindable(event="changeReplaceFixCommand")]
		public function get indexOfReplaceFixCommand():int { return replaceFixCommand ? 1 : 0; };
		[Bindable(event="changeReplaceFixCommand")]
		public function set indexOfReplaceFixCommand(value:int):void 
		{ 
			replaceFixCommand = value == 1; 
			dispatchEvent(new Event("changeReplaceFixCommand"));
		};
		
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
		
		public function initialize(gameModel:GameModel):void
		{
			this.gameModel = gameModel;
			gameModel.addTerget(ControlEvent.setOmino, setOminoListener);
			gameModel.addTerget(ControlEvent.fixOmino, fixOminoListener);
			materialization = new Vector.<Boolean>(GameCommand.materializationLength);
			lastControl = new GameCommand();
			moveDelay = 0;
			remainderMove = 0;
			remainderRotation = 0;
			remainderEarthFalling = 0;
			controlPhase = false;
		}
		
		private function setOminoListener(e:ControlEvent):void
		{
			controlPhase = true;
		}
		
		private function fixOminoListener(e:ControlEvent):void
		{
			controlPhase = false;
			moveDelay = primaryMoveDelay;
			restrainFall = true;
		}
		
		public function setMaterialization(index:int):void
		{
			materialization[index] = true;
		}
		
		public function issueGameCommand():GameCommand 
		{
			var value:GameCommand = new GameCommand(materialization);
			materialization = new Vector.<Boolean>(GameCommand.materializationLength);
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
				if (moveDelay > 0 && value.move != GameCommand.nothing)
				{
					value.move = GameCommand.stopgap;
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
			
			if (value.falling == GameCommand.fast && restrainFall)
			{
				value.falling = GameCommand.nothing;
			}
			else
			{
				restrainFall = false;
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