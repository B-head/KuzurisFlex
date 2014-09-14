package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class ControlWay 
	{
		public var lx:int;
		public var dir:int;
		public var cox:int;
		
		public function getWayIndex():int
		{
			return (lx << 2) | dir;
		}
		
		public static function getCurrent(currentModel:GameLightModel):ControlWay
		{
			var rect:Rect = currentModel.controlOmino.getRect();
			var cox:int = currentModel.init_cox(rect);
			var ret:ControlWay = new ControlWay();
			ret.lx = cox + rect.left;
			ret.dir = 0;
			return ret;
		}
		
		public static function getRotate(cw:ControlWay, currentModel:GameLightModel, rotation:int):ControlWay
		{
			var ret:ControlWay = new ControlWay();
			var control:OminoField = currentModel.controlOmino;
			var cache:OminoField = new OminoField(GameModelBase.ominoSize);
			if (rotation == GameCommand.left)
			{
				control.rotationLeft(cache);
				ret.dir = cw.dir + 1;
				if (ret.dir > 3) ret.dir = 0;
			}
			else if (rotation == GameCommand.right)
			{
				control.rotationRight(cache);
				ret.dir = cw.dir - 1;
				if (ret.dir < 0) ret.dir = 3;
			}
			var fr:Rect = control.getRect();
			var tr:Rect = cache.getRect();
			ret.lx = (cw.lx - fr.left) + currentModel.rotateReviseX(fr, tr) + tr.left;
			currentModel.controlOmino = cache;
			return ret;
		}
	}

}