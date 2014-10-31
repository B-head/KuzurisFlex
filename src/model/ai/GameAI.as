package model.ai {
	import model.*;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class GameAI 
	{
		public var level:int;
		protected var rootModel:FragmentGameModel;
		protected var treeRoot:AppraiseTree;
		
		public function setCurrentModel(currentModel:FragmentGameModel):void
		{
			this.rootModel = currentModel;
			treeRoot = new AppraiseTree(null);
		}
		
		public function getChoices(notice:int):Vector.<AppraiseTree>
		{
			var next:Vector.<AppraiseTree> = treeRoot.next;
			for (var i:int = 0; i < next.length; i++)
			{
				next[i].marks += postAppraise(rootModel, next[i].fr, notice);
			}
			return treeRoot.getChoices(getBorder());
		}
		
		protected function getBorder():Number
		{
			return 0;
		}
		
		public function consider():void
		{
			considerTree(treeRoot, rootModel);
		}
		
		protected function considerTree(tree:AppraiseTree, current:FragmentGameModel):void
		{
			var ps:Boolean = current.controlOmino.isPointSymmetry();
			var p90s:Boolean = current.controlOmino.isPoint90Symmetry();
			for (var lx:int = 0; lx < GameModelBase.fieldWidth; lx++)
			{
				for (var dir:int = 0; dir < 4; dir++)
				{
					if (ps == true && (dir == 2 || dir == 3)) continue;
					if (p90s == true && dir == 1) continue;
					var way:ControlWay = new ControlWay(lx, dir, false);
					var nm:FragmentGameModel = current.clone();
					var fr:ForwardResult = nm.forwardNext(way);
					if (fr == null) continue;
					if (ps && way.dir == 1 && fr.rightDir) way.dir = 3;
					var nt:AppraiseTree = new AppraiseTree(way);
					nt.fr = fr;
					nt.marks = appraise(nm, current, fr);
					tree.next.push(nt);
					if (fr.lossTime == 0 || fr.breakLine > 0) continue;
					way = new ControlWay(lx, dir, true);
					nm = current.clone();
					fr = nm.forwardNext(way);
					if (fr == null) continue;
					if (ps && way.dir == 1 && fr.rightDir) way.dir = 3;
					nt = new AppraiseTree(way);
					nt.fr = fr;
					nt.marks = appraise(nm, current, fr);
					tree.next.push(nt);
				}
			}
		}
		
		protected function appraise(current:FragmentGameModel, prev:FragmentGameModel, fr:ForwardResult):Number
		{
			return 0;
		}
		
		protected function postAppraise(current:FragmentGameModel, fr:ForwardResult, notice:int):Number
		{
			return 0;
		}
	}
	
}