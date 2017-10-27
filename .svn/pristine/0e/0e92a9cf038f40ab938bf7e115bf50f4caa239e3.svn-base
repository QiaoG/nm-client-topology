/**
 * 创建连线
 * @author GQ
 * create time:2013-11-4- 11:18:03
 */
package com.megaeyes.netmanagement.topology.presentation.tool
{
	import com.megaeyes.netmanagement.topology.infrastructure.ImageUtil;
	import com.megaeyes.netmanagement.topology.presentation.commands.CreateConnectionCommand;
	import com.megaeyes.netmanagement.topology.presentation.connection.Connection;
	import com.megaeyes.netmanagement.topology.presentation.connection.ConnectionPM;
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.controls.Alert;
	import mx.graphics.SolidColorStroke;
	import mx.managers.CursorManager;
	
	import spark.primitives.Line;
	
	public class CreateConnectionTool extends CustomTopologyTool
	{
		private var _sourceNode:NodePM;
		
		private var _targetNode:NodePM;
		
		private var _feedbackLine:Line = new Line();
		
		private var _showFeedback:Boolean = false;
		
		public function CreateConnectionTool()
		{
			var sc:SolidColorStroke = new SolidColorStroke();
			sc.color = 0x0000f0;
			sc.weight = 1;
			_feedbackLine.stroke = sc;
		}
		
		override public function mouseDownHanlder(event:MouseEvent):void
		{
		}
		
		override public function mouseMoveHandler(event:MouseEvent):void
		{
			var x:int = event.stageX-canvasM.OriginPointStageX+canvasM.canvas.scrollRect.x;
			var y:int = event.stageY - canvasM.OriginPointStageY+canvasM.canvas.scrollRect.y;
			if(_sourceNode){
				var from:Point = _sourceNode.getAnchorLocation(new Point(x,y));
				_feedbackLine.xFrom = from.x;
				_feedbackLine.yFrom = from.y;
				_feedbackLine.xTo = x;
				_feedbackLine.yTo = y;
				if(!_showFeedback){
					canvasM.canvas.addElement(_feedbackLine);
					_showFeedback = true;
				}
				var node:NodePM = displayBorderHanlder(x,y);
				if(node){
					node.borderColor = (node.equal(_sourceNode) || _sourceNode.checkLinkOtherNode(node))?0xff0000:0x00f000;
					node.borderAlpha = .5;
				}
			}
			
			CursorManager.setCursor(images.cursorConnection,2,-10,-10);
		}
		
		override public function mouseUpHandler(event:MouseEvent):void
		{
		}
		
		override public function mouseWheelHandler(event:MouseEvent):void
		{
		}
		
		override public function mouseOutHandler(event:MouseEvent):void
		{
			if(event.stageX < canvasM.OriginPointStageX
				|| event.stageX > (canvasM.OriginPointStageX + canvasM.displayRectangleW)
				|| event.stageY < canvasM.OriginPointStageY
				|| event.stageY > (canvasM.OriginPointStageY + canvasM.displayRectangleH)){
				CursorManager.removeAllCursors();
				removeFeedback();
			}
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
			if(canvasM.domain.focusNode){
				if(_sourceNode){//绘制连线
					if(_sourceNode.id == canvasM.domain.focusNode.id){//同节点
						removeFeedback();
					}else{
						_targetNode = canvasM.domain.focusNode;
						if(!checkExist()){
							canvasM.commandStack.execute(getCreateConnectionCommand());
						}
						removeFeedback();
					}
					hideBorder();
				}else{//
					_sourceNode = canvasM.domain.focusNode;
					_targetNode = null;
				}
			}else{
				if(_sourceNode){
					removeFeedback();
				}
			}
		}
		
		private function checkExist():Boolean
		{
			for each(var n:ConnectionPM in _sourceNode.connections){
				if(n.equal2(_sourceNode.data.deviceId , _targetNode.data.deviceId)){
					return true;
				}
			}
			return false;
		}
		
		private function removeFeedback():void
		{
			if(_showFeedback){
				canvasM.canvas.removeElement(_feedbackLine);
				_sourceNode = null;
				_showFeedback = false;
			}
			if(temp){
				canvasM.changeTool(0);
				CursorManager.removeAllCursors();
				if(_targetNode){
					CustomTopologyTool(canvasM.currentTool).showBtnImage(_targetNode);
				}
			}
			_targetNode = null;
		}
		
		private function getCreateConnectionCommand():CreateConnectionCommand
		{
			var command:CreateConnectionCommand = new CreateConnectionCommand("新建连线("+_sourceNode.data.deviceName+" - "+_targetNode.data.deviceName+")");
			command.canvasM = canvasM;
			command.source = _sourceNode;
			command.target = _targetNode;
			return command;
		}
	}
}