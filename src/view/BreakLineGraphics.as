package view 
{
	import flash.display.*;
	import flash.geom.Matrix;
	import mx.collections.ArrayCollection;
	/**
	 * ...
	 * @author B_head
	 */
	public dynamic class BreakLineGraphics extends ArrayCollection
	{
		
		public function BreakLineGraphics() 
		{
			super(new Array());
			for (var i:int = 0; i < 20; i++)
			{
				var color:uint = indexToColor(i);
				addItem(new ArrayCollection(new Array()));
				for (var j:int = 0; j < 15; j++)
				{
					var shape:Shape = new Shape();
					var grf:Graphics = shape.graphics;
					var matrix:Matrix = new Matrix();
					var w:int = 160 * (15 - j) / 15;
					matrix.createGradientBox(80, 16, 0, w - 120, 0);
					grf.beginGradientFill(GradientType.LINEAR, [color, color, color], [0, 1, 0], [0, 127, 255], matrix);
					grf.drawRect(0, 0, 160, 16);
					grf.endFill();
					matrix.createGradientBox(80, 16, 0, 200 - w, 0);
					grf.beginGradientFill(GradientType.LINEAR, [color, color, color], [0, 1, 0], [0, 127, 255], matrix);
					grf.drawRect(0, 0, 160, 16);
					grf.endFill();
					this[i].addItem(shape);
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