package presentation {
	import events.ShockBlockEvent;
	import model.GameSetting;
	/**
	 * ...
	 * @author B_head
	 */
	public class ShockEffectState 
	{
		public var gameTime:int;
		public var damage:Number;
		public var distance:int;
		public var toSplit:Boolean;
		public var frameCount:int;
		public var fireworksDirection:Number;
		
		public function ShockEffectState(e:ShockBlockEvent) 
		{
			gameTime = e.gameTime;
			damage = e.damage;
			distance = e.distance;
			toSplit = e.toSplit;
			frameCount = 0;
			fireworksDirection = int(Math.random() * 4) * 90;
		}
		
		public function getShockWaveFrame():int
		{
			return Math.min(ShockEffectGraphics.frameMax - 1, reviseFrame());
		}
		
		public function getFireworksFrame():int
		{
			return Math.min(ShockEffectGraphics.frameMax - 1, frameCount);
		}
		
		public function getDamageRest():Number
		{
			var a:Number = 1 - Math.min(1, frameCount / ShockEffectGraphics.frameMax);
			return damage * a;
		}
		
		public function getDamagePower():Number
		{
			return damage / GameSetting.hitPointMax;
		}
		
		public function isEndEffect():Boolean
		{
			return reviseFrame() >= ShockEffectGraphics.frameMax;
		}
		
		public function isShockWaveVisible():Boolean
		{
			var a:Number = Math.min(1, damage / GameSetting.hitPointMax);
			return frameCount >= delayFrame() && reviseFrame() < ShockEffectGraphics.frameMax * a;
		}
		public function isFireworksVisible():Boolean
		{
			if (!toSplit) return false;
			return frameCount < ShockEffectGraphics.frameMax;
		}
		
		private function delayFrame():int
		{
			return distance * 3;
		}
		
		private function reviseFrame():int
		{
			return frameCount - delayFrame();
		}
	}

}