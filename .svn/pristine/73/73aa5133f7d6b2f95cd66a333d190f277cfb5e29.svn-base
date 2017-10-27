/**
 * @author GQ
 * create time:2013-11-4- 14:22:08
 */
package com.megaeyes.netmanagement.topology.domain
{
	import com.megaeyes.networkmanagement.api.application.events.WebServiceEvent;
	import com.megaeyes.netmanagement.topology.domain.vo.Device;
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.netmanagement.topology.domain.vo.Topology;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;

	public class CustomDevicesDM extends DevicesDM
	{
		private var _currentIndex:int = 0;
		
		public var localSaveInfo:Topology;
		
		public function CustomDevicesDM()
		{
			super();
		}
		
		/**
		 *查找指定设备的相关设备 
		 * @param id
		 * 
		 */
		public function findTopologyDevices():void
		{
			if(localSaveInfo ==null || localSaveInfo.devices==null){
				gainDeviceComplement(null);
				return;
			}
			if(lock){
				return;
			}
			lock = true;
			relationgDevices.removeAll();
			_currentIndex = 0;
			getDeviceById();
		}
		
		private function getDeviceById():void
		{
			if(_currentIndex >= localSaveInfo.devices.length){
				gainDeviceComplement(null);
				return;
			}
			var id:String = localSaveInfo.devices[_currentIndex++].id;
			var query:Object = new Object();
			query.deviceId = id;
			query.size = 0;
			var event:WebServiceEvent = new WebServiceEvent("get_device_by_id_custom", query);
			dispatcher(event);
		}
		
		[CommandResult(selector="get_device_by_id_custom")]
		public function getDeviceResultHandler(result:Object,e:WebServiceEvent):void
		{
			var list:ArrayCollection = result.data as ArrayCollection;
			if(list && list.length>0){
				var d:Object = list.getItemAt(0);
				var device:TopologyDevice = transferToDeviceVO(d);
				relationgDevices.addItem(device);
			}else{
//				Alert.show("result = null "+e.para.deviceId);
			}
			getDeviceById();
		}
		
		[CommandError(selector="get_device_by_id_custom")]
		public function getDeviceErrorHandler(fault:FaultEvent,e:WebServiceEvent):void
		{
			getDeviceById();
		}
	}
}