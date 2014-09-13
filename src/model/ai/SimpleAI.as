package model.ai 
{
	import model.AppraiseTree;
	import model.ControlWay;
	import model.GameLightModel;
	import model.GameModelBase;
	/**
	 * ...
	 * @author B_head
	 */
	public class SimpleAI extends GameAI 
	{	
		override public function createTargetWay():ControlWay 
		{
			treeRoot.createNext(GameModelBase.fieldWidth);
			for (var i:int = 0; i < treeRoot.next.length; i++)
			{
				var nt:AppraiseTree = treeRoot.next[i];
				var nm:GameLightModel = currentModel.clone();
				if (nm.forwardNext(nt.way))
				{
					nt.marks = appraise(nm);
				}
				else
				{
					nt.marks = Number.NEGATIVE_INFINITY;
				}
			}
			var maxs:Vector.<AppraiseTree> = treeRoot.getMaxs();
			var ret:AppraiseTree = maxs[int(Math.random() * maxs.length)];
			trace("lx = " + ret.way.lx + ", dir = " + ret.way.dir);
			return ret.way;
		}
		
		private function appraise(gameModel:GameLightModel):Number
		{
			var tops:Vector.<int> = getTops(gameModel);
			var chasm:Vector.<int> = appraiseChasm(gameModel);
			var roughness:int = appraiseRoughness(tops);
			var ret:int = 0;
			tops.forEach(function (item:int, index:int, vector:Vector.<int>):void { ret += item; } );
			chasm.forEach(function (item:int, index:int, vector:Vector.<int>):void { ret -= item * 10; } );
			ret -= roughness * 5;
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
		
		private function appraiseChasm(gameModel:GameLightModel):Vector.<int>
		{
			var ret:Vector.<int> = new Vector.<int>(GameModelBase.fieldWidth);
			for (var x:int = 0; x < GameModelBase.fieldWidth; x++)
			{
				var cc:Boolean = false;
				for (var y:int = 0; y < GameModelBase.fieldHeight; y++)
				{
					if (gameModel.mainField.isExistBlock(x, y))
					{
						cc = true;
					}
					else
					{
						ret[x] += cc ? 1 : 0;
					}
				}
			}
			return ret;
		}
		
		private function appraiseRoughness(tops:Vector.<int>):int
		{
			var ret:int = 0;
			var prev:int = tops[0];
			for (var x:int = 1; x < GameModelBase.fieldWidth; x++)
			{
				ret += Math.abs(prev - tops[x]);
				prev = tops[x];
			}
			return ret;
		}
	}
}