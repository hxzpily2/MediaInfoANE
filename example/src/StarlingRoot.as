package {

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.ClipboardTransferMode;
	import flash.desktop.NativeDragActions;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeDragOptions;
	import flash.events.NativeDragEvent;
	import com.tuarua.MediaInfo;
	import com.tuarua.MediaInfoANE;
	import com.tuarua.mediainfo.events.MediaInfoEvent;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.text.TextFieldType;
	
	import events.InteractionEvent;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	import utils.TextUtils;
	
	import views.forms.Input;

	public class StarlingRoot extends Sprite {
		private var filePathInput:Input;
		private var chooseFileIn:Image = new Image(Assets.getAtlas().getTexture("choose-bg"));
		private var holder:Sprite = new Sprite();
		private var selectedFile:File = new File();
		private var mediaInfoANE:MediaInfoANE;
		private var bg:Quad = new Quad(1280,720,0x121314);
		public function StarlingRoot() {
			super();
			TextField.registerBitmapFont(Fonts.getFont("fira-sans-semi-bold-13"));
		}
		
		public function start():void {
			
			selectedFile.addEventListener(Event.SELECT, selectFile);
			mediaInfoANE = new MediaInfoANE();
			mediaInfoANE.addEventListener(MediaInfoEvent.ON_FILE_INFO,onFileInfo);
			
			trace("is media info supported",mediaInfoANE.isSupported());
			trace("GetVersion",mediaInfoANE.getVersion());
			
			filePathInput = new Input(350,"");
			filePathInput.type = TextFieldType.DYNAMIC;
			filePathInput.x = 100;
			filePathInput.y = 20;
			
			
			chooseFileIn.x = filePathInput.x + filePathInput.width + 8;
			chooseFileIn.y = filePathInput.y;
			chooseFileIn.useHandCursor = false;
			chooseFileIn.blendMode = BlendMode.NONE;
			chooseFileIn.addEventListener(TouchEvent.TOUCH,onInputTouch);
			
			holder.addChild(filePathInput);
			holder.addChild(chooseFileIn);
			
			holder.x = 40;
			holder.y = 20;
			addChild(bg);
			addChild(holder);
			
		}
		
		protected function onDragIn(event:NativeDragEvent):void {
			trace(event);
		}
		protected function onDrop(event:NativeDragEvent):void {
			trace(event);
		}
		protected function onDragExit(event:NativeDragEvent):void {
			trace(event);
		}
		protected function onDragOver(event:NativeDragEvent):void {
			trace(event);
		}
		
		protected function selectFile(event:Event):void {
			filePathInput.text = selectedFile.nativePath;
			filePathInput.unfreeze();
			filePathInput.visible = true;
			mediaInfoANE.getInfo(selectedFile.nativePath);
		}
		private function onInputTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(chooseFileIn, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)
				selectedFile.browseForOpen("Select video file...");
		}
		protected function onFileInfo(event:MediaInfoEvent):void {
			var mediaInfo:MediaInfo = event.params.data as MediaInfo;
			
			trace(TextUtils.bytesToString(mediaInfo.fileSize));
			trace(mediaInfo.duration);
		}
		public function acceptFilePath(filePath:String):void {
			trace("acceptFilePath");
			trace(filePath);
			filePathInput.text = filePath;
			filePathInput.unfreeze();
			filePathInput.visible = true;
			mediaInfoANE.getInfo(filePath);
		}
	}
}