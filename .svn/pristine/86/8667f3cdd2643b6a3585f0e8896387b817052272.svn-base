/**
 * 用于创建节点
 * @author GQ
 * create time:2013-11-4- 11:17:13
 */
package com.megaeyes.netmanagement.topology.presentation.tool
{
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.netmanagement.topology.infrastructure.ImageUtil;
	import com.megaeyes.netmanagement.topology.infrastructure.TopologyUtil;
	import com.megaeyes.netmanagement.topology.presentation.UIElement;
	import com.megaeyes.netmanagement.topology.presentation.commands.CreateNodeCommand;
	import com.megaeyes.netmanagement.topology.presentation.commands.DeleteConnectionCommand;
	import com.megaeyes.netmanagement.topology.presentation.commands.DeleteNodeCommand;
	import com.megaeyes.netmanagement.topology.presentation.connection.ConnectionPM;
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.EffectEvent;
	import mx.managers.DragManager;
	
	import spark.components.Image;
	import spark.components.List;
	import spark.effects.Fade;
	
	public class CustomTopologyTool extends DefaultTool
	{
		
		private var _showBtnElement:UIElement;
		
		private var _closeBtn:Image = new Image();
		
		private var _connectionBtn:Image = new Image();
		
		[Bindable]
		public var closeImage:Class;
		
		[Bindable]
		public var connectionImage:Class;
		
		private var _effect:Fade = new Fade();
		
		private var _hide:Boolean;
		
		private var _doConnection:Boolean;
		
		public function CustomTopologyTool()
		{
			closeImage = images.CLOSE;
			connectionImage = images.CONNECTION;
			_closeBtn.source = closeImage;
			_closeBtn.toolTip = "删除";
			_connectionBtn.source = connectionImage;
			_connectionBtn.toolTip = "连线";
			BindingUtils.bindProperty(_closeBtn,"source",this,"closeImage");
			BindingUtils.bindProperty(_connectionBtn,"source",this,"connectionImage");
			_closeBtn.addEventListener(MouseEvent.MOUSE_OVER,closeMouseOverHandler);
			_closeBtn.addEventListener(MouseEvent.MOUSE_OUT,closeMouseOutHandler);
			_closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,closeMouseDownHandler);
			_closeBtn.addEventListener(MouseEvent.CLICK,closeClickHandler);
			_closeBtn.addEventListener(MouseEvent.MOUSE_UP,closeUpHandler);
			_connectionBtn.addEventListener(MouseEvent.MOUSE_OVER,connectionMouseOverHandler);
			_connectionBtn.addEventListener(MouseEvent.MOUSE_OUT,connectionMouseOutHandler);
			_connectionBtn.addEventListener(MouseEvent.MOUSE_DOWN,connectionDownHandler);
			_connectionBtn.addEventListener(MouseEvent.CLICK,connectionClickHandler);
			_connectionBtn.addEventListener(MouseEvent.MOUSE_UP,connectionUpHandler);
			_effect.addEventListener(EffectEvent.EFFECT_END,effectEndHandler);
		}
		
		private function closeMouseOverHandler(event:MouseEvent):void
		{
			closeImage = images.CLOSE2;
		}
		
		private function closeMouseOutHandler(event:MouseEvent):void
		{
			closeImage = images.CLOSE;
		}
		
		private function closeMouseDownHandler(event:MouseEvent):void
		{
			event.stopPropagation();
			closeImage = images.CLOSE3;
		}
		
		private function closeClickHandler(event:MouseEvent):void
		{
			event.stopPropagation();
			closeImage = images.CLOSE3;
		}
		
		private function closeUpHandler(event:MouseEvent):void
		{
			event.stopPropagation();
			removeShowBtns();
			
			if(_showBtnElement is NodePM){
				canvasM.executeCommand(getDeleteDeviceCommand(_showBtnElement as NodePM));
			}
			if(_showBtnElement is ConnectionPM){
				canvasM.executeCommand(getDeleteConnectionCommand(_showBtnElement as ConnectionPM));
			}
			_showBtnElement = null;
		}
		
		private function connectionMouseOverHandler(event:MouseEvent):void
		{
			connectionImage = images.CONNECTION2;
		}
		
		private function connectionMouseOutHandler(event:MouseEvent):void
		{
			connectionImage = images.CONNECTION;
		}
		
		private function connectionDownHandler(event:MouseEvent):void
		{
			event.stopPropagation();
			connectionImage = images.CONNECTION;
		}
		
		private function connectionClickHandler(event:MouseEvent):void
		{
			event.stopPropagation();
			connectionImage = images.CONNECTION3;
		}
		
		private function connectionUpHandler(event:MouseEvent):void
		{
			event.stopPropagation();
			connectionImage = images.CONNECTION3;
			canvasM.changeTool(1,true);
			CreateConnectionTool(canvasM.currentTool).clickHandler2(_showBtnElement.centerPoint.x,_showBtnElement.centerPoint.y);
			_hide = true;
			effectEndHandler(null);
		}
		
		private function effectEndHandler(event:EffectEvent):void
		{
			if(_hide){
				removeShowBtns();
				_showBtnElement = null;
			}
		}
		
		private function removeShowBtns():void{
			try{
				canvasM.canvas.removeElement(_closeBtn);
			}catch(e:Error){
			}
			if(_showBtnElement is NodePM){
				try{
					canvasM.canvas.removeElement(_connectionBtn);
				}catch(e:Error){
				}
			}
		}
		
		private function doEffict(element:UIElement,hide:Boolean = true):void
		{
			var arr:Array = (element is NodePM)?[_closeBtn,_connectionBtn]:[_closeBtn];
			_effect.alphaFrom = hide?1:0;
			_effect.alphaTo = hide?0:1;
			_hide = hide;
//			_effect.duration = 2000;
			_effect.play(arr);
		}
		
		override public function mouseDownHanlder(event:MouseEvent):void
		{
			super.mouseDownHanlder(event);
		}
		
		override public function mouseMoveHandler(event:MouseEvent):void
		{
			if(canvasM.mouseState == 0){//显示关闭和连线按钮
				var x:int = event.stageX-canvasM.OriginPointStageX+canvasM.canvas.scrollRect.x;
				var y:int = event.stageY - canvasM.OriginPointStageY+canvasM.canvas.scrollRect.y;
				var node:NodePM = canvasM.domain.getNodeByMouse(x,y);
				if(node){
					showBtnImage(node);
				}else{
					var con:ConnectionPM = canvasM.domain.getConnectionByMouse(x,y);
					if(con && con.computeDistanceToCenter(x,y) < 60){
						if(_showBtnElement){
							if(!_showBtnElement.equal(con)){
								removeShowBtns();
								_showBtnElement = null;
							}else{
								return;
							}
						}
						_closeBtn.x = con.centerPoint.x ;
						_closeBtn.y = con.centerPoint.y < 20 ? 0 : con.centerPoint.y - 20;
						canvasM.canvas.addElement(_closeBtn);
						_showBtnElement = con;
						doEffict(con,false);
					}else{
						if(_showBtnElement){
							var distance:int = _showBtnElement.computeDistance(x,y);
							var min:int = 0;
							if(_showBtnElement is ConnectionPM){
								distance = Math.max(distance,ConnectionPM(_showBtnElement).computeDistanceToCenter(x,y));
								min = 50;
							}else{
								min = 55;
							}
							if(distance > min){
								doEffict(_showBtnElement,true);
							}
						}
					}
				}
			}else{
				if(_showBtnElement!=null){
					removeShowBtns();
					_showBtnElement = null;
				}
				super.mouseMoveHandler(event);
			}
		}
		
		public function showBtnImage(node:NodePM):void
		{
			if(_showBtnElement){
				if(!_showBtnElement.equal(node)){
					removeShowBtns();
					_showBtnElement = null;
				}else{
					return;
				}
			}
			_closeBtn.x = node.centerPoint.x + (node.x>(canvasM.width-node.width-20)?-55:30);
			_closeBtn.y = node.y<10?0:node.y-10;
			
			_connectionBtn.x = _closeBtn.x;//+(_closeBtn.x<node.x?5:-5);
			_connectionBtn.y = node.y + 40;
			canvasM.canvas.addElement(_closeBtn);
			canvasM.canvas.addElement(_connectionBtn);
			_showBtnElement = node;
			doEffict(node,false);
		}
		
		override public function mouseUpHandler(event:MouseEvent):void
		{
			if(event){
				var x:int = event.stageX-canvasM.OriginPointStageX+canvasM.canvas.scrollRect.x;
				var y:int = event.stageY - canvasM.OriginPointStageY+canvasM.canvas.scrollRect.y;
				var node:NodePM = canvasM.domain.getNodeByMouse(x,y);
			
				if(node!=null && node.equal(_showBtnElement)){
					
				}else{
					if(_showBtnElement!=null){
						removeShowBtns();
						_showBtnElement = null;
					}
				}
			}else{
				if(_showBtnElement!=null){
					removeShowBtns();
					_showBtnElement = null;
				}
			}
			super.mouseUpHandler(event);
			
		}
		
		override public function mouseWheelHandler(event:MouseEvent):void
		{
			super.mouseWheelHandler(event);
		}
		
		override public function mouseOutHandler(event:MouseEvent):void
		{
			super.mouseOutHandler(event);
		}
		
		override public function clickHanlder(event:MouseEvent):void
		{
			var x:int = event.stageX-canvasM.OriginPointStageX+canvasM.canvas.scrollRect.x;
			var y:int = event.stageY- canvasM.OriginPointStageY+canvasM.canvas.scrollRect.y;
			clickHandler2(x,y);
		}
		
		override public function clickHandler2(x:int,y:int):void
		{
			super.clickHandler2(x,y);
			if(!canvasM.domain.focusNode){//看是否有焦点连线
				var focus:ConnectionPM = canvasM.domain.getConnectionByMouse(x,y);
				if(focus){
					if(canvasM.domain.focusConnection){
						canvasM.domain.focusConnection.changeFocus(false);
					}
					focus.changeFocus(true);
					canvasM.domain.focusConnection = focus;
				}
				if(focus == null && canvasM.domain.focusConnection){
					canvasM.domain.focusConnection.changeFocus(false);
				}
			}else{
				if(canvasM.domain.focusConnection){
					canvasM.domain.focusConnection.changeFocus(false);
				}
			}
		}
		
		private function getNodeByMouse(x:int,y:int):NodePM
		{
			var node:NodePM = null;
			
			return node;
		}
		
		private function getConnectionByMouse(x:int,y:int):ConnectionPM
		{
			var connection:ConnectionPM = null;
			
			return connection;
		}
		
		public function dragEnterHandler(event:DragEvent):void
		{
			if( event.dragInitiator is DataGrid ) {
				var ds:DragSource = event.dragSource;
				if( !ds.hasFormat("items") ) {
					var formats:String = "";
					for(var item:String in ds.formats){
						formats += item +";";
					}
					Alert.show(formats);
					return
				}else{
				}
			} 
			DragManager.acceptDragDrop(UIComponent(event.currentTarget)); 
		}
		
		public function dragOverHandler(event:DragEvent):void
		{
			DragManager.showFeedback(DragManager.COPY);
		}
		
		public function dragDropHandler(event:DragEvent):void
		{
			var ds:DragSource = event.dragSource;
			var arr:Array;
			if( ds.hasFormat("items") ) {
				arr = ds.dataForFormat("items") as Array;
			}
			if(arr != null && arr.length>0){
				var node:Object = Object(arr[0]);
				var device:TopologyDevice = TopologyUtil.transferToDeviceVO(node);
				if(canvasM.domain.getDeviceById(device.deviceId)==null){
					canvasM.executeCommand(getAddDeviceCommand(device,event.stageX,event.stageY));
				}else{
					canvasM.locationDevice(device.deviceId);
				}
			}
		}
		
		public function dragExitHandler(event:DragEvent):void
		{
		}
		
		private function getAddDeviceCommand(device:TopologyDevice,x:int,y:int):CreateNodeCommand
		{
			var command:CreateNodeCommand = new CreateNodeCommand("添加设备:"+device.deviceName);
			command.canvasM = canvasM;
			command.device = device;
			command.x = x;
			command.y = y;
			return command;
		}
		
		private function getDeleteDeviceCommand(node:NodePM):DeleteNodeCommand
		{
			var command:DeleteNodeCommand = new DeleteNodeCommand("删除设备:"+node.data.deviceName);
			command.canvasM = canvasM;
			command.node = node;
			return command;
		}
		
		private function getDeleteConnectionCommand(con:ConnectionPM):DeleteConnectionCommand
		{
			var command:DeleteConnectionCommand = new DeleteConnectionCommand("删除连线("+con.source.data.deviceName+" - "+con.target.data.deviceName+")");
			command.canvasM = canvasM;
			command.connection = con;
			return command;
		}
		
	}
}