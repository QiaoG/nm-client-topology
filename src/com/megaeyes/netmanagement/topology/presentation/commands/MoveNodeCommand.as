/**
 * @author GQ
 * create time:2013-10-28- 15:14:17
 */
package com.megaeyes.netmanagement.topology.presentation.commands
{
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	
	import flash.geom.Point;
	
	import mx.events.EffectEvent;
	
	import spark.effects.Move;
	
	public class MoveNodeCommand extends Command
	{
		public var oldPoint:Point = new Point();
		
		public var newPoint:Point = new Point();
		
		public var node:NodePM;
		
		private var _effect:Move = new Move();
		
		private var _targetPoint:Point;
		
		private var _undo:Boolean = false;
		
		public function MoveNodeCommand(lab:String)
		{
			super(lab);
			_effect.duration = 200;
			_effect.addEventListener(EffectEvent.EFFECT_END,effectEndHandler);
		}
		
		private function effectEndHandler(event:EffectEvent):void
		{
			canvasM.moveNode(node,_targetPoint.x,_targetPoint.y);
			node.setConnectionsVisible(true);
			if(_undo && chain.length>0){
				var command:Command = null;
				for(var i:int = chain.length - 1;i>=0;i--){
					command = chain[i] as Command;
					command.undo();
				}
			}
			if(chain.length>0){
				canvasM.fireNodeLocationChangeEvent(null);
			}
		}
		
		private function doEffict(newPoint:Point):void
		{
			_effect.target = node.uiHost;
			_effect.xFrom = node.x;
			_effect.yFrom = node.y;
			_effect.xTo = newPoint.x;
			_effect.yTo = newPoint.y;
			node.setConnectionsVisible(false);
			_effect.play();
		}
		
		override public function execute():void
		{
			_targetPoint = newPoint;
			_undo = false;
			doEffict(_targetPoint);
		}
		
		override public function undo():void
		{
			_targetPoint = oldPoint;
			_undo = true;
			doEffict(_targetPoint);
		}
		
		override public function redo():void
		{
			_undo = false;
			if(chain.length>0){
				var command:Command = null;
				for(var i:int=0;i < chain.length;i++){
					command = chain[i] as Command;
					command.redo();
				}
			}
			_targetPoint = newPoint;
			doEffict(_targetPoint);
		}
		
		override public function dispose():void
		{
			super.dispose();
			if(chain && chain.length>0){
				var command:Command = null;
				for(var i:int=0;i < chain.length;i++){
					command = chain[i] as Command;
					command.dispose();
				}
			}
			chain.splice(0);
			chain = null;
		}
		
		override public function get label():String
		{
			return super.label+":"+node.name;
		}
	}
}