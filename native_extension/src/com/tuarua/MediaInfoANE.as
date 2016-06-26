package com.tuarua {
	import com.tuarua.mediainfo.events.MediaInfoEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;

	public class MediaInfoANE extends EventDispatcher {
		private var extensionContext:ExtensionContext;
		private var _inited:Boolean = false;
		private static const projectName:String = "MediaInfoANE";
		/**
		 * 
		 * 
		 */		
		public function MediaInfoANE() {
			initiate();
		}
		/**
		 *@private 
		 * 
		 */		
		protected function initiate():void {
			trace("["+projectName+"] Initalizing ANE...");
			try {
				extensionContext = ExtensionContext.createExtensionContext("com.tuarua."+projectName, null);
				extensionContext.addEventListener(StatusEvent.STATUS, gotEvent);
				_inited = true;
			} catch (e:Error) {
				trace("["+projectName+"] ANE Not loaded properly.  Future calls will fail.");
			}
		}
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function isSupported():Boolean {
			if(!extensionContext)
				return false;
			return extensionContext.call("isSupported"); 
		}
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function getInfo(fileName:String):void {
			extensionContext.call("triggerGetInfo",fileName);
			
		}
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function getInfoItem(fileName:String,type:String,item:String):void {
			extensionContext.call("triggerGetInfoItem",fileName,type,item);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */	
		public function getVersion():String {
			return extensionContext.call("getVersion") as String; 
		}
		
		/**
		 *@private 
		 * 
		 */	
		protected function gotEvent(event:StatusEvent):void {
			switch (event.level) {
				case "TRACE":
					trace(event.code);
					break;
				case "INFO":
					trace("INFO:",event.code);
					break;
				case "ON_FILE_INFO":
					this.dispatchEvent(new MediaInfoEvent(MediaInfoEvent.ON_FILE_INFO,{data:extensionContext.call("getInfo") as MediaInfo}));
					break;
				case "ON_FILE_INFO_ITEM":
					this.dispatchEvent(new MediaInfoEvent(MediaInfoEvent.ON_FILE_INFO_ITEM,{data:event.code}));
					break;
			}
		}
		/**
		 * 
		 * 
		 */		
		public function dispose():void {
			if (!extensionContext) {
				trace("["+projectName+"] Error. ANE Already in a disposed or failed state...");
				return;
			}
			trace("["+projectName+"] Unloading ANE...");
			extensionContext.removeEventListener(StatusEvent.STATUS, gotEvent);
			extensionContext.dispose();
			extensionContext = null;
		}
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get inited():Boolean {
			return _inited;
		}		
	}
}