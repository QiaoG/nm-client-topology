/**
 * 创建连线
 * @author GQ
 * create time:2013-11-4- 11:13:29
 */
package com.megaeyes.netmanagement.topology.presentation.commands
{
	import com.megaeyes.netmanagement.topology.presentation.connection.Connection;
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;

	public class CreateConnectionCommand extends Command
	{
		public var source:NodePM;
		
		public var target:NodePM;
		
		private var _connection:Connection;
		
		public function CreateConnectionCommand(lab:String)
		{
			super(lab);
		}
		
		override public function execute():void
		{
			_connection = canvasM.addConnectionBetweenNodes(source,target);
			canvasM.fireConnectionChangeEvent();
		}
		
		
		override public function undo():void
		{
			canvasM.removeConnection(_connection.model);
		}
		
		override public function redo():void
		{
			canvasM.addConnection(_connection.model);
		}
	}
}