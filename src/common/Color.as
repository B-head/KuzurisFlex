package common {
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.IBitmapDrawable;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author B_head
	 */
	public final class Color 
	{
		public static const red:uint = rgb(255, 40, 0);
		public static const yellow:uint = rgb(250, 245, 0);
		public static const green:uint = rgb(53, 161, 107);
		public static const blue:uint = rgb(0, 65, 255);
		public static const skyblue:uint = rgb(102, 204, 255);
		public static const pink:uint = rgb(255, 153, 160);
		public static const orange:uint = rgb(255, 153, 0);
		public static const purple:uint = rgb(154, 0, 121);
		public static const brown:uint = rgb(102, 51, 0);
		
		public static const lightpink:uint = rgb(255, 209, 209);
		public static const cream:uint = rgb(255, 255, 153);
		public static const lightpeagreen:uint = rgb(203, 242, 102);
		public static const lightskyblue:uint = rgb(180, 235, 250);
		public static const beige:uint = rgb(237, 197, 143);
		public static const lightgreen:uint = rgb(135, 231, 176);
		public static const lightpurple:uint = rgb(199, 178, 222);
		
		public static const white:uint = rgb(255, 255, 255);
		public static const lightgray:uint = rgb(200, 200, 203);
		public static const gray:uint = rgb(127, 135, 143);
		public static const black:uint = rgb(0, 0, 0);
		
		private static const indexArray:Array = [
			red, yellow, green, blue, skyblue, pink, orange, purple, brown,
			lightpink, cream, lightpeagreen, lightskyblue, beige, lightgreen, lightpurple,
			white, lightgray, gray, black
		];
		
		public static function toColor(index:int):uint
		{
			return indexArray[index];
		}
		
		public static function toIndex(color:uint):int
		{
			return indexArray.indexOf(color);
		}
		
		public static function rgb(r:uint, g:uint, b:uint):uint
		{
			r = r % 256 * 0x10000;
			g = g % 256 * 0x100;
			b = b % 256 * 0x1;
			return r + g + b + 0xFF000000;
		}
		
		public static function brightnessTransform(color:uint, brightness:Number):uint
		{
			var r:int = (color & 0x00FF0000) >> 16;
			var g:int = (color & 0x0000FF00) >> 8;
			var b:int = (color & 0x000000FF) >> 0;
			if (brightness > 0)
			{
				r += (255 - r) * brightness;
				g += (255 - g) * brightness;
				b += (255 - b) * brightness;
			}
			else
			{
				var a:Number = 1 - brightness;
				r *= a;
				g *= a;
				b *= a;
			}
			return rgb(r, g, b);
		}
		
		public static function makeTransform(color:uint):ColorTransform
		{
			var colorTransform:ColorTransform = new ColorTransform();
            colorTransform.redOffset = ((color & 0x00FF0000) >> 16) - 0x80;
            colorTransform.greenOffset = ((color & 0x0000FF00) >> 8) - 0x80;
            colorTransform.blueOffset = (color & 0x000000FF) - 0x80;
            colorTransform.alphaMultiplier = ((color & 0xFF000000) >> 24);
			return colorTransform;
		}
		
		public static function coloring(drawable:IBitmapDrawable, width:int, height:int, color:uint):BitmapData
		{
			var data:BitmapData = new BitmapData(width, height, true, color);
			data.draw(drawable, null, null, BlendMode.HARDLIGHT);
			data.draw(drawable, null, null, BlendMode.ALPHA);
			return data;
		}
	}

}