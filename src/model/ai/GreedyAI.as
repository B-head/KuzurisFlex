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
		
		override protected function appraise(current:GameLightModel, prev:GameLightModel, fr:ForwardResult):Number
		{
			var semiBreak:int = semiBreakLines(current);
			var tops:Vector.<int> = getTops(current);
			var vertical:Vector.<int> = verticalBlockCount(current);
			var roughness:int = appraiseRoughness(vertical);
			var chasm:Vector.<int> = appraiseChasm(current);
			var sumChasm:int = vectorSum(chasm);
			var prevChasm:Vector.<int> = appraiseChasm(prev);
			var sumPrevChasm:int = vectorSum(prevChasm);
			var ret:int = 0;
			ret += Math.pow(fr.breakLine, 2) * 100;
			ret -= fr.lossTime;
			ret += semiBreak * 4;
			tops.forEach(function (item:int, index:int, vector:Vector.<int>):void { if (item <= GameModelBase.gameOverHeight) ret -= 1000; } );
			ret -= roughness * 8;
			ret -= sumChasm * 5;
			ret -= Math.max(0, sumChasm - sumPrevChasm) * 400
			if (vertical[9] != 0) ret -= 400;
			return ret;
		}
		
		override protected function postAppraise(current:GameLightModel, fr:ForwardResult, notice:int):Number 
		{
			var blockCountLimit:int = GameModelBase.fieldHeight * GameModelBase.fieldWidth * (level / 20) / 4;
			var blockCount:int = current.mainField.countBlock();
			var over:int = Math.max(0, (blockCount + notice * 2) - blockCountLimit);
			return Math.min(over, fr.breakLine * 10) * 160;
		}
		
		private function semiBreakLines(gameModel:GameLightModel):int
		{
			var ret:int = 0;
			for (var y:int = 0; y < GameModelBase.fieldHeight; y++)
			{
				var count:int = 0;
				for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
				{
					if (gameModel.mainField.isExistBlock(x, y))
					{
						count++;
					}
				}
				ret += Math.pow(count, 2);
			}
			return ret;
		}
		
		private function getTops(gameModel:GameLightModel):Vector.<int>
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
		
		private function verticalBlockCount(gameModel:GameLightModel):Vector.<int>
		{
			var ret:Vector.<int> = new Vector.<int>(GameModelBase.fieldWidth);
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				ret[x] = 0;
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
		
		private function appraiseRoughness(vertical:Vector.<int>):int
		{
			var ret:int = 0;
			var prev:int = vertical[0];
			for (var x:int = 1; x < GameModelBase.fieldWidth; x++)
			{
				var a:int = Math.abs(prev - vertical[x]);
				ret += Math.pow(a, 2);
				prev = vertical[x];
			}
			return ret;
		}
		
		private function appraiseChasm(gameModel:GameLightModel):Vector.<int>
		{
			var ret:Vector.<int> = new Vector.<int>(GameModelBase.fieldWidth);
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				var cc:int = 0;
				for (var y:int = 0; y < GameModelBase.fieldHeight; y++)
				{
					if (gameModel.mainField.isExistBlock(x, y))
					{
						cc++;
					}
					else
					{
						ret[x] += Math.min(2, cc);
					}
				}
			}
			return ret;
		}
	}
}