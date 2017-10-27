/**
 * @author GQ
 * create time:2014-2-28- 10:04:40
 */
package com.megaeyes.netmanagement.topology.presentation.layout
{
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.IList;
	import mx.controls.Alert;

	public class CircleLayout implements Layout
	{
		private var list:IList;
		
		public function CircleLayout()
		{
		}
		
		public function layout(n:Object,startX:int,startY:int):Rectangle
		{
			var rec:Rectangle = new Rectangle(startX,startY);
			list = n as IList;
			var total:int = list.length;
			var columns:int = total<5?total:(total<26?5:Math.sqrt(total));
			var rows:int = total / columns +(total % columns == 0 ? 0 : 1);
			var node:NodePM = null;
			for(var i:int = 0; i < list.length; i++){
				setLocation(list.getItemAt(i) as NodePM,0,0);
			}
			
			var maxW:int = 0;
			var rowH:int = 0;
			var tr:Rectangle = null;
			var startXX:int = startX;
			var startYY:int = startY;
			var index:int = 0;
			for(var r:int = 0; r < rows; r++){
				startXX = startX;
				rowH = 0;
				for(var c:int = 0; c < columns; c++){
					index = r*columns+c;
					if(index >= list.length){
						break;
					}
					node =  list.getItemAt(index) as NodePM;
					tr = circleLayoutChildren(node);
					changeOringin(node,startXX,startYY);
					startXX += tr.width+20;
					if(startXX > maxW){
						maxW = startXX;
					}
					if(tr.height > rowH){
						rowH = tr.height;
					}
				}
				startYY += rowH+20;
			}
			var s:Point = new Point();
			computerBorder(list,s);
			
			rec.width = s.x;
			rec.height = s.y;
			return rec;
		}
		
		/**
		 *环形布局,子节点围绕在父节点周围 
		 * @param pm
		 * @param startX
		 * @param startY
		 * @return 
		 * 
		 */
		protected function circleLayoutChildren(pm:NodePM):Rectangle
		{
			var rec:Rectangle = new Rectangle(20,20);
			var minRadius:int = 120;
			var count:int = pm.children.length;
			if(count > 0){
				//平均角度
				var perAngle:Number = 360/count;
				var child:NodePM = null;
				var r:int = 0;
				var rt:Rectangle = null;
				var index:int = 0;
				var angle:Number = 0;
				var minX:int = 0;
				var minY:int = 0;
				var maxX:int = 0;
				var maxY:int = 0;
				var hDistance:int = 0;//水平距离
				var vDistance:int = 0;
				var recs:Array = new Array();
				for(var i:int = 0; i < pm.children.length; i++){
					child = pm.children.getItemAt(i) as NodePM;
					rt = circleLayoutChildren(child);
					if(perAngle==360){
						r = Math.max(rt.width,rt.height);
					}else{
						r = Math.max(rt.width,rt.height)/(Math.tan(perAngle/360*Math.PI)*2);
					}
					
					r = r < minRadius ? minRadius : (r>1200 ?r*1/2:(r>500?r*2/3:r));
					
					angle = index*perAngle;
					var short:Boolean = pm.children.length>20 && child.children.length==0 && i%2==1;
					hDistance = Math.cos(angle/180*Math.PI)*(short?r*2/(pm.children.length>50?4:3):r);
					vDistance = Math.sin(angle/180*Math.PI)*(short?r*2/(pm.children.length>50?4:3):r);
					recs.push({m:child,w:rt.width,h:rt.height,ho:hDistance,ve:vDistance});
					
					if(hDistance > 0){
						if(hDistance+rt.width > maxX){
							maxX = hDistance+rt.width;
						}
					}else{
						if(hDistance-rt.width < minX){
							minX = hDistance-rt.width;
						}
					}
					if(vDistance > 0){
						if(vDistance+rt.height > maxY){
							maxY = vDistance+rt.height;
						}
					}else{
						if(vDistance-rt.height < minY){
							minY = vDistance-rt.height;
						}
					}
					index++;
				}
				
				pm.x = -minX-pm.width/2;
				pm.y = -minY - pm.height/2;
				for each(var o:Object in recs){
					if(o.ho > 0){
						changeOringin(NodePM(o.m),-minX+o.ho,-minY+o.ve-(o.ve>0?0:o.h));
					}else{
						changeOringin(NodePM(o.m),-minX+o.ho-o.w,-minY+o.ve-(o.ve>0?0:o.h));
					}
				}
				rec.width = maxX - minX;
				rec.height = maxY - minY;
			}else{
				rec.width = pm.width;
				rec.height = pm.height;
			}
			
			return rec;
		}
		
		private function computerBorder(o:Object,p:Point):void
		{
			if(o is IList){
				var node:NodePM = null;
				for(var i:int = 0; i < list.length; i++){
					computerBorder(list.getItemAt(i),p);
				}
			}
			if(o is NodePM){
				if(NodePM(o).x + NodePM(o).width > p.x){
					p.x = NodePM(o).x + NodePM(o).width + 20;
				}
				if(NodePM(o).y + NodePM(o).height > p.y){
					p.y = NodePM(o).y + NodePM(o).height;
				}
				for(var j:int = 0; j< NodePM(o).children.length; j++){
					computerBorder(NodePM(o).children.getItemAt(j),p);
				}
			}
		}
		
		private function computerMin(o:Object,p:Point):void
		{
			if(o is IList){
				var node:NodePM = null;
				for(var i:int = 0; i < list.length; i++){
					computerMin(list.getItemAt(i),p);
				}
			}
			if(o is NodePM){
				if(NodePM(o).x  < p.x){
					p.x = NodePM(o).x ;
				}
				if(NodePM(o).y < p.y){
					p.y = NodePM(o).y;
				}
				for(var j:int = 0; j< NodePM(o).children.length; j++){
					computerMin(NodePM(o).children.getItemAt(j),p);
				}
			}
		}
		
		private function changeOringin(pm:NodePM,x:int,y:int):void
		{
			pm.changeLocation(pm.x + x,pm.y+y);
			var child:NodePM = null;
			for(var i:int = 0; i < pm.children.length; i++){
				child = pm.children.getItemAt(i) as NodePM;
				changeOringin(child,x,y);
			}
		}
		
		private function setLocation(pm:NodePM,x:int,y:int):void
		{
			pm.x = x;
			pm.y = y;
			var child:NodePM = null;
			for(var i:int = 0; i < pm.children.length; i++){
				child = pm.children.getItemAt(i) as NodePM;
				child.x = x;
				child.y = y;
				setLocation(child,x,y);
			}
		}
	}
}