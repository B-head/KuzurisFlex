package ai {
	import common.*;
	import model.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class FragmentGameModel extends GameModelBase 
	{
		public var comboTotalLine:int;
		public var comboCount:int;
		public var isHurryUp:Boolean;
		private var ominoCache:OminoField;
		
		public function FragmentGameModel() 
		{
			super();
			ominoCache = new OminoField(GameModelBase.ominoSize);
			_controlOmino = new OminoField(GameModelBase.ominoSize);
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
		
		public function getValidRange(cox:int, coy:int, dir:int, revise:Boolean):Range
		{
			var co:OminoField = new OminoField(GameModelBase.ominoSize);
			_controlOmino.copyTo(co);
			switch(dir)
			{
				case 0:
					break;
				case 1: 
					co.rotationLeft(ominoCache);
					ominoCache.copyTo(co);
					break;
				case 2: 
					co.rotationLeft(ominoCache);
					ominoCache.copyTo(co);
					co.rotationLeft(ominoCache); 
					ominoCache.copyTo(co);
					break;
				case 3: 
					co.rotationRight(ominoCache); 
					ominoCache.copyTo(co);
					break;
			}
			var controlRect:Rect = _controlOmino.getRect();
			var cacheRect:Rect = co.getRect();
			if (revise)
			{
				cox += rotateReviseX(controlRect, cacheRect);
				coy += rotateReviseY(controlRect, cacheRect);
			}
			for (var l:int = cox; ; --l)
			{
				if (co.blocksHitChack(_mainField, l - 1, coy, true) > 0) break;
			}
			for (var h:int = cox; ; ++h)
			{
				if (co.blocksHitChack(_mainField, h + 1, coy, true) > 0) break;
			}
			var left:int = cacheRect.left;
			return new Range(l + left, h + left);
		}
		
		public function forwardNext(fw:ControlWay, sw:ControlWay):ForwardResult
		{
			switch(fw.dir)
			{
				case 0:
					break;
				case 1: 
					_controlOmino.rotationLeft(ominoCache);
					ominoCache.copyTo(_controlOmino);
					break;
				case 2: 
					_controlOmino.rotationLeft(ominoCache);
					ominoCache.copyTo(_controlOmino);
					_controlOmino.rotationLeft(ominoCache); 
					ominoCache.copyTo(_controlOmino);
					break;
				case 3: 
					_controlOmino.rotationRight(ominoCache); 
					ominoCache.copyTo(_controlOmino);
					break;
			}
			var rect:Rect = _controlOmino.getRect();
			var cox:int = fw.getCox(rect);
			var coy:int = init_coy(rect);
			var ret:ForwardResult = new ForwardResult();
			if (_controlOmino.blocksHitChack(_mainField, cox, coy, true) > 0) return null;
			coy = earthFall(cox, coy, fw.shift, false);
			if (sw != null)
			{
				cox = sw.getCox(rect);
				if (_controlOmino.blocksHitChack(_mainField, cox, coy, true) > 0) return null;
				coy = earthFall(cox, coy, sw.shift, true);
				ret.secondMove = true;
			}
			_controlOmino.fix(_mainField, cox, coy);
			ret.fixCox = cox;
			ret.fixCoy = coy;
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
		
		private function earthFall(cox:int, coy:int, shockSave:Boolean, secondary:Boolean):int
		{
			var d:int = 0;
			for (var i:int = coy; i < GameModelBase.fieldHeight; i++)
			{
				if (_controlOmino.blocksHitChack(_mainField, cox, i + 1, true) == 0)
				{
					d++;
					continue;
				}
				if (!shockSave)
				{
					shockDamage(_controlOmino, cox, i, secondary ? distanceDamageCoefficient[d] : 1);
				}
				break;
			}
			return i;
		}
	}

}