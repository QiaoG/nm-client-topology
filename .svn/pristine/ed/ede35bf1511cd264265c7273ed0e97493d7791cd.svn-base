/**
 * @author GQ
 * create time:2013-10-22- 13:29:49
 */
package com.megaeyes.netmanagement.topology.domain
{
	import com.megaeyes.networkmanagement.api.application.events.WebServiceEvent;
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;
	import com.megaeyes.networkmanagement.api.domain.query.GroupQuery;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;

	public class DivisionDevicesDM extends DevicesDM
	{
		public var divisionId:String;
		
		public var divisionName:String;
		
		public function DivisionDevicesDM()
		{
		}
		
		public function gainDevicesByDivision(divId:String="-1",divName:String=""):void
		{
			if(lock){
				return;
			}
			devices.removeAll();
			relationgDevices.removeAll();
			var query:GroupQuery = new GroupQuery();
			divisionId = divId;
			divisionName = divName;
			query.divisionId = Number(divisionId);
			query.assignd = 1;
			query.assigned = 1;
			query.start = 0;
			query.size = 0;
			var event:WebServiceEvent = new WebServiceEvent("find_devices_by_division", query);
			lock = true;
			dispatcher(event);
		}
		
		[CommandResult(selector="find_devices_by_division")]
		public function queryResultHandler(result:Object,e:WebServiceEvent):void
		{
			
			var list:IList = result.data as IList;
			if(list){
				var d:TopologyDevice = null;
				for(var i:int = 0; i < list.length; i++){
					d = transferToDeviceVO(list.getItemAt(i));
					devices.addItem(d);
					relationgDevices.addItem(d);
				}
			}
			addRelations(relationgDevices);
			gainDeviceComplement(e);
		}
		
		[CommandError(selector="find_devices_by_division")]
		public function queryErrorHandler(fault:FaultEvent,e:WebServiceEvent):void
		{
			gainDeviceComplement(e);
		}
	}
}