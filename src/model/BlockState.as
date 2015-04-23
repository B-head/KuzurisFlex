package model 
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	/**
	 * ...
	 * @author B_head
	 */
	public final class BlockState implements IExternalizable
	{
		public static const empty:uint = 0;
		public static const normal:uint = 1;
		public static const nonBreak:uint = 2;
		public static const jewel:uint = 3;
		public static const strong:uint = 4;
		public static const float:uint = 5;
		public static const strongFloat:uint = 6;
		
		private static var nextId:uint = 0;
		
		public var type:uint;
		public var color:int;
		public var hitPoint:Number;
		public var specialUnion:Boolean;
		public var id:uint;
		
		public function BlockState(type:uint = 0, color:uint = 0, hitPoint:Number = 0, specialUnion:Boolean = false)
		{
			this.type = type;
			this.color = color;
			this.hitPoint = hitPoint;
			this.specialUnion = specialUnion;
		}
		
		public function setId():void
		{
			id = nextId++;
		}
		
		public function isEmpty():Boolean
		{
			return type == empty;
		}
		
		public function isNonBreak():Boolean
		{
			return type == empty || type == nonBreak;
		}
		
		public function hash():uint
		{
			var ret:uint = 0;
			ret ^= type;
			ret ^= color;
			ret ^= uint(hitPoint * 0x1000000);
			if (specialUnion) ret = ~ret;
			return ret;
		}
		
		public function writeExternal(output:IDataOutput):void 
		{
			output.writeUnsignedInt(type);
			output.writeUnsignedInt(color);
			output.writeDouble(hitPoint);
			output.writeBoolean(specialUnion);
		}
		
		public function readExternal(input:IDataInput):void 
		{
			type = input.readUnsignedInt();
			color = input.readUnsignedInt();
			hitPoint = input.readDouble();
			specialUnion = input.readBoolean();
			setId();
		}
	}
}