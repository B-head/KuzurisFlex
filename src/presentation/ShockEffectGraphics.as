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
	public class ShockEffectGraphics 
	{
		public var normal:Vector.<BitmapData>;
		public var toSplit:Vector.<BitmapData>;
		public var blockWidth:Number;
		public var blockHeight:Number;
		public var offsetX:Number;
		public var offsetY:Number;
		
		public static const frameMax:int = 30;
		
		public function ShockEffectGraphics(width:Number, height:Number) 
		{
			this.blockWidth = width;
			this.blockHeight = height;
			this.offsetX = -width * 1.5;
			this.offsetY = 0;
			normal = new Vector.<BitmapData>(frameMax);
			toSplit = new Vector.<BitmapData>(frameMax);
			for (var i:int = 0; i < frameMax; i++)
			{
				var n:BitmapData = new BitmapData(blockWidth * 4, blockHeight, true, 0);
				drawShockWaveGraphics(n, 3, Color.skyblue, i);
				normal[i] = n;
				var ts:BitmapData = new BitmapData(blockWidth * 4, blockHeight, true, 0);
				drawShockWaveGraphics(ts, 6, Color.orange, i);
				toSplit[i] = ts;
			}
		}
		
		private function drawShockWaveGraphics(bitmap:BitmapData, thickness:int, color:uint, frame:int):void
		{
			var shape:Shape = new Shape();
			var grf:Graphics = shape.graphics;
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(blockWidth * 3, blockHeight, Math.PI / 2, 0, 0);
			grf.lineStyle(thickness);
			grf.lineGradientStyle(GradientType.LINEAR, [color, Color.white, color], [1, 1, 1], [0, 128, 255], matrix);
			var a:Number = blockWidth * (frame / frameMax);
			var b:Number = blockWidth * 0.5;
			var cx:Number = blockWidth * 2;
			grf.moveTo(cx - a, blockHeight * 0);
			grf.lineTo(cx - a - b, blockHeight * 0.5);
			grf.lineTo(cx - a, blockHeight * 1);
			grf.moveTo(cx + a, blockHeight * 0);
			grf.lineTo(cx + a + b, blockHeight * 0.5);
			grf.lineTo(cx + a, blockHeight * 1);
			bitmap.draw(shape);
		}
		
	}

}