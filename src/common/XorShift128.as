package common {
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	/**
	 * ...
	 * @author B_head
	 */
	public class XorShift128 implements IExternalizable
	{
		private var a:uint = 1;
		private var b:uint = 0;
		private var c:uint = 0;
		private var d:uint = 0;
		
		public function RandomSeed():void
		{
			do
			{
				a = Math.random() * 0x100000000;
				b = Math.random() * 0x100000000;
				c = Math.random() * 0x100000000;
				d = Math.random() * 0x100000000;
			}
			while ((a + b + c + d) == 0)
		}
		
		public function clone():XorShift128
		{
			var ret:XorShift128 = new XorShift128();
			ret.a = a;
			ret.b = b;
			ret.c = c;
			ret.d = d;
			return ret;
		}
		
		public function genUint():uint
		{
			next();
			return d;
		}
		
		public function genNumber():Number
		{
			next();
			return d / 0x100000000;
		}
		
		private function next():void
		{
			var tmp:uint = a ^ (a << 15);
			a = b; b = c; c = d;
			d = d ^ (d >>> 21) ^ tmp ^ (tmp >>> 4);
		}
		
		public function writeExternal(output:IDataOutput):void 
		{
			output.writeUnsignedInt(a);
			output.writeUnsignedInt(b);
			output.writeUnsignedInt(c);
			output.writeUnsignedInt(d);
		}
		
		public function readExternal(input:IDataInput):void 
		{
			a = input.readUnsignedInt();
			b = input.readUnsignedInt();
			c = input.readUnsignedInt();
			d = input.readUnsignedInt();
		}
	}

}