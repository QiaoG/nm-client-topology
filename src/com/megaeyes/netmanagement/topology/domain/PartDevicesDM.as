/**
 * 用于获取指定设备的上级及子设备
 * @author GQ
 * create time:2013-8-5- 9:25:44
 */
package com.megaeyes.netmanagement.topology.domain
{
	import com.megaeyes.networkmanagement.api.application.events.WebServiceEvent;
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.netmanagement.topology.presentation.TopologyModel;
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	import com.megaeyes.networkmanagement.api.domain.query.ReqDeviceQuery;
	import com.megaeyes.networkmanagement.api.utils.AlertUtil;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;

	public class PartDevicesDM extends DevicesDM
	{
		public var mainDevice:TopologyDevice;
		
		public var rootDevice:TopologyDevice;
		
		public function PartDevicesDM()
		{
			super();
		}
		
		private function clear():void
		{
			devices.removeAll();
			mainDevice = null;
		}
		
		/**
		 *查找指定设备的相关设备 
		 * @param id
		 * 
		 */
		public function findTopologyDevices(id:String):void
		{
			if(lock){
				return;
			}
			clear();
			lock = true;
			relationgDevices.removeAll();
			getDeviceById(id);
		}
		
		public function refreshDevice(model:TopologyModel):void
		{
			var query:Object = new Object();
			query.deviceId = model.focusNode.data.deviceId;
			query.size = 0;
			query.model = model;
			var event:WebServiceEvent = new WebServiceEvent("get_device_by_id_2", query);
			dispatcher(event);
		}
		
		private function getDeviceById(id:String,state:int=0):void
		{
			var query:Object = new Object();
			query.deviceId = id;
			query.size = 0;
			query.state = state;
			var event:WebServiceEvent = new WebServiceEvent("get_device_by_id", query);
			dispatcher(event);
		}
		
		public function addSubChildren(device:TopologyDevice):void
		{
			var query:Object = new Object();
			query.parentId = device.deviceId;
			query.childTypes = [device.deviceType];
			query.state = 1;
			var event:WebServiceEvent = new WebServiceEvent("find_children_devices_by_id", query);
			dispatcher(event);
		}
		
		private function findAllChildrenById(device:TopologyDevice):void
		{
			var query:Object = new Object();
			query.parentId = device.deviceId;
			query.childTypes = getAllChildrenTypes(device.deviceType);
			query.state = 0;
			var event:WebServiceEvent = new WebServiceEvent("find_children_devices_by_id", query);
			dispatcher(event);
		}
		
		private function getAllChildrenTypes(parentType:String):Array
		{
			if(parentType == "40"){//接入
				return ["40","41","42","45","47","48","20"];
			}
			if(parentType == "43"){//中心
				return ["40","43","44","46"];
			}
			if(parentType == "02"){//视频服务器
				return ["05"];
			}
			return [parentType];
		}
		
		[CommandResult(selector="get_device_by_id_2")]
		public function getDevice2ResultHandler(result:Object,e:WebServiceEvent):void
		{
			var list:ArrayCollection = result.data as ArrayCollection;
			if(list && list.length>0){
				var device:TopologyDevice = transferToDeviceVO(list.getItemAt(0));
				TopologyModel(e.para.model).refreshFocusDevice(device);
				
			}else{
				AlertUtil.show("刷新失败,设备不存在！");
			}
		}
		
		[CommandError(selector="get_device_by_id_2")]
		public function getDevice2ErrorHandler(fault:FaultEvent,e:WebServiceEvent):void
		{
			AlertUtil.show("刷新失败,获取错误！");
		}
		
		[CommandResult(selector="get_device_by_id")]
		public function getDeviceResultHandler(result:Object,e:WebServiceEvent):void
		{
			var list:ArrayCollection = result.data as ArrayCollection;
			if(list && list.length>0){
				var d:Object = list.getItemAt(0);
				var device:TopologyDevice = transferToDeviceVO(d);
				rootDevice = device;
				if(e.para.state == 0){
					mainDevice = device;
					if(mainDevice.parentId && mainDevice.parentId.length>3){
						getDeviceById(mainDevice.parentId,1);
					}else{
						findAllChildrenById(mainDevice);
					}
				}else{
					if(rootDevice.deviceType == mainDevice.deviceType){//父是自己的集群宿主，则继续获取宿主的父设备
						mainDevice = rootDevice;
						if(rootDevice.deviceType != "43"){
							getDeviceById(rootDevice.parentId,1);
							return;
						}
					}else{
						rootDevice.children.addItem(mainDevice);
					}
					findAllChildrenById(mainDevice);
				}
			}else{
				if(e.para.state == 0){
					gainDeviceComplement(e);
				}else{
					findAllChildrenById(mainDevice);
				}
				
			}
		}
		
		[CommandResult(selector="find_children_devices_by_id")]
		public function findChildrenResultHandler(result:Object,e:WebServiceEvent):void
		{
			var list:ArrayCollection = result.data as ArrayCollection;
			if(list){
				var device:TopologyDevice = null;
				for(var i:int = 0; i < list.length; i++){
					device = transferToDeviceVO(list.getItemAt(i));
					if(device.deviceType == mainDevice.deviceType){
						var h:Boolean = false;
						for(var n:int = 0; n < mainDevice.subChildren.length; n++){
							if(TopologyDevice(mainDevice.subChildren.getItemAt(n)).deviceId == device.deviceId){
								h = true;
								break;
							}
						}
						if(!h)
							mainDevice.subChildren.addItem(device);
					}else{
						mainDevice.children.addItem(device);
					}
				}
				if(e.para.state == 1){
					mainDevice.dispatchSubChangeEvent();
				}
			}
			checkDeviceOnline(mainDevice);
			gainDeviceComplement(e);
		}
		
		[CommandError(selector="get_device_by_id")]
		public function getDeviceErrorHandler(fault:FaultEvent,e:WebServiceEvent):void
		{
			if(e.para.state == 0){
				gainDeviceComplement(e);
			}else{
				findAllChildrenById(mainDevice);
			}
		}
		
		[CommandError(selector="find_children_devices_by_id")]
		public function findChildrenErrorHandler(fault:FaultEvent,e:WebServiceEvent):void
		{
			gainDeviceComplement(e);
		}
		
		override protected function gainDeviceComplement(e:WebServiceEvent,d:TopologyDevice=null):void
		{
			if(rootDevice && relationgDevices.length==0){
				relationgDevices.addItem(rootDevice);
			}
			super.gainDeviceComplement(e);
		}
		
	}
	
}