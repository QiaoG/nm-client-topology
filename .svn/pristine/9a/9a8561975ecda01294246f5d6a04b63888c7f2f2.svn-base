/**
 * @author GQ
 * create time:2013-8-5- 9:33:32
 */
package com.megaeyes.netmanagement.topology.presentation.layout
{
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	
	import flash.geom.Rectangle;
	
	public class DefaultLayout implements Layout
	{
		public var horizontal:Boolean = false;
		
		public function DefaultLayout()
		{
		}
		
		public function layout(n:Object,startX:int,startY:int):Rectangle
		{
			var pm:NodePM = n as NodePM;
			var rec:Rectangle = horizontal?horizontalLayoutChildren(pm,startX,startY):verticalLayoutChildren(pm,startX,startY);
			return rec;
		}
		
		/**
		 * 布局返回传入及节点的宽度（递归包含子节点）
		 * @param pm
		 * @param layer
		 * @param startX
		 * @param align 对其方式
		 *  0:横向对齐
		 *  1：纵向对齐
		 * @return 
		 * 
		 */
		protected function horizontalLayoutChildren(pm:NodePM,startX:int=50,startY:int = 50):Rectangle
		{
			var rec:Rectangle = new Rectangle(startX,startY);
			var w:int = 0;
			var h:int = 0;
			var tr:Rectangle = null;
			var child:NodePM = null;
			for(var i:int = 0; i < pm.children.length; i++){
				child = pm.children.getItemAt(i) as NodePM;
				tr = child.children.length<4 ? horizontalLayoutChildren(child,startX+w,startY+ pm.height*2)
					:verticalLayoutChildren(child,startX+w,startY+ pm.height*2);
				w += tr.width;
				if(pm.height*2 + tr.height > h){
					h = pm.height*2 + tr.height;
				}
			}
			//调整节点位置
			if(pm.children.length < 1){
				w = pm.width+20;
				h = pm.height + 20;
				pm.changeLocation(startX+10,startY + 10);
//				pm.x = startX+10;
//				pm.y = startY + 10;
			}else{
				pm.changeLocation(startX + w / 2-pm.width/2,startY+10);
//				pm.x = startX + w / 2-pm.width/2;
//				pm.y = startY;
			}
			rec.width = w;
			rec.height = h;
			return rec;
		}
		
		protected function verticalLayoutChildren(pm:NodePM,startX:int=50,startY:int=50):Rectangle
		{
			var rec:Rectangle = new Rectangle(startX,startY);
			var w:int = 0;
			var h:int = 50;
			var tr:Rectangle = null;
			var child:NodePM = null;
			for(var i:int = 0; i < pm.children.length; i++){
				child = pm.children.getItemAt(i) as NodePM;
				tr = child.children.length<4 ? horizontalLayoutChildren(child,startX+pm.width+10,startY+ h)
					:verticalLayoutChildren(child,startX+pm.width+10,startY+h);
				w = pm.width*2+30;
				h += tr.height;
			}
			//调整节点位置
			if(pm.children.length < 1){
				w = pm.width+20;
				h = pm.height + 30;
			}
			pm.changeLocation(startX+10,startY + 10);
			rec.width = w;
			rec.height = h;
			return rec;
		}
		
	}
}