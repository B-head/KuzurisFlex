package view 
{
	import model.*;
	import events.*;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author B_head
	 */
	public class BreakLineEffect extends Sprite
	{
		public var breakLineGraphics:BreakLineGraphics;
		public var lineEffect:Bitmap;
		public var isFree:Boolean;
		public var count:int;
		public var powerLevel:int;
		
		public function BreakLineEffect() 
		{
			lineEffect = new Bitmap();
			addChild(lineEffect);
			reset();
		}
		
		public function reset():void
		{
			count = BreakLineGraphics.frameMax;
			isFree = true;
		}
		
		public function start():void
		{
			count = 0;
			isFree = false;
		}
		
		public function update():void
		{
			if (count < BreakLineGraphics.frameMax)
			{
				lineEffect.bitmapData = breakLineGraphics.grfs[count][powerLevel];
			}
			else
			{
				lineEffect.bitmapData = null;
				isFree = true;
			}
		}
	}

}