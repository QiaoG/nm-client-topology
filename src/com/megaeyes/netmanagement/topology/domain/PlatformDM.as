/**
 * @author GQ
 * create time:2013-8-9- 14:41:28
 */
package com.megaeyes.netmanagement.topology.domain
{
	import com.megaeyes.networkmanagement.api.application.events.WebServiceEvent;
	import com.megaeyes.networkmanagement.api.domain.vo.PlatformVO;
	import com.megaeyes.networkmanagement.api.model.ModelLocator;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.rpc.events.FaultEvent;

	[Event(name="find_platforms_complement", type="flash.events.Event")]
	public class PlatformDM extends EventDispatcher
	{
		[MessageDispatcher]
		public var dispatcher:Function;
		
		public var platforms:IList = new ArrayList();
		
		public function PlatformDM()
		{
		}
		
		public function findAllPlatforms():void
		{
			var query:Object = new Object();
			query.sessionId=ModelLocator.getInstance().currentUser.sessionId;
			var event:WebServiceEvent = new WebServiceEvent("find_platforms", query);
			dispatcher(event);
		}
		
		[CommandResult(selector="find_platforms")]
		public function queryResultHandler(result:Object,e:WebServiceEvent):void
		{
			var list:IList = result.data as IList;
			if(list){
				var d:PlatformVO = null;
				for(var i:int = 0; i < list.length; i++){
					d = transferToPlatformVO(list.getItemAt(i));
					platforms.addItem(d);
				}
			}
			dispatchEvent(new Event("find_platforms_complement"));
		}
		
		[CommandError(selector="find_platforms")]
		public function queryErrorHandler(fault:FaultEvent,e:WebServiceEvent):void
		{
			dispatchEvent(new Event("find_platforms_complement"));
		}
		
		protected function transferToPlatformVO(object:Object):PlatformVO
		{
			var d:PlatformVO = new PlatformVO();
			d.id = object.id;
			d.name = object.name;
			return d;
		}
	}
}