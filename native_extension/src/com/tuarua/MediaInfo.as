package com.tuarua {
	import com.tuarua.mediainfo.VideoStream;
	import com.tuarua.mediainfo.AudioStream;
	import com.tuarua.mediainfo.TextStream;
	[RemoteClass(alias="com.tuarua.MediaInfo")]
	public class MediaInfo extends Object {
		public var name:String;
		public var format:String;
		public var profile:String;
		public var codecId:String;
		public var fileSize:Number = -1.0;
		public var duration:uint;
		public var bitrate:uint;
		public var encoder:String;
		public var videoStreams:Vector.<VideoStream>;
		public var audioStreams:Vector.<AudioStream>;
		public var textStreams:Vector.<TextStream>;
	}
}