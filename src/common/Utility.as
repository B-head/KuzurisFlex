package common {
	import flash.display.*;
	import flash.ui.*;
	import flash.utils.*;
	import model.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class Utility 
	{
		public static function global_trace(...args):void
		{
			trace.apply(null, args);
		}
		
		public static function makeSendHash(commandRecord:Vector.<GameCommand>, hashRecord:Vector.<uint>):uint
		{
			var ret:uint = 0;
			for (var i:int = 0; i < commandRecord.length; i++)
			{
				ret ^= commandRecord[i].toUInt();
			}
			for (var k:int = 0; k < hashRecord.length; k++)
			{
				ret ^= hashRecord[k];
			}
			return ret;
		}
		
		public static function makeKeyDictionary():Dictionary
		{
			var ret:Dictionary = new Dictionary();
			var kd:XML = describeType(Keyboard);
			var kn:XMLList = kd.constant.@name;
			var kl:int = kn.length();
			for (var i:int = 0; i < kl; i++)
			{
				var key:String = String(kn[i]);
				var str:String = key;
				switch (key)
				{
					case "UP":
						str = "↑";
						break;
					case "DOWN":
						str = "↓";
						break;
					case "LEFT":
						str = "←";
						break;
					case "RIGHT":
						str = "→";
						break;
				}
				ret[Keyboard[key]] = str;
			}
			return ret;
		}
		
		public static function rotate(disp:DisplayObject, rotation:Number, x:Number, y:Number):void 
		{
			var x1:Number, y1:Number;
			var rad1:Number = degreesToRadians(disp.rotation);
			x1 = x * Math.cos(rad1) - y * Math.sin(rad1);
			y1 = x * Math.sin(rad1) + y * Math.cos(rad1);

			var x2:Number, y2:Number;
			var rad2:Number = degreesToRadians(rotation);
			x2 = x * Math.cos(rad2) - y * Math.sin(rad2);
			y2 = x * Math.sin(rad2) + y * Math.cos(rad2);

			disp.rotation = rotation;
			disp.x += x1 - x2;
			disp.y += y1 - y2;
		}

		public static function degreesToRadians(degrees:Number):Number 
		{
			return (degrees/180) * Math.PI;
		}
		
		public static function summation(a:Number):Number
		{
			return a * (a + 1) / 2;
		}
		
		public static function toArray(list:*):Array
		{
			if (list == null) return null;
			var arr:Array = new Array(list.length);
			for (var i:int = 0; i < list.length; i++)
			{
				arr[i] = list[i];
			}
			return arr;
		}
		
		public static function max(list:*):Number
		{
			return Math.max.apply(null, toArray(list));
		}
		
		public static function min(list:*):Number
		{
			return Math.min.apply(null, toArray(list));
		}
		
		public static function sum(list:*):Number
		{
			var ret:Number = 0;
			for (var i:int = 0; i < list.length; i++)
			{
				ret += list[i];
			}
			return ret
		}
		
		public static function copyTo(from:*, to:*, startIndex:uint):void
		{
			for (var i:int = 0; i < from.length; i++)
			{
				to[startIndex + i] = from[i];
			}
		}
		
		public static function insert(list:*, index:int, ...items):void
		{
			items.unshift(index, 0);
			list.splice.apply(null, items);
		}
		
		public static function remove(list:*, item:*):void
		{
			var index:int = list.indexOf(item);
			while (index != -1)
			{
				list.splice(index, 1);
				index = list.indexOf(item, index);
			}
		}
		
		public static function any(list:*, cond:Function):Boolean
		{
			return list.every(toCond(cond));
		}
		
		public static function all(list:*, cond:Function):Boolean
		{
			return list.some(toCond(cond));
		}
		
		public static function filter(list:*, cond:Function):*
		{
			return list.filter(toCond(cond));
		}
		
		public static function count(list:*, cond:Function):int
		{
			var ret:int = 0;
			for (var i:int = 0; i < list.length; i++)
			{
				if (cond(list[i])) ret++;
			}
			return ret;
		}
		
		public static function first(list:*, cond:Function, fromIndex:int = 0):int
		{
			if (fromIndex < 0) fromIndex = list.length - fromIndex;
			for (var i:int = fromIndex; i < list.length; i++)
			{
				if (cond(list[i])) return i;
			}
			return -1;
		}
		
		public static function last(list:*, cond:Function, fromIndex:int = int.MAX_VALUE):int
		{
			if (fromIndex < 0) fromIndex = list.length - fromIndex;
			fromIndex = Math.min(fromIndex, list.length - 1);
			for (var i:int = fromIndex; i >= 0; i--)
			{
				if (cond(list[i])) return i;
			}
			return -1;
		}
		
		public static function toCond(cond:Function):Function
		{
			return function (item:*, index:int, list:*):Boolean { return cond(item); };
		}
	}

}