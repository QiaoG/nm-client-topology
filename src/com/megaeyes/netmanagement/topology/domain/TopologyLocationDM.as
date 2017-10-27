/**
 * 获取/保存各拓扑图的大小及其中设备的位置
 * @author GQ
 * create time:2013-9-25- 15:45:08
 */
package com.megaeyes.netmanagement.topology.domain
{
	import com.megaeyes.networkmanagement.api.application.events.HttpRequestEvent;
	import com.megaeyes.netmanagement.topology.domain.vo.Connection;
	import com.megaeyes.netmanagement.topology.domain.vo.Device;
	import com.megaeyes.netmanagement.topology.domain.vo.Topology;
	import com.megaeyes.netmanagement.topology.domain.vo.Topologys;
	import com.megaeyes.networkmanagement.api.domain.vo.AlarmListenerVO;
	import com.megaeyes.networkmanagement.api.model.ModelLocator;
	import com.megaeyes.networkmanagement.api.utils.AlertUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.System;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	import org.spicefactory.lib.xml.XmlObjectMapper;
	import org.spicefactory.lib.xml.mapper.XmlObjectMappings;

	[Event(name="gain_xml_complement", type="flash.events.Event")]
	[Event(name="save_xml_complement", type="flash.events.Event")]
	public class TopologyLocationDM extends EventDispatcher
	{
		
		private var _mapper:XmlObjectMapper;
		
		[MessageDispatcher]
		public var dispatcher:Function;
		
		[Bindable]
		/**
		 *保存的拓扑图信息 
		 */
		public var data:Topologys;
		
		[Bindable]
		public var dataXML:XML;
		
		[Bindable]
		public var lock:Boolean;
		
		public var updateSuccess:Boolean;
		
		public function TopologyLocationDM()
		{
			_mapper = XmlObjectMappings.forUnqualifiedElements()
				.withRootElement(Topologys)
				.mappedClasses(Topology)
				.mappedClasses(Device)
				.mappedClasses(Connection)
				.build();
		}
		
		public function newData():void
		{
			data = new Topologys();
			data.topologys = new Array();
		}
		
		public function getMapXML():String
		{
			if(data){
				return XML(_mapper.mapToXml(data)).toXMLString();
			}else{
				return "null";
			}
		}
		
		private function getRequestPara(save:Boolean):Object
		{
			var para:Object = new Object();
			para.fileName=ModelLocator.getInstance().currentUser.logonName+"-topology";
			if(save){
				para.content=XML(_mapper.mapToXml(data)).toXMLString();
			}else{
				para.content = "get";
			}
			return para;
		}
		
		/**
		 * 从服务端获取/保存 拓扑图信息 
		 * 
		 */
		public function updateInfo(save:Boolean):void
		{
			flash.system.System.useCodePage=true;
			lock = true;
			var event:HttpRequestEvent = new HttpRequestEvent();
			var url:String = ModelLocator.getInstance().rootUrl;
			var url2:String = url.substr(url.indexOf("//")+2);
			var url3:String = url2.substr(0,url2.indexOf("/"));
			event.ip = url3.split(":")[0];
			event.port = int(url3.split(":")[1]);
			event.interfaceName="/client/uploadConf";
			event.request = getRequestPara(save);
//			if(event.request.content != "get")
//				AlertUtil.show("save xml="+event.request.content);
			event.selector = "topology_location_info_xml";
			this.dispatcher(event);
		}
		
		[CommandResult(selector="topology_location_info_xml")]
		public function updateComplementHandle(result:String,event:HttpRequestEvent):void
		{
			flash.system.System.useCodePage=false;
			lock = false;
			var save:Boolean = event.request.content != "get";
			if(save){
				updateSuccess = "success" == result;
				dispatchEvent(new Event("save_xml_complement"));
			}else{
				if("failure" == result){
					updateSuccess = false;
				}else{
					try{
						var xml:XML = new XML(result);
						data = _mapper.mapToObject(xml) as Topologys;
						dataXML = (data.topologys==null || data.topologys.length==0)?null:xml;
						filterXML();
						updateSuccess = true;
					}catch(e:Error){
						updateSuccess = false;
					}
//					Alert.show("id="+data.topologys[0].name+" "+data.topologys[0].devices[0].typeName);
				}
				dispatchEvent(new Event("gain_xml_complement"));
			}
		}
		
		private function filterXML():void
		{
			if(dataXML){
				for each(var child:XML in dataXML.topology){
					for each(var dev:XML in child.device){
						delete dev.connection;
					}
				}
			}
		}
		
		[CommandError(selector="topology_location_info_xml")]
		public function updateErrorHandle(fault:FaultEvent,event:HttpRequestEvent) : void {
			lock = false
			var save:Boolean = event.request.content != "get";
			if(!save){
				data = null;
			}
			updateSuccess = false;
			flash.system.System.useCodePage=false;
			this.dispatchEvent(save?new Event("save_xml_complement"):new Event("gain_xml_complement"));
			
		}
		
		
		public function getTopologyById(id:String):Topology
		{
			var t:Topology = null;
			if(data && data.topologys){
				for each(var to:Topology in data.topologys){
					if(to.id == id){
						t = to;
						break;
					}
				}
			}
			return t;
		}
		
		public function delTopology(id:String):void
		{
			var d:Topology = null;
			for (var i:int = 0; i <data.topologys.length; i++){
				d = data.topologys[i] as Topology;
				if(d.id == id){
					data.topologys.splice(i,1);
					break;
				}
			}
//			dataXML = _mapper.mapToXml(data);
		}
		
		public function checkName(name:String):Boolean
		{
			var exist:Boolean = false;
			if(data && data.topologys){
				for each(var n:Topology in data.topologys){
					if(n.name == name){
						exist = true;
						break;
					}
				}
			}
			return exist;
		}
		
	}
}