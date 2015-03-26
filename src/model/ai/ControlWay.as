package model.ai {
	import model.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class ControlWay 
	{
		public var lx:int;
		public var dir:int;
		public var shift:Boolean;
		public var verge:Boolean;
		public var fall:Boolean;
		public var fix:Boolean;
		
		public function ControlWay(lx:int = 0, dir:int = 0, shift:Boolean = false)
		{
			this.lx = lx;
			this.dir = dir;
			this.shift = shift;
			this.verge = false;
			this.fall = true;
		}
		
		public function getWayIndex():int
		{
			return (lx << 2) | dir;
		}
		
		public function getCox(rect:Rect):int
		{
			return lx - rect.left;
		}
		
		public function getControlRect(currentModel:FragmentGameModel):Rect
		{
			return getDirectionRect(currentModel.controlOmino.getRect(), dir);
		}
		
		public function setVerge(currentModel:FragmentGameModel):void
		{
			var rect:Rect = getControlRect(currentModel);
			verge = lx <= 0 || (lx + rect.width) >= GameModelBase.fieldWidth;
		}
		
		public static function getCurrent(gameModel:GameModel):ControlWay
		{
			var rect:Rect = gameModel.getControlOmino().getRect();
			var ret:ControlWay = new ControlWay();
			ret.lx = gameModel.cox + rect.left;
			ret.dir = gameModel.cd;
			return ret;
		}
		
		public static function getInit(currentModel:FragmentGameModel):ControlWay
		{
			var rect:Rect = currentModel.controlOmino.getRect();
			var cox:int = currentModel.init_cox(rect);
			var ret:ControlWay = new ControlWay();
			ret.lx = cox + rect.left;
			ret.dir = 0
			return ret;
		}
		
		public static function getRotate(cw:ControlWay, currentModel:FragmentGameModel, rotation:int):ControlWay
		{
			var ret:ControlWay = new ControlWay();
			if (rotation == GameCommand.left)
			{
				ret.dir = cw.dir + 1;
				if (ret.dir > 3) ret.dir = 0;
			}
			else if (rotation == GameCommand.right)
			{
				ret.dir = cw.dir - 1;
				if (ret.dir < 0) ret.dir = 3;
			}
			else
			{
				throw new Error();
			}
			var cr:Rect = currentModel.controlOmino.getRect();
			var fr:Rect = getDirectionRect(cr, cw.dir);
			var tr:Rect = getDirectionRect(cr, ret.dir);
			ret.lx = (cw.lx - fr.left) + currentModel.rotateReviseX(fr, tr) + tr.left;
			ret.shift = cw.shift;
			return ret;
		}
		
		public static function getDirectionRotate(cw:ControlWay, currentModel:FragmentGameModel, dir:int):ControlWay
		{
			var ret:ControlWay = new ControlWay();
			var cr:Rect = currentModel.controlOmino.getRect();
			var fr:Rect = getDirectionRect(cr, cw.dir);
			var tr:Rect = getDirectionRect(cr, dir);
			ret.lx = (cw.lx - fr.left) + currentModel.rotateReviseX(fr, tr) + tr.left;
			ret.dir = dir;
			ret.shift = cw.shift;
			return ret;
		}
		
		public static function getDirectionRect(rect:Rect, dir:int):Rect
		{
			switch(dir)
			{
				case 0:
					break;
				case 1:
					rect = Rect.getRotate(rect, GameCommand.left, GameModelBase.ominoSize);
					break;
				case 2:
					rect = Rect.getRotate(rect, GameCommand.left, GameModelBase.ominoSize);
					rect = Rect.getRotate(rect, GameCommand.left, GameModelBase.ominoSize);
					break;
				case 3:
					rect = Rect.getRotate(rect, GameCommand.right, GameModelBase.ominoSize);
					break;
				default:
					throw new Error();
			}
			return rect;
		}
		
		public static function getVergeWay(cw:ControlWay, currentModel:FragmentGameModel):ControlWay
		{
			var ret:ControlWay = new ControlWay();
			var cr:Rect = currentModel.controlOmino.getRect();
			ret.lx = GameModelBase.fieldWidth - cr.width;
			ret.dir = cw.dir;
			ret.shift = cw.shift;
			return ret;
		}
	}

}