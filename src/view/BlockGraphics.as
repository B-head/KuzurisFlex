package view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import model.Color;
	import spark.components.supportClasses.Skin;
	
	/**
	 * ...
	 * @author B_head
	 */
	public dynamic class BlockGraphics
	{
		[Embed(source='../graphic/block/0.png')]
		private var Block0:Class;
		[Embed(source='../graphic/block/1.png')]
		private var Block1:Class;
		[Embed(source='../graphic/block/2.png')]
		private var Block2:Class;
		[Embed(source='../graphic/block/3.png')]
		private var Block3:Class;
		[Embed(source='../graphic/block/4.png')]
		private var Block4:Class;
		[Embed(source='../graphic/block/5.png')]
		private var Block5:Class;
		[Embed(source='../graphic/block/6.png')]
		private var Block6:Class;
		[Embed(source='../graphic/block/7.png')]
		private var Block7:Class;
		[Embed(source='../graphic/block/8.png')]
		private var Block8:Class;
		[Embed(source='../graphic/block/9.png')]
		private var Block9:Class;
		[Embed(source='../graphic/block/10.png')]
		private var Block10:Class;
		
		public const blockLength:int = 11;
		public var blockWidth:int;
		public var blockHeight:int;
		
		public function BlockGraphics(blockWidth:int = 16, blockHeight:int = 16)
		{
			this.blockWidth = blockWidth;
			this.blockHeight = blockHeight;
			for (var i:int; i < 19; i++)
			{
				var blockColorSet:uint = indexToColor(i);
				this[blockColorSet] = new Vector.<BitmapData>(blockLength);
				for (var j:int = 0; j < blockLength; j++)
				{
					var bitmap:Bitmap = indexToBlock(j);
					var data:BitmapData = new BitmapData(blockWidth, blockHeight, false, blockColorSet);
					data.draw(bitmap, null, null, BlendMode.HARDLIGHT);
					this[blockColorSet][j] = data;
				}
			}
		}
		
		private function indexToColor(index:int):uint
		{
			switch (index)
			{
				case 0: 
					return Color.black;
				case 1: 
					return Color.gray;
				case 2: 
					return Color.lightgray;
				case 3: 
					return Color.white;
				case 4: 
					return Color.red;
				case 5: 
					return Color.yellow;
				case 6: 
					return Color.green;
				case 7: 
					return Color.blue;
				case 8: 
					return Color.skyblue;
				case 9: 
					return Color.pink;
				case 10: 
					return Color.orange;
				case 11: 
					return Color.purple;
				case 12: 
					return Color.brown;
				case 13: 
					return Color.cream;
				case 14: 
					return Color.lightgreen;
				case 15: 
					return Color.lightskyblue;
				case 16: 
					return Color.lightpink;
				case 17: 
					return Color.beige;
				case 18: 
					return Color.lightpeagreen;
				case 19: 
					return Color.lightpurple;
				default: 
					throw new Error();
			}
		}
		
		public function indexToBlock(index:int):Bitmap
		{
			switch (index)
			{
				case 0: 
					return new Block0();
				case 1: 
					return new Block1();
				case 2: 
					return new Block2();
				case 3: 
					return new Block3();
				case 4: 
					return new Block4();
				case 5: 
					return new Block5();
				case 6: 
					return new Block6();
				case 7: 
					return new Block7();
				case 8: 
					return new Block8();
				case 9: 
					return new Block9();
				case 10: 
					return new Block10();
				default: 
					throw new Error();
			}
		}
	
	}

}