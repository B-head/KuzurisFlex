package model.ai 
{
	import model.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class GreedyAI extends GameAI 
	{	
	 	override protected function getBotder():Number
		{
			return (21 - level) / 200;
		}
		
		override protected function appraise(current:FragmentGameModel, prev:FragmentGameModel, fr:ForwardResult):Number
		{
			var tops:Vector.<int> = getTops(current);
			//var rMinTops:int = GameModelBase.fieldHeight - vectorMin(tops);
			var countOverTops:int = vectorCount(tops, function(i:int):Boolean { return i <= GameModelBase.gameOverHeight; });
			var vertical:Vector.<int> = verticalBlockCount(current);
			var minVertical:int = vectorMin(vertical);
			var roughness:int = appraiseRoughness(vertical);
			var horizontal:Vector.<int> = horizontalBlockCount(current);
			var semiBreak:int = semiBreakLines(horizontal);
			var coveredSemiBreak:int = coveredSemiBreakLines(current, horizontal);
			var chasm:Vector.<int> = appraiseChasm(current, horizontal);
			var sumChasm:int = vectorSum(chasm);
			//var prevChasm:Vector.<int> = appraiseChasm(prev);
			//var sumPrevChasm:int = vectorSum(prevChasm);
			var ret:int = 0;
			ret += Math.pow(fr.breakLine, 2) * 100;
			ret -= fr.lossTime * 5;
			ret -= countOverTops * 2000;
			ret += minVertical * 250;
			ret -= roughness * 20;
			ret += semiBreak * 4;
			ret += Math.pow(coveredSemiBreak, 2) * 25;
			ret -= sumChasm * 50;
			if (vertical[9] != 0) ret -= 50;
			return ret;
		}
		
		override protected function postAppraise(current:FragmentGameModel, fr:ForwardResult, notice:int):Number 
		{
			var blockCountLimit:int = GameModelBase.fieldHeight * GameModelBase.fieldWidth * (level / 20) / 3;
			var blockCount:int = current.mainField.countBlock();
			var over:int = Math.max(0, (blockCount + notice * 2) - blockCountLimit);
			return Math.min(over, fr.breakLine * 10) * 200;
		}
		
		private function getTops(gameModel:FragmentGameModel):Vector.<int>
		{
			var ret:Vector.<int> = new Vector.<int>(GameModelBase.fieldWidth);
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				ret[x] = GameModelBase.fieldHeight;
				for (var y:int = 0; y < GameModelBase.fieldHeight; y++)
				{
					if (gameModel.mainField.isExistBlock(x, y))
					{
						ret[x] = y;
						break;
					}
				}
			}
			return ret;
		}
		
		private function verticalBlockCount(gameModel:FragmentGameModel):Vector.<int>
		{
			var ret:Vector.<int> = new Vector.<int>(GameModelBase.fieldWidth);
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				for (var y:int = 0; y < GameModelBase.fieldHeight; y++)
				{
					if (gameModel.mainField.isExistBlock(x, y))
					{
						ret[x]++;
					}
				}
			}
			return ret;
		}
		
		private function horizontalBlockCount(gameModel:FragmentGameModel):Vector.<int>
		{
			var ret:Vector.<int> = new Vector.<int>(GameModelBase.fieldHeight);
			for (var y:int = 0; y < GameModelBase.fieldHeight; y++)
			{
				for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
				{
					if (gameModel.mainField.isExistBlock(x, y))
					{
						ret[y]++;
					}
				}
			}
			return ret;
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
		
		private function appraiseRoughness(vertical:Vector.<int>):int
		{
			var minVertical:int = vectorMin(vertical);
			var countMin:int = vectorCount(vertical, function(i:int):Boolean { return i == minVertical; } );
			if (countMin > 1) minVertical = int.MIN_VALUE;
			var ret:int = 0;
			var prev:int = int.MIN_VALUE;
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				if (vertical[x] == minVertical) continue;
				if (prev != int.MIN_VALUE)
				{
					var a:int = Math.abs(prev - vertical[x]);
					ret += Math.pow(a, 2);
				}
				prev = vertical[x];
			}
			return ret;
		}
		
		private function semiBreakLines(horizontal:Vector.<int>):int
		{
			var ret:int = 0;
			for (var y:int = 0; y < GameModelBase.fieldHeight; y++)
			{
				ret += Math.pow(horizontal[y], 2);
			}
			return ret;
		}
		
		private function coveredSemiBreakLines(gameModel:FragmentGameModel, horizontal:Vector.<int>):int
		{
			var ret:int = 0;
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				var cover:int = 0;
				var chasm:Boolean = false;
				for (var y:int = 0; y < GameModelBase.fieldHeight; y++)
				{
					if (gameModel.mainField.isExistBlock(x, y))
					{
						if (chasm) break;
						cover++;
					}
					else
					{
						if (cover == 0) continue;
						chasm = true;
						if (horizontal[y] != 9) continue;
						ret++;
					}
				}
			}
			return ret;
		}
		
		private function appraiseChasm(gameModel:FragmentGameModel, horizontal:Vector.<int>):Vector.<int>
		{
			var ret:Vector.<int> = new Vector.<int>(GameModelBase.fieldWidth);
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				var cc:int = 0;
				var smhp:Number = 0;
				var first:Boolean = true;
				for (var y:int = 0; y < GameModelBase.fieldHeight; y++)
				{
					if (gameModel.mainField.isExistBlock(x, y))
					{
						if (gameModel.mainField.isUnionSideBlock(x, y))
						{
							var hp:Number = gameModel.mainField.getHitPoint(x, y);
							if (first) hp /= GameModelBase.shockDamageCoefficient;
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