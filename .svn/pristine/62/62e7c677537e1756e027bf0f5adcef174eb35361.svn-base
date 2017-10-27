/**
 * @author GQ
 * create time:2013-11-6- 14:38:17
 */
package com.megaeyes.netmanagement.topology.presentation.commands
{
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.netmanagement.topology.presentation.connection.ConnectionPM;
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	
	import mx.controls.Alert;
	import mx.events.EffectEvent;
	
	import spark.effects.Fade;

	public class DeleteNodeCommand extends Command
	{
		public var node:NodePM;
		
		private var _effect:Fade = new Fade();
		
		private var _isDelete:Boolean;
		
		public function DeleteNodeCommand(lab:String)
		{
			super(lab);
			_effect.addEventListener(EffectEvent.EFFECT_END,effectEndHandler);
		}
		
		private function effectEndHandler(event:EffectEvent):void
		{
			if(_isDelete){
				canvasM.deleteDevice(node);
			}else{
				for each(var dc:DeleteConnectionCommand in chain){
					dc.undo();
				}
			}
			canvasM.fireNodeLocationChangeEvent(node);
		}
		
		private function doEffict(show:Boolean = true):void
		{
			_effect.target = node.uiHost;
			_effect.alphaFrom = show?0:1;
			_effect.alphaTo = show?1:0;
			_isDelete = !show;
			_effect.play();
		}
		
		override public function execute():void
		{
			var delConCmd:DeleteConnectionCommand = null;
			for each(var con:ConnectionPM in node.connections){
				delConCmd = new DeleteConnectionCommand("");
				delConCmd.canvasM = canvasM;
				delConCmd.connection = con;
				chain.push(delConCmd);
			}
			for each(var delC:DeleteConnectionCommand in chain){
				delC.execute();
			}
			doEffict(false);
		}
		
		
		override public function undo():void
		{
			canvasM.addNodePM(node);
			canvasM.fireNodeLocationChangeEvent(node);
			doEffict();
		}
		
		override public function redo():void
		{
			for each(var delC:DeleteConnectionCommand in chain){
				delC.redo();
			}
			doEffict(false);
		}
	}
}