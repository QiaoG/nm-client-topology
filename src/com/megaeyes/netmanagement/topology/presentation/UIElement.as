/**
 * @author GQ
 * create time:2013-11-6- 13:18:18
 */
package com.megaeyes.netmanagement.topology.presentation
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import mx.core.IVisualElement;
	import mx.graphics.SolidColorStroke;
	
	public class UIElement extends EventDispatcher
	{
		/**
		 *对于Node为UIComponent
		 *对于Connection为GraphicElement 
		 */
		public var uiHost:IVisualElement;
		
		[Bindable]
		public var visible:Boolean = true;
		
		[Bindable]
		public var focus:Boolean;
		
		[Bindable]
		public var borderStoke:SolidColorStroke=new SolidColorStroke(0xffffff);
		
		public var centerPoint:Point = new Point();
		
		public function UIElement(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function changeFocus(f:Boolean):void
		{
			if(focus != f){
				focus = f;
				if(focus){
					borderStoke.color = 0x0000e0;
				}else{
					borderStoke.color = 0xffffff;//0xa0a0a0;
				}
			}
		}
		
		public function computeCenter():void
		{
			
		}
		
		/**
		 *计算某点到本组件的距离 
		 * @param x
		 * @param y
		 * @return 
		 * 
		 */
		public function computeDistance(x:int,y:int):int
		{
			return 0;
		}
		
		public function equal(element:UIElement):Boolean
		{
			return false;
		}
	}
}