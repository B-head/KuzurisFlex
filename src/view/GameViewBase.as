package view 
{
	import events.*;
	import model.*;
	import model.network.*;
	import mx.events.*;
	import spark.components.*;
	/**
	 * ...
	 * @author B_head
	 */
	[SkinState("normal")]
	[SkinState("ready")]
	[SkinState("pause")]
	[SkinState("gameOver")]
	[SkinState("gameClear")]
	public class GameViewBase extends SkinnableContainer 
	{
		[Bindable] 
		public var blockGraphics:BlockGraphics;
		[Bindable] 
		public var breakLineGraphics:BreakLineGraphics;
		[Bindable] 
		public var shockGraphics:ShockEffectGraphics;
		private var _gameManager:GameManager;
		[Bindable] 
		private var shockEffectHelper:ShockEffectHelper;
		[Bindable]
		private var _gameModel:GameModel;
		[Bindable]
		private var playerInfo:PlayerInformation;
		[Bindable]
		private var _playerIndex:int;
		[Bindable]
		private var line:BreakLineEvent;
		[Bindable]
		private var technicalSpin:BreakLineEvent;
		[Bindable]
		private var levelClear:LevelClearEvent;
		
		public function GameViewBase() 
		{
			
		}
		
		public function get gameManager():GameManager
		{
			return _gameManager;
		}
		public function set gameManager(value:GameManager):void
		{
			_gameManager = value;
			_gameManager.addTerget(KuzurisEvent.gameReady, function():void { currentState = "ready" }, false);
			_gameManager.addTerget(KuzurisEvent.gameStart, function():void { currentState = "normal" }, false);
			_gameManager.addTerget(KuzurisEvent.gamePause, function():void { currentState = "pause" }, false);
			_gameManager.addTerget(KuzurisEvent.gameResume, function():void { currentState = "normal" }, false);
			_gameManager.addTerget(KuzurisEvent.initializeGameModel, setGameModel);
			_gameManager.addTerget(KuzurisEvent.playerUpdate, updatePlayerListener);
			playerInfo = _gameManager.getPlayerInfo(_playerIndex);
		}
		
		public function get playerIndex():int
		{
			return _playerIndex;
		}
		public function set playerIndex(value:int):void
		{
			_playerIndex = value;
			if (_gameManager == null) return;
			playerInfo = _gameManager.getPlayerInfo(_playerIndex);
		}
		
		public function setGameModel(e:KuzurisEvent):void
		{
			_gameModel = _gameManager.getGameModel(_playerIndex);
			comboScore.visible = false;
			lineRecord.visible = false;
			lineScore.visible = false;
			obstacleRecord.visible = false;
			levelUpRecord.visible = false;
			levelUpBonus.visible = false;
			technicalSpinRecord.visible = false;
			technicalSpinBonus.visible = false;
			allClear.visible = false;
			allClearBonus.visible = false;
			main.update(_gameModel.getMainField(), _gameModel.shockSave);
			fall.update(_gameModel.getFallField(), _gameModel.shockSave);
			ghost.update(_gameModel.getControlOmino(), _gameModel.shockSave);
			control.update(_gameModel.getControlOmino(), _gameModel.shockSave);
			next.update(_gameModel.getNextOmino(), _gameModel.shockSave, true);
			obstacle.update();
			breakLineContainer.removeAllElements();
			_gameModel.addTerget(GameEvent.forwardGame, updateFieldListener);
			_gameModel.addTerget(GameEvent.forwardGame, updateControlListener);
			_gameModel.addTerget(GameEvent.updateNext, updateNextListener);
			_gameModel.addTerget(GameEvent.firstUpdateNext, updateNextListener);
			_gameModel.addTerget(GameEvent.forwardGame, updateBreakLineListener);
			_gameModel.obstacleManager.addTerget(GameEvent.updateObstacle, updateObstacleLestener);
			_gameModel.obstacleManager.addTerget(GameEvent.outsideUpdateObstacle, updateObstacleLestener);
			_gameModel.addTerget(BreakLineEvent.breakLine, breakLineListener);
			_gameModel.addTerget(BreakLineEvent.sectionBreakLine, breakLineListener);
			_gameModel.addTerget(BreakLineEvent.totalBreakLine, breakLineListener);
			_gameModel.addTerget(BreakLineEvent.technicalSpin, technicalSpinListener);
			_gameModel.addTerget(ShockBlockEvent.shockDamage, shockBlockListener);
			_gameModel.addTerget(LevelClearEvent.levelClear, levelClearListener);
			_gameModel.addTerget(GameEvent.blockAllClear, allClearListener);
			_gameModel.addTerget(GameEvent.gameOver, function():void { currentState = "gameOver" }, false);
			_gameModel.addTerget(GameEvent.gameClear, function():void { currentState = "gameClear"  }, false);
		}
		
		private function init():void
		{
			blockGraphics = Main.blockGraphics;
			breakLineGraphics = Main.breakLineGraphics;
			shockGraphics = Main.shockGraphics;
			shockEffectHelper = new ShockEffectHelper();
		}
		
		private function updatePlayerListener(e:KuzurisEvent):void
		{
			if (_gameManager == null) return;
			playerInfo = _gameManager.getPlayerInfo(_playerIndex);
		}
		
		private function updateFieldListener(e:GameEvent):void
		{
			main.update(_gameModel.getMainField(), _gameModel.shockSave);
			fall.update(_gameModel.getFallField(), _gameModel.shockSave);
		}
		
		private function updateControlListener(e:GameEvent):void
		{
			ghost.update(_gameModel.getControlOmino(), _gameModel.shockSave);
			control.update(_gameModel.getControlOmino(), _gameModel.shockSave);
		}
		
		private function updateNextListener(e:GameEvent):void
		{
			next.update(_gameModel.getNextOmino(), _gameModel.shockSave, e.type == GameEvent.firstUpdateNext);
		}
		
		private function updateObstacleLestener(e:GameEvent):void
		{
			if (_gameModel.isGameOver) return;
			obstacle.update();
		}
		
		private function updateBreakLineListener(e:GameEvent):void
		{
			for (var i:int = 0; i < breakLineContainer.numElements; i++)
			{
				var a:BreakLineEffect = BreakLineEffect(breakLineContainer.getElementAt(i));
				a.update();
			}
		}
		
		private function breakLineListener(e:BreakLineEvent):void
		{
			line = e;
			fieldRecordEffect.stop();
			fieldRecordEffect.play([lineRecord]);
			if (battle)
			{
				fieldRecordEffect.play([obstacleRecord]);
			}
			else
			{
				fieldRecordEffect.play([lineScore]);
			}
			if (e.comboCount > 0)
			{
				fieldRecordEffect.play([comboScore]);
			}
			else
			{
				comboScore.visible = false;
			}
			if (e.type == BreakLineEvent.breakLine)
			{
				var ble:BreakLineEffect = new BreakLineEffect();
				ble.lineEvent = e;
				ble.breakLineGraphics = breakLineGraphics;
				ble.y = e.position * blockGraphics.blockHeight - 256;
				ble.addEventListener(EffectEvent.EFFECT_END, function(e:EffectEvent):void { breakLineContainer.removeElement(ble); } );
				breakLineContainer.addElement(ble);
			}
			else if (e.type == BreakLineEvent.sectionBreakLine)
			{
				var powerLevel:int = Math.min(20, e.powerLevel());
				for (var i:int = 0; i < breakLineContainer.numElements; i++)
				{
					var a:BreakLineEffect = BreakLineEffect(breakLineContainer.getElementAt(i));
					a.powerLevel = powerLevel;
				}
			}
		}
		
		private function technicalSpinListener(e:BreakLineEvent):void
		{
			technicalSpin = e;
			bonusEffect.play([technicalSpinRecord, technicalSpinBonus]);
		}
		
		private function shockBlockListener(e:ShockBlockEvent):void
		{
			shockEffectHelper.registerShockBlockEvent(e);
		}
		
		private function levelClearListener(e:LevelClearEvent):void
		{
			levelClear = e;
			bonusEffect.play([levelUpRecord, levelUpBonus]);
		}
		
		private function allClearListener(e:GameEvent):void
		{
			bonusEffect.play([allClear, allClearBonus]);
		}
	}

}