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
		public static const normal:uint = 0;
		public static const unbreak:uint = 1;
		public static const strong:uint = 2;
		public static const float:uint = 3;
		public static const strongFloat:uint = 4;
		
		public var type:uint;
		public var color:uint;
		public var hitPoint:Number;
		public var specialUnion:Boolean;
		
		public function BlockState(type:uint = 0, color:uint = 0, hitPoint:Number = 0, specialUnion:Boolean = false)
		{
			this.type = type;
			this.color = color;
			this.hitPoint = hitPoint;
			this.specialUnion = specialUnion;
		}
		
		public function clone():BlockState
		{
			return new BlockState(type, color, hitPoint, specialUnion);
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
		}
	}
}