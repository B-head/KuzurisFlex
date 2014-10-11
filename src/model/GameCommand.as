package model 
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	/**
	 * ...
	 * @author B_head
	 */
	public class GameCommand implements IExternalizable
	{
		public static const bitMask:int = 0x3;
		public static const bitShift:int = 2;
		public static const booleanMask:int = 0x1;
		public static const booleanShift:int = 1;
		public static const materializationLength:int = 8;
		
		public static const nothing:int = 0;
		public static const right:int = 1;
		public static const left:int = 2;
		public static const fast:int = 1;
		public static const earth:int = 2;
		
		public var rotation:int;
		public var move:int;
		public var falling:int;
		public var fix:Boolean;
		public var noDamege:Boolean;
		public var materialization:Vector.<Boolean>;
		
		public function GameCommand(materialization:Vector.<Boolean> = null)
		{
			this.materialization = materialization;
		}
		
		public function writeExternal(output:IDataOutput):void 
		{
			var value:uint = 0;
			value |= rotation & bitMask;
			value <<= bitShift;
			value |= move & bitMask;
			value <<= bitShift;
			value |= falling & bitMask;
			value <<= booleanShift;
			value |= uint(fix) & booleanMask;
			value <<= booleanShift;
			value |= uint(noDamege) & booleanMask;
			for (var i:int = 0; i < materializationLength; i++)
			{
				value <<= booleanShift;
				value |= uint(materialization[i]) & booleanMask;
			}
			output.writeShort(value);
		}
		
		public function readExternal(input:IDataInput):void 
		{
			var value:uint = input.readUnsignedShort();
			materialization = new Vector.<Boolean>(materializationLength);
			for (var i:int = materializationLength - 1; i >= 0; i--)
			{
				materialization[i] = Boolean(value & booleanMask);
				value >>>= booleanShift;
			}
			noDamege = Boolean(value & booleanMask);
			value >>>= booleanShift;
			fix = Boolean(value & booleanMask);
			value >>>= booleanShift;
			falling = value & bitMask;
			value >>>= bitShift;
			move = value & bitMask;
			value >>>= bitShift;
			rotation = value & bitMask;
		}
	}

}