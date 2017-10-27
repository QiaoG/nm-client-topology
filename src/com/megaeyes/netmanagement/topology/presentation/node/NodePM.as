/**
 * @author GQ
 * create time:2013-7-18- 16:28:01
 */
package com.megaeyes.netmanagement.topology.presentation.node
{
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.netmanagement.topology.infrastructure.ImageUtil;
	import com.megaeyes.netmanagement.topology.presentation.UIElement;
	import com.megaeyes.netmanagement.topology.presentation.connection.ConnectionPM;
	import com.megaeyes.networkmanagement.api.domain.vo.AlarmVO;
	import com.megaeyes.networkmanagement.api.domain.vo.Device;
	import com.megaeyes.networkmanagement.api.domain.vo.OrganVO;
	import com.megaeyes.networkmanagement.api.utils.DeviceUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.graphics.SolidColorStroke;

	[Event(name="change_location", type="flash.events.Event")]
	public class NodePM extends UIElement
	{
		[Bindable]
		public var images:ImageUtil;
		
		public var id:String;
		
		[Bindable]
		public var title:String;
		
		[Bindable]
		public var name:String;
		
		[Bindable]
		public var data:Object;
		
		[Bindable]
		public var x:int;
		
		[Bindable]
		public var y:int;
		
		[Bindable]
		public var hawkeyeX:int;
		
		[Bindable]
		public var hawkeyeY:int;
		
		[Bindable]
		public var hawkeyeW:int;
		
		[Bindable]
		public var hawkeyeH:int;
		
		[Bindable]
		public var width:int = 80;
		
		[Bindable]
		public var height:int = 65;
		
		[Bindable]
		public var subListHeight:int = 0;
		
		public var connections:Array = new Array();
		
		public var children:IList = new ArrayList();
		
		/**
		 *子节点对齐方式
		 * 0：横向对齐
		 * 1：纵向对齐 
		 */
		public var chilrenAlign:int = 0;
		
		[Bindable]
		public var focusDevice:TopologyDevice
		
		private var _isMain:Boolean;
		
		[Bindable]
		public var image:Class
		
		[Bindable]
		public var stateImage:Class;
		
		[Bindable]
		public var borderVisible:Boolean = true;
		
		[Bindable]
		public var borderAlpha:Number = 0;
		
		[Bindable]
		public var borderColor:uint = 0x0000f0;
		
//		[Inject]
//		public var deviceUtiles:DeviceUtils;
		
		public function NodePM()
		{
			
		}
		
		public function get isMain():Boolean
		{
			return _isMain;
		}

		public function set isMain(value:Boolean):void
		{
			_isMain = value;
			borderStoke.weight = isMain?3:1;
			width = isMain?96:92
//			borderStoke.color = isMain?0xa0a0a0:0xdddddd;
		}

		public function setData(d:Object):void
		{
			data = d;
			var de:TopologyDevice = data as TopologyDevice;
			id = de.deviceId;
			title = getTitle(de);
			name = de.displayName;
			focusDevice = data as TopologyDevice;
			image = images.getImage(de);
			stateImage = images.getStateImage(de);
			computeSize();
		}
		
		public function refreshDevice(de:TopologyDevice):int
		{
			var r:int = 0;
			if(de.onLine !=TopologyDevice(data).onLine){
				TopologyDevice(data).onLine = de.onLine;
				image = images.getImage(de);
				r = 1;
			}
			if(de.currentStatus != TopologyDevice(data).currentStatus){
				TopologyDevice(data).currentStatus = de.currentStatus;
				stateImage = images.getStateImage(de);
				if(r == 1){
					r = 3;
				}else{
					r = 2;
				}
			}
			return r;
		}
		
		private function getTitle(d:TopologyDevice):String
		{
			return DeviceUtils.getDeviceTypeName(d.deviceType);
		}
		
		public function changeLocation(nx:int,ny:int):void
		{
			x = nx;
			y = ny;
			computeCenter();
			dispatchEvent(new Event("change_location"));
		}
		
		private function computeSize():void
		{
			var de:TopologyDevice = data as TopologyDevice;
			subListHeight = (de.subChildren.length>4?4:de.subChildren.length) * 32;
			height = 65 + subListHeight;
			computeCenter();
		}
		
		override public function computeCenter():void
		{
			centerPoint.x = x + width/2;
			centerPoint.y = y + height/2;
		}
		
		public function getAnchorLocation(reference:Point):Point
		{
			var centerX:int = x + width/2;
			var centerY:int = y + height/2;
			
			if (reference.x == centerX && reference.y == centerY)
				return new Point(centerX, centerY); 
			
			var dx:int = reference.x - centerX;
			var dy:int = reference.y - centerY;
			
			var scale:Number = 0.5 / Math.max(Math.abs(dx) / width, Math.abs(dy) / height);
			
			dx *= scale;
			dy *= scale;
			centerX += dx;
			centerY += dy;
			
			return new Point(Math.round(centerX), Math.round(centerY));
		}
		
		public function computeHawkeyeLocation(ratioX:Number,ratioY:Number):void
		{
			hawkeyeX = x / ratioX;
			hawkeyeY = y / ratioY;
			hawkeyeW = width / ratioX;
			hawkeyeH = height / ratioY;
		}
		
		public function removeConncetion(con:ConnectionPM):void
		{
			var i:int = 0;
			for each(var c:ConnectionPM in connections){
				if(c.equal(con)){
					connections.splice(i,1);
					break;
				}
				i++;
			}
		}
		
		public function setConnectionsVisible(v:Boolean):void
		{
			for each(var con:ConnectionPM in connections){
				con.visible = v;
			}
		}
		
		/**
		 * 检测是否已经和指定的节点有连接
		 * @param other
		 * @return 
		 * 
		 */
		public function checkLinkOtherNode(other:NodePM):Boolean
		{
			var link:Boolean = false;
			for each(var con:ConnectionPM in connections){
				if(other.equal(con.source) || other.equal(con.target)){
					link = true;
				}
			}
			return link;
		}
		
		override public function computeDistance(x:int,y:int):int
		{
			var value:int = Math.sqrt((x-centerPoint.x)*(x-centerPoint.x)+(y-centerPoint.y)*(y-centerPoint.y));
			return value;
		}
		
		override public function equal(element:UIElement):Boolean
		{
			if(element==null || !(element is NodePM)){
				return false;
			}
			
			return NodePM(element).id == id;
		}
		
		public function alarmNotify(alarm:AlarmVO):void
		{
			//无心跳，进程未启动
			if(alarm.alarmTypeCode == '104000' || alarm.alarmTypeCode == '404000' || alarm.alarmTypeCode == '401005'){
				if(alarm.clearFlag==1){
					TopologyDevice(data).onLine = true;
				}else{
					TopologyDevice(data).onLine = false;
				}
				image = images.getImage(TopologyDevice(data));
				stateImage = images.getStateImage(TopologyDevice(data));
			}
		}
		
	}
}