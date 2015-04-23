package view 
{
	import events.*;
	import model.*;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import mx.core.UIComponent;
	/**
	 * ...
	 * @author B_head
	 */
	public class GameManagerSoundEffect extends UIComponent
	{	
		[Embed(source = "../sound/silent.mp3")]
		private const GameReady:Class;
		[Embed(source = "../sound/silent.mp3")]
		private const GameFinish:Class;
		[Embed(source = "../sound/silent.mp3")]
		private const GameWin:Class;
		[Embed(source = "../sound/silent.mp3")]
		private const gameLose:Class;
		[Embed(source = "../sound/silent.mp3")]
		private const gameDraw:Class;
		[Embed(source = "../sound/silent.mp3")]
		private const SelfKO:Class;
		[Embed(source = "../sound/silent.mp3")]
		private const OtherKO:Class;
		[Embed(source = "../sound/bell02.mp3")]
		private const HarryUp:Class;
		[Embed(source = "../sound/bell00.mp3")]
		private const EntranceRoom:Class;
		
		private var _gameManager:GameManager;
		private var gameReady:Sound;
		private var gameFinish:Sound;
		private var gameWin:Sound;
		private var gameLose:Sound;
		private var gameDraw:Sound;
		private var selfKO:Sound;
		private var otherKO:Sound;
		private var harryUp:Sound;
		private var entranceRoom:Sound;
		
		public function GameManagerSoundEffect() 
		{
			
		}
		
	}

}