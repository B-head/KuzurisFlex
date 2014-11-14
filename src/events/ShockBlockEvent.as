package events {
	import flash.events.Event;
	import model.BlockState;
	
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
		public var newState:BlockState;
		public var oldState:BlockState;
		
		public static const shockDamage:String = "shockDamage";
		public static const sectionDamage:String = "sectionDamage";
		public static const totalDamage:String = "totalDamage";
		public static const clearSpecialUnion:String = "clearSpecialUnion";
		
		public function ShockBlockEvent(type:String, gameTime:int, plusScore:int, damage:Number, total:Number, coefficient:Number = Number.NaN, newState:BlockState = null, oldState:BlockState = null) 
		{
			super(type, gameTime, plusScore);
			this.damage = damage;
			this.total = total;
			this.coefficient = coefficient;
			this.newState = newState;
			this.oldState = oldState;
		}
		
		public override function clone():Event 
		{ 
			return new ShockBlockEvent(type, gameTime, plusScore, damage, total, coefficient, newState, oldState);
		} 
		
		public function isToSplit():Boolean
		{
			return newState.hitPoint <= 0 && oldState.hitPoint > 0;
		}
	}
	
}