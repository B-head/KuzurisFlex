package presentation {
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import common.Color;
	/**
	 * ...
	 * @author B_head
	 */
	public class BreakBlockGraphics 
	{
		public var fireworks:Vector.<Vector.<BitmapData>>;
		public var jewel:Vector.<Vector.<BitmapData>>;
		public var size:Number;
		public var offsetX:Number;
		public var offsetY:Number;
		
		public static const frameMax:int = 30;
		
		public function BreakBlockGraphics(size:Number) 
		{
			this.size = size;
			this.offsetX = -size;
			this.offsetY = -size;
			fireworks = new Vector.<Vector.<BitmapData>>(19);
			jewel = new Vector.<Vector.<BitmapData>>(19);
			for (var c:int; c < 19; c++)
			{
				fireworks[c] = new Vector.<BitmapData>(frameMax);
				jewel[c] = new Vector.<BitmapData>(frameMax);
				var color:uint = Color.toColor(c);
				var pixels:Vector.<PixelState> = makePixelStates(size * 3, color, size * size);
				for (var i:int = 0; i < frameMax; i++)
				{
					var fw:BitmapData = new BitmapData(size * 3, size * 3, true, 0);
					drawFireworksGraphics(fw, color, pixels, i);
					fireworks[c][i] = fw;
					var j:BitmapData = new BitmapData(size * 3, size * 3, true, 0);
					drawJewelGraphics(j, color, i);
					jewel[c][i] = j;
				}
			}
		}
		
		private function drawFireworksGraphics(bitmap:BitmapData, color:uint, pixels:Vector.<PixelState>, frame:int):void
		{
			var p:Number = (frame + 1) / frameMax;
			for (var i:int = 0; i < pixels.length; ++i)
			{
				//if (pixels[i].lifeTime < p) continue;
				var o:int = size * (1 - p) * 1.5;
				var x:int = o + pixels[i].x * p;
				var y:int = o + pixels[i].y * p;
				bitmap.setPixel32(x, y, pixels[i].color);
			}
		}
		
		private function drawJewelGraphics(bitmap:BitmapData, color:uint, frame:int):void
		{
			var p:Number = 1 - frame / frameMax;
			var np:Number = 1 - p;
			var shape:Shape = new Shape();
			var grf:Graphics = shape.graphics;
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(p * size * 3, p * size * 3, 0, np * size * 1.5, np * size * 1.5);
			grf.beginGradientFill(GradientType.RADIAL, [Color.white, color, color], [1, 1, 0], [0, 128, 255], matrix);
			grf.lineStyle(1, Color.white);
			grf.drawCircle(size * 1.5, size * 1.5, p * size * 1.5);
			grf.endFill();
			bitmap.draw(shape);
		}
		
		private function makePixelStates(size:int, color:uint, count:int):Vector.<PixelState>
		{
			var ret:Vector.<PixelState> = new Vector.<PixelState>();
			for (var i:int = 0; i < count; ++i)
			{
				var ps:PixelState = new PixelState();
				ps.x = Math.random() * size;
				ps.y = Math.random() * size;
				var s:Number = size / 2;
				if (vectorLangth(ps.x - s, ps.y - s) > s) continue;
				ps.color = Color.brightnessTransform(color, Math.random());
				ps.lifeTime = Math.random();
				ret.push(ps);
			}
			return ret;
		}
		
		private function vectorLangth(x:Number, y:Number):Number
		{
			return Math.sqrt(x * x + y * y);
		}
	}
}

internal class PixelState
{
	public var x:int;
	public var y:int;
	public var color:uint;
	public var lifeTime:Number;
}