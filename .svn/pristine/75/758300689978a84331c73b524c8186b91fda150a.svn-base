/**
 * @author GQ
 * create time:2013-7-25- 11:05:47
 */
package com.megaeyes.netmanagement.topology.domain.vo
{
	import com.megaeyes.networkmanagement.api.domain.vo.Device;
	
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	
	[Event(name="subchildren_change", type="flash.events.Event")]
	public class TopologyDevice extends Device
	{
		[Bindable]
		public var displayName:String;
		
		[Bindable]
		public var tooltip:String;
		
		[Bindable]
		public var parent:TopologyDevice;
		
		[Bindable]
		public var children:IList = new ArrayList();
		
		[Bindable]
		/**
		 *集群或双击子设备 
		 * @return 
		 * 
		 */
		public var subChildren:IList = new ArrayList();
		
		[Bindable]
		public var properties:IList = new ArrayList();
		
		public function TopologyDevice()
		{
			super();
		}
		
		public function toXMLString():String
		{
			var xml:String = "";
			xml += "<device id=\""+deviceId+"\" name=\""+deviceName+"\" online=\""+onLine+"\" icon=\""+getIcon()+"\">";
			for(var i:int = 0; i < children.length; i++){
				xml += TopologyDevice(children.getItemAt(i)).toXMLString();
			}
			xml += "</device>";
			return xml;
		}
		
		private function getIcon():String
		{
			var icon:String = "SERVER";
			if(deviceType == "20"){
				icon = "WALL";
			}
			if(deviceType == "05"){
				icon = "DEVICE";
			}
			return icon;
		}
		
		public function dispatchSubChangeEvent():void
		{
			dispatchEvent(new Event("subchildren_change"));
		}
		
		public function removeSubChildren():void
		{
			subChildren.removeAll();
			dispatchEvent(new Event("subchildren_change"));
		}
	}
}