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
		private var nextModel:FragmentGameModel;
		
		public function GameAI()
		{
			nextModel = new FragmentGameModel();
		}
		
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
		
		private function considerTree(tree:AppraiseTree, current:FragmentGameModel):void
		{
			var ps:Boolean = current.controlOmino.isPointSymmetry();
			var p90s:Boolean = current.controlOmino.isPoint90Symmetry();
			for (var lx:int = 0; lx < GameModelBase.fieldWidth; lx++)
			{
				for (var dir:int = 0; dir < 4; dir++)
				{
					if (ps == true && (dir == 2 || dir == 3)) continue;
					if (p90s == true && dir == 1) continue;
					var nt:AppraiseTree = considerWay(current, ps, lx, dir, false);
					if (nt != null) tree.next.push(nt);
					if (nt == null || nt.fr.lossTime == 0) continue; //TODO ゲームオーバー時でも崩壊判定できるようにする。
					nt = considerWay(current, ps, lx, dir, true);
					if (nt != null) tree.next.push(nt);
				}
			}
		}
		
		private function considerWay(current:FragmentGameModel, ps:Boolean, lx:int, dir:int, shift:Boolean):AppraiseTree
		{
			var way:ControlWay = new ControlWay(lx, dir, false);
			current.copyTo(nextModel);
			var rect:Rect = way.getControlRect(current);
			if (ps && way.dir == 1 && way.getCox(rect) >= current.init_cox(rect)) way.dir = 3;
			var fr:ForwardResult = nextModel.forwardNext(way);
			if (fr == null) return null;
			var marks:Number = appraise(nextModel, current, fr);
			return new AppraiseTree(way, null, fr, marks);
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