package {
	import com.tuarua.MediaInfo;
	import com.tuarua.MediaInfoANE;
	import com.tuarua.mediainfo.events.MediaInfoEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import utils.TextUtils;
	
	public class MediaInfoANESample extends Sprite {
		private var mediaInfoANE:MediaInfoANE;
		private var btn:Sprite = new Sprite();
		public function MediaInfoANESample() {
			btn.graphics.beginFill(0x333FF0);
			btn.graphics.drawRect(20,20,100,50);
			btn.graphics.endFill();
			btn.addEventListener(MouseEvent.CLICK,onClick);
			mediaInfoANE = new MediaInfoANE();
			mediaInfoANE.addEventListener(MediaInfoEvent.ON_FILE_INFO,onFileInfo);
			
			trace("is media info supported",mediaInfoANE.isSupported());
			trace("GetVersion",mediaInfoANE.getVersion());
			trace();
			
			addChild(btn);
		
		}
		protected function onFileInfo(event:MediaInfoEvent):void {
			var mediaInfo:MediaInfo = event.params.data as MediaInfo;
			
			trace(TextUtils.bytesToString(mediaInfo.fileSize));
			
			trace();
		}
		protected function onClick(event:MouseEvent):void {
			mediaInfoANE.getInfo("D:\\dvds\\JurassicWorld\\FullAllStreams_t01.mkv");
		}
	}
}