package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class GameLightModel extends GameModelBase 
	{
		
		public function GameLightModel() 
		{
			super(false);
		}
		
		public function get mainField():MainField
		{
			return _mainField;
		}
		public function set mainField(value:MainField):void
		{
			_mainField = value;
		}
		
		public function get fallField():MainField
		{
			return _fallField;
		}
		public function set fallField(value:MainField):void
		{
			_fallField = value;
		}
		
		public function get controlOmino():OminoField
		{
			return _controlOmino;
		}
		public function set controlOmino(value:OminoField):void
		{
			_controlOmino = value;
		}
		
		public function get nextOmino():Vector.<OminoField>
		{
			return _nextOmino;
		}
		public function set nextOmino(value:Vector.<OminoField>):void
		{
			_nextOmino = value;
		}
		
	}

}