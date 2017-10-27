/**
 * @author GQ
 * create time:2013-9-25- 15:51:53
 */
package com.megaeyes.netmanagement.topology.domain.vo
{
	[Bindable]
	[XmlMapping(elementName="Device",ignoreUnmappedAttributes="true", ignoreUnmappedChildren="true")]
	public class Device
	{
		public var layer:int = 2;
		
		public var id:String;
		
		public var name:String;
		
		[Attribute("typeName")]
		public var typeName:String;
		
		public var type:String;
		
		public var x:int;
		
		public var y:int;
		
		public var icon:String;
		
		[ChoiceType("com.megaeyes.netmanagement.topology.domain.vo.Connection")]
		public var cons:Array;
		
		public function Device()
		{
		}
	}
}