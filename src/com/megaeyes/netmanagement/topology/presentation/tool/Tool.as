/**
 * @author GQ
 * create time:2013-10-22- 16:56:16
 */
package com.megaeyes.netmanagement.topology.presentation.tool
{
	import com.megaeyes.netmanagement.topology.presentation.CanvasPM;
	
	import flash.events.MouseEvent;
	
	import spark.components.BorderContainer;
	import spark.primitives.Rect;

	public interface Tool
	{
		function activate():void;
		
		function deactivate():void;
		
		function mouseDownHanlder(event:MouseEvent):void;
		
		function mouseMoveHandler(event:MouseEvent):void;
		
		function mouseUpHandler(event:MouseEvent):void;
		
		function mouseWheelHandler(event:MouseEvent):void;
		
		function mouseOutHandler(event:MouseEvent):void;
		
		function clickHanlder(event:MouseEvent):void;
		
	}
}