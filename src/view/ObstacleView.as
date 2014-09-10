package view 
{
	import flash.accessibility.ISearchableText;
	import spark.components.BorderContainer;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class ObstacleView extends BorderContainer 
	{
		private var parts:Vector.<ObstacleViewParts>;
		private var _blockGraphics:BlockGraphics;
		
		public function ObstacleView() 
		{
			parts = new Vector.<ObstacleViewParts>(4);
			for (var i:int = 0; i < 4; i++)
			{
				parts[i] = new ObstacleViewParts();
				addElementAt(parts[i], 0);
			}
		}
		
		public function get blockGraphics():BlockGraphics
		{
			return _blockGraphics;
		}
		public function set blockGraphics(value:BlockGraphics):void
		{
			_blockGraphics = value;
			parts[0].blockGraphic = value.obstacleOne;
			parts[1].blockGraphic = value.obstacleTen;
			parts[2].blockGraphic = value.obstacleHundred;
			parts[3].blockGraphic = value.obstacleThousand;
		}
		
		public function update(notice:int, noticeSave:int):void
		{
			var n:int = notice + noticeSave;
			visible = n > 0
			if (n > 9999)
			{
				n = 9999;
			}
			var f:int = setCounts(n);
			var s:int = f - 1;
			setScales(f);
			parts[f].x = (width - parts[f].width) / 2;
			parts[f].y = (height - parts[f].height) / (n % Math.pow(10, f) == 0 ? 2 : 4);
			setY(f, s);
			setX(s);
		}
		
		private function setCounts(n:int):int
		{
			var f:int = 0;
			for (var i:int = 0; i < 4; i++)
			{
				if (n != 0) f = i;
				parts[i].update(n % 10);
				n /= 10;
			}
			return f;
		}
		
		private function setScales(f:int):void
		{
			var scale:Number = 1;
			for (var i:int = f; i >= 0; i--)
			{
				parts[i].scaleX = scale;
				parts[i].scaleY = scale;
				scale /= 2;
			}
		}
		
		private function setY(f:int, s:int):void
		{
			var y:Number = parts[f].y + parts[f].height;
			for (var i:int = s; i >= 0; i--)
			{
				parts[i].y = y;
				y += parts[i].height / 2;
			}
		}
		
		private function setX(s:int):void
		{
			var sWidth:Number = sumWidth(s);
			var x:Number = (width - sWidth) / 2;
			for (var i:int = s; i >= 0; i--)
			{
				parts[i].x = x;
				x += parts[i].width;
			}
		}
		
		private function sumWidth(s:int):Number
		{
			var sum:Number = 0;
			for (var i:int = s; i >= 0; i--)
			{
				sum += parts[i].width;
			}
			return sum;
		}
	}

}