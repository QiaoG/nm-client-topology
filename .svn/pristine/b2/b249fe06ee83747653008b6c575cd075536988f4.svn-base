/**
 * @author GQ
 * create time:2013-7-31- 16:31:03
 */
package com.megaeyes.netmanagement.topology.domain
{
	import com.megaeyes.networkmanagement.api.application.events.WebServiceEvent;
	import com.megaeyes.netmanagement.topology.domain.vo.PropertiesVO;
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.netmanagement.topology.infrastructure.TopologyUtil;
	import com.megaeyes.networkmanagement.api.domain.query.ReqDeviceQuery;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	import org.spicefactory.parsley.tag.core.ObjectDecoratorMarker;

	[Event(name="get_devices_complement", type="flash.events.Event")]
	public class DevicesDM extends EventDispatcher
	{
		public const CMS:String = "43";
		
		public const PU:String ="02";
		
		[Bindable]
		/**
		 *所有的平台设备 
		 */
		public var devices:IList = new ArrayList();
		
		[MessageDispatcher]
		public var dispatcher:Function;
		
		public var relationgDevices:IList = new ArrayList();
		
		[Bindable]
		public var lock:Boolean
		
		public function DevicesDM()
		{
		}
		
		protected function gainDeviceComplement(e:WebServiceEvent,d:TopologyDevice=null):void
		{
			lock = false;
			this.dispatchEvent(new Event("get_devices_complement"));
		}
		
		/**
		 *为离散设备建立关系
		 * 
		 */
		public function addRelations(list:IList,index:int = 0):void
		{
			if(index >= list.length){
				return;
			}
			var d:TopologyDevice = list.getItemAt(index) as TopologyDevice;
			var parent:TopologyDevice = null;
			for(var i:int = 0; i < list.length; i++){
				if(i == index){
					continue;
				}
				parent = findParent(d.parentId,list.getItemAt(i) as TopologyDevice);
				if(parent){
					if(d.deviceType == parent.deviceType){
						parent.subChildren.addItem(d);
					}else{
						parent.children.addItem(d);
					}
					break;
				}
			}
			if(parent){
				list.removeItemAt(index);
				addRelations(list,index);
			}else{
				addRelations(list,index+1);
			}
		}
		
		/**
		 *在指定的设备中查找父 
		 * @param id
		 * @param device
		 * @return 
		 * 
		 */
		private function findParent(parentId:String,device:TopologyDevice):TopologyDevice
		{
			var parent:TopologyDevice = null;
			if(device.deviceId == parentId){
				parent = device;
			}else{
				for(var i:int = 0; i < device.children.length; i++){
					parent = findParent(parentId,device.children.getItemAt(i) as TopologyDevice);
					if(parent){
						break;
					}
				}
			}
			return parent;
		}
		
		/**
		 *根据集群/双机的状态来判断虚拟父设备的在线状态 
		 * @param parent
		 * 
		 */
		protected function checkDeviceOnline(parent:TopologyDevice):void
		{
			if(parent==null){
				return;
			}
			var child:TopologyDevice = null;
			if(parent.subChildren.length>0){
				var co:Boolean = false;
				for(var i:int = 0; i < parent.subChildren.length; i++){
					child = parent.subChildren.getItemAt(i) as TopologyDevice;
					if(child.onLine){
						co = true;
						if(child.currentStatus >= 4){
							parent.currentStatus = child.currentStatus;
						}
						if(child.currentStatus > 4 && child.currentStatus < parent.currentStatus){
							parent.currentStatus = child.currentStatus;
						}
					}
				}
				parent.isVirtual = true;
				parent.onLine = co;
				parent.properties.getItemAt(9).value = parent.onLine?(parent.currentStatus == 4 ? "正常":(parent.currentStatus==5?'严重告警':(parent.currentStatus==6?'主要告警':'警告告警'))):"不在线";
			}else{
				parent.isVirtual = false;
			}
			parent.properties.getItemAt(8).value = parent.isVirtual?"虚拟设备":"实际设备";
			for(var n:int = 0; n < parent.children.length; n++){
				child = parent.children.getItemAt(n) as TopologyDevice;
				checkDeviceOnline(child);
			}
			
		}

		protected function transferToDeviceVO(object:Object):TopologyDevice
		{
			return TopologyUtil.transferToDeviceVO(object);
		}
		
	}
}