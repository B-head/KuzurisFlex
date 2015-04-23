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
		private var mugicList:Vector.<Sound>;
		private var currentMusic:Sound;
		private var mugicChannel:SoundChannel
		private var position:int;
		
		public function BackGroundMugic() 
		{
			mugicList = new Vector.<Sound>();
			mugicList.push(new Sound(new URLRequest("music/Dance_With_Powder.mp3")));
			mugicList.push(new Sound(new URLRequest("music/タイムベンド.mp3")));
			mugicList.push(new Sound(new URLRequest("music/メタリック・ウィンク.mp3")));
			mugicList.push(new Sound(new URLRequest("music/危機.mp3")));
		}
		
		public function play(continuation:Boolean, loop:Boolean = false):void
		{
			if (mugicChannel != null)
			{
				stop();
			}
			if (!continuation)
			{
				position = 0;
				if (!loop)
				{
					var rand:int = Math.random() * mugicList.length;
					currentMusic = mugicList[rand];
				}
			}
			mugicChannel = currentMusic.play(position);
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
			play(false, true);
		}
	}

}