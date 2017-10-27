/**
 * @author GQ
 * create time:2013-11-7- 15:10:29
 */
package com.megaeyes.netmanagement.topology.domain.vo
{
	[Bindable]
	[XmlMapping(elementName="Connection",ignoreUnmappedAttributes="true", ignoreUnmappedChildren="true")]
	public class Connection
	{
		[Attribute("targetId")]
		public var targetId:String;
		
		[Attribute("targetX")]
		public var targetX:int;
		
		[Attribute("targetY")]
		public var targetY:int;
		
		[Attribute("sourceId")]
		public var sourceId:String;
		
		[Attribute("sourceX")]
		public var sourceX:int;
		
		[Attribute("sourceY")]
		public var sourceY:int;
		
//		public var x:int;
//		
//		public var y:int;
		
		public function Connection()
		{
		}
	}
}