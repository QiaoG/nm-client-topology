/**
 * @author GQ
 * create time:2013-10-23- 16:56:16
 */
package com.megaeyes.netmanagement.topology.presentation.tool
{
	import com.megaeyes.netmanagement.topology.infrastructure.ImageUtil;
	import com.megaeyes.netmanagement.topology.presentation.CanvasPM;
	import com.megaeyes.netmanagement.topology.presentation.TopologyCanvasPM;
	import com.megaeyes.netmanagement.topology.presentation.TopologyModel;
	import com.megaeyes.netmanagement.topology.presentation.commands.ChangeCanvasSizeCommand;
	import com.megaeyes.netmanagement.topology.presentation.commands.Command;
	import com.megaeyes.netmanagement.topology.presentation.commands.MoveNodeCommand;
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.edit.IInteractionEventHandler;
	
	import mx.controls.Alert;
	import mx.graphics.SolidColorStroke;
	import mx.managers.CursorManager;
	
	import spark.components.BorderContainer;
	import spark.components.Image;
	import spark.primitives.Rect;
	
	public class DefaultTool implements Tool
	{
		public var canvasM:TopologyCanvasPM;
		
		private var _feedbackRect:Rect;
				
		private var _feedbackRectState:int;
		
		protected var _mouseCurrentX:int;
				
		protected var _mouseCurrentY:int;
		
		private var _readyIncreasesWidthDirection:int;
		
		private var _readyIncreasesHeightDirection:int;
				
		private var _continuousIncreasesSizeCount:int = 0;
		
		private const MAX_CONTINUOUS_ADDITION_COUNT:int = 10;
		
		public var increasesSizeCommandChain:Array = new Array();
		
		private var _showFocusTimer:Timer = new Timer(200,6);
		
		public var temp:Boolean = false;
		
		protected var images:ImageUtil = new ImageUtil();
		
		private var _resizeImage:Image = new Image();
		
		private var _showResizeImage:Boolean;
		
		private var _showBorderNode:NodePM;
		
		public function DefaultTool()
		{
			_showFocusTimer.addEventListener(TimerEvent.TIMER,flashFocusNode);
		}
		
		public function activate():void
		{
		}
		
		public function deactivate():void
		{
		}
		
		public function mouseDownHanlder(event:MouseEvent):void
		{
			_mouseCurrentX = event.stageX;
			_mouseCurrentY = event.stageY;
			increasesSizeCommandChain.splice(0);
			clickHanlder(event);
			hideFeedbackRect();
			var pm:NodePM = canvasM.domain.focusNode;
			if(pm){
				canvasM.state = 1;
				showNode(pm);
//				showFeedBackRectOfFocusNode();
			}else{
				canvasM.state = 0;
			}
			canvasM.mouseState = 1;
		}
		
		public function mouseMoveHandler(event:MouseEvent):void
		{
			var x:int = event.stageX-canvasM.OriginPointStageX+canvasM.canvas.scrollRect.x;
			var y:int = event.stageY - canvasM.OriginPointStageY+canvasM.canvas.scrollRect.y;
			if(canvasM.mouseState == 0){
				displayBorderHanlder(x,y);
				return;
			}
			if(canvasM.state == 0){//移动窗口
				var offsetX:int = event.stageX - _mouseCurrentX;
				var offsetY:int = event.stageY - _mouseCurrentY;
				canvasM.changeScrollRectLocation(canvasM.canvas.scrollRect.x-offsetX,canvasM.canvas.scrollRect.y - offsetY);
			}else{//移动选中节点
				showFeedBackRectOfFocusNode();
				var v:Array = moveFeedBackRect(event.stageX,event.stageY);
				if(v[0]!=0 || v[1]!=0){
					if(_feedbackRect){
						SolidColorStroke(_feedbackRect.stroke).color = 0xf00000;
					}
				}else{
					if(_feedbackRect){
						SolidColorStroke(_feedbackRect.stroke).color = 0xbbbbbb;
					}
				}
				if(_readyIncreasesWidthDirection != int(v[0]) || _readyIncreasesHeightDirection != int(v[1])){
					_continuousIncreasesSizeCount = 0;
					delayIncreasesSize(v[0],v[1],createChangeCanvasSizeCommand());
				}
			}
			_mouseCurrentX = event.stageX;
			_mouseCurrentY = event.stageY;
		}
		
		protected function displayBorderHanlder(x:int,y:int):NodePM
		{
			var node:NodePM = null;
			if(canvasM.mouseState == 0){//显示关闭和连线按钮
				node = canvasM.domain.getNodeByMouse(x,y);
				if(node){
					if(_showBorderNode){
						if(!_showBorderNode.equal(node)){
							_showBorderNode.borderAlpha = 0;
						}
					}
					_showBorderNode = node;
					node.borderAlpha = .2;
				}else{
					hideBorder();
				}
			}
			return node;
		}
		
		protected function hideBorder():void
		{
			if(_showBorderNode){
				_showBorderNode.borderAlpha = 0;
				_showBorderNode = null;
			}
		}
		
		/**
		 *延迟增大画布尺寸 
		 * @param type
		 * 	0:双向
		 * 	1:横向
		 * 	2:纵向
		 * @param dw:横向值
		 * @param dh :纵向值
		 * @param delay
		 * 
		 */
		public function delayIncreasesSize(dw:int,dh:int,command:ChangeCanvasSizeCommand):void
		{
			_readyIncreasesWidthDirection = dw;
			_readyIncreasesHeightDirection = dh;
			
			if(dw == 0 && dh == 0){
				return;
			}
			
			command.oldSize.x = canvasM.width;
			command.oldSize.y = canvasM.height;
			
			command.newSize.x = canvasM.width;
			command.newSize.y = canvasM.height;
			
			command.oldWindowRect.x = canvasM.displayRectangleX;
			command.oldWindowRect.y = canvasM.displayRectangleY;
			if(dw != 0){
				command.newSize.x = canvasM.width+_feedbackRect.width;
			}
			if(dh != 0){
				command.newSize.y = canvasM.height+_feedbackRect.height;
			}
			setTimeout(increasesSize,1000,dw,dh,command);
		}
		
		/**
		 * 增加画布高度和宽度 
		 * @param dh
		 * 
		 */
		private function increasesSize(dw:int,dh:int,command:ChangeCanvasSizeCommand):void
		{
			if(_readyIncreasesWidthDirection != dw || _readyIncreasesHeightDirection != dh){
				return;
			}
			
			if(_feedbackRect && _feedbackRectState == 1 && canvasM.mouseState==1){
				if(_continuousIncreasesSizeCount > MAX_CONTINUOUS_ADDITION_COUNT){
					mouseUpHandler(null);
					return;
				}
				increaseWidth(dw,command);
				increaseHeight(dh,command);
				command.execute();
				increasesSizeCommandChain.push(command);
				_continuousIncreasesSizeCount++;
				delayIncreasesSize(dw,dh,command.clone());
			}
		}
		
		private function increaseWidth(dw:int,command:ChangeCanvasSizeCommand):void
		{
			if(dw > 0){
				command.newWindowRect.x = canvasM.displayRectangleX + _feedbackRect.width;
				_feedbackRect.x += _feedbackRect.width;
				command.moveValue = 0;
			}else if(dw < 0){
				command.newWindowRect.x = 0;
				_feedbackRect.x = 0;
				command.moveValue = _feedbackRect.width;
			}else{
				command.newWindowRect.x = canvasM.displayRectangleX;
				command.moveValue = 0;
			}
		}
		
		private function increaseHeight(dh:int,command:ChangeCanvasSizeCommand):void
		{
			if(dh > 0 ){
				command.newWindowRect.y = canvasM.displayRectangleY+_feedbackRect.height;
				_feedbackRect.y += _feedbackRect.height;
				command.moveValue2 = 0;
			}else if(dh < 0){
				command.newWindowRect.y = 0;
				_feedbackRect.y = 0;
				command.moveValue2 = _feedbackRect.height;
			}else{
				command.newWindowRect.y = canvasM.displayRectangleY;
				command.moveValue2 = 0;
			}
		}
		
		private function showResizeImage(v:Array,event:MouseEvent):Boolean
		{
			var offset:int = 28;
			var show:Boolean = true;
			if(v[0] != 0 && v[1] != 0){
				if(v[0] * v[1] > 0){
					_resizeImage.source = images.RESIZE_RIGHT;
					if(v[0] > 0){//右下角
						_resizeImage.x = canvasM.width-offset;
						_resizeImage.y = canvasM.height-offset;
					}else{//左上角
						_resizeImage.x = -4;
						_resizeImage.y = -4;
					}
				}else{
					_resizeImage.source = images.RESIZE_LEFT;
					if(v[0] > 0){//右上角
						_resizeImage.x = canvasM.width-offset;
						_resizeImage.y = -4;
					}else{//左下角
						_resizeImage.x = -4;
						_resizeImage.y = canvasM.height-offset;
					}
				}
			}else if(v[0] != 0){
				_resizeImage.source = images.RESIZE_VERT;
				if(v[0] > 0){
					_resizeImage.x = canvasM.width-offset;
				}else{
					_resizeImage.x = -4;
				}
				_resizeImage.y = event.stageY - canvasM.OriginPointStageY+canvasM.canvas.scrollRect.y-16;
			}else if(v[1] != 0){
				_resizeImage.source = images.RESIZE_HORZ;
				if(v[1] >0 ){
					_resizeImage.y = canvasM.height - offset;
				}else{
					_resizeImage.y = -4;
				}
				_resizeImage.x = event.stageX-canvasM.OriginPointStageX+canvasM.canvas.scrollRect.x-16;
			}else{
				show = false;
			}
			if(show){
				if(!_showResizeImage){
					canvasM.canvas.addElement(_resizeImage);
					_showResizeImage = true;
				}
			}else if(_showResizeImage){
				canvasM.canvas.removeElement(_resizeImage);
				_showResizeImage = false;
			}
			return show;
		}
		
		public function mouseUpHandler(event:MouseEvent):void
		{
			canvasM.mouseState = 0;
			if(_showResizeImage){
				canvasM.canvas.removeElement(_resizeImage);
				_showResizeImage = false;
			}
			if(canvasM.state == 1 && _feedbackRectState==1){
				
				if(_feedbackRect.x <= 0){
					_feedbackRect.x = 2;
				}
				if(_feedbackRect.y <= 0){
					_feedbackRect.y = 2;
				}
				if(_feedbackRect.x >= canvasM.width - _feedbackRect.width){
					_feedbackRect.x -= 2;
				}
				if(_feedbackRect.y >= canvasM.height - _feedbackRect.height){
					_feedbackRect.y -= 2;
				}
				var command:MoveNodeCommand = createMoveNodeCommand(canvasM.domain.focusNode,_feedbackRect.x,_feedbackRect.y);
				if(command){
					for each(var c:Command in increasesSizeCommandChain){
						command.chain.push(c);
					}
					canvasM.executeCommand(command);
				}
				hideFeedbackRect();
			}
		}
		
		public function mouseWheelHandler(event:MouseEvent):void
		{
			if(event.ctrlKey){
				canvasM.changeScrollRectLocation(canvasM.canvas.scrollRect.x-event.delta*5,canvasM.canvas.scrollRect.y);
			}else{
				canvasM.changeScrollRectLocation(canvasM.canvas.scrollRect.x,canvasM.canvas.scrollRect.y-event.delta*5);
			}
		}
		
		public function mouseOutHandler(event:MouseEvent):void
		{
			if(event.stageX <= canvasM.OriginPointStageX
				|| event.stageX >= (canvasM.OriginPointStageX + canvasM.displayRectangleW)
				|| event.stageY <= canvasM.OriginPointStageY
				|| event.stageY >= (canvasM.OriginPointStageY + canvasM.displayRectangleH)){
				this.mouseUpHandler(null);
			}
		}
		
		public function clickHanlder(event:MouseEvent):void
		{
			clickHandler2(event.stageX-canvasM.OriginPointStageX+canvasM.canvas.scrollRect.x,event.stageY
				- canvasM.OriginPointStageY+canvasM.canvas.scrollRect.y);
		}
		
		public function clickHandler2(x:int,y:int):void
		{
			stopFocusTimer();
			canvasM.refreshNodeFocusState(x,y);
		}
		
		private function showFeedBackRectOfFocusNode():void
		{
			if(_feedbackRectState==1){
				return;
			}
			if(_feedbackRect == null){
				_feedbackRect = new Rect();
				var sc:SolidColorStroke = new SolidColorStroke();
				sc.color = 0xbbbbbb;
				sc.weight = 2;
				_feedbackRect.stroke = sc;
			}
			_feedbackRect.x = canvasM.domain.focusNode.x;
			_feedbackRect.y = canvasM.domain.focusNode.y;
			_feedbackRect.width = canvasM.domain.focusNode.width;
			_feedbackRect.height = canvasM.domain.focusNode.height;	
			
			canvasM.canvas.addElement(_feedbackRect);
			_feedbackRectState = 1;
		}
		
		public function hideFeedbackRect():void
		{
			if(_feedbackRectState==1){
				canvasM.canvas.removeElement(_feedbackRect);
				_feedbackRectState = 0;
			}
		}
		
		public function moveFeedBackRect(stageX:int,stageY:int):Array
		{
			var dx:int = stageX - _mouseCurrentX;
			var dy:int = stageY - _mouseCurrentY;
			
			_mouseCurrentX = stageX;
			_mouseCurrentY = stageY;
			if(dx ==0 && dy == 0){
				return [0,0];
			}
			var x:int = _feedbackRect.x + dx;
			var y:int =  _feedbackRect.y + dy;
			var aw:int = 0;
			var ah:int = 0;
			if(x <= 0){
				aw = -1;
				x = 0;
			}
			if(y <= 0){
				ah = -1;
				y = 0;
			}
			
			if(x + _feedbackRect.width >= canvasM.width){
				aw = 1;
				x = canvasM.width - _feedbackRect.width;
			}
			if(y + _feedbackRect.height >= canvasM.height){
				ah = 1;
				y = canvasM.height - _feedbackRect.height;
			}
			var xb:int = 0;
			var yb:int = 0;
			if(x < canvasM.displayRectangleX){
				xb = x - canvasM.displayRectangleX;
			}
			if(x > canvasM.displayRectangleX + canvasM.displayRectangleW -_feedbackRect.width){
				xb = x - (canvasM.displayRectangleX + canvasM.displayRectangleW -_feedbackRect.width);
			}
			if(y < canvasM.displayRectangleY){
				yb = y - canvasM.displayRectangleY;
			}
			if(y > canvasM.displayRectangleY + canvasM.displayRectangleH - _feedbackRect.height){
				yb = y - (canvasM.displayRectangleY + canvasM.displayRectangleH - _feedbackRect.height);
			}
			if(xb != 0 || yb != 0){
				canvasM.changeScrollRectLocation(canvasM.displayRectangleX+xb,canvasM.displayRectangleY+yb);
			}
			_feedbackRect.x = x+xb;
			_feedbackRect.y = y+yb;
			return [aw,ah];
		}
		
		
		
		/**
		 * 使指定的节点可见
		 * 
		 */
		public function showNode(node:NodePM):void
		{
			var centX:int = node.x + node.width/2;
			var centY:int = node.y + node.height/2;
			var ldx:int = centX - canvasM.displayRectangleX-node.width/2;
			var rdx:int = canvasM.displayRectangleX + canvasM.displayRectangleW - centX-node.width/2;
			var tdy:int = centY - canvasM.displayRectangleY-node.height/2;
			var bdy:int = canvasM.displayRectangleY + canvasM.displayRectangleH - centY - node.height/2;
			var move:Boolean = false;
			var x:int = canvasM.displayRectangleX;
			var y:int = canvasM.displayRectangleY;
			if(ldx < 0){
				x += ldx;
				if(centX > canvasM.displayRectangleW/2){
					x -= (canvasM.displayRectangleW/2-node.width/2);
				}else{
					x = 0;
				}
				move = true;
			}
			if(rdx < 0){
				x -= rdx;
				if(canvasM.width-centX > canvasM.displayRectangleW/2){
					x += (canvasM.displayRectangleW/2-node.width/2);
				}else{
					x = canvasM.width - canvasM.displayRectangleW-2;
				}
				move = true;
			}
			if(tdy < 0){
				y += tdy;
				if(centY > canvasM.displayRectangleH/2){
					y -= (canvasM.displayRectangleH/2-node.height/2);
				}else{
					y = 0;
				}
				move = true;
			}
			if(bdy < 0){
				y -= bdy;
				if(canvasM.height-centY > canvasM.displayRectangleH/2){
					y += (canvasM.displayRectangleH/2-node.height/2);
				}else{
					y = canvasM.height - canvasM.displayRectangleH-2;
				}
				move = true;
			}
			if(move){
				canvasM.changeScrollRectLocation(x,y);
			}
		}
		
		public function locationDevice(id:String):void
		{
			stopFocusTimer();
			var node:NodePM = canvasM.domain.findNodeByDeviceId(id,true);
			if(node){
				showNode(node);
				_showFocusTimer.reset();
				_showFocusTimer.start();
			}
		}
		
		private function flashFocusNode(event:TimerEvent):void
		{
			if(canvasM.domain.focusNode){
				//				domain.focusNode.changeFocus(!domain.focusNode.focus);
				canvasM.domain.focusNode.visible = !canvasM.domain.focusNode.visible;
			}
		}
		
		public function stopFocusTimer():void
		{
			if(canvasM.domain.focusNode){
				canvasM.domain.focusNode.visible = true;
			}
			_showFocusTimer.stop();
		}
		
		private function createMoveNodeCommand(node:NodePM,x:int,y:int):MoveNodeCommand
		{
			if(Math.pow(x-node.x,2)+Math.pow(y-node.y,2)<4){//移动很小距离
				return null;
			}
			var c:MoveNodeCommand = new MoveNodeCommand("移动设备");
			c.canvasM = canvasM;
			c.node = node;
			c.newPoint.x = x;
			c.newPoint.y = y;
			c.oldPoint.x = node.x;
			c.oldPoint.y = node.y;
			return c;
		}
		
		private function createChangeCanvasSizeCommand():ChangeCanvasSizeCommand
		{
			var c:ChangeCanvasSizeCommand = new ChangeCanvasSizeCommand("改变画布尺寸");
			c.canvasM = canvasM;
			return c;
		}
		
	}
}