/**
 * 创建节点
 * @author GQ
 * create time:2013-11-4- 11:13:04
 */
package com.megaeyes.netmanagement.topology.presentation.commands
{
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	
	import mx.controls.Alert;
	import mx.events.EffectEvent;
	
	import spark.effects.Fade;

	public class CreateNodeCommand extends Command
	{
		public var device:TopologyDevice;
		
		private var _node:NodePM;
		
		public var x:int;
		
		public var y:int;
		
		private var _effect:Fade = new Fade();
		
		private var _isDelete:Boolean;
		
		public function CreateNodeCommand(lab:String)
		{
			super(lab);
			_effect.addEventListener(EffectEvent.EFFECT_END,effectEndHandler);
		}
		
		private function effectEndHandler(event:EffectEvent):void
		{
			if(_isDelete){
				canvasM.deleteDevice(_node);
			}
			canvasM.fireNodeLocationChangeEvent(_node);
		}
		
		private function doEffict(show:Boolean = true):void
		{
			_effect.target = _node.uiHost;
			_effect.alphaFrom = show?0:1;
			_effect.alphaTo = show?1:0;
			_isDelete = !show;
			_effect.play();
		}
		
		override public function execute():void
		{
			_node = canvasM.addDevice(device);
			var cx:int = x -canvasM.OriginPointStageX + canvasM.displayRectangleX;
			var cy:int = y -canvasM.OriginPointStageY + canvasM.displayRectangleY;;
			if(cx - _node.width/2 < 0){
				cx = _node.width/2 + 5;;
			}
			if(cy - _node.height/2 <0){
				cy = _node.height/2 + 5;
			}
			if(cx + _node.width/2 > canvasM.width-5){
				cx = canvasM.width - _node.width/2 - 5;
			}
			if(cy + _node.height/2 > canvasM.height -5){
				cy = canvasM.height - _node.height/2 - 5;
			}
			x = cx-_node.width/2;;
			y = cy-_node.height/2;
			_node.changeLocation(x,y);
			canvasM.refreshNodeFocusState(cx,cy);
			doEffict();
		}
		
		
		override public function undo():void
		{
			doEffict(false);
		}
		
		override public function redo():void
		{
			_node.changeFocus(false);
			canvasM.addNodePM(_node);
			doEffict();
		}
	}
}