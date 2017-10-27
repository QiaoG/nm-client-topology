/**
 * @author GQ
 * create time:2013-11-6- 11:51:21
 */
package com.megaeyes.netmanagement.topology.infrastructure
{
	import com.megaeyes.netmanagement.topology.domain.vo.PropertiesVO;
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;

	public class TopologyUtil
	{
		public function TopologyUtil()
		{
		}
		
		public static function transferToDeviceVO(object:Object):TopologyDevice
		{
			var device:TopologyDevice = new TopologyDevice();
			var properties:PropertiesVO = new PropertiesVO();
			device.deviceName = object.deviceName;
			properties.key = "名称";
			properties.value = device.deviceName;
			device.properties.addItem(properties);
			
			device.deviceId = object.deviceId;
			properties = new PropertiesVO();
			properties.key = "id";
			properties.value = device.deviceId
			device.properties.addItem(properties);
			
			device.deviceIp = object.deviceIp;
			properties = new PropertiesVO();
			properties.key = "ip";
			properties.value = device.deviceIp;
			device.properties.addItem(properties);
			
			device.deviceNumber = object.deviceNumber;
			properties = new PropertiesVO();
			properties.key = "编号";
			properties.value = device.deviceNumber;
			device.properties.addItem(properties);
			
			device.deviceType = object.deviceType;
			properties = new PropertiesVO();
			properties.key = "类别码";
			properties.value = device.deviceType;
			device.properties.addItem(properties);
			
			device.deviceTypeName = object.deviceTypeName;
			properties = new PropertiesVO();
			properties.key = "类别名";
			properties.value = device.deviceTypeName;
			device.properties.addItem(properties);
			
			device.organId = object.organId;
			device.organName = object.organName;
			properties = new PropertiesVO();
			properties.key = "所属机构";
			properties.value = device.organName;
			device.properties.addItem(properties);
			
			device.platFormId = object.platFormId;
			device.platFormName = object.platFormName;
			properties = new PropertiesVO();
			properties.key = "所属平台";
			properties.value = device.platFormName;
			device.properties.addItem(properties);
			
			device.isVirtual = object.isVirtual;
			properties = new PropertiesVO();
			properties.key = "类型";
			properties.value = device.isVirtual?"虚拟设备":"实际设备";
			device.properties.addItem(properties);
			
			device.currentStatus = object.currentStatus;
			
			device.onLine = object.onLine;
			properties = new PropertiesVO();
			properties.key = "在线状态";
			properties.value = device.onLine?(device.currentStatus == 4 ? "正常":(device.currentStatus==5?'严重告警':(device.currentStatus==6?'主要告警':'警告告警'))):"不在线";
			device.properties.addItem(properties);
			
			device.parentId = object.parentId;
			properties = new PropertiesVO();
			properties.key = "父id";
			properties.value = device.parentId;
			device.properties.addItem(properties);
			
			if(device.deviceType == "05"){//摄像头
				device.hasPtz = object.hasPtz;
				properties = new PropertiesVO();
				properties.key = "云台";
				properties.value = device.hasPtz?"有":"无";
				device.properties.addItem(properties);
			}
			
			device.displayName = device.deviceName;//.>10 ? device.deviceName.substr(0,10)+"." : device.deviceName;
			device.tooltip = device.deviceName;//.length>10?device.deviceName + "/"+device.deviceIp : device.deviceIp;
			
			return device;
		}
	}
}