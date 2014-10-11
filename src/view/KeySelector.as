package view 
{
	import flash.events.*;
	import flash.ui.*;
	import flash.utils.*;
	import model.*;
	import mx.collections.*;
	import spark.components.*;
	
	/**
	 * ...
	 * @author B_head
	 */
	[SkinState("normal")]
	[SkinState("over")]
	[SkinState("selected")]
	[SkinState("disabled")]
	public class KeySelector extends SkinnableContainer 
	{
		[Bindable]
		public var labelText:String;
		public var input:UserInput;
		private var _keys:Vector.<uint>;
		private var keyDictionary:Dictionary;
		private var pressKey:uint;
		private var selected:Boolean;
		private var mouseOvered:Boolean;
		
		public function KeySelector() 
		{
			super();
			mouseChildren = false;
            setStyle("skinClass", KeySelectorSkin);
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			keyDictionary = new Dictionary();
			var kd:XML = describeType(Keyboard);
			var kn:XMLList = kd.constant.@name;
			var kl:int = kn.length();
			for (var i:int = 0; i < kl; i++)
			{
				var str:String = String(kn[i]);
				keyDictionary[Keyboard[str]] = str;
			}
			pressKey = uint.MAX_VALUE;
		}
		
		[Bindable(event="keysChanged")]
		public function get keys():Vector.<uint>
		{
			return _keys;
		}
		[Bindable(event="keysChanged")]
		public function set keys(value:Vector.<uint>):void
		{
			_keys = value;
			dispatchEvent(new Event("keysChanged"));
		}
		
		[Bindable(event="keysChanged")]
		public function keysText():ArrayCollection
		{
			var ret:ArrayCollection = new ArrayCollection(new Array());
			for (var i:int = 0; i < keys.length; i++)
			{
				ret.addItem(keyDictionary[keys[i]]);
			}
			return ret;
		}
		
		override protected function getCurrentSkinState():String 
		{
			if (!enabled) return "disabled";
			if (selected) return "selected";
			if (mouseOvered) return "over";
			return "normal";
		}
		
		private function onClick(e:MouseEvent):void
		{
			setFocus();
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			mouseOvered = true;
			invalidateSkinState();
		}
		
		private function onMouseOut(e:MouseEvent):void
		{
			mouseOvered = false;
			invalidateSkinState();
		}
		
		private function onFocusIn(e:FocusEvent):void
		{
			selected = true;
			pressKey = uint.MAX_VALUE;
			invalidateSkinState();
		}
		
		private function onFocusOut(e:FocusEvent):void
		{
			selected = false;
			pressKey = uint.MAX_VALUE;
			invalidateSkinState();
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (!selected) return;
			pressKey = e.keyCode;
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			if (!selected) return;
			if (pressKey != e.keyCode) return;
			stage.focus = null;
			if (parentApplication.pause.indexOf(e.keyCode) != -1) return;
			var i:int = _keys.indexOf(e.keyCode);
			if (i == -1)
			{
				input.removeKeyCode(e.keyCode);
				_keys.push(e.keyCode);
			}
			else
			{
				_keys.splice(i, 1);
			}
			dispatchEvent(new Event("keysChanged"));
		}
		
	}

}