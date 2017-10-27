/**
 * @author GQ
 * create time:2013-7-18- 16:28:40
 */
package com.megaeyes.netmanagement.topology.infrastructure
{
	import com.megaeyes.netmanagement.topology.domain.vo.TopologyDevice;

	public class ImageUtil
	{
		[Embed(source='/images/a_1.png')]
		public const ONLINE:Class;
		
		[Embed(source='/images/a_2.png')]
		public const OUTLINE:Class;
		
		[Embed(source='/images/a_4.png')]
		public const OK:Class;
		
		[Embed(source='/images/a_5.png')]
		public const PRIMARY:Class;
		
		[Embed(source='/images/a_6.png')]
		public const MAIN:Class;
		
		[Embed(source='/images/a_7.png')]
		public const WARNING:Class;
		
		[Embed(source='/images/device/中心管理服务器.png')]
		public const CMS:Class;
		
		[Embed(source='/images/device/中心管理服务器灰.png')]
		public const CMS_GRAY:Class;
		
		[Embed(source='/images/device/视频服务器.png')]
		public const PU:Class;
		
		[Embed(source='/images/device/视频服务器灰.png')]
		public const PU_GRAY:Class;
		
		[Embed(source='/images/device/分发服务器.png')]
		public const VTDU:Class;
		
		[Embed(source='/images/device/分发服务器灰.png')]
		public const VTDU_GRAY:Class;
		
		[Embed(source='/images/device/储存服务器.png')]
		public const NRU:Class;
		
		[Embed(source='/images/device/储存服务器灰.png')]
		public const NRU_GRAY:Class;
		
		[Embed(source='/images/device/视频分析设备.png')]
		public const VA_SERVER:Class;
		
		[Embed(source='/images/device/视频分析设备灰.png')]
		public const VA_SERVER_GRAY:Class;
		
		[Embed(source='/images/device/数据服务器.png')]
		public const DB:Class;
		
		[Embed(source='/images/device/数据服务器灰.png')]
		public const DB_GRAY:Class;
		
		[Embed(source='/images/device/摄像头.png')]
		public const CAMERA:Class;
		
		[Embed(source='/images/device/摄像头灰.png')]
		public const CAMERA_GRAY:Class;
		
		[Embed(source='/images/device/云台摄像头.png')]
		public const CAMERA_PAN:Class;
		
		[Embed(source='/images/device/云台摄像头灰.png')]
		public const CAMERA_PAN_GRAY:Class;
		
		[Embed(source='/images/device/预设-摄像头.png')]
		public const CAMERA_SCHEME:Class;
		
		[Embed(source='/images/device/预设-云台摄像机.png')]
		public const CAMERA_PAN_SCHEME:Class;
		
		[Embed(source='/images/device/服务器.png')]
		public const SERVICE:Class;
		
		[Embed(source='/images/device/服务器灰.png')]
		public const SERVICE_GRAY:Class;
		
		[Embed(source='/images/device/接入服务器.png')]
		public const CSS:Class;
		
		[Embed(source='/images/device/接入服务器灰.png')]
		public const CSS_GRAY:Class;
		
		[Embed(source='/images/device/显示服务器.png')]
		public const DISPLAY:Class;
		
		[Embed(source='/images/device/显示服务器灰.png')]
		public const DISPLAY_GRAY:Class;
		
		[Embed(source='/images/device/增值模块.png')]
		public const APPRECIATION:Class;
		
		[Embed(source='/images/device/增值模块灰.png')]
		public const APPRECIATION_GRAY:Class;
		
		[Embed(source='/images/noclose.png')]
		public const cursorPreConnection:Class;
		
		[Embed(source='/images/bothnoclose.png')]
		public const cursorConnection:Class;
		
		[Embed(source='/images/close.png')]
		public const CLOSE:Class;
		
		[Embed(source='/images/close2.png')]
		public const CLOSE2:Class;
		
		[Embed(source='/images/close3.png')]
		public const CLOSE3:Class;
		
		[Embed(source='/images/connection.png')]
		public const CONNECTION:Class;
		
		[Embed(source='/images/connection2.png')]
		public const CONNECTION2:Class;
		
		[Embed(source='/images/connection3.png')]
		public const CONNECTION3:Class;
		
		[Embed(source='/images/SizeHorz.png')]
		public const RESIZE_HORZ:Class;
		
		[Embed(source='/images/SizeVert.png')]
		public const RESIZE_VERT:Class;
		
		[Embed(source='/images/ResizeLeft.png')]
		public const RESIZE_LEFT:Class;
		
		[Embed(source='/images/ResizeRight.png')]
		public const RESIZE_RIGHT:Class;
		
		public const LAYOUTING_COLOR:uint = 0x00ff00;
		
		public const DEFAULT_COLOR:uint = 0x000000;
		
		public function ImageUtil()
		{
		}
		
		public function getImage(device:TopologyDevice):Class
		{
			var deviceType:String = device.deviceType;
			var img:Class = SERVICE;
			if(deviceType == "43"){
				img = device.onLine?CMS:CMS_GRAY;
			}else if(deviceType == "40" || deviceType == "62" || deviceType == "70" || deviceType == "60"){
				//接入，上级信令网关，下级信令网关、国标接入
				img = device.onLine?CSS:CSS_GRAY;
			}else if(deviceType == "41"){
				img = device.onLine?NRU:NRU_GRAY;
			}else if(deviceType == "42" || deviceType == "45" || deviceType == "47" ||deviceType == "48" || deviceType == "69" ||deviceType == "61"){
				//分发，VAU、上级媒体网关、RSS、下级媒体网关，国标分发
				img = device.onLine?VTDU:VTDU_GRAY;
			}else if(deviceType == "44"){
				img = device.onLine?DB:DB_GRAY;
			}else if(deviceType == "46"){
				img = device.onLine?VA_SERVER:VA_SERVER_GRAY;
			}else if(deviceType == "05"){//
				if(device.hasPtz){
					img = device.onLine?CAMERA_PAN:CAMERA_PAN_GRAY;
				}else{
					img = device.onLine?CAMERA:CAMERA_GRAY;
				}
			}else if(deviceType == "20"){
				img = device.onLine?DISPLAY:DISPLAY_GRAY;
			}else if(deviceType == "02"){
				img = device.onLine?PU:PU_GRAY;
			}else if(int(deviceType) > 40){
				img = device.onLine?APPRECIATION:APPRECIATION_GRAY;
			}
			
			return img;
		}
		
		public function getStateImage(device:TopologyDevice):Class
		{
			if(device.onLine){
				if(device.currentStatus == 4){
					return OK;
				}else if(device.currentStatus == 5){
					return PRIMARY;
				}else if(device.currentStatus == 6){
					return MAIN;
				}else{
					return WARNING;
				}
			}else{
				return OUTLINE;
			}
		}
	}
}