/**
 * 用于显示指定平台所有的服务器设备
 * @author GQ
 * create time:2013-8-5- 9:25:54
 */
package com.megaeyes.netmanagement.topology.domain
{
	import com.megaeyes.networkmanagement.api.application.events.WebServiceEvent;
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.networkmanagement.api.domain.query.ReqDeviceQuery;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.rpc.events.FaultEvent;

	public class PlatformDevicesDM extends DevicesDM
	{
		public var findPlatformId:String;
		
		public var findPlatformName:String;
		
		public function PlatformDevicesDM()
		{
		}
		
		public function gainDevicesByPlatform(platformId:String="-1",platformName:String=""):void
		{
			if(lock){
				return;
			}
			relationgDevices.removeAll();
			findPlatformId = platformId;
			findPlatformName = platformName;
			devices.removeAll();
			var query:ReqDeviceQuery = new ReqDeviceQuery();
			query.platformId = Number(platformId);
			query.isPlatFormDevices = true;
			query.size = 0;
			var event:WebServiceEvent = new WebServiceEvent("find_devices_by_platform", query);
			lock = true;
			dispatcher(event);
//			mockRequestDisptch(event);
		}
		
		[CommandResult(selector="find_devices_by_platform")]
		public function queryResultHandler(result:Object,e:WebServiceEvent):void
		{
			
			var list:IList = result.data as IList;
			if(list){
				var d:TopologyDevice = null;
				for(var i:int = 0; i < list.length; i++){
					if(list.getItemAt(i).deviceType == "20"){
						continue;
					}
					d = transferToDeviceVO(list.getItemAt(i));
					devices.addItem(d);
					relationgDevices.addItem(d);
				}
			}
			addRelations(relationgDevices);
			
			for(var j:int = 0; j < relationgDevices.length; j++){
				checkDeviceOnline(relationgDevices.getItemAt(j) as TopologyDevice);
			}
			
			gainDeviceComplement(e);
		}
		
		[CommandError(selector="find_devices_by_platform")]
		public function queryErrorHandler(fault:FaultEvent,e:WebServiceEvent):void
		{
			gainDeviceComplement(e);
		}
		
		//------------------------------------------------------------------
		//                         mock
		//------------------------------------------------------------------
		private function mockRequestDisptch(event:WebServiceEvent):void
		{
			var result:Object = new Object();
			var data:IList = new ArrayList();
			result.data = data;
			var root:TopologyDevice = new TopologyDevice();
			root.deviceId = "1";
			root.deviceName = "test_1";
			root.deviceType = "43";
			root.deviceTypeName= "中心服务器";
			data.addItem(root);
			mockAddChildren(root,data);
			queryResultHandler(result,event);
		}
		
		/**
		 *模拟添加双机/集群子设备 
		 * @param parent
		 * @param list
		 * 
		 */
		private function mockAddSubChildren(parent:Object,list:IList):int
		{
			var count:int = Math.round(Math.random()*3)+1;
			var child:Object = null;
			for(var i:int = 0; i < count; i++){
				child = new Object();
				child.deviceId = parent.deviceId + "_" + i;
				child.parentId = parent.deviceId;
				child.deviceName = "test_"+child.deviceId;
				child.deviceType = parent.deviceType;
				child.deviceTypeName = parent.deviceTypeName;
				child.onLine = Math.round(Math.random())==0?false:true;
				child.isVirtual = false;
				list.addItem(child);
			}
			return count;
		}
		
		/**
		 *模拟添加子设备 
		 * @param parent
		 * @param list
		 * @param layer
		 * 
		 */
		private function mockAddChildren(parent:Object,list:IList,layer:int = 1):void
		{
			mockAddSubChildren(parent,list);
			if(layer == 3){
				return;
			}
			parent.isVirtual = true;
			var count:int = Math.round(Math.random()*5)+2;
			var child:Object = null;
			for(var i:int = 0; i < count; i++){
				child = new Object();
				child.deviceId = list.length+"";
				child.parentId = parent.deviceId;
				child.deviceName = "test_"+child.deviceId;
				child.deviceType = layer==1?"40":"41";
				child.deviceTypeName = layer==1?"接入服务器":"存储服务器";
				child.onLine = Math.round(Math.random())==0?false:true;
				list.addItem(child);
				mockAddChildren(child,list,layer+1);
			}
		}
	}
}