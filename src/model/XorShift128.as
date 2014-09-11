package model 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author B_head
	 */
	public class XorShift128 
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
		
		public function fromByteArray(value:ByteArray):void
		{
			value.position = 0;
			value.length = 16;
			a = value.readUnsignedInt();
			b = value.readUnsignedInt();
			c = value.readUnsignedInt();
			d = value.readUnsignedInt();
		}
		
		public function toByteArray():ByteArray
		{
			var ret:ByteArray = new ByteArray();
			ret.writeUnsignedInt(a);
			ret.writeUnsignedInt(b);
			ret.writeUnsignedInt(c);
			ret.writeUnsignedInt(d);
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
	}

}