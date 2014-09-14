package model.ai 
{
	import model.*;
	/**
	 * ...
	 * @author B_head
	 */
	public class GreedyAI extends GameAI 
	{	
		override public function createTargetWay():ControlWay 
		{
			treeRoot.createNext(GameModelBase.fieldWidth);
			for (var i:int = 0; i < treeRoot.next.length; i++)
			{
				var nt:AppraiseTree = treeRoot.next[i];
				var nm:GameLightModel = currentModel.clone();
				var result:ForwardResult = nm.forwardNext(nt.way);
				if (result == null)
				{
					nt.marks = Number.NEGATIVE_INFINITY;
				}
				else
				{
					nt.marks = appraise(nm, result);
				}
			}
			var maxs:Vector.<AppraiseTree> = treeRoot.getMaxs();
			var ret:AppraiseTree = maxs[int(Math.random() * maxs.length)];
			return ret.way;
		}
		
		private function appraise(gameModel:GameLightModel, result:ForwardResult):Number
		{
			var blockCountLimit:int = (GameModelBase.gameOverHeight - 9) * (GameModelBase.fieldWidth - 1);
			var blockCount:int = gameModel.mainField.countBlock();
			var semiBreak:int = semiBreakLines(gameModel);
			var tops:Vector.<int> = getTops(gameModel);
			var vertical:Vector.<int> = verticalBlockCount(gameModel);
			var roughness:int = appraiseRoughness(vertical);
			var chasm:Vector.<int> = appraiseChasm(gameModel);
			var ret:int = 0;
			ret += (result.breakLine * result.breakLine) * 10;
			ret += semiBreak * 5;
			ret -= Math.max(0, (blockCount + gameModel.notice * 2) - blockCountLimit) * 10;
			tops.forEach(function (item:int, index:int, vector:Vector.<int>):void { if (item <= GameModelBase.gameOverHeight) ret -= 1000; } );
			ret -= roughness * 5;
			chasm.forEach(function (item:int, index:int, vector:Vector.<int>):void { ret -= item * 50; } );
			if (vertical[0] != 0 && vertical[9] != 0) ret -= 50;
			return ret;
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
				if (count > 0)
				{
					ret += count - 1;
				}
			}
			return ret;
		}
		
		private function getTops(gameModel:GameLightModel):Vector.<int>
		{
			var ret:Vector.<int> = new Vector.<int>(GameModelBase.fieldWidth);
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				ret[x] = 0;
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
		
		private function appraiseRoughness(tops:Vector.<int>):int
		{
			var ret:int = 0;
			var prev:int = tops[0];
			for (var x:int = 1; x < GameModelBase.fieldWidth; x++)
			{
				var a:int = Math.abs(prev - tops[x]);
				ret += Math.max(0, a * 2 - 1);
				prev = tops[x];
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