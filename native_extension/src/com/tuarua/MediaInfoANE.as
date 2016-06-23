package com.tuarua {
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import com.tuarua.mediainfo.events.MediaInfoEvent;

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