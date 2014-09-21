package view 
{
	import flash.display.Bitmap;
	import flash.geom.ColorTransform;
	import model.BlockField;
	import mx.core.UIComponent;
	import mx.core.UIComponentCachePolicy;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class BlockFieldView extends UIComponent
	{
		private static const noTransform:ColorTransform = new ColorTransform();
		private static const whiteTransform:ColorTransform = new ColorTransform(0.5, 0.5, 0.5, 1, 128, 128, 128, 0);
		private static const blackTransform:ColorTransform = new ColorTransform(0.5, 0.5, 0.5, 1, 0, 0, 0, 0);
			
		public var blockGraphics:BlockGraphics;
		public var showSpecial:Boolean;
		
		private var sprites:Vector.<Bitmap>;
		
		public function BlockFieldView() 
		{
			super();
			spritesLength = 0;
		}
		
		public function set spritesLength(value:int):void
		{
			this.sprites = new Vector.<Bitmap>(value);
			for (var i:int = 0; i < value; i++)
			{
				var temp:Bitmap = new Bitmap();
				sprites[i] = temp;
				addChild(temp);
			}
		}
		
		public function update(field:BlockField, shockSave:Boolean):void
		{
			if (field == null)
			{
				for (var i:int = 0; i < sprites.length; i++)
				{
					sprites[i].visible = false;
				}
				return;
			}
			var w:int = field.width;
			var h:int = field.height;
			for (var x:int = 0; x < w; x++)
			{
				for (var y:int = 0; y < h; y++)
				{
					var temp:Bitmap = sprites[x * h + y];
					if (!field.isExistBlock(x, y))
					{
						temp.visible = false;
						continue;
					}
					var graphicIndex:int = Math.ceil(field.getHitPoint(x, y));
					graphicIndex = Math.max(graphicIndex, 0);
					graphicIndex = Math.min(graphicIndex, blockGraphics.blockLength - 1);
					var color:uint = field.getColor(x, y);
					var specialUnion:Boolean = field.getSpecialUnion(x, y);
					temp.visible = true;
					temp.bitmapData = blockGraphics[color][graphicIndex];
					temp.x = x * blockGraphics.blockWidth;
					temp.y = y * blockGraphics.blockHeight;
					if (showSpecial && specialUnion)
					{
						if (shockSave)
						{
							temp.transform.colorTransform = blackTransform;
						}
						else
						{
							temp.transform.colorTransform = whiteTransform;
						}
					}
					else
					{
						temp.transform.colorTransform = noTransform;
					}
				}
			}
		}
		
	}

}