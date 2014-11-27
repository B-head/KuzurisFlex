package view 
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import model.Color;
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
		
		public static const frameMax:int = 30;
		
		public function ShockEffectGraphics(width:Number, height:Number) 
		{
			this.blockWidth = width;
			this.blockHeight = height;
			normal = new Vector.<BitmapData>(frameMax);
			toSplit = new Vector.<BitmapData>(frameMax);
			for (var i:int = 0; i < frameMax; i++)
			{
				var n:BitmapData = new BitmapData(blockWidth * 2, blockHeight * 2, true, 0);
				drawGraphics(n, 1, Color.skyblue, i);
				normal[i] = n;
				var ts:BitmapData = new BitmapData(blockWidth * 2, blockHeight * 2, true, 0);
				drawGraphics(ts, 3, Color.orange, i);
				toSplit[i] = ts;
			}
		}
		
		private function drawGraphics(bitmap:BitmapData, thickness:int, color:uint, frame:int):void
		{
			var shape:Shape = new Shape();
			var grf:Graphics = shape.graphics;
			grf.lineStyle(thickness, color);
			var x:Number = blockWidth / 2 * (2 - frame / frameMax);
			var y:Number = blockHeight / 2 * (2 - frame / frameMax);
			var w:Number = blockWidth * (0 + frame / frameMax);
			var h:Number = blockHeight * (0 + frame / frameMax);
			grf.drawRect(x, y, w, h);
			bitmap.draw(shape);
		}
		
	}

}