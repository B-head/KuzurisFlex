package presentation {
	import common.*;
	import events.*;
	import flash.display.*;
	import model.*;
	import presentation.*;
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
					Utility.rotate(blockEffects[i], blockRotations[i], breakBlockGraphics.size * 1.5, breakBlockGraphics.size * 1.5);
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
	}

}