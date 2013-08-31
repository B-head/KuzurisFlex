package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public final class BlockState 
	{
		public var hitPoint:Number;
		public var color:uint;
		public var specialUnion:Boolean;
		
		public function BlockState(hitPoint:Number = 0, color:uint = 0, specialUnion:Boolean = false)
		{
			this.hitPoint = hitPoint;
			this.color = color;
			this.specialUnion = specialUnion;
		}
		
		public function clone():BlockState
		{
			return new BlockState(hitPoint, color, specialUnion);
		}
	}
}