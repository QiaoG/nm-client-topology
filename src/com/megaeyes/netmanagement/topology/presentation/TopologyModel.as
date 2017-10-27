/**
 * @author GQ
 * create time:2013-8-5- 14:42:26
 */
package com.megaeyes.netmanagement.topology.presentation
{
	import com.megaeyes.netmanagement.topology.domain.vo.Device;
	import com.megaeyes.netmanagement.topology.domain.vo.Topology;
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.netmanagement.topology.domain.vo.Topologys;
	import com.megaeyes.netmanagement.topology.infrastructure.event.CustomEvent;
	import com.megaeyes.netmanagement.topology.presentation.connection.Arrow;
	import com.megaeyes.netmanagement.topology.presentation.connection.Connection;
	import com.megaeyes.netmanagement.topology.presentation.connection.ConnectionPM;
	import com.megaeyes.netmanagement.topology.presentation.node.Node;
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	import com.megaeyes.networkmanagement.api.domain.vo.AlarmVO;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.Alert;

	[Event(name="get_devices_complement", type="flash.events.Event")]
	[Event(name="change_device_online_status", type="flash.events.Event")]
	[Event(name="add_node", type="com.megaeyes.netmanagement.performances.Infrastructure.event.CustomEvent")]
	[Event(name="delete_node", type="com.megaeyes.netmanagement.performances.Infrastructure.event.CustomEvent")]
	[Event(name="add_connection", type="com.megaeyes.netmanagement.performances.Infrastructure.event.CustomEvent")]
	[Event(name="delete_connection", type="com.megaeyes.netmanagement.performances.Infrastructure.event.CustomEvent")]
	public class TopologyModel extends EventDispatcher
	{
		[Bindable]
		public var focusNode:NodePM;
		
		[Bindable]
		public var focusConnection:ConnectionPM;
		
		public var rootPM:NodePM;
		
		public var rootDevice:TopologyDevice;
		
		public var devices:IList;
		
		[Bindable]
		public var devicesXML:XML;
		
		/**
		 *包含所有子节点的pm 
		 * @return 
		 * 
		 */
		public var children:IList = new ArrayList();
		
		public var connections:IList = new ArrayList();
		
		private var _mainId:String;
		
		private var _type:String;
		
		private var _filterDeviceTypes:Array = ["20"];
		
		/**
		 *离散 
		 */
		public var discreteNodePms:IList = new ArrayList();
		
		public function TopologyModel()
		{
		}
		
		/**
		 *类型
		 * 平台：'platform'
		 * 分组：'division'
		 * 设备：'device' 
		 */
		public function get type():String
		{
			return _type;
		}

		/**
		 * @private
		 */
		public function set type(value:String):void
		{
			_type = value;
		}

		/**
		 * 整体移动所有的节点 
		 * @param dx
		 * @param dy
		 * 
		 */
		public function moveAllNodes(dx:int,dy:int):void
		{
			var node:NodePM = null;
			for(var i:int = 0; i < children.length; i++){
				node = children.getItemAt(i) as NodePM;
				node.x += dx;
				node.y += dy;
				node.computeCenter();
			}
		}
		
		public function computeAllConnections():void
		{
			var con:ConnectionPM = null;
			for(var i:int = 0; i < connections.length; i++){
				con = connections.getItemAt(i) as ConnectionPM;
				con.compute();
			}
		}
		
		/**
		 *此拓扑图是哪个设备(id)的拓扑图 
		 */
		public function get mainId():String
		{
			return _mainId;
		}
		
		public function getDeviceById(id:String):TopologyDevice
		{
			var d:TopologyDevice = null;
			var temp:TopologyDevice = null;
			for(var i:int = 0; i < devices.length; i++){
				temp = devices.getItemAt(i) as TopologyDevice;
				if(temp.deviceId == id){
					d = temp;
					break;
				}
			}
			return d;
		}

		public function setDevices(devices:IList,mainId:String):void
		{
			this.devices = devices;
			transferToDevicesXML();
			_mainId = mainId;
			dispatchEvent(new Event("get_devices_complement"));
		}
		
		public function refreshFocusDevice( device:TopologyDevice):void
		{
			if(focusNode){
				var v:int = focusNode.refreshDevice(device);
				if(v==1){//online changed
					dispatchEvent(new Event("change_device_online_status"));
				}
				//Alert.show(v+"");
			}
		}
		
		public function addDevice(device:TopologyDevice):void
		{
			devices.addItem(device);
			transferToDevicesXML();
		}
		
		public function deleteNode(node:NodePM):void
		{
			deleteDevice(node.data as TopologyDevice);
			var n:NodePM = null;
			for(var i:int = 0; i < children.length; i++){
				n = children.getItemAt(i) as NodePM;
				if(node.id == n.id){
					if(focusNode && focusNode.id == node.id){
						focusNode = null;
					}
					children.removeItemAt(i);
					break;
				}
			}
		}
		
		public function deleteDevice(device:TopologyDevice):void
		{
			var d:TopologyDevice = null;
			for(var i:int = 0; i < devices.length; i++){
				d = devices.getItemAt(i) as TopologyDevice;
				if(d.deviceId == device.deviceId){
					devices.removeItemAt(i);
					transferToDevicesXML();
					break;
				}
			}
		}
		
		private function transferToDevicesXML():void
		{
			var xml:String = "<device id=\"root\" name=\"root\">";
			for(var i:int = 0; i < devices.length; i++){
				xml += TopologyDevice(devices.getItemAt(i)).toXMLString();
			}
			xml += "</device>";
			devicesXML =devices.length==0?null: new XML(xml);
		}
		
		public function getXMLByDeviceId(id:String,xml:XML):XML
		{
			if(xml.@id == id){
				return xml;
			}
			for each(var child:XML in xml.children()){
				var x:XML = getXMLByDeviceId(id,child);
				if(x != null){
					return x;
				}
			}
			return null;
		}
		
		public function addChild(device:TopologyDevice,parentPM:NodePM=null,discrete:Boolean = false):Node
		{
			var node:Node = new Node();
			var pm:NodePM = new NodePM();
			if(_mainId && _mainId == device.deviceId){
				pm.isMain = true;
			}
			if(parentPM){
				parentPM.children.addItem(pm);
			}else{
				if(!discrete){//非离散
					rootPM = pm;
				}
			}
			node.model = pm;
			pm.uiHost = node;
			children.addItem(pm);
			return node;
		}
		
		public function clear():void
		{
			rootPM = null;
			for(var i:int = 0; i < connections.length; i++){
				ConnectionPM(connections.getItemAt(i)).destroy();
			}
			children.removeAll();
			connections.removeAll();
		}
		
		public function layoutBySavedInfo(info:Topology):void
		{
			if(info.devices){
				var pm:NodePM = null;
				for each(var d:Device in info.devices){
					pm = findNodeByDeviceId(d.id);
					if(pm){
						pm.changeLocation(d.x,d.y);
					}
				}
			}
		}
		
		/**
		 * 
		 * @param id
		 * @param focus 是否将找到的节点设置为焦点
		 * @return 
		 * 
		 */
		public function findNodeByDeviceId(id:String,focus:Boolean = false):NodePM
		{
			var pm:NodePM = null;
			var temp:NodePM = null;
			for(var i:int = 0; i < children.length; i++){
				temp = children.getItemAt(i) as NodePM;
				if(temp.data.deviceId == id){
					pm = temp;
					if(focus){
						pm.changeFocus(true);
						focusNode = pm;
					}
				}else{
					if(focus){
						temp.changeFocus(false);
					}
				}
			}
			return pm;
		}
		
		public function refreshNodeFocusState(x:int,y:int):void
		{
			var pm:NodePM = getNodeByMouse(x,y);
			if(pm){
				if(focusNode){
					focusNode.changeFocus(false);
				}
				focusNode = pm;
				pm.changeFocus(true);
			}else if(focusNode){
				focusNode.changeFocus(false);
				focusNode = null;
			}
		}
		
		public function getNodeByMouse(x:int,y:int):NodePM
		{
			var node:NodePM = null;
			var pm:NodePM = null;
			for(var i:int = 0; i < children.length; i++){
				pm = children.getItemAt(i) as NodePM;
				if(x >= pm.x && x <= pm.x + pm.width && y >= pm.y && y <= pm.y + pm.height){
					node = pm;
					break;
				}
			}
			return node;
		}
		
		public function getConnectionByMouse(x:int,y:int):ConnectionPM
		{
			var connection:ConnectionPM = null;
			var focuss:Array = new Array();
			var pm:ConnectionPM = null;
			var offsetW:int = 0;
			var offsetH:int = 0
			for(var i:int = 0; i < connections.length; i++){
				pm = connections.getItemAt(i) as ConnectionPM;
				if(pm.rectW < 50){
					offsetW = 10;
				}
				if(pm.rectH < 50){
					offsetH = 10;
				}
				if(x >= pm.rectX-offsetW && x <= pm.rectX + pm.rectW+offsetW && y >= pm.rectY-offsetH && y <= pm.rectY + pm.rectH + offsetH){
					focuss.push(pm);
				}
			}
			for each(var focus:ConnectionPM in focuss){
//				var dx:int = (focus.fromX - focus.toX);
//				var dy:int = (focus.fromY - focus.toY);
//				var dr:int = Math.sqrt(dx*dx + dy*dy);
				
				var dv:int = focus.computeDistance(x,y);//(x - (y - focus.toY)/(dy/dx) - focus.toX)*dy/dr;
				if(Math.abs(dv) < 8){
					connection =focus;
					break;
				}
			}
			return connection;
		}
		
		/**
		 * 
		 * @param one
		 * @param two
		 * @return 
		 * 
		 */
		public function addConnections(one:NodePM,two:NodePM,arrow:Boolean = true):Connection
		{
			var con:Connection = new Connection();
			var conPm:ConnectionPM = new ConnectionPM();
			conPm.hasArrow = arrow;
			conPm.source = one;
			conPm.target = two;
			conPm.compute();
			con.model = conPm;
			con.model.uiHost = con;
			connections.addItem(conPm);
			return con;
		}
		
		public function addArrow(connection:ConnectionPM):Arrow
		{
			var arrow:Arrow = new Arrow();
			arrow.model = connection;
			arrow.model.uiArrow = arrow;
			return arrow;
		}
		
		public function addConnection(con:ConnectionPM):void
		{
			var c:ConnectionPM = null;
			var exist:Boolean = false;
			for(var i:int = 0; i < connections.length; i++){
				c = connections.getItemAt(i) as ConnectionPM;
				if(c.equal(con)){
					exist = true;
					break;
				}
			}
			if(!exist)
				connections.addItem(con);
		}
		
		public function removeConnection(con:ConnectionPM):void
		{
			var c:ConnectionPM = null;
			for(var i:int = 0; i < connections.length; i++){
				c = connections.getItemAt(i) as ConnectionPM;
				if(c.equal(con)){
					if(con.equal(focusConnection)){
						focusConnection = null;
					}
					connections.removeItemAt(i);
					break;
				}
			}
		}
		
		public function alarmNotify(alarm:AlarmVO):void
		{
			var node:NodePM = null;
			for(var i:int = 0; i < discreteNodePms.length; i++){
				node = discreteNodePms.getItemAt(i) as NodePM;
				if(alarm.deviceId != node.data.deviceId){
					continue;
				}
				node.alarmNotify(alarm);
			}
		}
		
	}
}