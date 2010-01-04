/*
 *
 */

package toolbox {
	
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.system.*;
	import flash.net.URLRequest;
	import flash.display.Loader;
	
	public class AssetLoader {
		
		// public function AssetLoader() {	}
		
		// used for text files
		public static function loadURL( location:String, funcToCall:Function ):void {
			trace( "loadURL", location );
			__func = funcToCall;
			__urlLoader = new URLLoader();
			__urlLoader.addEventListener( Event.COMPLETE, urlLoaderComplete );
			__urlLoader.addEventListener( HTTPStatusEvent.HTTP_STATUS, loaderHttpStatus );
			__urlLoader.addEventListener( Event.INIT, loaderInit );
			__urlLoader.addEventListener( IOErrorEvent.IO_ERROR, loaderIOError );
			__urlLoader.addEventListener( Event.OPEN, loaderOpen );
			__urlLoader.addEventListener( ProgressEvent.PROGRESS, loaderProgress );
			__urlLoader.addEventListener( Event.UNLOAD, loaderUnload );
			__urlLoader.load( new URLRequest( location ) );
		}
		
		// used for swfs
		public static function loadIntoDomain( location:String, funcToCall:Function, domain:ApplicationDomain ):void {
			trace( "load", location );
			__func = funcToCall;
			__loader = new Loader();
			__loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loaderComplete );
			__loader.contentLoaderInfo.addEventListener( HTTPStatusEvent.HTTP_STATUS, loaderHttpStatus );
			__loader.contentLoaderInfo.addEventListener( Event.INIT, loaderInit );
			__loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loaderIOError );
			__loader.contentLoaderInfo.addEventListener( Event.OPEN, loaderOpen );
			__loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, loaderProgress );
			__loader.contentLoaderInfo.addEventListener( Event.UNLOAD, loaderUnload );
			__loader.load( new URLRequest( location ), new LoaderContext( false, domain ) );
		}
		
		private static var __loader:Loader;
		private static var __urlLoader:URLLoader;
		private static var __func:Function;
		
		private static function loaderComplete( e:Event ):void { trace( "loaderComplete", e ); destroy(); __func( e ); }
		
		private static function urlLoaderComplete( e:Event ):void { trace( "urlLoaderComplete", e ); destroyURLLoader(); __func( e ); }
		
		private static function loaderHttpStatus( e:HTTPStatusEvent ):void { trace( "loaderHttpStatusEvent", e ); }
		
		private static function loaderInit( e:Event ):void { trace( "loaderInit", e ); }
		
		private static function loaderIOError( e:IOErrorEvent ):void { trace( "loaderIOError", e ); }
		
		private static function loaderOpen( e:Event ):void { trace( "loaderOpen", e ); }
		
		private static function loaderProgress( e:ProgressEvent ):void { trace( "loaderProgress", e ); }
		
		private static function loaderUnload( e:Event ):void { trace( "loaderUnload", e ); }

		private static function destroyURLLoader():void {
			__urlLoader.removeEventListener( Event.COMPLETE, urlLoaderComplete );
			__urlLoader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, loaderHttpStatus );
			__urlLoader.removeEventListener( Event.INIT, loaderInit );
			__urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, loaderIOError );
			__urlLoader.removeEventListener( Event.OPEN, loaderOpen );
			__urlLoader.removeEventListener( ProgressEvent.PROGRESS, loaderProgress );
			__urlLoader.removeEventListener( Event.UNLOAD, loaderUnload );
			__urlLoader = null;
		}
		
		private static function destroy():void {
			__loader.unload();
			__loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, loaderComplete );
			__loader.contentLoaderInfo.removeEventListener( HTTPStatusEvent.HTTP_STATUS, loaderHttpStatus );
			__loader.contentLoaderInfo.removeEventListener( Event.INIT, loaderInit );
			__loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, loaderIOError );
			__loader.contentLoaderInfo.removeEventListener( Event.OPEN, loaderOpen );
			__loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, loaderProgress );
			__loader.contentLoaderInfo.removeEventListener( Event.UNLOAD, loaderUnload );
			__loader = null;
		}
	}
	
}