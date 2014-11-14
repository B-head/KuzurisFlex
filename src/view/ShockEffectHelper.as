package view 
{
	import events.ShockBlockEvent;
	import flash.utils.Dictionary;
	import model.BlockState;
	/**
	 * ...
	 * @author B_head
	 */
	public class ShockEffectHelper 
	{
		private var shockDictionary:Dictionary;
		
		public function ShockEffectHelper() 
		{
			shockDictionary = new Dictionary();
		}
		
		public function registerShockBlockEvent(e:ShockBlockEvent):void
		{
			if (shockDictionary[e.oldState] == undefined)
			{
				var n:Vector.<ShockEffectState> = new Vector.<ShockEffectState>();
				n.push(new ShockEffectState(e));
				shockDictionary[e.newState] = n;
			}
			else
			{
				var v:Vector.<ShockEffectState> = shockDictionary[e.oldState];
				shockDictionary[e.newState] = v;
				delete shockDictionary[e.oldState];
				var s:ShockEffectState = findState(v, e.gameTime);
				if (s == null)
				{
					s = new ShockEffectState(e);
					v.push(s);
				}
				else
				{
					s.damage += e.damage;
					if (e.isToSplit() == true) s.toSplit = true;
				}
			}
		}
		
		public function getEffectState(state:BlockState):Vector.<ShockEffectState>
		{
			return shockDictionary[state];
		}
		
		public function getDamageRest(state:BlockState):Number
		{
			var v:Vector.<ShockEffectState> = shockDictionary[state];
			if (v == null) return 0;
			var ret:Number = 0;
			for (var i:int = 0; i < v.length; i++)
			{
				ret += v[i].getDamageRest();
			}
			return ret;
		}
		
		private function findState(vec:Vector.<ShockEffectState>, gameTime:int):ShockEffectState
		{
			for (var i:int = 0; i < vec.length; i++)
			{
				if (vec[i].gameTime == gameTime) return vec[i];
			}
			return null;
		}
	}

}