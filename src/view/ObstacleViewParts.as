package view 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import mx.core.UIComponent;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class ObstacleViewParts extends UIComponent
	{
		private var blocks:Vector.<Bitmap>;
		private var _blockGraphic:BitmapData;
		private var _count:int;
		
		public function ObstacleViewParts() 
		{
			blocks = new Vector.<Bitmap>(9);
			for (var i:int = 0; i < 9; i++)
			{
				blocks[i] = new Bitmap();
				addChild(blocks[i]);
			}
		}
		
		public function get blockGraphic():BitmapData
		{
			return _blockGraphic;
		}
		public function set blockGraphic(value:BitmapData):void
		{
			_blockGraphic = value;
			for (var i:int = 0; i < 9; i++)
			{
				blocks[i].bitmapData = value;
				blocks[i].x = value.width * i;
			}
		}
		
		public function update(count:int):void
		{
			_count = count; 
			for (var i:int = 0; i < 9; i++)
			{
				blocks[i].visible = i < count;
			}
		}
		
		override public function get width():Number 
		{
			if (_blockGraphic == null) return 0;
			return _blockGraphic.width * _count * scaleX;
		}
		override public function set width(value:Number):void 
		{
			return;
		}
		
		override public function get height():Number 
		{
			if (_blockGraphic == null) return 0;
			return _blockGraphic.height * scaleY;
		}
		override public function set height(value:Number):void 
		{
			return;
		}
	}

}