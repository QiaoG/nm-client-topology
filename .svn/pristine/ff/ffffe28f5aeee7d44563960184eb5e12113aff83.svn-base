/**
 * @author GQ
 * create time:2013-11-6- 14:38:38
 */
package com.megaeyes.netmanagement.topology.presentation.commands
{
	import com.megaeyes.netmanagement.topology.presentation.connection.ConnectionPM;
	
	import mx.controls.Alert;

	public class DeleteConnectionCommand extends Command
	{
		public var connection:ConnectionPM;
		
		public function DeleteConnectionCommand(lab:String)
		{
			super(lab);
		}
		
		override public function execute():void
		{
			canvasM.removeConnection(connection);
		}
		
		
		override public function undo():void
		{
			canvasM.addConnection(connection);
		}
		
	}
}