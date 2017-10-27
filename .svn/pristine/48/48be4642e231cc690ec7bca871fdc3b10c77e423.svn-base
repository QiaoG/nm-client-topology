/**
 * @author GQ
 * create time:2013-10-30- 14:28:27
 */
package com.megaeyes.netmanagement.topology.presentation.commands
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.Alert;

	[Event(name="command_stack_change", type="flash.events.Event")]
	[Event(name="command_execute_error", type="flash.events.Event")]
	[Event(name="dirty_change", type="flash.events.Event")]
	public class CommandStack extends EventDispatcher
	{
		[Bindable("redoable_change")]
		public var redoable:IList = new ArrayList();
		
		[Bindable("undoable_change")]
		public var undoable:IList = new ArrayList();
		
		private var _undoLimit:int;
		
		private var _redoLimit:int;
		
		private var _saveLocation:int = 0;
		
		[Bindable]
		public var lastUndoCommandLabel:String;
		
		[Bindable]
		public var lastRedoCommandLabel:String;
		
		public function CommandStack()
		{
		}
		
		public function canRedo():Boolean
		{
			return redoable.length != 0;
		}
		
		public function canUndo():Boolean
		{
			if(undoable.length == 0){
				return false;
			}
			return getLastUndoCommand().canUndo();
		}
		
		public function setLastCommandLabel(undo:Boolean):void
		{
			var c:Command = undo?getLastUndoCommand():getLastRedoCommand();
			undo?(lastUndoCommandLabel = c?c.label:""):(lastRedoCommandLabel=c?c.label:"");
		}
		
		public function getLastUndoCommand():Command
		{
			if(undoable.length == 0)
				return null;
			var c:Command = undoable.getItemAt(undoable.length-1) as Command;
			return c;
		}
		
		public function getLastRedoCommand():Command
		{
			if(redoable.length == 0)
				return null;
			return redoable.getItemAt(redoable.length-1) as Command;
		}
		
		private function popCommand(undo:Boolean):Command
		{
			var list:IList = undo?undoable:redoable;
			if(list.length == 0)
				return null;
			var c:Command = Command(list.removeItemAt(list.length-1));
			setLastCommandLabel(undo);
			dispatchEvent(new Event(undo?"undoable_change":"redoable_change"));
			return c;
		}
		
		public function flush():void
		{
			flushRedo();
			flushUndo();
		}
		
		private function flushUndo():void
		{
			while(undoable.length != 0){
				Command(undoable.removeItemAt(undoable.length-1)).dispose();
				setLastCommandLabel(true);
			}
			dispatchEvent(new Event("undoable_change"));
		}
		
		private function flushRedo():void
		{
			while(redoable.length != 0){
				Command(redoable.removeItemAt(redoable.length-1)).dispose();
				setLastCommandLabel(false);
			}
			dispatchEvent(new Event("redoable_change"));
		}
		
		public function execute(command:Command):void
		{
			flushRedo();
			try {
				command.execute();
				if (undoLimit > 0) {
					while (undoable.length >= undoLimit) {
						Command(undoable.removeItemAt(0)).dispose();
						if (_saveLocation > -1)
							saveLocation = _saveLocation-1;
					}
				}
				if (_saveLocation > undoable.length)
					saveLocation = -1; //The save point was somewhere in the redo stack
				undoable.addItem(command);
				setLastCommandLabel(true);
				dispatchEvent(new Event("undoable_change"));
				dispatchEvent(new Event("dirty_change"));
			} finally {
				dispatchEvent(new Event("command_execute_error"));
			}
		}
		
		public function redo():void {
			if (!canRedo())
				return;
			var command:Command = popCommand(false);
			try {
				command.redo();
				undoable.addItem(command);
				setLastCommandLabel(true);
				dispatchEvent(new Event("undoable_change"));
				dispatchEvent(new Event("dirty_change"));
			} finally {
				dispatchEvent(new Event("command_execute_error"));
			}
		}
		
		public function undo():void {
			var command:Command = popCommand(true);
			try {
				command.undo();
				redoable.addItem(command);
				setLastCommandLabel(false);
				dispatchEvent(new Event("redoable_change"));
				dispatchEvent(new Event("dirty_change"));
			} finally {
				dispatchEvent(new Event("command_execute_error"));
			}
		}
		
		public function markSaveLocation():void
		{
			_saveLocation = undoable.length;
			dispatchEvent(new Event("dirty_change"));
		}
		
		public function isDirty():Boolean {
			return undoable.length != _saveLocation;
		}
		
		/**
		 *标识是否变脏的参照点 
		 */
		private function set saveLocation(value:int):void
		{
			_saveLocation = value;
			dispatchEvent(new Event("dirty_change"));
		}

		
		public function get redoLimit():int
		{
			return _redoLimit;
		}
		
		public function set redoLimit(value:int):void
		{
			_redoLimit = value;
		}
		
		public function get undoLimit():int
		{
			return _undoLimit;
		}
		
		public function set undoLimit(value:int):void
		{
			_undoLimit = value;
		}
	}
}