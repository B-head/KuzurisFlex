package view 
{
	import flash.accessibility.ISearchableText;
	import model.Color;
	import mx.graphics.SolidColorStroke;
	import spark.components.BorderContainer;
	import spark.effects.Move;
	import spark.effects.Scale;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class ObstacleView extends BorderContainer 
	{
		private var parts:Vector.<ObstacleViewParts>;
		private var moveEffects:Vector.<Move>;
		private var scaleEffects:Vector.<Scale>;
		private var _blockGraphics:BlockGraphics;
		
		public function ObstacleView() 
		{
			parts = new Vector.<ObstacleViewParts>(4);
			moveEffects = new Vector.<Move>(4);
			scaleEffects = new Vector.<Scale>(4);
			var duration:Number = 1000 * 4 / 60;
			for (var i:int = 0; i < 4; i++)
			{
				parts[i] = new ObstacleViewParts();
				moveEffects[i] = new Move(parts[i]);
				moveEffects[i].duration = duration;
				scaleEffects[i] = new Scale(parts[i]);
				scaleEffects[i].duration = duration;
				addElement(parts[i]);
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
			visible = n > 0;
			borderStroke = new SolidColorStroke(notice > 0 ? Color.orange : Color.green);
			if (n == 0)
			{
				reset();
				return;
			}
			if (n > 9999)
			{
				n = 9999;
			}
			var f:int = setCounts(n);
			var s:int = f - 1;
			setScales(f);
			moveEffects[f].xTo = (width - parts[f].width) / 2;
			moveEffects[f].yTo = (height - parts[f].height) / (n % Math.pow(10, f) == 0 ? 2 : 4);
			setY(f, s);
			setX(s);
			playEffect();
		}
		
		private function reset():void
		{
			for (var i:int = 0; i < 4; i++)
			{
				parts[i].x = 0;
				parts[i].y = height / 4;
				parts[i].scaleX = 1;
				parts[i].scaleY = 1;
			}
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
				scaleEffects[i].scaleXTo = scale;
				scaleEffects[i].scaleYTo = scale;
				scale /= 2;
			}
		}
		
		private function setY(f:int, s:int):void
		{
			var y:Number = parts[f].y + parts[f].height;
			for (var i:int = s; i >= 0; i--)
			{
				moveEffects[i].yTo = y;
				y += parts[i].height / 2;
			}
		}
		
		private function setX(s:int):void
		{
			var sWidth:Number = sumWidth(s);
			var x:Number = (width - sWidth) / 2;
			for (var i:int = s; i >= 0; i--)
			{
				moveEffects[i].xTo = x;
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
		
		private function playEffect():void
		{
			for (var i:int = 0; i < 4; i++)
			{
				moveEffects[i].stop();
				moveEffects[i].play();
				scaleEffects[i].stop();
				scaleEffects[i].play();
			}
		}
	}

}