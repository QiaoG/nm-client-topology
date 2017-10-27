/**
 * @author GQ
 * create time:2013-10-30- 10:27:47
 */
package com.megaeyes.netmanagement.topology.presentation.layout
{
	import com.megaeyes.netmanagement.topology.presentation.node.NodePM;
	
	import flash.geom.Rectangle;
	
	import mx.collections.IList;
	
	/**
	 * 离散布局
	 * @author gq
	 * 
	 */
	public class DiscreteLayout extends DefaultLayout
	{
		public function DiscreteLayout()
		{
		}
		
		override public function layout(n:Object, startX:int, startY:int):Rectangle
		{
			var rec:Rectangle = new Rectangle(startX,startY);
			var list:IList = n as IList;
			var total:int = list.length;
			var columns:int = total<5?total:(total<26?5:Math.sqrt(total));
			var rows:int = total / columns +(total % columns == 0 ? 0 : 1);
			var node:NodePM = null;
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
					tr = (node.children.length>5?verticalLayoutChildren(node,startXX,startYY):horizontalLayoutChildren(node,startXX,startYY));
					startXX += tr.width+20;
					if(startXX > maxW){
						maxW = startXX;
					}
					if(tr.height > rowH){
						rowH = tr.height;
					}
				}
				startYY += (rowH+30);
			}
			rec.width = maxW;
			rec.height = startYY;
			return rec;
		}
	}
}