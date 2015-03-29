package view 
{
	import events.ShockBlockEvent;
	/**
	 * ...
	 * @author B_head
	 */
	public class ShockEffectState 
	{
		public var gameTime:int;
		public var damage:Number;
		public var toSplit:Boolean;
		public var frameCount:int;
		
		public static const hitPointMax:Number = 10;
		
		public function ShockEffectState(e:ShockBlockEvent) 
		{
			gameTime = e.gameTime;
			damage = e.damage;
			toSplit = e.toSplit;
			frameCount = 0;
		}
		
		public function getReviseFrame():int
		{
			var a:Number = Math.min(1, damage / hitPointMax);
			return frameCount * a;
		}
		
		public function getDamageRest():Number
		{
			var a:Number = 1 - frameCount / ShockEffectGraphics.frameMax;
			return damage * a;
		}
		
		public function isEndEffect():Boolean
		{
			return frameCount >= ShockEffectGraphics.frameMax;
		}
		
		public function isNonVisible():Boolean
		{
			return !toSplit && damage < 1;
		}
	}

}