package ai {
	import common.*;
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
			var tops:Vector.<int> = AppraiseUtility.getTops(current);
			var blockCount:int = current.mainField.blockCount; 
			var vertical:Vector.<int> = current.mainField.verticalBlockCount;
			var minVertical:int = Utility.min(vertical);
			var roughness:int = AppraiseUtility.appraiseRoughness(current);
			var horizontal:Vector.<int> = current.mainField.horizontalBlockCount;
			var semiBreak:int = AppraiseUtility.semiBreakLines(current);
			var chasm:Vector.<int> = AppraiseUtility.appraiseChasm(current);
			var sumChasm:int = Utility.sum(chasm);
			var breakPower:int = fr.breakLine + prev.comboTotalLine - prev.comboCount;
			fr.minTops = GameModelBase.fieldHeight - Utility.min(tops);
			var ret:int = 0;
			if (fr.breakLine > 0) ret += Utility.summation(breakPower) * (isDig ? 10 : 15);
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
	}
}