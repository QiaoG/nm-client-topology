/**
 * @author GQ
 * create time:2013-9-25- 15:52:03
 */
package com.megaeyes.netmanagement.topology.domain.vo
{
	[Bindable]
	[XmlMapping(elementName="Topology",ignoreUnmappedAttributes="true", ignoreUnmappedChildren="true")]
	public class Topology
	{
		public var layer:int = 1;
		
		public var id:String;
		
		public var name:String;
		
		public var width:int;
		
		public var height:int;
		
		public var icon:String;
		
		[ChoiceType("com.megaeyes.netmanagement.topology.domain.vo.Device")]
		public var devices:Array;
		
		public function Topology()
		{
		}
	}
}