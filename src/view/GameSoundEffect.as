package view 
{
	import event.*;
	import model.*;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import mx.core.UIComponent;
	/**
	 * ...
	 * @author B_head
	 */
	public class GameSoundEffect extends UIComponent
	{
		[Embed(source = "../sound/line/line-1.mp3")]
		private const Line1:Class;
		[Embed(source = "../sound/line/line-2.mp3")]
		private const Line2:Class;
		[Embed(source = "../sound/line/line-3.mp3")]
		private const Line3:Class;
		[Embed(source = "../sound/line/line-4.mp3")]
		private const Line4:Class;
		[Embed(source = "../sound/line/line-5.mp3")]
		private const Line5:Class;
		[Embed(source = "../sound/line/line-6.mp3")]
		private const Line6:Class;
		[Embed(source = "../sound/line/line-7.mp3")]
		private const Line7:Class;
		[Embed(source = "../sound/line/line-8.mp3")]
		private const Line8:Class;
		[Embed(source = "../sound/line/line-9.mp3")]
		private const Line9:Class;
		[Embed(source = "../sound/line/line-10.mp3")]
		private const Line10:Class;
		[Embed(source = "../sound/line/line-11.mp3")]
		private const Line11:Class;
		[Embed(source = "../sound/line/line-12.mp3")]
		private const Line12:Class;
		[Embed(source = "../sound/line/line-13.mp3")]
		private const Line13:Class;
		[Embed(source = "../sound/line/line-14.mp3")]
		private const Line14:Class;
		[Embed(source = "../sound/line/line-15.mp3")]
		private const Line15:Class;
		[Embed(source = "../sound/line/line-16.mp3")]
		private const Line16:Class;
		[Embed(source = "../sound/line/line-17.mp3")]
		private const Line17:Class;
		[Embed(source = "../sound/line/line-18.mp3")]
		private const Line18:Class;
		[Embed(source = "../sound/line/line-19.mp3")]
		private const Line19:Class;
		[Embed(source = "../sound/line/line-20.mp3")]
		private const Line20:Class;
		
		[Embed(source = "../sound/level_up.mp3")]
		private const LevelUp:Class;
		[Embed(source = "../sound/bom26_a.mp3")]
		private const Shock:Class;
		[Embed(source = "../sound/hit28.mp3")]
		private const ShockSave:Class;
		[Embed(source = "../sound/on01b.mp3")]
		private const Move:Class;
		[Embed(source = "../sound/on04.mp3")]
		private const Rotation:Class;
		[Embed(source = "../sound/on01.mp3")]
		private const Fall:Class;
		[Embed(source = "../sound/clock03.mp3")]
		private const Shift:Class;
		
		private var _gameModel:GameModel;
		private var line:Vector.<Sound>;
		private var levelUp:Sound;
		private var shock:Sound;
		private var shockSave:Sound;
		private var cMove:Sound;
		private var cRotation:Sound;
		private var fall:Sound;
		private var shift:Sound;
		
		public function GameSoundEffect() 
		{
			line = new Vector.<Sound>(21);
			for (var i:int = 0; i < 21; i++)
			{
				line[i] = indexToLine(i);
			}
			
			levelUp = new LevelUp();
			shock = new Shock();
			shockSave = new ShockSave();
			cMove = new Move();
			cRotation = new Rotation();
			fall = new Fall();
			shift = new Shift();
		}
		
		public function get gameModel():GameModel
		{
			return _gameModel;
		}
		public function set gameModel(value:GameModel):void
		{
			_gameModel = value;
			value.addEventListener(BreakLineEvent.sectionBreakLine, breakLineListener);
			value.addEventListener(LevelClearEvent.levelClear, function(e:LevelClearEvent):void { levelUp.play(); } );
			value.addEventListener(ShockBlockEvent.sectionDamage, shockBlockListener);
			value.addEventListener(ControlEvent.fallShockSave, function(e:ControlEvent):void { shockSave.play(); } );
			value.addEventListener(ControlEvent.moveOK, function(e:ControlEvent):void { cMove.play(0, 0, new SoundTransform(0.5)); } );
			value.addEventListener(ControlEvent.rotationOK, function(e:ControlEvent):void { cRotation.play(0, 0, new SoundTransform(0.5)); } );
			value.addEventListener(ControlEvent.startFall, function(e:ControlEvent):void { fall.play(0, 0, new SoundTransform(0.5)); } );
			value.addEventListener(ControlEvent.shockSaveON, function(e:ControlEvent):void { shift.play(0, 0, new SoundTransform(0.5)); } );
			value.addEventListener(ControlEvent.shockSaveOFF, function(e:ControlEvent):void { shift.play(0, 0, new SoundTransform(0.5)); } );
		}
		
		public function shockBlockListener(e:ShockBlockEvent):void
		{
			var v:Number = e.coefficient;
			shock.play(0, 0, new SoundTransform(v));
		}
		
		public function breakLineListener(e:BreakLineEvent):void
		{
			line[e.combo].play(); 
		}
		
		private function indexToLine(index:int):Sound
		{
			switch(index)
			{
				case 0:
					return null;
				case 1:
					return new Line1();
				case 2:
					return new Line2();
				case 3:
					return new Line3();
				case 4:
					return new Line4();
				case 5:
					return new Line5();
				case 6:
					return new Line6();
				case 7:
					return new Line7();
				case 8:
					return new Line8();
				case 9:
					return new Line9();
				case 10:
					return new Line10();
				case 11:
					return new Line11();
				case 12:
					return new Line12();
				case 13:
					return new Line13();
				case 14:
					return new Line14();
				case 15:
					return new Line15();
				case 16:
					return new Line16();
				case 17:
					return new Line17();
				case 18:
					return new Line18();
				case 19:
					return new Line19();
				case 20:
					return new Line20();
				default:
					throw new Error();
			}
		}
		
	}

}