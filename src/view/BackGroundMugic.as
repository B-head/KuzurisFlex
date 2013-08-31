package view 
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author B_head
	 */
	public class BackGroundMugic 
	{
		private var mugic:Sound;
		private var mugicChannel:SoundChannel
		private var position:int;
		
		public function BackGroundMugic() 
		{
			mugic = new Sound(new URLRequest(""));
		}
		
		public function play(continuation:Boolean):void
		{
			if (!continuation) position = 0;
			mugicChannel = mugic.play(position);
			mugicChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}
		
		public function stop():void
		{
			if (mugicChannel == null) return;
			position = mugicChannel.position;
			mugicChannel.stop();
		}
		
		private function onSoundComplete(e:Event):void
		{
			play(false);
		}
	}

}