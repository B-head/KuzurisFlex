package view 
{
	import flash.display.DisplayObject;
	import model.*;
	import events.*;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import view.BreakBlockGraphics;
	/**
	 * ...
	 * @author B_head
	 */
	public class BreakLineEffect extends Sprite
	{
		public var breakLineGraphics:BreakLineGraphics;
		public var breakBlockGraphics:BreakBlockGraphics;
		public var lineEffect:Bitmap;
		public var blockEffects:Vector.<Bitmap>;
		public var blockRotations:Vector.<Number>;
		public var blockStates:Vector.<BlockState>;
		public var isFree:Boolean;
		public var count:int;
		public var powerLevel:int;
		
		public function BreakLineEffect() 
		{
			lineEffect = new Bitmap();
			addChild(lineEffect);
			blockEffects = new Vector.<Bitmap>();
			blockRotations = new Vector.<Number>();
			for (var i:int = 0; i < 10; ++i)
			{
				blockEffects[i] = new Bitmap();
				addChild(blockEffects[i]);
			}
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
			for (var i:int = 0; i < 10; ++i)
			{
				blockRotations[i] = int(Math.random() * 4) * 90;
			}
			isFree = false;
		}
		
		public function update():void
		{
			if (count < BreakLineGraphics.frameMax)
			{
				lineEffect.bitmapData = breakLineGraphics.grfs[count][powerLevel];
				for (var i:int = 0; i < 10; ++i)
				{
					if (blockStates[i].type != BlockState.jewel) continue;
					blockEffects[i].bitmapData = breakBlockGraphics.jewel[blockStates[i].color][count];
					blockEffects[i].x = breakBlockGraphics.size * (i - 1);
					blockEffects[i].y = -breakBlockGraphics.size;
					blockEffects[i].rotation = 0;
					rotate(blockEffects[i], blockRotations[i], breakBlockGraphics.size * 1.5, breakBlockGraphics.size * 1.5);
				}
			}
			else
			{
				lineEffect.bitmapData = null;
				for (var k:int = 0; k < 10; ++k)
				{
					blockEffects[k].bitmapData = null;
				}
				isFree = true;
			}
		}
		
		private function rotate(disp:DisplayObject, rotation:Number, x:Number, y:Number):void 
		{
			var x1:Number, y1:Number;
			var rad1:Number = degreesToRadians(disp.rotation);
			x1 = x * Math.cos(rad1) - y * Math.sin(rad1);
			y1 = x * Math.sin(rad1) + y * Math.cos(rad1);

			var x2:Number, y2:Number;
			var rad2:Number = degreesToRadians(rotation);
			x2 = x * Math.cos(rad2) - y * Math.sin(rad2);
			y2 = x * Math.sin(rad2) + y * Math.cos(rad2);

			disp.rotation = rotation;
			disp.x += x1 - x2;
			disp.y += y1 - y2;
		}

		private function degreesToRadians(degrees:Number):Number 
		{
			return (degrees/180) * Math.PI;
		}
	}

}