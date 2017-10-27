/**
 * @author GQ
 * create time:2013-7-11- 16:26:59
 */
package com.megaeyes.netmanagement.topology.presentation
{
	import com.megaeyes.netmanagement.topology.domain.vo.Device;
	import com.megaeyes.netmanagement.topology.domain.vo.Topology;
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.netmanagement.topology.domain.vo.Topologys;
	import com.megaeyes.netmanagement.topology.infrastructure.TopologyUtil;
	import com.megaeyes.netmanagement.topology.infrastructure.event.CustomEvent;
	import com.megaeyes.netmanagement.topology.presentation.commands.ChangeCanvasSizeCommand;
	import com.megaeyes.netmanagement.topology.presentation.commands.Command;
	import com.megaeyes.netmanagement.topology.presentation.commands.CommandStack;
	import com.megaeyes.netmanagement.topology.presentation.connection.Arrow;
	import com.megaeyes.netmanagement.topology.presentation.connection.Connection;
	import com.megaeyes.netmanagement.topology.presentation.connection.ConnectionPM;
	import com.megaeyes.netmanagement.topology.presentation.layout.DefaultLayout;
	import com.megaeyes.netmanagement.topology.presentation.layout.Layout;
	import com.megaeyes.netmanagement.topology.presentation.node.Node;
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	import com.megaeyes.netmanagement.topology.presentation.tool.CreateConnectionTool;
	import com.megaeyes.netmanagement.topology.presentation.tool.CustomTopologyTool;
	import com.megaeyes.netmanagement.topology.presentation.tool.DefaultTool;
	import com.megaeyes.netmanagement.topology.presentation.tool.Tool;
	import com.megaeyes.networkmanagement.api.utils.AlertUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColorStroke;
	import mx.managers.DragManager;
	
	import spark.components.BorderContainer;
	import spark.primitives.Rect;

	[Event(name="scrollRect_change", type="flash.events.Event")]
	[Event(name="ratio_change", type="flash.events.Event")]
	[Event(name="node_location_change", type="com.megaeyes.netmanagement.topology.infrastructure.event.CustomEvent")]
	[Event(name="focus_node_change", type="flash.events.Event")]
	[Event(name="all_complement", type="flash.events.Event")]
	[Event(name="connection_change", type="flash.events.Event")]
	public class TopologyCanvasPM extends CanvasPM
	{
		[Bindable]
		/**
		 *状态
		 * 0：待选状态
		 * 1：有节点被选中 
		 * @return 
		 * 
		 */
		public var state:int=0;
		
		/**
		 *显示窗口宽度 
		 */
		public var displayWidth:int;
		
		/**
		 *显示窗口高度 
		 */
		public var displayHeight:int;
		
		[Bindable]
		/**
		 *长宽比 
		 * @return 
		 * 
		 */
		public var ratio:Number;
		
		private var _layout:Layout;
		
		public var tools:IList = new ArrayList();
		
		private var _currentTool:Tool;
		
		private var _commandStack:CommandStack;
		
		public function TopologyCanvasPM()
		{
			super();
		}
		
		public function get currentTool():Tool
		{
			return _currentTool;
		}

		public function initTools(type:String):void
		{
			if(type == "custom"){
				tools.addItem(new CustomTopologyTool());
				tools.addItem(new CreateConnectionTool());
			}else{
				tools.addItem(new DefaultTool());
			}
			changeTool(0);
		}
		
		/**
		 * 
		 * @param index
		 * @param temp 暂时
		 * 
		 */
		public function changeTool(index:int,temp:Boolean = false):void
		{
			_currentTool = tools.getItemAt(index) as DefaultTool;
			DefaultTool(_currentTool).temp = temp;
			DefaultTool(_currentTool).canvasM = this;
		}
		
		public function get commandStack():CommandStack
		{
			return _commandStack;
		}

		public function set commandStack(value:CommandStack):void
		{
			_commandStack = value;
		}

		public function get layout():Layout
		{
			return _layout;
		}

		public function set layout(value:Layout):void
		{
			_layout = value;
		}

		override public function set canvas(value:BorderContainer):void
		{
			super.canvas = value;
			super.canvas.addEventListener(MouseEvent.CLICK ,clickHanlder);
		}
		
		public function locationDevice(id:String):void
		{
			if(_currentTool){
				DefaultTool(_currentTool).locationDevice(id);
			}
		}
		
		//---------------------------------- nodes ------------------------------
		
		/**
		 *绘制入口 ,监听TopologyModel的get_devices_complement事件 
		 * @param event
		 * 
		 */
		override protected function refreshCanvas(event:Event):void
		{
			clearNodes();
			if(domain.rootDevice){
				addNode(domain.rootDevice);
				layoutChildren();
				addConnections(domain.rootPM);
			}else{
				addNode2();
				layoutChildren();
				var c:NodePM = null;
				for(var i:int = 0; i < domain.discreteNodePms.length; i++){
					c = domain.discreteNodePms.getItemAt(i) as NodePM;
					addConnections(c);
					if(c.data.deviceType == "43"){
						if(_currentTool){
							DefaultTool(_currentTool).showNode(c);
						}
					}
				}
			}
			dispatchEvent(new Event("all_complement"));
		}
		
		private function clearNodes():void
		{
			domain.clear();
			canvas.removeAllElements();
			width = displayWidth;
			height = displayHeight;
		}
		
		/**
		 * 
		 * @param parent
		 * @return 节点宽度（包含子节点）
		 * 
		 */
		private function addNode(device:TopologyDevice,filter:String="20",parentPM:NodePM=null,discrete:Boolean = false):NodePM
		{
			if(device.deviceType == filter){//如果是监视器 忽略
				return null;
			}
			var node:Node = domain.addChild(device,parentPM,discrete);
			node.model.images = images;
			node.model.setData(device);
			try{
				canvas.addElement(node);
			}catch(e:Error){
				Alert.show("draw error:"+e.getStackTrace().substr(0,200));
			}
			for(var i:int = 0; i < device.children.length; i++){
				addNode(device.children.getItemAt(i) as TopologyDevice,filter,node.model,discrete);
			}
			return node.model;
		}
		
		/**
		 *添加离散设备 
		 * @param device
		 * @param parentPM
		 * 
		 */
		private function addNode2():void
		{
			domain.discreteNodePms.removeAll();
			if(domain.devices){
				var device:TopologyDevice = null;
				var node:NodePM = null;
				for(var i:int = 0; i < domain.devices.length; i++){
					device = domain.devices.getItemAt(i) as TopologyDevice;
					node = addNode(device,"",null,true);
					if(node)
						domain.discreteNodePms.addItem(node);
				}
			}
		}
		
		/**
		 * 由CreateNodeCommand的redo方法调用,添加曾经删除的node 
		 * @param node
		 * 
		 */
		public function addNodePM(node:NodePM):void
		{
			domain.addDevice(node.data as TopologyDevice);
			domain.children.addItem(node);
			try{
				canvas.addElement(node.uiHost as UIComponent);
			}catch(e:Error){
				Alert.show("draw error:"+e.getStackTrace().substr(0,200));
			}
		}
		
		public function addDevice(device:TopologyDevice):NodePM
		{
			domain.addDevice(device);
			var pm:NodePM  = addNode(device,"",null,true);
			domain.discreteNodePms.addItem(pm);
			return pm;
		}
		
		public function deleteDevice(pm:NodePM):void
		{
			try{
				canvas.removeElement(pm.uiHost as UIComponent);
			}catch(e:Error){
				Alert.show("draw error:"+e.getStackTrace().substr(0,200));
			}
			pm.changeFocus(false);
			domain.deleteNode(pm);
		}
		
		public function layoutChildren():void
		{
			if(layout){
				var rec:Rectangle = null;
				var h:Boolean = true;
				rec = layout.layout(domain.rootPM?domain.rootPM:domain.discreteNodePms,50,50);
				
				//调整面板大小
				var change:Boolean = false;
				if(rec.x + rec.width > this.width){
					width = rec.x + rec.width+50;
					change = true;
				}
				if(rec.y + rec.height > this.height){
					height = rec.y + rec.height+50;
					change = true;
				}
//				Alert.show(change+" rw="+rec.width+",rh="+rec.height+",w="+this.width+",h="+this.height);
				if(change){
					changeCanvasSize(width,height);
				}
			}
		}
		
		/**
		 *根据保存的信息调整位置 
		 * @param info
		 * 
		 */
		public function layoutBySavedInfo(info:Topology):void
		{
			changeCanvasSize(info.width,info.height);
			domain.layoutBySavedInfo(info);
		}
		
		/**
		 * 为树结构数据添加连线 
		 * @param parent
		 * 
		 */
		private function addConnections(parent:NodePM):void
		{
			var child:NodePM = null;
			for(var i:int = 0; i < parent.children.length; i++){
				child = parent.children.getItemAt(i) as NodePM;
				if(child.data.deviceType == "69" || child.data.deviceType == "69"){
					addConnectionBetweenNodes(parent,child,true);
				}else if(child.data.deviceType == "47" || child.data.deviceType == "62"){
					addConnectionBetweenNodes(child,parent,true);
				}else{
					addConnectionBetweenNodes(parent,child);
				}
				addConnections(child);
			}
		}
		
		public function addConnectionBetweenNodes(one:NodePM,two:NodePM,arrow:Boolean=false):Connection
		{
			var con:Connection = domain.addConnections(one,two,arrow);
			canvas.addElement(con);
			if(arrow){
				con.model.hasArrow = true;
				var a:Arrow = domain.addArrow(con.model);
				canvas.addElement(a);
			}
			return con;
		}
		
		public function addConnection(con:ConnectionPM):void
		{
			con.reborn();
			canvas.addElement(con.uiHost);
			if(con.uiArrow){
				canvas.addElement(con.uiArrow);
			}
			domain.addConnection(con);
			fireConnectionChangeEvent();
		}
		
		public function removeConnection(con:ConnectionPM):void
		{
			canvas.removeElement(con.uiHost);
			if(con.uiArrow){
				canvas.removeElement(con.uiArrow);
			}
			con.destroy();
			domain.removeConnection(con);
			fireConnectionChangeEvent();
		}
		
		public function moveNode(node:NodePM,x:int,y:int):void
		{
			node.changeLocation(x,y);
			fireNodeLocationChangeEvent(node);
		}
		
		public function fireNodeLocationChangeEvent(node:NodePM):void
		{
			var event:CustomEvent = new CustomEvent("node_location_change");
			event.data = node;
			dispatchEvent(event);
		}
		
		public function fireConnectionChangeEvent():void
		{
			dispatchEvent(new Event("connection_change"));
		}
		
		//--------------------------------- canvas ------------------------------
		
		public function initSize(w:int,h:int):void
		{
			displayWidth = w;
			displayHeight = h;
			width = displayWidth;
			height = displayHeight;
			changeCanvasSize(width,height);
		}
		
		/**
		 *改变显示界面大小 
		 * @param w
		 * @param h
		 * 
		 */
		public function changeDisplaySize(w:int,h:int):void
		{
			displayWidth = w;
			displayHeight = h;
			var cr:Boolean = false;
			if(displayWidth > width){
				width = displayWidth;
				cr = true;
			}
			if(displayHeight > height){
				height = displayHeight;
				cr = true;
			}
			if(cr){
				changeCanvasSize(width,height);
			}
			changeScrollRectLocation(displayRectangleX,displayRectangleY);
		}
		
		/**
		 *改变画布大小 
		 * @param w
		 * @param h
		 * 
		 */
		public function changeCanvasSize(w:int,h:int):void
		{
			width = w;
			height = h;
			computeRatio();
		}
		
		public function computeRatio():void
		{
			ratio = width / height;
			this.dispatchEvent(new Event("ratio_change"));
		}
		
		public function refreshNodeFocusState(x:int,y:int):void
		{
			domain.refreshNodeFocusState(x,y);
			setTimeout(dispatchFocusNodeChangeEvent,100);
		}
		
		/**
		 *计算显示位置和大小 
		 * 随动鹰眼(处理鹰眼的改变)
		 */
		public function computeCanvasDisplayRec(hawkeyeDisRectX:int,hawkeyeDisRectY:int,hawkeyeW:int,hawkeyeH:int):void
		{
			displayRectangleX = hawkeyeDisRectX*width/hawkeyeW;
			displayRectangleY = hawkeyeDisRectY*height/hawkeyeH;
			changeScrollRectLocation(displayRectangleX,displayRectangleY,false);
		}
		
		public function clickHanlder(event:MouseEvent):void
		{
			if(_currentTool){
				_currentTool.clickHanlder(event);
			}
		}
		
		public function dispatchFocusNodeChangeEvent():void
		{
			dispatchEvent(new Event("focus_node_change"));
		}
		
		override protected function mouseDownHanlder(event:MouseEvent):void
		{
			if(_currentTool){
				_currentTool.mouseDownHanlder(event);
			}
		}
		
		override protected function mouseMoveHandler(event:MouseEvent):void
		{
			if(_currentTool){
				_currentTool.mouseMoveHandler(event);
			}
		}
		
		override protected function mouseUpHandler(event:MouseEvent):void
		{
			if(_currentTool){
				_currentTool.mouseUpHandler(event);
			}
		}
		
		override protected function mouseOutHandler(event:MouseEvent):void
		{
			if(_currentTool){
				_currentTool.mouseOutHandler(event);
			}
		}
		
		override protected function mouseWheelHandler(event:MouseEvent):void
		{
			if(_currentTool){
				_currentTool.mouseWheelHandler(event);
			}
			
		}
		
		public function dragEnterHandler(event:DragEvent):void
		{
			if(_currentTool is CustomTopologyTool){
				CustomTopologyTool(_currentTool).dragEnterHandler(event);
			}
		}
		
		public function dragOverHandler(event:DragEvent):void
		{
			if(_currentTool is CustomTopologyTool){
				CustomTopologyTool(_currentTool).dragOverHandler(event);
			}
		}
		
		public function dragDropHandler(event:DragEvent):void
		{
			if(_currentTool is CustomTopologyTool){
				CustomTopologyTool(_currentTool).dragDropHandler(event);
			}
		}
		
		public function dragExitHandler(event:DragEvent):void
		{
		}
		
		/**
		 *改变显示区域的起始坐标 
		 * @param x
		 * @param y
		 * @param dispatch
		 * 
		 */
		public function changeScrollRectLocation(x:int,y:int,dispatch:Boolean=true):void
		{
			x = x < 0 ? 0 : x;
			y = y < 0 ? 0 : y;
			if(x + displayWidth > width){
				x = width - displayWidth;
			}
			if(y + displayHeight > height){
				y = height - displayHeight;
			}
			var rec:Rectangle = new Rectangle(x,y,displayWidth,displayHeight);
			displayRectangleX = rec.x;
			displayRectangleY = rec.y;
			displayRectangleW = rec.width;
			displayRectangleH = rec.height;
			canvas.scrollRect = rec;
			if(dispatch){
				dispatchEvent(new Event("scrollRect_change"));
			}
		}
		
		public function executeCommand(command:Command):void
		{
			_commandStack.execute(command);
		}
		
	}
}