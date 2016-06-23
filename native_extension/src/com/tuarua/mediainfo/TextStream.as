package com.tuarua.mediainfo {
	[RemoteClass(alias="com.tuarua.mediainfo.TextStream")]
	public class TextStream extends Object {
		public var id:uint;
		public var format:String;
		public var codecId:String;
		public var codecName:String;
		public var isDefault:Boolean;
		public var isForced:Boolean;
		public var language:String;
		public var languageFull:String;
		public function TextStream() {
			super();
		}
	}
}