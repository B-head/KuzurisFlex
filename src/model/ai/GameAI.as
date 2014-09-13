package model.ai {
	import model.AppraiseTree;
	import model.ControlWay;
	import model.GameLightModel;
	
	/**
	 * ...
	 * @author B_head
	 */
	public class GameAI 
	{
		protected var currentModel:GameLightModel;
		protected var treeRoot:AppraiseTree;
		
		public function setCurrentModel(currentModel:GameLightModel):void
		{
			this.currentModel = currentModel;
			treeRoot = new AppraiseTree(null);
		}
		
		public function createTargetWay():ControlWay
		{
			var ret:ControlWay = new ControlWay();
			ret.lx = Math.random() * 9;
			ret.dir = Math.random() * 4;
			return ret;
		}
	}
	
}