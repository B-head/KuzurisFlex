package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class PlayerInformation 
	{
		[Bindable]
		public var name:String;
		public var isAI:Boolean;
		public var peerID:String;
		
		public function PlayerInformation() 
		{
			name = "名無しさん";
		}
		
	}

}