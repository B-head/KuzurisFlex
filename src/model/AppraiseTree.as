package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class AppraiseTree 
	{
		public var way:ControlWay;
		public var next:Vector.<AppraiseTree>;
		public var marks:Number;
		
		public function AppraiseTree(way:ControlWay) 
		{
			this.way = way;
		}
		
		public function isExistNext():Boolean
		{
			return next != null;
		}
		
		public function createNext(width:int):void
		{
			next = new Vector.<AppraiseTree>(width * 4);
			for (var lx:int = 0; lx < width; lx++)
			{
				for (var dir:int = 0; dir < 4; dir++)
				{
					var w:ControlWay = new ControlWay();
					w.lx = lx;
					w.dir = dir;
					next[lx * 4 + dir] = new AppraiseTree(w);
				}
			}
		}
		
		public function getMaxs():Vector.<AppraiseTree>
		{
			var m:Number = next[0].marks;
			for (var i:int = 1; i < next.length; i++)
			{
				if (m < next[i].marks)
				{
					m = next[i].marks;
				}
			}
			return next.filter(function (item:AppraiseTree, index:int, vector:Vector.<AppraiseTree>):Boolean { return item.marks == m; } );
		}
	}

}