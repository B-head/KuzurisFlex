package presentation {
	import events.ShockBlockEvent;
	import flash.utils.Dictionary;
	import model.BlockState;
	import model.GameModel;
	/**
	 * ...
	 * @author B_head
	 */
	public class ShockEffectHelper 
	{
		private var _gameModel:GameModel;
		private var shockDictionary:Dictionary;
		
		public function ShockEffectHelper() 
		{
			shockDictionary = new Dictionary();
		}
		
		public function get gameModel():GameModel
		{
			return _gameModel;
		}
		public function set gameModel(value:GameModel):void
		{
			_gameModel = value;
			_gameModel.addTerget(ShockBlockEvent.shockDamage, shockBlockListener);
			shockDictionary = new Dictionary();
		}
		
		private function shockBlockListener(e:ShockBlockEvent):void
		{
			if (shockDictionary[e.id] == undefined)
			{
				var n:Vector.<ShockEffectState> = new Vector.<ShockEffectState>();
				n.push(new ShockEffectState(e));
				shockDictionary[e.id] = n;
			}
			else
			{
				var v:Vector.<ShockEffectState> = shockDictionary[e.id];
				var s:ShockEffectState = findState(v, e.gameTime);
				if (s == null)
				{
					s = new ShockEffectState(e);
					v.push(s);
				}
				else
				{
					s.damage += e.damage;
					s.distance = Math.min(s.distance, e.distance);
					if (e.toSplit == true) s.toSplit = true;
				}
			}
		}
		
		public function incrementFrame():void
		{
			for (var s:String in shockDictionary)
			{
				var v:Vector.<ShockEffectState> = shockDictionary[s];
				for (var i:int = 0; i < v.length; i++)
				{
					v[i].frameCount++;
					if (v[i].isEndEffect())
					{
						v.splice(i--, 1);
					}
				}
			}
		}
		
		public function getEffectState(id:uint):Vector.<ShockEffectState>
		{
			return shockDictionary[id];
		}
		
		public function getDamageRest(id:uint):Number
		{
			var v:Vector.<ShockEffectState> = shockDictionary[id];
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