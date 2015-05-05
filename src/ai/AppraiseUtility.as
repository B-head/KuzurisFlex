package ai 
{
	import common.*;
	import model.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class AppraiseUtility 
	{
		public static function getTops(gameModel:FragmentGameModel):Vector.<int>
		{
			var ret:Vector.<int> = new Vector.<int>(GameModelBase.fieldWidth);
			var m:MainField = gameModel.mainField;
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				ret[x] = GameModelBase.fieldHeight;
				for (var y:int = m.top; y <= m.bottom; y++)
				{
					if (m.isExistBlock(x, y))
					{
						ret[x] = y;
						break;
					}
				}
			}
			return ret;
		}
		
		public static function appraiseRoughness(gameModel:FragmentGameModel):int
		{
			var vertical:Vector.<int> = gameModel.mainField.verticalBlockCount;
			var ret:int = 0;
			var prev:int = int.MIN_VALUE;
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				if (prev != int.MIN_VALUE)
				{
					var a:int = Math.abs(prev - vertical[x]);
					ret += Utility.summation(a);
				}
				prev = vertical[x];
			}
			return ret;
		}
		
		public static function semiBreakLines(gameModel:FragmentGameModel):int
		{
			var ret:int = 0;
			var m:MainField = gameModel.mainField;
			for (var y:int = m.top; y <= m.bottom; y++)
			{
				var left:int = GameModelBase.fieldWidth;
				var right:int = 0;
				for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
				{
					if (!m.isExistBlock(x, y))
					{
						left = Math.min(left, x);
						right = Math.max(right, x);
					}
				}
				var raw:int = GameModelBase.fieldWidth - (1 + right - left);
				ret += Utility.summation(raw);
			}
			return ret;
		}
		
		public static function appraiseChasm(gameModel:FragmentGameModel):Vector.<int>
		{
			var horizontal:Vector.<int> = gameModel.mainField.horizontalBlockCount;
			var ret:Vector.<int> = new Vector.<int>(GameModelBase.fieldWidth);
			var m:MainField = gameModel.mainField;
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				var cc:int = 0;
				var smhp:Number = 0;
				var first:Boolean = true;
				for (var y:int = m.top; y <= m.bottom; y++)
				{
					if (m.isExistBlock(x, y))
					{
						if (m.isUnionSideBlock(x, y))
						{
							var hp:Number = m.getHitPoint(x, y);
							if (first) hp /= GameSetting.shockDamageCoefficient;
							smhp = Math.max(smhp, hp);
						}
						first = false;
					}
					else 
					{
						if (smhp > 0)
						{
							cc += smhp;
							ret[x] += cc;
							smhp = 0;
						}
						if (horizontal[y] == 9)
						{
							ret[x] += cc;
						}
					}
				}
			}
			return ret;
		}
	}
}