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
		
		public function FragmentGameModel() 
		{
			super(false);
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
			
		public function clone():FragmentGameModel
		{
			var result:FragmentGameModel = new FragmentGameModel();
			result.mainField = _mainField.clone();
			result.fallField = _fallField.clone();
			result.controlOmino = _controlOmino.clone();
			result.nextOmino = new Vector.<OminoField>(nextLength, true);
			for (var i:int = 0; i < nextLength; i++)
			{
				result.nextOmino[i] = _nextOmino[i].clone();
			}
			return result;
		}
		
		public function forwardNext(way:ControlWay):ForwardResult
		{
			var cache:OminoField = new OminoField(GameModelBase.ominoSize);
			switch(way.dir)
			{
				case 0:
					cache = _controlOmino;
					break;
				case 1: 
					_controlOmino.rotationLeft(cache); 
					break;
				case 2: 
					_controlOmino.rotationLeft(cache);
					_controlOmino = cache;
					cache = new OminoField(GameModelBase.ominoSize);
					_controlOmino.rotationLeft(cache); 
					break;
				case 3: 
					_controlOmino.rotationRight(cache); 
					break;
			}
			_controlOmino = cache;
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
			while (_fallField.countBlock() > 0);
			_mainField.clearSpecialUnion();
			rotateNext(null);
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
				_mainField.fix(_controlOmino, cox, i);
				break;
			}
		}
	}

}