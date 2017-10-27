/**
 * @author GQ
 * create time:2013-7-10- 16:26:22
 */
package com.megaeyes.netmanagement.topology.presentation
{
	import com.megaeyes.netmanagement.topology.domain.vo.Connection;
	import com.megaeyes.netmanagement.topology.domain.vo.Device;
	import com.megaeyes.netmanagement.topology.domain.vo.Topology;
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.netmanagement.topology.infrastructure.event.CustomEvent;
	import com.megaeyes.netmanagement.topology.presentation.commands.CommandStack;
	import com.megaeyes.netmanagement.topology.presentation.connection.ConnectionPM;
	import com.megaeyes.netmanagement.topology.presentation.layout.CircleLayout;
	import com.megaeyes.netmanagement.topology.presentation.layout.DefaultLayout;
	import com.megaeyes.netmanagement.topology.presentation.layout.DiscreteLayout;
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	import com.megaeyes.networkmanagement.api.domain.vo.AlarmVO;
	import com.megaeyes.networkmanagement.api.view.tree.LocalTreeBase;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.managers.CursorManager;
	
	import spark.components.BorderContainer;
	import spark.components.NavigatorContent;
	import spark.components.Scroller;

	[Event(name="dirty_change", type="flash.events.Event")]
	public class TopologyViewerPM extends EventDispatcher
	{
		
		[Bindable]
		public var canvas:TopologyCanvasPM;
		
		[Bindable]
		public var hawkeye:HawkeyeViewerPM;
		
		[Bindable]
		public var model:TopologyModel;
		
		public var id:String;
		
		public var name:String;
		
		[Bindable]
		/**
		 *类型
		 * 平台：'platform'
		 * 分组：'division'
		 * 设备：'device' 
		 * 自定义：'custom'
		 */
		public var type:String;
		
		public var outline:LocalTreeBase;
		
		[Bindable]
		public var selectedDeviceXML:Object;
		
		private var _topologyInfo:Topology;
		
		[Bindable]
		public var commandStack:CommandStack;
		
		[Bindable]
		public var isDirty:Boolean;
		
		[Bindable]
		public var lineBtnSelected:Boolean;
		
		public var layouts:IList = new ArrayList();
		
		public function TopologyViewerPM()
		{
			model = new TopologyModel();
			commandStack = new CommandStack();
			commandStack.addEventListener("dirty_change",dirtyChangeHandler);
		}
		
		/**
		 * 保存的拓扑图信息 
		 */
		public function get topologyInfo():Topology
		{
			return _topologyInfo;
		}

		/**
		 * @private
		 */
		public function set topologyInfo(value:Topology):void
		{
			_topologyInfo = value;
		}

		
		/**
		 * 绘制的触发方法
		 *不包含关系的设备列表
		 * @param devices
		 * @param mainId
		 * 
		 */
		public function setDevices(devices:IList,mainId:String = null):void
		{
			model.setDevices(devices,mainId);
			model.type = type;
		}
		
		/**
		 *指定画布对应的布局器 
		 * 
		 */
		public function configCanvasLayout(index:int=0):void
		{
			canvas.layout = new CircleLayout();//new DiscreteLayout();
		}
		
		public function injectCanvasPM(pm:TopologyCanvasPM):void
		{
			canvas = pm;
			canvas.initTools(type);
			canvas.commandStack = commandStack;
			canvas.injectDM(model);
			canvas.addEventListener("scrollRect_change",canvasScrollRectChangeHandler);
			canvas.addEventListener("ratio_change",canvasRatioChangeHandler);
			canvas.addEventListener("node_location_change",nodeLocationChangeHandler);
			canvas.addEventListener("focus_node_change",nodeFocusChangeHandler);
			canvas.addEventListener("all_complement",allComplementChangeHandler);
			canvas.addEventListener("connection_change",connectionChangeHandler);
		}
		
		public function injectHawkeyePM(pm:HawkeyeViewerPM):void
		{
			hawkeye = pm;
			hawkeye.injectDM(model);
			hawkeye.addEventListener("displayRect_change",hawkeyeDisplayRectChangeHandler);
		}
		
		public function setHawkeyeWidth(w:int):void
		{
			hawkeye.width = w;
			hawkeye.maxWidth = w;
			hawkeye.computeHeight(canvas.ratio);
		}
		
		private function dirtyChangeHandler(event:Event):void
		{
			if(commandStack.isDirty()){
				isDirty = true;
				dispatchEvent(new Event("dirty_change"));
			}else{
				isDirty = false;
				dispatchEvent(new Event("dirty_change"));
			}
		}
		
		public function canvasRatioChangeHandler(event:Event):void
		{
			hawkeye.computeHeight(canvas.ratio);
			hawkeye.refresh(canvas.width,canvas.height);
		}
		
		public function nodeLocationChangeHandler(event:CustomEvent):void
		{
			hawkeye.refresh(canvas.width,canvas.height,event.data?event.data as NodePM:null);
		}
		
		public function connectionChangeHandler(event:Event):void
		{
			hawkeye.reDrawConnections(canvas.width,canvas.height);
		}
		
		public function nodeFocusChangeHandler(event:Event):void
		{
			if(model.focusNode){
				outline.expandChildrenOf(model.devicesXML,true);
				this.selectedDeviceXML = model.getXMLByDeviceId(model.focusNode.data.deviceId,model.devicesXML);
				outline.scrollToIndex(outline.getItemIndex(selectedDeviceXML));
			}else{
				this.selectedDeviceXML = null;
			}
		}
		
		public function allComplementChangeHandler(event:Event):void
		{
			if(topologyInfo){//根据保存的位置信息调整各节点位置
				canvas.layoutBySavedInfo(topologyInfo);
				if(type == "custom"){//绘制连线
					var node:NodePM = null;
					var dev:Device = null;
					var con:Connection = null;
					var otherId:String = "";
					var otherNode:NodePM = null;
					for(var i:int = 0; i < model.children.length; i++){
						node = model.children.getItemAt(i) as NodePM;
						dev = null;
						for each(var device:Device in topologyInfo.devices){
							if(device.id == node.data.deviceId){
								dev = device;
								break;
							}
						}
						for each(var c:Connection in dev.cons){
							otherId = c.sourceId==node.id ? c.targetId:c.sourceId;
							otherNode = model.findNodeByDeviceId(otherId);
							if(otherNode){
								canvas.addConnectionBetweenNodes(node,otherNode);
							}
						}
					}
				}
			}
			hawkeye.computeHawkeyeDisplayRec(canvas.canvas.scrollRect,canvas.width,canvas.height);
			hawkeye.refresh(canvas.width,canvas.height);
		}
		
		public function canvasScrollRectChangeHandler(event:Event):void
		{
			hawkeye.computeHawkeyeDisplayRec(canvas.canvas.scrollRect,canvas.width,canvas.height);
		}
		
		public function hawkeyeDisplayRectChangeHandler(event:Event):void
		{
			canvas.computeCanvasDisplayRec(hawkeye.displayRectangleX,hawkeye.displayRectangleY,hawkeye.width,hawkeye.height);
		}
		
		public function outlineSelectedChangeHandler(xml:XML):void
		{
			canvas.locationDevice(xml.@id);
		}
		
		public function autoLayout():void
		{
			commandStack.flush();
			commandStack.markSaveLocation();
			canvas.layoutChildren();
			hawkeye.refresh(canvas.width,canvas.height);
		}
		
		/**
		 * 根据当前各节点位置更新保存信息 
		 * @return true:更新，false：新建
		 * 
		 */
		public function updateTopologyInfo():Boolean
		{
			var children:Array = model.children.toArray();
			var update:Boolean = true;
			if(topologyInfo == null){
				topologyInfo = new Topology();
				topologyInfo.id = this.id;
				topologyInfo.name = name;
				topologyInfo.icon = (type == "platform"||type=="division"||type=="custom")?"ORGAN":(type=="05"?"DEVICE":"SERVER");
				topologyInfo.devices = new Array();
				update = false;
			}
			topologyInfo.width = canvas.width;
			topologyInfo.height = canvas.height;
			topologyInfo.devices.splice(0);
			
			var device:Device = null;
			var cons:Array = new Array();
			var exist:Boolean = false;
			for each(var node:NodePM in children){
				device = new Device();
				device.id = node.focusDevice.deviceId;
				device.name = node.focusDevice.deviceName;
				device.type = node.focusDevice.deviceType;
				device.icon = device.type=="05"?"DEVICE":"SERVER";
				device.typeName = node.focusDevice.deviceTypeName;
				device.x = node.x;
				device.y = node.y;
				device.cons = new Array();
				if(type == "custom"){
					var cl:Connection = null;
					for each(var con:ConnectionPM in node.connections){
						exist = false;
						for each(var c:Connection in cons){
							if(con.equal2(c.sourceId,c.targetId)){
								exist = true;
								break;
							}
						}
						if(exist)
							continue;
						cl = new Connection();
						cl.sourceId = con.source.data.deviceId;
						cl.targetId = con.target.data.deviceId;
						cl.sourceX = con.fromX;
						cl.sourceY = con.fromY;
						cl.targetX = con.toX;
						cl.targetY = con.toY;
						device.cons.push(cl);
						cons.push(cl);
					}
				}
				
				topologyInfo.devices.push(device);	
			}
			return update;
		}
		
		public function notifyAlarmHanlder(alarm:AlarmVO):void
		{
			model.alarmNotify(alarm);
		}
		
		public function lineBtnClick(event:Event):void
		{
			if(lineBtnSelected){
				canvas.changeTool(1);
			}else{
				CursorManager.removeAllCursors();
				canvas.changeTool(0);	
			}
		}
		
	}
}