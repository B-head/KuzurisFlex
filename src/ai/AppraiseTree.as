package ai {
	/**
	 * ...
	 * @author B_head
	 */
	public class AppraiseTree 
	{
		public var firstWay:ControlWay;
		public var secondWay:ControlWay;
		public var fr:ForwardResult;
		public var marks:Number;
		public var next:Vector.<AppraiseTree>;
		
		public function AppraiseTree(firstWay:ControlWay = null, secondWay:ControlWay = null, fr:ForwardResult = null, marks:Number = 0) 
		{
			this.firstWay = firstWay;
			this.secondWay = secondWay;
			this.fr = fr;
			this.marks = marks;
			next = new Vector.<AppraiseTree>();
		}
		
		public function isExistNext():Boolean
		{
			return next != null;
		}
		
		public function getChoices(border:Number):Vector.<AppraiseTree>
		{
			if (next.length == 0) return new Vector.<AppraiseTree>();
			var max:Number = next[0].marks;
			for (var i:int = 1; i < next.length; i++)
			{
				if (max < next[i].marks) max = next[i].marks;
			}
			var min:Number = next[0].marks;
			for (i = 1; i < next.length; i++)
			{
				if (min > next[i].marks) min = next[i].marks;
			}
			var sub:Number = max - min;
			var b:Number = max - sub * border;
			return next.filter(cond);
			
			function cond(item:AppraiseTree, index:int, vector:Vector.<AppraiseTree>):Boolean
			{
				return item.marks >= b ; 
			}
		}
	}

}