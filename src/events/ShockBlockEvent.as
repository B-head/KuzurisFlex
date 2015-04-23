package events {
	import flash.events.Event;
	import model.BlockState;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class ShockBlockEvent extends GameEvent
	{
		public var damage:Number;
		public var coefficient:Number;
		public var distance:int;
		public var id:uint;
		public var toSplit:Boolean;
		
		public static const shockDamage:String = "shockDamage";
		public static const sectionDamage:String = "sectionDamage";
		public static const totalDamage:String = "totalDamage";
		
		public function ShockBlockEvent(type:String, gameTime:int, plusScore:int, damage:Number, coefficient:Number = Number.NaN, distance:int = 0, id:uint = 0, toSplit:Boolean = false) 
		{
			super(type, gameTime, plusScore);
			this.damage = damage;
			this.coefficient = coefficient;
			this.distance = distance;
			this.id = id;
			this.toSplit = toSplit;
		}
		
		public override function clone():Event 
		{ 
			return new ShockBlockEvent(type, gameTime, plusScore, damage, coefficient, distance, id, toSplit);
		} 
	}
	
}