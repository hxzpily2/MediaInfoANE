package com.tuarua.mediainfo {
	[RemoteClass(alias="com.tuarua.mediainfo.AudioStream")]
	public class AudioStream extends Object {
		public var id:uint;
		public var format:String;
		public var formatName:String;
		public var profile:String;
		public var codecId:String;
		public var codecName:String;
		public var duration:uint;
		public var bitrate:uint;
		public var bitrateMode:String;
		public var size:Number;
		public var channels:uint;
		public var channelLayout:String;
		public var sampleRate:uint;
		public var compressionMode:String;
		public var isDefault:Boolean;
		public var isForced:Boolean;
		public var alternateGroup:uint;
		public var language:String;
		public var languageFull:String;
		
		public function AudioStream() {
			super();
		}
	}
}