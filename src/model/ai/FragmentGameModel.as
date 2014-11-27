package model.ai {
	import model.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class FragmentGameModel extends GameModelBase 
	{
		public var comboTotalLine:int;
		public var comboCount:int;
		private var ominoCache:OminoField;
		
		public function FragmentGameModel() 
		{
			super();
			_controlOmino = new OminoField(GameModelBase.ominoSize);
			ominoCache = new OminoField(GameModelBase.ominoSize);
			for (var i:int = 0; i < nextLength; i++)
			{
				_nextOmino[i] = new OminoField(GameModelBase.ominoSize);
			}
		}
		
		public function get mainField():MainField
		{
			return _mainField;
		}
		public function set mainField(value:MainField):void
		{
			_mainField = value;
		}
		
		public function get fallField():MainField
		{
			return _fallField;
		}
		public function set fallField(value:MainField):void
		{
			_fallField = value;
		}
		
		public function get controlOmino():OminoField
		{
			return _controlOmino;
		}
		public function set controlOmino(value:OminoField):void
		{
			_controlOmino = value;
		}
		
		public function get nextOmino():Vector.<OminoField>
		{
			return _nextOmino;
		}
		public function set nextOmino(value:Vector.<OminoField>):void
		{
			_nextOmino = value;
		}
		
		public function forwardNext(way:ControlWay):ForwardResult
		{
			ominoCache.clearAll();
			switch(way.dir)
			{
				case 0:
					ominoCache = _controlOmino;
					break;
				case 1: 
					_controlOmino.rotationLeft(ominoCache); 
					break;
				case 2: 
					_controlOmino.rotationLeft(ominoCache);
					ominoCache.copyTo(_controlOmino);
					ominoCache.clearAll();
					_controlOmino.rotationLeft(ominoCache); 
					break;
				case 3: 
					_controlOmino.rotationRight(ominoCache); 
					break;
			}
			ominoCache.copyTo(_controlOmino);
			var rect:Rect = _controlOmino.getRect();
			var cox:int = way.lx - rect.left;
			var coy:int = init_coy(rect);
			if (_controlOmino.blocksHitChack(_mainField, cox, coy, true) > 0) return null;
			var ret:ForwardResult = new ForwardResult();
			ret.verge = way.lx == 0 || (way.lx + rect.width) == fieldWidth;
			ret.rightDir = cox >= init_cox(rect);
			earthFix(cox, coy, way.shift);
			do
			{
				ret.lossTime += fallingField(0, GameModelBase.fieldHeight - 1, false);
				ret.breakLine += breakLines();
				extractFallBlocks();
			}
			while (_fallField.blockCount > 0);
			_mainField.clearSpecialUnion();
			_controlOmino.clearAll();
			rotateNext(_controlOmino);
			rect = _controlOmino.getRect();
			cox = init_cox(rect);
			coy = init_coy(rect);
			if (_controlOmino.blocksHitChack(_mainField, cox, coy, true) > 0) return null;
			return ret;
		}
		
		private function earthFix(cox:int, coy:int, shockSave:Boolean):void
		{
			for (var i:int = coy; i < GameModelBase.fieldHeight; i++)
			{
				if (_controlOmino.blocksHitChack(_mainField, cox, i + 1, true) == 0)
				{
					continue;
				}
				if (!shockSave)
				{
					shockDamage(_controlOmino, cox, i, 1);
				}
				_controlOmino.fix(_mainField, cox, i);
				break;
			}
		}
	}

}