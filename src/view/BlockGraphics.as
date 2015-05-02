package view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	import model.Color;
	import spark.components.supportClasses.Skin;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class BlockGraphics
	{
		public const blockLength:int = 11;
		public var split:Vector.<Vector.<BitmapData>>;
		public var union:Vector.<Vector.<BitmapData>>;
		public var ghost:Vector.<BitmapData>;
		public var nonBreak:Vector.<BitmapData>;
		public var jewel:Vector.<BitmapData>;
		[Bindable] 
		public var blockWidth:int;
		[Bindable] 
		public var blockHeight:int;
		
		public function BlockGraphics(blockWidth:int = 16, blockHeight:int = 16)
		{
			split = new Vector.<Vector.<BitmapData>>(19);
			union = new Vector.<Vector.<BitmapData>>(19);
			ghost = new Vector.<BitmapData>(19);
			nonBreak = new Vector.<BitmapData>(19);
			jewel = new Vector.<BitmapData>(19);
			this.blockWidth = blockWidth;
			this.blockHeight = blockHeight;
			for (var i:int; i < 19; i++)
			{
				split[i] = new Vector.<BitmapData>(blockLength);
				union[i] = new Vector.<BitmapData>(blockLength);
				for (var j:int = 0; j < blockLength; j++)
				{
					var s:Bitmap = indexToSplit(j);
					split[i][j] = coloring(s, Color.toColor(i));
					var u:Bitmap = indexToUnion(j);
					union[i][j] = coloring(u, Color.toColor(i));
				}
				var gh:Bitmap = new Ghost();
				ghost[i] = coloring(gh, Color.toColor(i));
				var nb:Bitmap = new NonBreak();
				nonBreak[i] = coloring(nb, Color.toColor(i));
				var je:Bitmap = new Jewel();
				jewel[i] = coloring(je, Color.toColor(i));
			}
		}
		
		private function coloring(bitmap:Bitmap, color:uint):BitmapData
		{
			var matrix:Matrix = new Matrix();
			matrix.createBox(blockWidth / bitmap.width, blockHeight / bitmap.height);
			var data:BitmapData = new BitmapData(blockWidth, blockHeight, true, color);
			data.draw(bitmap, matrix, null, BlendMode.HARDLIGHT);
			data.draw(bitmap, matrix, null, BlendMode.ALPHA);
			return data;
		}
		
		public function indexToSplit(index:int):Bitmap
		{
			switch (index)
			{
				case 0: return new Split0();
				case 1: return new Split1();
				case 2: return new Split2();
				case 3: return new Split3();
				case 4: return new Split4();
				case 5: return new Split5();
				case 6: return new Split6();
				case 7: return new Split7();
				case 8: return new Split8();
				case 9: return new Split9();
				case 10: return new Split10();
				default: throw new Error();
			}
		}
		
		public function indexToUnion(index:int):Bitmap
		{
			switch (index)
			{
				case 0: return new Union0();
				case 1: return new Union1();
				case 2: return new Union2();
				case 3: return new Union3();
				case 4: return new Union4();
				case 5: return new Union5();
				case 6: return new Union6();
				case 7: return new Union7();
				case 8: return new Union8();
				case 9: return new Union9();
				case 10: return new Union10();
				default: throw new Error();
			}
		}
		
		[Embed(source='../../graphic/block/split0.png')]
		private var Split0:Class;
		[Embed(source='../../graphic/block/split1.png')]
		private var Split1:Class;
		[Embed(source='../../graphic/block/split2.png')]
		private var Split2:Class;
		[Embed(source='../../graphic/block/split3.png')]
		private var Split3:Class;
		[Embed(source='../../graphic/block/split4.png')]
		private var Split4:Class;
		[Embed(source='../../graphic/block/split5.png')]
		private var Split5:Class;
		[Embed(source='../../graphic/block/split6.png')]
		private var Split6:Class;
		[Embed(source='../../graphic/block/split7.png')]
		private var Split7:Class;
		[Embed(source='../../graphic/block/split8.png')]
		private var Split8:Class;
		[Embed(source='../../graphic/block/split9.png')]
		private var Split9:Class;
		[Embed(source='../../graphic/block/split10.png')]
		private var Split10:Class;
		[Embed(source='../../graphic/block/union0.png')]
		private var Union0:Class;
		[Embed(source='../../graphic/block/union1.png')]
		private var Union1:Class;
		[Embed(source='../../graphic/block/union2.png')]
		private var Union2:Class;
		[Embed(source='../../graphic/block/union3.png')]
		private var Union3:Class;
		[Embed(source='../../graphic/block/union4.png')]
		private var Union4:Class;
		[Embed(source='../../graphic/block/union5.png')]
		private var Union5:Class;
		[Embed(source='../../graphic/block/union6.png')]
		private var Union6:Class;
		[Embed(source='../../graphic/block/union7.png')]
		private var Union7:Class;
		[Embed(source='../../graphic/block/union8.png')]
		private var Union8:Class;
		[Embed(source='../../graphic/block/union9.png')]
		private var Union9:Class;
		[Embed(source='../../graphic/block/union10.png')]
		private var Union10:Class;
		[Embed(source='../../graphic/block/ghost.png')]
		private var Ghost:Class;
		[Embed(source='../../graphic/block/non-break.png')]
		private var NonBreak:Class;
		[Embed(source='../../graphic/block/jewel.png')]
		private var Jewel:Class;
	
	}

}