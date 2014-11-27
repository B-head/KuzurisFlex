package view 
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import mx.core.UIComponent;
	/**
	 * ...
	 * @author B_head
	 */
	public class BackGroundMugic extends UIComponent
	{
		private var mugic:Sound;
		private var mugicChannel:SoundChannel
		private var position:int;
		
		public function BackGroundMugic() 
		{
			mugic = new Sound(new URLRequest("./tetris-tribe.mp3"));
		}
		
		public function play(continuation:Boolean):void
		{
			if (mugicChannel != null)
			{
				stop();
			}
			if (!continuation) position = 0;
			mugicChannel = mugic.play(position);
			mugicChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}
		
		public function stop():void
		{
			if (mugicChannel == null) return;
			mugicChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			position = mugicChannel.position;
			mugicChannel.stop();
			mugicChannel = null;
		}
		
		private function onSoundComplete(e:Event):void
		{
			play(false);
		}
	}

}