/**
 * @author GQ
 * create time:2013-10-23- 14:31:21
 */
package com.megaeyes.netmanagement.topology.presentation.commands
{
	import com.megaeyes.netmanagement.topology.presentation.TopologyCanvasPM;

	public class Command
	{
		public var canvasM:TopologyCanvasPM;
		
		private var _label:String;
		
		public var chain:Array  = new Array();
		
		public function Command(lab:String)
		{
			label = lab;
		}
		
		public function canExecute():Boolean
		{
			return true;
		}
		
		public function canUndo():Boolean
		{
			return true;
		}
		
		public function execute():void
		{
			
		}
		
		public function redo():void
		{
			execute();
		}
		
		public function undo():void
		{
			
		}
		
		public function dispose():void
		{
			canvasM = null;
		}

		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;
		}

	}
}