/**
 * @author GQ
 * create time:2013-10-28- 15:13:36
 */
package com.megaeyes.netmanagement.topology.presentation.commands
{
	import flash.geom.Point;

	public class ChangeCanvasSizeCommand extends Command
	{
		
		public var oldSize:Point = new Point();
		
		public var newSize:Point = new Point();
		
		/**
		 *节点移动值 横向
		 */
		public var moveValue:int;
		
		/**
		 *节点移动值纵向
		 */
		public var moveValue2:int;
		
		public var oldWindowRect:Point = new Point();
		
		public var newWindowRect:Point = new Point();
		
		public function ChangeCanvasSizeCommand(lab:String)
		{
			super(lab);
		}
		
		override public function execute():void
		{
			canvasM.changeCanvasSize(newSize.x,newSize.y);
			if(moveValue != 0 || moveValue2 != 0){
				canvasM.domain.moveAllNodes(moveValue,moveValue2);
				canvasM.domain.computeAllConnections();
			}
			canvasM.changeScrollRectLocation(newWindowRect.x,newWindowRect.y);
		}
		
		
		override public function undo():void
		{
			if(moveValue != 0 || moveValue2 != 0){
				canvasM.domain.moveAllNodes(-moveValue,-moveValue2);
				canvasM.domain.computeAllConnections();
			}
			canvasM.changeCanvasSize(oldSize.x,oldSize.y);
			canvasM.changeScrollRectLocation(oldWindowRect.x,oldWindowRect.y);
		}
		
		public function clone():ChangeCanvasSizeCommand
		{
			var c:ChangeCanvasSizeCommand = new ChangeCanvasSizeCommand(label);
			c.canvasM = canvasM;
			return c;
		}
	}
}