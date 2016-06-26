package {

	import com.tuarua.MediaInfo;
	import com.tuarua.MediaInfoANE;
	import com.tuarua.mediainfo.AudioStream;
	import com.tuarua.mediainfo.TextStream;
	import com.tuarua.mediainfo.VideoStream;
	import com.tuarua.mediainfo.events.MediaInfoEvent;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.text.TextFieldType;
	
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import utils.TextUtils;
	import utils.TimeUtils;
	
	import views.SrollableContent;
	import views.forms.Input;

	public class StarlingRoot extends Sprite {
		private var filePathInput:Input;
		private var chooseFileIn:Image = new Image(Assets.getAtlas().getTexture("choose-bg"));
		private var holder:Sprite = new Sprite();
		private var selectedFile:File = new File();
		private var mediaInfoANE:MediaInfoANE;
		private var bg:Quad = new Quad(800,720,0x121314);
		private var txtHolder:Sprite = new Sprite();
		
		private var infoList:SrollableContent;
		
		public function StarlingRoot() {
			super();
			TextField.registerBitmapFont(Fonts.getFont("fira-sans-semi-bold-13"));
		}
		
		public function start():void {
			
			selectedFile.addEventListener(Event.SELECT, selectFile);
			mediaInfoANE = new MediaInfoANE();
			mediaInfoANE.addEventListener(MediaInfoEvent.ON_FILE_INFO,onFileInfo);
			mediaInfoANE.addEventListener(MediaInfoEvent.ON_FILE_INFO_ITEM,onFileInfoItem);
			trace("is media info supported",mediaInfoANE.isSupported());
			trace("GetVersion",mediaInfoANE.getVersion());
			
			
			filePathInput = new Input(350,"");
			filePathInput.type = TextFieldType.DYNAMIC;
			filePathInput.x = 70;
			filePathInput.y = 20;
			
			
			chooseFileIn.x = filePathInput.x + filePathInput.width + 8;
			chooseFileIn.y = filePathInput.y;
			chooseFileIn.useHandCursor = false;
			chooseFileIn.blendMode = BlendMode.NONE;
			chooseFileIn.addEventListener(TouchEvent.TOUCH,onInputTouch);
			
			holder.addChild(filePathInput);
			holder.addChild(chooseFileIn);
			

			addChild(bg);
			addChild(holder);
			
			infoList = new SrollableContent(540,610,txtHolder);
			infoList.x = 50;
			infoList.y = 80;
			addChild(infoList);
		}
		
		private function createTextField(text:String,indent:int = 0,y:int=0):TextField{
			var txt:TextField;
			txt = new TextField(600,32,text, "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			txt.hAlign = HAlign.LEFT;
			txt.vAlign = VAlign.TOP;
			txt.batchable = true;
			txt.touchable = false;
			txt.x = (indent * 40)+20;
			txt.y = y;
			return txt;
		}
		
		protected function selectFile(event:Event):void {
			filePathInput.text = selectedFile.nativePath;
			filePathInput.unfreeze();
			filePathInput.visible = true;
			//get single item
			mediaInfoANE.getInfoItem(selectedFile.nativePath,"General","Format");
			//get pre-defined list
			mediaInfoANE.getInfo(selectedFile.nativePath);
		}
		private function onInputTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(chooseFileIn, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)
				selectedFile.browseForOpen("Select video file...");
		}
		protected function onFileInfoItem(event:MediaInfoEvent):void {
			trace("result has come back of single item",event.params.data)
		}
		protected function onFileInfo(event:MediaInfoEvent):void {
			var mediaInfo:MediaInfo = event.params.data as MediaInfo;
			
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			
			var cnt:int = -1;
			if(mediaInfo.name){
				cnt++;
				txtHolder.addChild(createTextField(mediaInfo.name));
			}
			cnt++;
			txtHolder.addChild(createTextField("General",1,cnt*20));
			if(mediaInfo.format){
				cnt++;
				txtHolder.addChild(createTextField("Format : "+mediaInfo.format,2,cnt*20));
			}
			if(mediaInfo.profile){
				cnt++;
				txtHolder.addChild(createTextField("Profile : "+mediaInfo.profile,2,cnt*20));
			}
			if(mediaInfo.codecId){
				cnt++;
				txtHolder.addChild(createTextField("Codec ID : "+mediaInfo.codecId,2,cnt*20));
			}
			if(mediaInfo.fileSize > 0){
				cnt++;
				txtHolder.addChild(createTextField("File size : "+TextUtils.bytesToString(mediaInfo.fileSize),2,cnt*20));
			}
			if(mediaInfo.duration){
				cnt++;
				txtHolder.addChild(createTextField("Duration : "+TimeUtils.secsToFriendly(mediaInfo.duration),2,cnt*20));
			}
			if(mediaInfo.bitrateMode){
				cnt++;
				txtHolder.addChild(createTextField("Bit rate mode : "+mediaInfo.bitrateMode,2,cnt*20));
			}
			if(mediaInfo.bitrate > 0){
				cnt++;
				txtHolder.addChild(createTextField("Bit rate : "+TextUtils.bitsPerSecToString(mediaInfo.bitrate),2,cnt*20));
			}
			if(mediaInfo.encoder){
				cnt++;
				txtHolder.addChild(createTextField("Writing Application : "+mediaInfo.encoder,2,cnt*20));
			}
			
			for each(var v:VideoStream in mediaInfo.videoStreams){
				cnt++;
				txtHolder.addChild(createTextField("Video",1,cnt*20));
				cnt++;
				txtHolder.addChild(createTextField("ID : "+v.id,2,cnt*20));
				if(v.format){
					cnt++;
					txtHolder.addChild(createTextField("Format : "+v.format,2,cnt*20));
				}
				if(v.formatName){
					cnt++;
					txtHolder.addChild(createTextField("Format name: "+v.formatName,2,cnt*20));
				}
				if(v.profile){
					cnt++;
					txtHolder.addChild(createTextField("Profile : "+v.profile,2,cnt*20));
				}
				if(v.cabac){
					cnt++;
					txtHolder.addChild(createTextField("Cabac : "+v.cabac,2,cnt*20));
				}
				if(v.refFrames){
					cnt++;
					txtHolder.addChild(createTextField("ReFrames : "+v.refFrames+" frames",2,cnt*20));
				}
				if(v.codecId){
					cnt++;
					txtHolder.addChild(createTextField("Codec ID : "+v.codecId,2,cnt*20));
				}
				if(v.codecName){
					cnt++;
					txtHolder.addChild(createTextField("Codec Name : "+v.codecName,2,cnt*20));
				}
				if(v.duration){
					cnt++;
					txtHolder.addChild(createTextField("Duration : "+TimeUtils.secsToFriendly(v.duration),2,cnt*20));
				}
				if(v.bitrateMode){
					cnt++;
					txtHolder.addChild(createTextField("Bit rate mode : "+v.bitrateMode,2,cnt*20));
				}
				if(v.bitrate > 0){
					cnt++;
					txtHolder.addChild(createTextField("Bit rate : "+TextUtils.bitsPerSecToString(v.bitrate),2,cnt*20));
				}
				if(v.maxBitrate > 0){
					cnt++;
					txtHolder.addChild(createTextField("Max bit rate : "+TextUtils.bitsPerSecToString(v.maxBitrate),2,cnt*20));
				}
				if(v.width > 0){
					cnt++;
					txtHolder.addChild(createTextField("Width : "+v.width+"px",2,cnt*20));
				}
				if(v.height){
					cnt++;
					txtHolder.addChild(createTextField("Height : "+v.height+"px",2,cnt*20));
				}
				if(v.aspectRatio > 0){
					cnt++;
					txtHolder.addChild(createTextField("Aspect ratio : "+v.aspectRatioAsString,2,cnt*20));
				}
				if(v.framerateMode){
					cnt++;
					txtHolder.addChild(createTextField("Frame rate mode : "+v.framerateMode,2,cnt*20));
				}
				
				if(v.framerate > 0){
					cnt++;
					txtHolder.addChild(createTextField("Frame rate : "+v.framerate,2,cnt*20));
				}
				if(v.colorSpace){
					cnt++;
					txtHolder.addChild(createTextField("Color space : "+v.colorSpace,2,cnt*20));
				}
				if(v.chroma){
					cnt++;
					txtHolder.addChild(createTextField("Chroma subsampling : "+v.chroma,2,cnt*20));
				}
				if(v.bitDepth > 0){
					cnt++;
					txtHolder.addChild(createTextField("Bit depth : "+v.bitDepth+" bits",2,cnt*20));	
				}
				if(v.scanType){
					cnt++;
					txtHolder.addChild(createTextField("Scan type : "+v.scanType,2,cnt*20));
				}
				if(v.bits){
					cnt++;
					txtHolder.addChild(createTextField("Bits : "+v.bits,2,cnt*20));
				}
				if(v.size > 0){
					cnt++;
					txtHolder.addChild(createTextField("Stream size : "+TextUtils.bytesToString(v.size),2,cnt*20));
				}
				if(v.languageFull){
					cnt++;
					txtHolder.addChild(createTextField((v.languageFull) ? "Language : "+v.languageFull : "Language : ",2,cnt*20));
				}
				
				
			}
			
			for each(var a:AudioStream in mediaInfo.audioStreams){
				cnt++;
				txtHolder.addChild(createTextField("Audio",1,cnt*20));
				if(a.id){
					cnt++;
					txtHolder.addChild(createTextField("ID : "+a.id,2,cnt*20));
				}
				if(a.format){
					cnt++;
					txtHolder.addChild(createTextField("Format : "+a.format,2,cnt*20));
				}
				if(a.formatName){
					cnt++;
					txtHolder.addChild(createTextField("Format name: "+a.formatName,2,cnt*20));
				}
				if(a.profile){
					cnt++;
					txtHolder.addChild(createTextField("Profile : "+a.profile,2,cnt*20));
				}
				if(a.codecId){
					cnt++;
					txtHolder.addChild(createTextField("Codec ID : "+a.codecId,2,cnt*20));
				}
				if(a.codecName){
					cnt++;
					txtHolder.addChild(createTextField("Codec Name : "+a.codecName,2,cnt*20));
				}
				if(a.duration > 0){
					cnt++;
					txtHolder.addChild(createTextField("Duration : "+TimeUtils.secsToFriendly(a.duration),2,cnt*20));
				}
				if(a.bitrateMode){
					cnt++;
					txtHolder.addChild(createTextField("Bit rate mode : "+a.bitrateMode,2,cnt*20));
				}
				if(a.bitrate > 0){
					cnt++;
					txtHolder.addChild(createTextField("Bit rate : "+TextUtils.bitsPerSecToString(a.bitrate),2,cnt*20));
				}
				if(a.maxBitrate > 0){
					cnt++;
					txtHolder.addChild(createTextField("Max bit rate : "+TextUtils.bitsPerSecToString(a.maxBitrate),2,cnt*20));
				}
				if(a.channels > 0){
					cnt++;
					txtHolder.addChild(createTextField("Channels : "+a.channels,2,cnt*20));
				}
				if(a.channelLayout){
					cnt++;
					txtHolder.addChild(createTextField("Channel positions : "+a.channelLayout,2,cnt*20));
				}
				if(a.sampleRate){
					cnt++;
					txtHolder.addChild(createTextField("Sampling rate : "+(a.sampleRate/1000).toFixed(1)+" KHz",2,cnt*20));
				}
				if(1==0){
					cnt++;
					txtHolder.addChild(createTextField("Frame rate : ",2,cnt*20));
				}
				if(a.compressionMode){
					cnt++;
					txtHolder.addChild(createTextField("Compression mode : "+a.compressionMode,2,cnt*20));
				}
				if(a.size > 0){
					cnt++;
					txtHolder.addChild(createTextField("Stream size : "+TextUtils.bytesToString(a.size),2,cnt*20));
				}
				if(a.isDefault){
					cnt++;
					txtHolder.addChild(createTextField("Default : "+a.isDefault,2,cnt*20));
				}
				if(a.isForced){
					cnt++;
					txtHolder.addChild(createTextField("Forced : "+a.isForced,2,cnt*20));
				}
				if(a.alternateGroup){
					cnt++;
					txtHolder.addChild(createTextField("Alternate group : "+a.alternateGroup,2,cnt*20));
				}
				if(a.languageFull){
					cnt++;
					txtHolder.addChild(createTextField("Language : "+a.languageFull,2,cnt*20));
				}
			}
			
			for each(var t:TextStream in mediaInfo.textStreams){
				cnt++;
				txtHolder.addChild(createTextField("Text",1,cnt*20));
				if(t.id){
					cnt++;
					txtHolder.addChild(createTextField("ID : "+t.id,2,cnt*20));
				}
				if(t.format){
					cnt++;
					txtHolder.addChild(createTextField("Format : "+t.format,2,cnt*20));
				}
				if(t.codecId){
					cnt++;
					txtHolder.addChild(createTextField("Codec ID : "+t.codecId,2,cnt*20));
				}
				if(t.codecName){
					cnt++;
					txtHolder.addChild(createTextField("Codec Name : "+t.codecName,2,cnt*20));
				}
				if(t.languageFull){
					cnt++;
					txtHolder.addChild(createTextField("Language : "+t.languageFull,2,cnt*20));
				}
				if(t.isDefault){
					cnt++;
					txtHolder.addChild(createTextField("Default : "+t.isDefault,2,cnt*20));
				}
				if(t.isForced){
					cnt++;
					txtHolder.addChild(createTextField("Forced : "+t.isForced,2,cnt*20));
				}
			}
			
			infoList.fullHeight = txtHolder.height;
			infoList.init();

			
		}
		public function acceptFilePath(filePath:String):void {
			filePathInput.text = filePath;
			filePathInput.unfreeze();
			filePathInput.visible = true;
			mediaInfoANE.getInfo(filePath);
		}
	}
}