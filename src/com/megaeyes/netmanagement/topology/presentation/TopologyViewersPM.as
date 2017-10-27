/**
 * @author GQ
 * create time:2013-8-6- 9:07:25
 */
package com.megaeyes.netmanagement.topology.presentation
{
	import com.megaeyes.netmanagement.topology.domain.CustomDevicesDM;
	import com.megaeyes.netmanagement.topology.domain.DevicesDM;
	import com.megaeyes.netmanagement.topology.domain.DivisionDevicesDM;
	import com.megaeyes.netmanagement.topology.domain.PartDevicesDM;
	import com.megaeyes.netmanagement.topology.domain.PlatformDM;
	import com.megaeyes.netmanagement.topology.domain.PlatformDevicesDM;
	import com.megaeyes.netmanagement.topology.domain.TopologyLocationDM;
	import com.megaeyes.netmanagement.topology.domain.vo.Topology;
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.netmanagement.topology.domain.vo.Topologys;
	import com.megaeyes.netmanagement.topology.infrastructure.event.CustomEvent;
	import com.megaeyes.netmanagement.topology.presentation.commands.CommandStack;
	import com.megaeyes.networkmanagement.api.domain.vo.PlatformVO;
	import com.megaeyes.networkmanagement.api.events.local.AlarmNotifyEvent;
	import com.megaeyes.networkmanagement.api.events.local.LocalEvent;
	import com.megaeyes.networkmanagement.api.utils.AlertUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.utils.StringUtil;
	
	import spark.events.IndexChangeEvent;

	[Event(name="add_viewer", type="com.megaeyes.netmanagement.performances.Infrastructure.event.CustomEvent")]
	public class TopologyViewersPM extends EventDispatcher
	{
		public var platformDevicesDM:PlatformDevicesDM;
		
		public var partDevicesDM:PartDevicesDM;
		
		public var platformDM:PlatformDM;
		
		public var divisionDevicesDM:DivisionDevicesDM;
		
		[Bindable]
		public var viewers:IList = new ArrayList();
		
		[Bindable]
		public var selViewerIndex:int;
		
		[Bindable]
		public var platformsXML:XML;
		
		[Bindable]
		public var currentFocusViewer:TopologyViewerPM;
		
		[Bindable]
		public var lock:Boolean
		
		[Inject]
		[Bindable]
		/**
		 * 获取或者保存拓扑图信息（个设备的位置）的domain 
		 */
		public var topologyLocationDM:TopologyLocationDM;
		
		public var customDM:CustomDevicesDM;
		
		[Bindable]
		public var selSavedTopologysItem:Boolean;
		
		private var _showSavePromptWindow:Boolean ;
		
		private var _willDelTopologyId:String;
		
		private var _showTopologys:Array = new Array();
		
		[Bindable]
		public var customViewerName:String = "";
		
		[Bindable]
		public var customViewerNameValid:Boolean = true;
		
		[Bindable]
		public var showCustomViewerPopup:Boolean;
		
		[Bindable]
		public var checkDescription:String="重名";
		
		[Bindable]
		public var selIndex:int = 0;
		
		public function TopologyViewersPM()
		{
		}
		
		[Inject]
		public function injectPlatformDM(dm:PlatformDM):void
		{
			platformDM = dm;
			platformDM.addEventListener("find_platforms_complement",findPlatformsHandler);
			platformDM.findAllPlatforms();
		}
		
		[Inject]
		public function injectDivisionDevicesDM(dm:DivisionDevicesDM):void
		{
			divisionDevicesDM = dm;
			divisionDevicesDM.addEventListener("get_devices_complement",divisionDevicesHandler);
		}
		
		[Inject]
		public function injectPlatformDevicesDM(dm:PlatformDevicesDM):void
		{
			platformDevicesDM = dm;
			platformDevicesDM.addEventListener("get_devices_complement",platformDevicesHandler);
		}
		
		[Inject]
		public function injectPartDM(dm:PartDevicesDM):void
		{
			partDevicesDM = dm;
			partDevicesDM.addEventListener("get_devices_complement",partDevicesHandler);
		}
		
		[Inject]
		public function injectTopologyLocationDM(topologyLocation:TopologyLocationDM):void
		{
			lock = true;
			topologyLocationDM = topologyLocation;
			topologyLocationDM.addEventListener("gain_xml_complement",gainXmlComplementHanlder);
			topologyLocationDM.addEventListener("save_xml_complement",saveXmlComplementHanlder);
			topologyLocationDM.updateInfo(false);
		}
		
		[Inject]
		public function injectCustomDevicesDM(dm:CustomDevicesDM):void
		{
			customDM = dm;
			customDM.addEventListener("get_devices_complement",customAllDeviceHandler);
		}
		
		private function gainXmlComplementHanlder(event:Event):void
		{
			lock = false;
		}
		
		private function saveXmlComplementHanlder(event:Event):void
		{
			if(_showSavePromptWindow){
				if(!topologyLocationDM.updateSuccess){
					AlertUtil.show("保存失败");
				}
			}
			if(topologyLocationDM.updateSuccess){
				topologyLocationDM.updateInfo(false);
			}
		}
		
		private function findPlatformsHandler(event:Event):void
		{
			var xml:String = "<root>";
			var p:PlatformVO = null;
			for(var i:int = 0; i < platformDM.platforms.length; i++){
				p = platformDM.platforms.getItemAt(i) as PlatformVO;
				xml += "<platform id=\""+p.id+"\" name=\""+p.name+"\"/>";
			}
			xml += "</root>";
			platformsXML = new XML(xml);
		}
		
		private function devicesHandler(dm:DevicesDM,id:String,name:String,type:String):void
		{
			if(dm.relationgDevices.length == 0){
				lock = false;
				AlertUtil.show("没有设备！","提示");
				return;
			}
			try{
				var ce:CustomEvent = new CustomEvent("add_viewer");
				ce.data = new Object();
				ce.data.devices = dm.relationgDevices;
				ce.data.id= id;
				ce.data.name= name;
				ce.data.type=type;
				dispatchEvent(ce);
			}catch(e:Error){
				AlertUtil.show(e.message);
			}
		}
		
		private function divisionDevicesHandler(event:Event):void
		{
			var id:String = "division_"+ divisionDevicesDM.divisionId;
			var name:String = "(分组)"+divisionDevicesDM.divisionName;
			devicesHandler(divisionDevicesDM,id,name,"division");
		}
		
		private function platformDevicesHandler(event:Event):void
		{
			var id:String = "platform_"+ platformDevicesDM.findPlatformId;
			var name:String = "(平台)"+platformDevicesDM.findPlatformName;
			devicesHandler(platformDevicesDM,id,name,"platform");
			
		}
		
		private function partDevicesHandler(event:Event):void
		{
			if(partDevicesDM.mainDevice){
				var id:String = partDevicesDM.mainDevice.deviceId;
				var name:String = partDevicesDM.mainDevice.deviceName;
				devicesHandler(partDevicesDM,id,name,"device");
			}else{
				Alert.show("没有找到设备！","提示");
			}
		}
		
		private function customAllDeviceHandler(event:Event):void
		{
			var id:String = customDM.localSaveInfo.id;
			var name:String = customDM.localSaveInfo.name;
			devicesHandler(customDM,id,name,"custom");
		}
		
		public function addOneViewerPM(pm:TopologyViewerPM):void{
			this.viewers.addItem(pm);
			this.selViewerIndex = viewers.length-1;
			currentFocusViewer = pm;
			pm.updateTopologyInfo();
			_showTopologys.push(pm.topologyInfo);
			lock = false;
		}
		
		public function selSavedTopologysChangeHandler(xml:XML):void
		{
			if(xml.@layer == "1"){
				selSavedTopologysItem = true;
			}else{
				selSavedTopologysItem = false;
			}
		}
		
		public function deleSavedTopologysItem(xml:XML):void
		{
			AlertUtil.okLabel="确定";
			AlertUtil.cancelLabel="取消";
			_willDelTopologyId = xml.@id;
			AlertUtil.show("确认删除吗？","提示",AlertUtil.OK|Alert.CANCEL,null,doDel,null,AlertUtil.CANCEL);
		}
		
		private function doDel(event:CloseEvent):void
		{
			if(event.detail == Alert.OK){
				_showSavePromptWindow = false;
				this.topologyLocationDM.delTopology(_willDelTopologyId);
				topologyLocationDM.updateInfo(true);
				selSavedTopologysItem = false;
			}
		}
		
		public function openSavedTopologyHandler(xml:XML):void
		{
			if(lock){
				return;
			}
			if(xml.@layer == "1"){
				var index:int = focusViewer(xml.@id);
				if(index > -1){
					selViewerIndex = index;
				}else{
					lock = true;
					if(String(xml.@id).indexOf("platform_") == 0){
						platformDevicesDM.gainDevicesByPlatform(String(xml.@id).substr(9),String(xml.@name).substr(4));
					}else if(String(xml.@id).indexOf("division_") == 0){
						divisionDevicesDM.gainDevicesByDivision(String(xml.@id).substr(9),String(xml.@name).substr(4));
					}else if(String(xml.@id).indexOf("custom_") == 0){
						selIndex = 2;
						var de:Topology = topologyLocationDM.getTopologyById(xml.@id);
						customDM.localSaveInfo = de;
						customDM.findTopologyDevices();
					}else{
						partDevicesDM.findTopologyDevices(xml.@id);
					}
				}
			}
		}
		
		/**
		 *驱动 
		 * 打开指定平台的拓扑图
		 * @param xml
		 * 
		 */
		public function platformChangeHandler(xml:XML):void
		{
			if(lock){
				return;
			}
			if(xml.@id == ""){
				return;
			}
			var index:int = focusViewer("platform_"+xml.@id);
			if(index > -1){
				selViewerIndex = index;
			}else{
				lock = true;
				platformDevicesDM.gainDevicesByPlatform(xml.@id,xml.@name);
			}
		}
		
		public function divisionChangeHanlder(xml:XML):void
		{
			var id:String = xml.@id;
			var name:String = xml.@name;
			if(lock){
				return;
			}
			var index:int = focusViewer("division_"+id);
			if(index > -1){
				selViewerIndex = index;
			}else{
				lock = true;
				divisionDevicesDM.gainDevicesByDivision(id,name);
			}
		}
		
		public function changeSelView():void
		{
			if(selViewerIndex>-1){
				currentFocusViewer = viewers.getItemAt(selViewerIndex) as TopologyViewerPM;
			}else{
				currentFocusViewer = null;
			}
		}
		
		/**
		 *驱动 
		 * 打开指定设备的拓扑图
		 * @param deviceId
		 * 
		 */
		public function addDeviceTopology(deviceId:String):void
		{
			var index:int = focusViewer(deviceId);
			if(index > -1){
				selViewerIndex = index;
			}else{
				lock = true;
				partDevicesDM.findTopologyDevices(deviceId);
			}
		}
		
		private function focusViewer(id:String):int
		{
			var index:int = -1;
			var pm:TopologyViewerPM = null;
			for(var i:int = 0; i < viewers.length; i++){
				pm = viewers.getItemAt(i) as TopologyViewerPM;
				if(pm.id == id){
					index = i;
					currentFocusViewer = pm;
					break;
				}
			}
			return index;
		}
		
		public function doRemoveCurrentViewer(e:CloseEvent=null):void
		{
			if(e && e.detail!=Alert.OK){
				return;	
			}
			viewers.removeItemAt(selViewerIndex);
			var i:int = 0;
			for each(var t:Topology in _showTopologys){
				if(t.id == currentFocusViewer.id){
					_showTopologys.splice(i,1);
				}
				i++;
			}
			var ci:int = selViewerIndex - 1;
			if(ci < 0){
				ci = viewers.length > 0 ? 0 : -1;
			}
			if(ci == -1){
				currentFocusViewer = null;
			}else{
				currentFocusViewer = viewers.getItemAt(ci) as TopologyViewerPM;
			}
			selViewerIndex = ci;
		}
		
		public function autoLayout():void
		{
			currentFocusViewer.autoLayout();
		}
		
		public function getSaveTopologyInfo(id:String):Topology
		{
			var vo:Topology = null;
			if(this.topologyLocationDM && this.topologyLocationDM.data){
				vo = topologyLocationDM.getTopologyById(id);
			}
			return vo;
		}
		
		public function saveTopologysInfo():void
		{
			_showSavePromptWindow = true;
			currentFocusViewer.updateTopologyInfo();
			if(topologyLocationDM.data == null){
				topologyLocationDM.newData();
			}	
			if(topologyLocationDM.data.topologys == null){
				topologyLocationDM.data.topologys = new Array();
			}
			var info:Topology = null;
			for(var i:int = 0; i < topologyLocationDM.data.topologys.length; i++){
				info = topologyLocationDM.data.topologys[i] as Topology;
				if(info.id == currentFocusViewer.topologyInfo.id){
					topologyLocationDM.data.topologys.splice(i,1);
					break;
				}
			}
			topologyLocationDM.data.topologys.push(currentFocusViewer.topologyInfo);
			lock = true;
			topologyLocationDM.updateInfo(true);
			currentFocusViewer.commandStack.markSaveLocation();
		}
		
		[MessageHandler]
		public function notifyAlarmHanlder(event:AlarmNotifyEvent):void
		{
			var pm:TopologyViewerPM = null;
			for(var i:int = 0; i < viewers.length;i++){
				pm = viewers.getItemAt(i) as TopologyViewerPM;
				pm.notifyAlarmHanlder(event.alarm);
			}
		}
		
		public function undo():void
		{
			currentFocusViewer.commandStack.undo();
		}
		
		public function redo():void
		{
			currentFocusViewer.commandStack.redo();
		}
		
		public function showCustomViewerPopupF():void
		{
			showCustomViewerPopup = true;
			doCheckCustomViewerName();
		}
		
		public function addCustomViewer():void
		{
			if(customViewerNameValid)
				doAddCustomViewer("(自定义)"+customViewerName,"custom_"+new Date().time);
		}
		
		public function doAddCustomViewer(name:String,id:String,array:Array=null):void
		{
			var ce:CustomEvent = new CustomEvent("add_viewer");
			ce.data = new Object();
			ce.data.id= id;
			ce.data.name= name;
			ce.data.type="custom";
			var list:IList = new ArrayList();
			if(array){
				for each(var de:Topology in array){
					list.addItem(de);
				}
			}
			ce.data.devices = list;
			dispatchEvent(ce);
			closeAddCustomeViewerPopup();
			selIndex = 2;
		}
		
		public function closeAddCustomeViewerPopup():void
		{
			showCustomViewerPopup = false;
			customViewerName = "";
		}
		
		public function lineBtnClick(event:Event):void
		{
			currentFocusViewer.lineBtnClick(event);
		}
		
		public function doCheckCustomViewerName():void
		{
			if(StringUtil.trim(customViewerName).length==0){
				checkDescription="不能为空";
				customViewerNameValid = false;
				return;
			}
			checkDescription="重名";
			customViewerName = StringUtil.trim(customViewerName);
			customViewerNameValid =!topologyLocationDM.checkName("(自定义)"+customViewerName);
			if(customViewerNameValid){
				for each(var t:Topology in _showTopologys){
					if(t.name == ("(自定义)"+customViewerName)){
						customViewerNameValid = false;
						break;
					}
				}
			}
		}
		
		public function refreshDevice():void
		{
			this.partDevicesDM.refreshDevice(currentFocusViewer.model);
		}
	}
}