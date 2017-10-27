/**
 * @author GQ
 * create time:2013-7-11- 16:09:14
 */
package com.megaeyes.netmanagement.topology.presentation
{
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.netmanagement.topology.presentation.connection.Connection;
	import com.megaeyes.netmanagement.topology.presentation.connection.ConnectionPM;
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.graphics.ImageSnapshot;
	import mx.graphics.SolidColorStroke;
	import mx.graphics.codec.JPEGEncoder;
	import mx.utils.ObjectUtil;
	
	import spark.components.BorderContainer;
	import spark.components.Image;
	import spark.primitives.Line;
	import spark.primitives.Rect;

	[Event(name="displayRect_change", type="flash.events.Event")]
	public class HawkeyeViewerPM extends CanvasPM
	{
		[Bindable]
		public var maxWidth:int;
		
		private const _MAX_HEIGHT:int = 150;
		
		private var _rects:IList = new ArrayList();
		
		private var _connections:IList = new ArrayList();
		
		public var mouseOriginalLocation:Point = new Point();
		
		[Bindable]
		public var borderStoke:SolidColorStroke=new SolidColorStroke(0x0000f0);
		
		private var _imagecanvas:BorderContainer=new BorderContainer();
		
		[Bindable]
		public var snapshot:ByteArray;
		
		[Bindable]
		public var snapshotScale:Number=1;;
		
		private var _jpegEncoder:JPEGEncoder = new JPEGEncoder();
		
		public function HawkeyeViewerPM()
		{
		}
		
		override public function set canvas(value:BorderContainer):void
		{
			super.canvas = value;
		}
		
		override protected function onlineChanged(event:Event):void
		{
			reDrawNodes();
		}
		
		public function computeHeight(ratio:Number):void
		{
			var dr:Number = maxWidth / _MAX_HEIGHT;
			if(ratio >= dr){
				width = maxWidth;
				height = width / ratio;
			}else{
				height = _MAX_HEIGHT;
				width = height * ratio;
			}
		}
		
		/**
		 *计算鹰眼的位置和大小 
		 * 
		 */
		public function computeHawkeyeDisplayRec(canvasDisRec:Rectangle,canvasW:int,canvasH:int):void
		{
			displayRectangleW = canvasDisRec.width*width/canvasW;
			displayRectangleH = canvasDisRec.height*height/canvasH;
			if(displayRectangleW>=width){
				displayRectangleW = width -1;
			}
			if(displayRectangleH >= height){
				displayRectangleH = height - 1;
			}
			var x:int = canvasDisRec.x*width/canvasW;
			var y:int = canvasDisRec.y*height/canvasH;
			changeDisplayRect(x,y,false);
		}
		
		override protected function mouseDownHanlder(event:MouseEvent):void
		{
			var localx:int = event.localX;
			var localy:int = event.localY;
			mouseState = 0;
			if(localx > displayRectangleX && localy > displayRectangleY 
				&& localx < displayRectangleX+displayRectangleW && localy < displayRectangleY + displayRectangleH){
				mouseState = 1;
			}
			setMouseOriginalLocation(localx,localy);
			
		}
		
		public function setMouseOriginalLocation(x:int,y:int):void
		{
			mouseOriginalLocation.x = x;
			mouseOriginalLocation.y = y;
		}
		
		override protected function mouseMoveHandler(event:MouseEvent):void
		{
			if(mouseState == 0){
				return;
			}
			var localx:int = event.localX;
			var localy:int = event.localY;
			var offsetX:int = localx - mouseOriginalLocation.x;
			var offsetY:int = localy - mouseOriginalLocation.y;
			changeDisplayRect(displayRectangleX+offsetX , displayRectangleY + offsetY);
			setMouseOriginalLocation(localx,localy);
		}
		
		override protected function mouseUpHandler(event:MouseEvent):void
		{
			if(mouseState > 0){
				mouseState = 0;
			}else{
				var localx:int = event.localX - displayRectangleW/2;
				var localy:int = event.localY - displayRectangleH/2;
				changeDisplayRect(localx,localy);
			}
			
		}
		
		public function changeDisplayRect(x:int,y:int,dispatch:Boolean = true):void
		{
			x = x < 0 ? 0 : x;
			y = y < 0 ? 0 : y;
			if(x + displayRectangleW >= width){
				x = width - displayRectangleW-1;
			}
			if(y + displayRectangleH >= height){
				y = height - displayRectangleH-1;
			}
			displayRectangleX = x;
			displayRectangleY = y;
			if(dispatch){
				dispatchEvent(new Event("displayRect_change"));
			}
		}
		
		public function updateBackgroundImage(target:BorderContainer):void
		{
			canvas.removeAllElements();
			
			_imagecanvas.removeAllElements();
			_imagecanvas.graphics.clear();
			
			_imagecanvas.graphics.beginFill(0x0000aa,.5);
			_imagecanvas.graphics.endFill();
			
			_imagecanvas.width = target.width;
			_imagecanvas.height = target.height;
			
			var tempbd:BitmapData;
			var tempbitmap:Bitmap;
			var tempsprt:Sprite;
			var tempuic:UIComponent;
			var child:IVisualElement = null;
			
			for(var i:int = 0; i < canvas.numElements; i++){
				child = canvas.getElementAt(i) as IVisualElement;
				try{
					tempbd=ImageSnapshot.captureBitmapData(child as IBitmapDrawable);
				}
				catch(event:Error){
					Alert.show("error!");
					continue;
				}
				if(tempbd == null){
					Alert.show(ObjectUtil.getClassInfo(child).name);
					continue;
				}
				tempbitmap=new Bitmap(tempbd.clone());
				tempbitmap.width=tempbd.width;
				tempbitmap.height=tempbd.height;
				
				tempsprt=new Sprite();
				tempsprt.addChild(tempbitmap);
				
				tempuic=new UIComponent();
				tempuic.width=tempbd.width;
				tempuic.height=tempbd.height;
				tempuic.addChild(tempsprt);
				tempuic.x=IVisualElement(child).x;
				tempuic.y=IVisualElement(child).y;
				_imagecanvas.addElement(tempuic);
			}
			
			var rate:Number=this.width/target.width;
			rate=rate<this.height/target.height?rate:this.height/target.height;
			_imagecanvas.scaleX=rate;
			_imagecanvas.scaleY=rate;
			canvas.addElement(_imagecanvas);
		}
		
		public function refresh(canvasW:int,canvasH:int,node:NodePM=null):void
		{
			computeNodesLocation(canvasW,canvasH,node);
			reDrawConnections(canvasW,canvasH,node);
			reDrawNodes(node);
		}
		
		public function computeNodesLocation(canvasW:int,canvasH:int,node:NodePM=null):void
		{
			if(node){
				node.computeHawkeyeLocation(canvasW/width,canvasH/height);
				return;
			}
			var n:NodePM = null;
			for(var i:int = 0; i < domain.children.length; i++){
				n = domain.children.getItemAt(i) as NodePM;
				n.computeHawkeyeLocation(canvasW/this.width,canvasH/this.height);
			}
		}
		
		/**
		 *重新绘制节点 
		 * @param node 如果为null，则绘制所有节点
		 * 
		 */
		public function reDrawNodes(node:NodePM=null):void
		{
			var rec:Rect = null;
			for(var j:int = 0; j < _rects.length; j++){
				rec = _rects.getItemAt(j) as Rect;
				canvas.removeElement(rec);
			}
			_rects.removeAll();
			
			var n:NodePM = null;
			for(var i:int = 0; i < domain.children.length; i++){
				n = domain.children.getItemAt(i) as NodePM;
				var r:Rect = new Rect();
				r.x = n.hawkeyeX;
				r.y = n.hawkeyeY;
				r.width = n.hawkeyeW;
				r.height = n.hawkeyeH;
				var sc:SolidColorStroke = new SolidColorStroke();
				sc.color = TopologyDevice(n.data).onLine?0x0000f0:0xcacaca;
				sc.weight = 1;
				r.stroke = sc;
				canvas.addElement(r);
				_rects.addItem(r);
			}
		}
		
		public function reDrawConnections(canvasW:int,canvasH:int,node:NodePM=null):void
		{
			if(true){
				var con:Line = null;
				for(var j:int = 0; j < _connections.length; j++){
					con = _connections.getItemAt(j) as Line;
					canvas.removeElement(con);
				}
				_connections.removeAll();
			}
			var connection:ConnectionPM = null;
			var line:Line = null;
			var scs:SolidColorStroke = null;
			for(var i:int = 0; i < domain.connections.length; i++){
				connection = domain.connections.getItemAt(i) as ConnectionPM;
				line = new Line();
				line.xFrom = connection.fromX * width/canvasW;
				line.xTo = connection.toX * width/canvasW;
				line.yFrom = connection.fromY * height/canvasH;
				line.yTo = connection.toY * height/canvasH;
				scs = new SolidColorStroke();
				scs.color = 0xbbbbbb;
				scs.weight = 1;
				line.stroke = scs;
				canvas.addElement(line);
				_connections.addItem(line);
			}
		}
	}
}