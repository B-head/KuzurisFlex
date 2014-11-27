package view 
{
	import flash.display.*;
	import flash.geom.Matrix;
	import model.*;
	import mx.graphics.*;
	import spark.components.*;
	import spark.effects.*;
	
	/**
	 * ...
	 * @author B_head
	 */
	//TODO 桁の変わる更新があった時に表示がズレるバグを修正する。
	public class ObstacleView extends BorderContainer 
	{
		[Embed(source='../graphic/obs1.png')]
		private var Obs1:Class;
		[Embed(source='../graphic/obs10.png')]
		private var Obs10:Class;
		[Embed(source='../graphic/obs100.png')]
		private var Obs100:Class;
		[Embed(source='../graphic/obs1000.png')]
		private var Obs1000:Class;
		
		[Bindable]
		public var obstacleManager:ObstacleManager;
		private var blocks:Vector.<Image>;
		private var moveEffects:Vector.<Move>;
		private var lastNotice:int;
		private const duration:Number = 1000 * 8 / 60;
		
		private var obstacleOne:BitmapData;
		private var obstacleTen:BitmapData;
		private var obstacleHundred:BitmapData;
		private var obstacleThousand:BitmapData;
		
		public function ObstacleView() 
		{ 
			blocks = new Vector.<Image>();
			moveEffects = new Vector.<Move>();
			blockScale = 1;
		}
		
		public function set blockScale(value:Number):void
		{
			obstacleOne = coloring(new Obs1(), Color.brown, value);
			obstacleTen = coloring(new Obs10(), Color.lightgray, value);
			obstacleHundred = coloring(new Obs100(), Color.yellow, value);
			obstacleThousand = coloring(new Obs1000(), Color.purple, value);
		}
		
		private function coloring(bitmap:Bitmap, color:uint, blockScale:Number):BitmapData
		{
			var matrix:Matrix = new Matrix();
			matrix.createBox(blockScale, blockScale);
			var data:BitmapData = new BitmapData(bitmap.width * blockScale, bitmap.height * blockScale, true, color);
			data.draw(bitmap, matrix, null, BlendMode.HARDLIGHT);
			data.draw(bitmap, matrix, null, BlendMode.ALPHA);
			return data;
		}
		
		public function update():void
		{
			var n:int = obstacleManager.noticeSaveCount;
			visible = n > 0;
			if (obstacleManager.noticeCount > 0)
			{
				if (obstacleManager.isActiveNotice())
				{
					borderStroke = new SolidColorStroke(Color.orange, 3);
				}
				else
				{
					borderStroke = new SolidColorStroke(Color.green, 2);
				}
			}
			else
			{
				borderStroke = new SolidColorStroke(Color.skyblue, 1);
			}
			if (lastNotice == n) return;
			lastNotice = n;
			setBitmaps(n);
			setXY(n);
			playEffect();
		}
		
		private function setBitmaps(n:int):void
		{
			for (var i:int = 0; i < blocks.length || n > 0; i++)
			{
				if (i >= blocks.length)
				{
					var b:Image = new Image();
					b.visible = false;
					blocks.push(b);
					addElementAt(b, 0);
					var m:Move = new Move(b);
					m.duration = duration;
					moveEffects.push(m);
				}
				if (n >= 1000)
				{
					blocks[i].source = obstacleThousand;
					n -= 1000;
				}
				else if (n >= 100)
				{
					blocks[i].source = obstacleHundred;
					n -= 100;
				}
				else if (n >= 10)
				{
					blocks[i].source = obstacleTen;
					n -= 10;
				}
				else if (n >= 1)
				{
					blocks[i].source = obstacleOne;
					n -= 1;
				}
				else
				{
					blocks[i].source = null;
					blocks[i].visible = false;
				}
			}
		}
		
		private function setXY(n:int):void
		{
			var sumW:Number = sumWidth();
			var stdY:Number = height / 2 + int(Math.log(n) * Math.LOG10E + 1) * obstacleOne.height / 2;
			var currentX:Number = Math.max(0, width - sumW) / 2;
			var offset:Number = Math.min(1, width / sumW);
			for (var i:int = 0; i < blocks.length; i++)
			{
				var source:BitmapData = blocks[i].source as BitmapData;
				if (source == null) continue;
				var y:Number = stdY - source.height;
				if (blocks[i].visible == false)
				{
					blocks[i].x = currentX;
					blocks[i].y = y;
					blocks[i].visible = true;
				}
				moveEffects[i].xFrom = blocks[i].x;
				moveEffects[i].yFrom = blocks[i].y;
				moveEffects[i].xTo = currentX;
				moveEffects[i].yTo = y;
				currentX += source.width * offset;
			}
		}
		
		private function sumWidth():Number
		{
			var ret:Number = 0;
			for (var i:int = 0; i < blocks.length; i++)
			{
				if (blocks[i].source == null) continue;
				ret += blocks[i].source.width;
			}
			return ret;
		}
		
		private function visibleCount():int
		{
			var ret:int = 0;
			for (var i:int = 0; i < blocks.length; i++)
			{
				if (blocks[i].visible == false) continue;
				ret++;
			}
			return ret;
		}
		
		private function playEffect():void
		{
			for (var i:int = 0; i < moveEffects.length; i++)
			{
				moveEffects[i].stop();
				moveEffects[i].play();
			}
		}
	}

}