package com.tuarua.mediainfo.events {
	import flash.events.Event;
	public class MediaInfoEvent extends Event {
		public static const ON_FILE_INFO:String = "onMediainfoFileInfo";
		public static const ON_FILE_INFO_ITEM:String = "onMediainfoFileInfoItem";
		public var params:Object;
		public function MediaInfoEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.params = _params;
		}
		public override function clone():Event {
			return new MediaInfoEvent(type, this.params, bubbles, cancelable);
		}	
		public override function toString():String {
			return formatToString("MediaInfoEvent", "params", "type", "bubbles", "cancelable");
		}
	}
}