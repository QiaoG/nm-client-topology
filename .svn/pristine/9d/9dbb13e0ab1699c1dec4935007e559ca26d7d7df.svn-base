/**
 * @author GQ
 * create time:2013-7-11- 16:27:35
 */
package com.megaeyes.netmanagement.topology.presentation
{
	import com.megaeyes.netmanagement.topology.infrastructure.ImageUtil;
	import com.megaeyes.netmanagement.topology.presentation.tool.Tool;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import org.spicefactory.lib.reflect.types.Void;
	
	import spark.components.BorderContainer;
	import spark.primitives.Line;

	public class CanvasPM extends EventDispatcher
	{
		
		[Bindable]
		/**
		 *canvas原点在stage坐标系中的x坐标 
		 */
		public var OriginPointStageX:int;
		
		[Bindable]
		/**
		 * canvas原点在stage坐标系中的y坐标 
		 */
		public var OriginPointStageY:int;
		
		[Bindable]
		public var width:int;
		
		[Bindable]
		public var height:int;
		
		[Bindable]
		public var displayRectangleX:int;
		
		[Bindable]
		public var displayRectangleY:int;
		
		[Bindable]
		public var displayRectangleW:int;
		
		[Bindable]
		public var displayRectangleH:int;
		
		/**
		 *鼠标状态
		 * 0： 弹起
		 * 1：按下
		 */
		public var mouseState:int = 0;
		
//		[Bindable]
//		public var mouseOriginalLocation:Point = new Point();
		
		private var _canvas:BorderContainer;
		
		public var scale:Number=1;
		
		/**
		 *最大放大倍率 
		 */
		public static const MAX:int = 5;
		
		[Bindable]
		public var domain:TopologyModel;
		
		[Inject]
		[Bindable]
		public var images:ImageUtil;
		
		private var _currentTool:Tool;
		
		public function CanvasPM()
		{
//			images = new ImageUtil();
		}
		
		[Bindable]
		public function get canvas():BorderContainer
		{
			return _canvas;
		}
		
		public function set canvas(value:BorderContainer):void
		{
			_canvas = value;
			_canvas.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHanlder);
			_canvas.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
			_canvas.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			_canvas.addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler);
			_canvas.addEventListener(MouseEvent.MOUSE_OUT ,mouseOutHandler);
		}
		
		public function injectDM(dm:TopologyModel):void
		{
			domain = dm;
			domain.addEventListener("get_devices_complement",refreshCanvas);
			domain.addEventListener("change_device_online_status",onlineChanged);
		}
		
		/**
		 *当domain(TopologyModel)获取到所有设备后，在画布上绘制 ;
		 * 由domain.setDevices()或domain.setRootDevice()触发。
		 * @param event
		 * 
		 */
		protected function refreshCanvas(event:Event):void
		{
		}
		
		protected function onlineChanged(event:Event):void
		{
			
		}
		
//		public function setMouseOriginalLocation(x:int,y:int):void
//		{
//			mouseOriginalLocation.x = x;
//			mouseOriginalLocation.y = y;
//		}
		
		public function initOriginalLocation(x:int,y:int):void
		{
			OriginPointStageX = x;
			OriginPointStageY = y;
		}
		
		protected function mouseDownHanlder(event:MouseEvent):void
		{
			
		}
		
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			
		}
		
		protected function mouseUpHandler(event:MouseEvent):void
		{
		}
		
		protected function mouseOutHandler(event:MouseEvent):void
		{
			
		}
		
		protected function mouseWheelHandler(event:MouseEvent):void
		{
			
		}
	}
}