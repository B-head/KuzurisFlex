package model 
{
	/**
	 * ...
	 * @author B_head
	 */
	public class MessageObject 
	{
		public static const posting:String = "posting";
		public static const toPeer:String = "toPeer";
		public static const decreasing:String = "decreasing";
		public static const increasing:String = "increasing";
		public static const neighbors:String = "neighbors";
		
		private static var nextSequence:uint;
		
		public var type:String;
		public var obj:Object;
		public var sendMode:String;
		public var peerID:String;
		public var toPeerID:String;
		public var sequence:uint;
		
		public function MessageObject(type:String = "", obj:Object = null, sendMode:String = "", peerID:String = "", toPeerID:String = "") 
		{
			this.type = type;
			this.obj = obj;
			this.sendMode = sendMode;
			this.peerID = peerID;
			this.toPeerID = toPeerID;
			this.sequence = nextSequence++;
		}
		
	}

}