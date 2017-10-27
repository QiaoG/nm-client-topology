/**
 * @author GQ
 * create time:2013-7-31- 17:33:41
 */
package com.megaeyes.netmanagement.topology.presentation.connection
{
	import com.megaeyes.netmanagement.topology.presentation.UIElement;
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.controls.Alert;
	
	import spark.primitives.Path;

	public class ConnectionPM extends UIElement
	{
		[Bindable]
		public var fromX:int;
		
		[Bindable]
		public var fromY:int;
		
		[Bindable]
		public var toX:int;
		
		[Bindable]
		public var toY:int;
		
		private var _source:NodePM;
		
		private var _target:NodePM;
		
		public var rectX:int;
		
		public var rectY:int;
		
		public var rectW:int;
		
		public var rectH:int;
		
		public var length2:int;
		
		//arrow
		public var uiArrow:Path;
		
		public var hasArrow:Boolean;
		
		/**
		 *箭头长度 
		 */
		public var ARROW_LENGHT:int = 10;
		
		/**
		 *箭头高度的一半 
		 */
		public var ARROW_HEIGHT:int = 4;
		
		/**
		 *箭头底部端点1，上； 
		 */
		[Bindable]
		public var arrowEndpoint1_X:int;
		
		[Bindable]
		public var arrowEndpoint1_Y:int;
		
		/**
		 * 箭头底部端点1，下； 
		 */
		[Bindable]
		public var arrowEndpoint2_X:int;
		
		[Bindable]
		public var arrowEndpoint2_Y:int;
		
		[Bindable]
		public var pathData:String = "";
		
		[Bindable]
		public var arrowColor:uint = 0xaaaaaa;
		
		public function ConnectionPM()
		{
			borderStoke.color = 0x999999;
		}
		
		public function get target():NodePM
		{
			return _target;
		}

		public function set target(value:NodePM):void
		{
			_target = value;
			_target.connections.push(this);
			_target.addEventListener("change_location",targetLocationChangeHandler);
		}

		public function get source():NodePM
		{
			return _source;
		}

		public function set source(value:NodePM):void
		{
			_source = value;
			_source.connections.push(this);
			_source.addEventListener("change_location",sourceLocationChangeHandler)
		}
		
		private function targetLocationChangeHandler(event:Event):void
		{
			compute();
		}
		
		private function sourceLocationChangeHandler(event:Event):void
		{
			compute();
		}
		
		public function compute():void
		{
			computeSourceAnchor();
			computetargetAnchor();
			rectX = Math.min(fromX,toX);
			rectY = Math.min(fromY,toY);
			rectW = Math.abs(toX - fromX);
			rectH = Math.abs(toY - fromY);
			computeCenter();
			length2 = Math.sqrt((fromX-toX)*(fromX-toX)+(fromY-toY)*(fromY-toY));
			if(hasArrow){
				computeArrow();
				pathData = "M "+toX+" "+toY+" L "+arrowEndpoint1_X+" "+arrowEndpoint1_Y+" L "+arrowEndpoint2_X+" "+arrowEndpoint2_Y+" Z";
			}
		}
		
		/**
		 *计算箭头的位置 
		 * 
		 */
		public function computeArrow():void
		{
			var coX:int = Number(toX) - Number(ARROW_LENGHT)/Number(length2)*Number(toX - fromX);
			var coY:int = Number(toY) - Number(ARROW_LENGHT)/Number(length2)*Number(toY - fromY);
			
			arrowEndpoint1_X = Number(coX) + Number(ARROW_HEIGHT)/Number(ARROW_LENGHT)*Number(toY-coY);
			arrowEndpoint1_Y = Number(coY) - Number(ARROW_HEIGHT)/Number(ARROW_LENGHT)*Number(toX-coX);
			
			arrowEndpoint2_X = Number(coX) - Number(ARROW_HEIGHT)/Number(ARROW_LENGHT)*Number(toY-coY);
			arrowEndpoint2_Y = Number(coY) + Number(ARROW_HEIGHT)/Number(ARROW_LENGHT)*Number(toX-coX);
		}
		
		override public function computeCenter():void
		{
			centerPoint.x = (fromX + toX)/2;
			centerPoint.y = (fromY + toY)/2;
		}
		
		private function computeSourceAnchor():void
		{
			var anchor:Point = source.getAnchorLocation(target.centerPoint);
			this.fromX = anchor.x;
			this.fromY = anchor.y;
		}
		
		private function computetargetAnchor():void
		{
			var anchor:Point = target.getAnchorLocation(source.centerPoint);
			this.toX = anchor.x;
			this.toY = anchor.y;
		}
		
		public function reborn():void
		{
			source = _source;
			target = _target;
		}
		
		public function destroy():void
		{
			_source.removeConncetion(this);
			_target.removeConncetion(this);
			_source.removeEventListener("change_location",sourceLocationChangeHandler);
			_target.removeEventListener("change_location",targetLocationChangeHandler);
			changeFocus(false);
			
		}
		
		override public function equal(element:UIElement):Boolean
		{
			if(element==null || !(element is ConnectionPM)){
				return false;
			}
			var e:Boolean = false;
			var connection:ConnectionPM = element as ConnectionPM;
			e = (connection.source.id == source.id && connection.target.id == target.id) 
				|| (connection.source.id == target.id && connection.target.id == source.id);	
			return e;
		}
		
		public function equal2(sourceId:String,targetId:String):Boolean
		{
			var e:Boolean = false;
			if(sourceId && targetId){
				e = (sourceId == source.id && targetId == target.id) 
					|| (sourceId == target.id && targetId == source.id);
			}
			return e;
		}
		
		override public function changeFocus(f:Boolean):void
		{
			if(focus != f){
				focus = f;
				if(focus){
					borderStoke.color = 0x0000e0;
					borderStoke.weight = 2;
					arrowColor = 0x0000e0;
				}else{
					borderStoke.color = 0xaaaaaa;//0xa0a0a0;
					borderStoke.weight = 1;//0xa0a0a0;
					arrowColor = 0xaaaaaa;
				}
			}
		}
		
		/**
		 *计算某点到此直线的垂直距离 
		 * @param x
		 * @param y
		 * @return 
		 * 
		 */
		override public function computeDistance(x:int,y:int):int
		{
			var dx:int = fromX - toX;
			var dy:int = fromY - toY;
			var dr:int = Math.sqrt(dx*dx + dy*dy);
			
			var dv:int = (x - (y - toY)/(dy/dx) - toX)*dy/dr;
			return Math.abs(dv);
		}
		
		public function computeDistanceToCenter(x:int,y:int):int
		{
			var value:int = Math.sqrt((x-centerPoint.x)*(x-centerPoint.x)+(y-centerPoint.y)*(y-centerPoint.y));
			return value;
		}

	}
}