package {
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.ClipboardTransferMode;
	import flash.desktop.NativeDragActions;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeDragOptions;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.events.Event;
	
	[SWF(width = "1280", height = "720", frameRate = "60", backgroundColor = "#121314")]
	public class MediaInfoANESample extends Sprite {
		public var mStarling:Starling;
		private var btn:Sprite = new Sprite();
		private var hitArea:Sprite = new Sprite();

		private var theApp:StarlingRoot;
		public function MediaInfoANESample() {
			super();

			addEventListener(flash.events.Event.ADDED_TO_STAGE, onStaged);
			
			hitArea.graphics.beginFill(0x000FFF,0);
			hitArea.graphics.drawRect(0,620,1280,100);
			hitArea.graphics.endFill();
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			Starling.multitouchEnabled = false;  // useful on mobile devices
			Starling.handleLostContext = true;
			var viewPort:Rectangle = new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
			mStarling = new Starling(StarlingRoot, stage, viewPort,null,"auto","auto");
			mStarling.stage.stageWidth = stage.stageWidth;  // <- same size on all devices!
			mStarling.stage.stageHeight = stage.stageHeight;
			mStarling.simulateMultitouch = false;
			mStarling.showStatsAt("right","bottom");
			mStarling.enableErrorChecking = false;
			mStarling.antiAliasing = 16;
			
			mStarling.addEventListener(starling.events.Event.ROOT_CREATED, 
				function onRootCreated(event:Object, app:StarlingRoot):void {
					theApp = app;
					mStarling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
					app.start();
					mStarling.start();
					addChild(hitArea);
				});
		}
		
		protected function onStaged(event:flash.events.Event):void {
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,onDragIn);
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_OVER,onDragOver);
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDrop);
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT,onDragExit);
		}
		
		protected function onDragIn(event:NativeDragEvent):void {
			var cb:Clipboard = event.clipboard;
			if(cb.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)){
				NativeDragManager.dropAction = NativeDragActions.LINK;
				NativeDragManager.acceptDragDrop(hitArea);
			} else {
				trace("Unrecognized format");
			}
		}
		
		protected function onDragOver(event:NativeDragEvent):void {
		}
		
		protected function onDragExit(event:NativeDragEvent):void {
		}
		protected function onDrop(event:NativeDragEvent):void {
			var cb:Clipboard = event.clipboard;
			var dropObj:Object = cb.getData(ClipboardFormats.FILE_LIST_FORMAT);
			var file:File;
			if(dropObj){
				file = dropObj[0] as File;
				if(file){
					theApp.acceptFilePath(file.nativePath);
				}
			}
		}
	}
	
	
	
	
	
}