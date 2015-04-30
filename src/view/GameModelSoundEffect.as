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
	public class GameModelSoundEffect extends UIComponent
	{
		[Embed(source = "../sound/line/lineC3.mp3")]
		private const Line1:Class;
		[Embed(source = "../sound/line/lineD3.mp3")]
		private const Line2:Class;
		[Embed(source = "../sound/line/lineE3.mp3")]
		private const Line3:Class;
		[Embed(source = "../sound/line/lineF3.mp3")]
		private const Line4:Class;
		[Embed(source = "../sound/line/lineG3.mp3")]
		private const Line5:Class;
		[Embed(source = "../sound/line/lineA4.mp3")]
		private const Line6:Class;
		[Embed(source = "../sound/line/lineB4.mp3")]
		private const Line7:Class;
		[Embed(source = "../sound/line/lineC4.mp3")]
		private const Line8:Class;
		[Embed(source = "../sound/line/lineD4.mp3")]
		private const Line9:Class;
		[Embed(source = "../sound/line/lineE4.mp3")]
		private const Line10:Class;
		[Embed(source = "../sound/line/lineF4.mp3")]
		private const Line11:Class;
		[Embed(source = "../sound/line/lineG4.mp3")]
		private const Line12:Class;
		[Embed(source = "../sound/line/lineA5.mp3")]
		private const Line13:Class;
		[Embed(source = "../sound/line/lineB5.mp3")]
		private const Line14:Class;
		[Embed(source = "../sound/line/lineC5.mp3")]
		private const Line15:Class;
		[Embed(source = "../sound/line/lineD5.mp3")]
		private const Line16:Class;
		[Embed(source = "../sound/line/lineE5.mp3")]
		private const Line17:Class;
		[Embed(source = "../sound/line/lineF5.mp3")]
		private const Line18:Class;
		[Embed(source = "../sound/line/lineG5.mp3")]
		private const Line19:Class;
		[Embed(source = "../sound/line/lineA6.mp3")]
		private const Line20:Class;
		
		[Embed(source = "../sound/receipt05.mp3")]
		private const TecnicalSpin:Class;
		[Embed(source = "../sound/itemgetsea.mp3")]
		private const EraseJewel:Class;
		[Embed(source = "../sound/receipt02.mp3")]
		private const JewelAllClear:Class;
		[Embed(source = "../sound/receipt02.mp3")]
		private const AllClear:Class;
		[Embed(source = "../sound/itemgetseb.mp3")]
		private const LevelUp:Class;
		[Embed(source = "../sound/on01.mp3")]
		private const Move:Class;
		[Embed(source = "../sound/kachi14.mp3")]
		private const MoveNG:Class;
		[Embed(source = "../sound/chari04.mp3")]
		private const Rotation:Class;
		[Embed(source = "../sound/beep13.mp3")]
		private const RotationNG:Class;
		[Embed(source = "../sound/swing30_c.mp3")]
		private const Fall:Class;
		[Embed(source = "../sound/kachi04.mp3")]
		private const Shift:Class;
		[Embed(source = "../sound/gun30.mp3")]
		private const Shock:Class;
		[Embed(source = "../sound/hit28.mp3")]
		private const ShockSave:Class;
		[Embed(source = "../sound/silent.mp3")]
		private const ForceFix:Class;
		[Embed(source = "../sound/silent.mp3")]
		private const TimeOutAlert:Class;
		[Embed(source = "../sound/silent.mp3")]
		private const TimeOutFix:Class;
		[Embed(source = "../sound/cursor02.mp3")]
		private const CautionObstacle:Class;
		
		private var _gameModel:GameModel;
		private var _compact:Boolean;
		private var line:Vector.<Sound>;
		private var tecnicalSpin:Sound;
		private var eraseJewel:Sound;
		private var jewelAllClear:Sound;
		private var allClear:Sound;
		private var levelUp:Sound;
		private var cMove:Sound;
		private var cMoveNG:Sound;
		private var cRotation:Sound;
		private var cRotationNG:Sound;
		private var cFall:Sound;
		private var cShift:Sound;
		private var shock:Sound;
		private var shockSave:Sound;
		private var forceFix:Sound;
		private var timeOutAlert:Sound;
		private var timeOutFix:Sound;
		private var cautionObstacle:Sound;
		
		public function GameModelSoundEffect() 
		{
			line = new Vector.<Sound>(21);
			for (var i:int = 0; i < 21; i++)
			{
				line[i] = indexToLine(i);
			}
			tecnicalSpin = new TecnicalSpin();
			eraseJewel = new EraseJewel();
			jewelAllClear = new JewelAllClear();
			allClear = new AllClear();
			levelUp = new LevelUp();
			cMove = new Move();
			cMoveNG = new MoveNG();
			cRotation = new Rotation();
			cRotationNG = new RotationNG();
			cFall = new Fall();
			cShift = new Shift();
			shock = new Shock();
			shockSave = new ShockSave();
			forceFix = new ForceFix();
			timeOutAlert = new TimeOutAlert();
			timeOutFix = new TimeOutFix();
			cautionObstacle = new CautionObstacle();
		}
		
		public function get gameModel():GameModel
		{
			return _gameModel;
		}
		public function set gameModel(value:GameModel):void
		{
			_gameModel = value;
			var st:SoundTransform = new SoundTransform(0.5);
			value.addTerget(BreakLineEvent.sectionBreakLine, breakLineListener);
			value.addTerget(ShockBlockEvent.sectionDamage, shockBlockListener);
			value.addTerget(BreakLineEvent.breakTechnicalSpin, function(e:BreakLineEvent):void { tecnicalSpin.play(); }, false);
			value.addTerget(BreakLineEvent.eraseJewel, function(e:BreakLineEvent):void { eraseJewel.play(); }, false);
			value.addTerget(GameEvent.jewelAllClear, function(e:GameEvent):void { jewelAllClear.play(); }, false);
			value.addTerget(GameEvent.blockAllClear, function(e:GameEvent):void { allClear.play(); }, false);
			value.addTerget(LevelClearEvent.levelClear, function(e:LevelClearEvent):void { levelUp.play(); }, false);
			value.addTerget(ControlEvent.moveOK, function(e:ControlEvent):void { cMove.play(0, 0, st); }, false);
			value.addTerget(ControlEvent.moveNG, function(e:ControlEvent):void { cMoveNG.play(0, 0, st); }, false);
			value.addTerget(ControlEvent.rotationOK, function(e:ControlEvent):void { cRotation.play(0, 0, st); }, false);
			value.addTerget(ControlEvent.rotationNG, function(e:ControlEvent):void { cRotationNG.play(0, 0, st); }, false);
			value.addTerget(ControlEvent.startFall, function(e:ControlEvent):void { cFall.play(0, 0, st); }, false);
			value.addTerget(ControlEvent.shockSaveON, function(e:ControlEvent):void { cShift.play(0, 0, st); }, false);
			value.addTerget(ControlEvent.shockSaveOFF, function(e:ControlEvent):void { cShift.play(0, 0, st); }, false);
			value.addTerget(ControlEvent.fallShockSave, function(e:ControlEvent):void { shockSave.play(); }, false);
			value.addTerget(ControlEvent.forceFix, function(e:ControlEvent):void { forceFix.play(); }, false);
			value.addTerget(ControlEvent.timeOutAlert, function(e:ControlEvent):void { timeOutAlert.play(); }, false);
			value.addTerget(ControlEvent.timeOutFix, function(e:ControlEvent):void { timeOutFix.play(); }, false);
			//value.obstacleManager.addTerget(GameEvent.cautionObstacle, function(e:GameEvent):void { cautionObstacle.play(); }, false);
		}
		
		public function shockBlockListener(e:ShockBlockEvent):void
		{
			var v:Number = e.coefficient;
			shock.play(0, 0, new SoundTransform(v));
		}
		
		public function breakLineListener(e:BreakLineEvent):void
		{
			var powerLevel:int = Math.max(1, Math.min(20, e.powerLevel())); 
			line[powerLevel].play(); 
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