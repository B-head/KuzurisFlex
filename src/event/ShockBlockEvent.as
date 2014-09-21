package event 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class ShockBlockEvent extends GameEvent
	{
		[Bindable] 
		public var damage:Number;
		[Bindable] 
		public var total:Number;
		public var coefficient:Number;
		public var x:int;
		public var y:int;
		
		public static const shockDamage:String = "shockDamage";
		public static const sectionDamage:String = "sectionDamage";
		public static const totalDamage:String = "totalDamage";
		
		public function ShockBlockEvent(type:String, gameTime:int, plusScore:int, damage:Number, total:Number, coefficient:Number, x:int, y:int) 
		{
			super(type, gameTime, plusScore);
			this.damage = damage;
			this.total = total;
			this.coefficient = coefficient;
			this.x = x;
			this.y = y;
		}
		
		public override function clone():Event 
		{ 
			return new ShockBlockEvent(type, gameTime, plusScore, damage, total, coefficient, x, y);
		} 
	}
	
}