package model.network {
	/**
	 * ...
	 * @author B_head
	 */
	public class MessageObject 
	{
		private static var nextSequence:uint;
		
		public var type:String;
		public var obj:Object;
		public var peerID:String;
		public var toPeerID:String;
		public var sequence:uint;
		
		public function MessageObject(type:String = "", obj:Object = null, peerID:String = "", toPeerID:String = "") 
		{
			this.type = type;
			this.obj = obj;
			this.peerID = peerID;
			this.toPeerID = toPeerID;
			this.sequence = nextSequence++;
		}
		
	}

}