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
				next[i].marks += postAppraise(next[i].fr, notice);
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
			for (var dir:int = 0; dir < 4; dir++)
			{
				var rect:Rect = current.controlOmino.getRect();
				var fr:Range = current.getValidRange(current.init_cox(rect), current.init_coy(rect), dir, true);
				for (var flx:int = fr.low; flx <= fr.high; flx++)
				{
					if (ps == true && (dir == 2 || dir == 3)) continue;
					if (p90s == true && dir == 1) continue;
					var fw:ControlWay = new ControlWay(flx, dir, false);
					var nt:AppraiseTree = considerWay(current, ps, fw);
					if (nt == null) continue;
					tree.next.push(nt);
					var fixCox:int = nt.fr.fixCox;
					var fixCoy:int = nt.fr.fixCoy;
					var fixDir:int = fw.dir;
					if (nt.fr.lossTime > 0 && nt.fr.breakLine == 0)
					{
						fw = new ControlWay(flx, dir, true);
						nt = considerWay(current, ps, fw);
						if (nt != null) tree.next.push(nt);
					}
					var sr:Range = current.getValidRange(fixCox, fixCoy, fixDir, false);
					for (var slx:int = sr.low; slx <= sr.high; slx++)
					{
						if (flx == slx) continue;
						fw = new ControlWay(flx, dir, false);
						var sw:ControlWay = new ControlWay(slx, dir, false);
						nt = considerWay(current, ps, fw, sw);
						if (nt != null) tree.next.push(nt);
					}
				}
			}
		}
		
		private function considerWay(current:FragmentGameModel, ps:Boolean, fw:ControlWay, sw:ControlWay = null):AppraiseTree
		{
			current.copyTo(nextModel);
			var rect:Rect = fw.getControlRect(nextModel);
			if (ps && fw.dir == 1 && fw.getCox(rect) >= nextModel.init_cox(rect)) 
			{
				fw.dir = 3;
				if (sw != null) sw.dir = 3;
			}
			var fr:ForwardResult = nextModel.forwardNext(fw, sw);
			if (fr == null) return null;
			var marks:Number = appraise(nextModel, current, fr);
			return new AppraiseTree(fw, sw, fr, marks);
		}
		
		protected function appraise(current:FragmentGameModel, prev:FragmentGameModel, fr:ForwardResult):Number
		{
			return 0;
		}
		
		protected function postAppraise(fr:ForwardResult, notice:int):Number
		{
			return 0;
		}
	}
	
}