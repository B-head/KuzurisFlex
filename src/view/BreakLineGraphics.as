package view 
{
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	import mx.collections.ArrayCollection;
	/**
	 * ...
	 * @author B_head
	 */
	public class BreakLineGraphics
	{
		public var grfs:Vector.<Vector.<Shape>>;
		public var width:Number;
		public var height:Number;
		
		public static const frameMax:int = 30;
		
		public function BreakLineGraphics(width:Number = 160, height:Number = 16) 
		{
			grfs = new Vector.<Vector.<Shape>>(frameMax);
			this.width = width;
			this.height = height;
			for (var i:int = 0; i < frameMax; i++)
			{
				grfs[i] = new Vector.<Shape>(20);
				for (var c:int = 0; c <= 20; c++)
				{
					var color:uint = indexToColor(c);
					var shape:Shape = new Shape();
					var grf:Graphics = shape.graphics;
					var matrix:Matrix = new Matrix();
					var w:int = width * (frameMax - i) / frameMax;
					matrix.createGradientBox(width, height, 0, w - width, 0);
					grf.beginGradientFill(GradientType.LINEAR, [color, color, color], [0, 1, 0], [0, 127, 255], matrix);
					grf.drawRect(0, 0, width, height);
					grf.endFill();
					matrix.createGradientBox(width, height, 0, width - w, 0);
					grf.beginGradientFill(GradientType.LINEAR, [color, color, color], [0, 1, 0], [0, 127, 255], matrix);
					grf.drawRect(0, 0, width, height);
					grf.endFill();
					grfs[i][c] = shape;
				}
			}
		}
		
		private function indexToColor(index:int):uint
		{
			switch (index)
			{
				case 0: 
					return 0x000000;
				case 1: 
					return 0xFF0000;
				case 2: 
					return 0xFF5500;
				case 3: 
					return 0xFFAA00;
				case 4: 
					return 0xFFFF00;
				case 5: 
					return 0xAAFF00;
				case 6: 
					return 0x55FF00;
				case 7: 
					return 0x00FF00;
				case 8: 
					return 0x00FF55;
				case 9: 
					return 0x00FFAA;
				case 10: 
					return 0x00FFFF;
				case 11: 
					return 0x00AAFF;
				case 12: 
					return 0x0055FF;
				case 13: 
					return 0x0000FF;
				case 14: 
					return 0x5500FF;
				case 15: 
					return 0xAA00FF;
				case 16: 
					return 0xFF00FF;
				case 17: 
					return 0xFF44FF;
				case 18: 
					return 0xFF88FF;
				case 19: 
					return 0xFFBBFF;
				case 20: 
					return 0xFFFFFF;
				default: 
					throw new Error();
			}
		}
	}

}