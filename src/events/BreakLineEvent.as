package events {
	import flash.events.Event;
	/**
	 * ...
	 * @author B_head
	 */
	public class BreakLineEvent extends GameEvent
	{
		[Bindable]
		public var combo:int;
		public var position:int;
		public var colors:Vector.<uint>;
		
		public static const breakLine:String = "breakLine";
		public static const sectionBreakLine:String = "sectionBreakLine";
		public static const totalBreakLine:String = "totalBreakLine";
		
		public function BreakLineEvent(type:String, gameTime:int, plusScore:int, combo:int, position:int, colors:Vector.<uint>) 
		{ 
			super(type, gameTime, plusScore);
			this.combo = combo;
			this.position = position;
			this.colors = colors;
		} 
		
		public override function clone():Event 
		{ 
			return new BreakLineEvent(type, gameTime, plusScore, combo, position, colors)
		}
	}

}