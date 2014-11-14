package model 
{
	import flash.geom.ColorTransform;
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
		
		public static function rgb(r:uint, g:uint, b:uint):uint
		{
			r = r % 256 * 0x10000;
			g = g % 256 * 0x100;
			b = b % 256 * 0x1;
			return r + g + b + 0xFF000000;
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
	}

}