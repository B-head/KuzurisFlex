package model.ai 
{
	import model.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class GreedyAI extends GameAI 
	{	
	 	override protected function getBorder():Number
		{
			if (level > 20) return 0;
			return (21 - level) / 100;
		}
		
		override protected function appraise(current:FragmentGameModel, prev:FragmentGameModel, fr:ForwardResult):Number
		{
			var isDig:Boolean = gameMode == GameSetting.digBattle;
			var tops:Vector.<int> = getTops(current);
			var blockCount:int = current.mainField.blockCount; 
			var vertical:Vector.<int> = current.mainField.verticalBlockCount;
			var minVertical:int = vectorMin(vertical);
			var roughness:int = appraiseRoughness(vertical);
			var horizontal:Vector.<int> = current.mainField.horizontalBlockCount;
			var semiBreak:int = semiBreakLines(current);
			var chasm:Vector.<int> = appraiseChasm(current, horizontal);
			var sumChasm:int = vectorSum(chasm);
			var breakPower:int = fr.breakLine + prev.comboTotalLine - prev.comboCount;
			fr.minTops = GameModelBase.fieldHeight - vectorMin(tops);
			var ret:int = 0;
			if (fr.breakLine > 0) ret += summation(breakPower) * (isDig ? 10 : 15);
			if (fr.secondMove) ret -= 100;
			ret -= fr.lossTime;
			ret += minVertical * 0;
			ret -= roughness;
			ret += semiBreak;
			ret -= sumChasm * (isDig ? 1 : 3);
			if (vertical[0] == minVertical) ret += 10;
			if (vertical[9] == minVertical) ret += 20;
			if (blockCount == 0) ret += 100;
			return ret;
		}
		
		override protected function postAppraise(fr:ForwardResult, notice:int):Number 
		{
			var isDig:Boolean = gameMode == GameSetting.digBattle;
			var topsLimitBase:int = GameModelBase.fieldHeight / 2;
			var topsLimit:int = Math.min(topsLimitBase, topsLimitBase * level / 10);
			var noticeHeight:int = (fr.breakLine > 0 ? 0 : Math.ceil(notice / (isDig ? 5 : 3)));
			var topHeight:int = fr.minTops + noticeHeight;
			var over:int = Math.max(0, topHeight - topsLimit);
			return -(over > 0 ? 300 : 0);
		}
		
		private function summation(a:Number):Number
		{
			return a * (a + 1) / 2;
		}
		
		private function vectorMax(v:Vector.<int>):int
		{
			var ret:int = int.MIN_VALUE;
			for (var i:int = 0; i < v.length; i++)
			{
				ret = Math.max(ret, v[i]);
			}
			return ret
		}
		
		private function vectorMin(v:Vector.<int>):int
		{
			var ret:int = int.MAX_VALUE;
			for (var i:int = 0; i < v.length; i++)
			{
				ret = Math.min(ret, v[i]);
			}
			return ret
		}
		
		private function vectorSum(v:Vector.<int>):int
		{
			var ret:int = 0;
			for (var i:int = 0; i < v.length; i++)
			{
				ret += v[i];
			}
			return ret
		}
		
		private function vectorCount(v:Vector.<int>, cond:Function):int
		{
			var ret:int = 0;
			for (var i:int = 0; i < v.length; i++)
			{
				if (cond(v[i])) ret++;
			}
			return ret
		}
		
		private function getTops(gameModel:FragmentGameModel):Vector.<int>
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
		
		private function appraiseRoughness(vertical:Vector.<int>):int
		{
			var ret:int = 0;
			var prev:int = int.MIN_VALUE;
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				if (prev != int.MIN_VALUE)
				{
					var a:int = Math.abs(prev - vertical[x]);
					ret += summation(a);
				}
				prev = vertical[x];
			}
			return ret;
		}
		
		private function semiBreakLines(gameModel:FragmentGameModel):int
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
				ret += summation(raw);
			}
			return ret;
		}
		
		private function appraiseChasm(gameModel:FragmentGameModel, horizontal:Vector.<int>):Vector.<int>
		{
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