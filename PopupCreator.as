/*Params
 * Name			Type		Usage
 * ----			----		-----
 * showFunc		function	Function to call when showing the popup
 * closeFunc	function	Function to call when closing the popup
 * persist		Boolean		Causes popup to stay around after closing, must be deleted manually
 * inFrame		String		popup opening animation
 * outFrame		String		popup closing animation
 */

package toolbox {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class PopupCreator {
		
		public static function createPopup( mc:MovieClip, closeBtn:MovieClip, params:Object = null ):void {
			//persist:Boolean = false, doneFunc:Function = null, hoverMC:MovieClip = null
			
			if( params == null ) { params = { }; }
			params.mc = mc;
			params.closeBtn = closeBtn;
			__popups.push( params );
		}
		
		public static function removeAllRegisteredMovieclips():void {
			trace( "+- RemoveAllRegisteredMovieClips -+", __registeredButtons.length );
			while( __popups.length ) {
				RemoveRegisteredMovieClip( __popups[ 0 ].mc );
			}
			trace( "+---------------------------------+" );
		}
				
		public static function RemoveRegisteredMovieClip( mc:MovieClip ):void {
			var params:Object = FindMovieClipParams( mc, true );
			if( params == null ) { return; }
			
			//reset all variables
			//remove listeners
		}
		
		private static var __popups:Array = [];
		
		private static function FindMovieClipParams( mc:MovieClip, forceRemove:Boolean = false ):Object {
			var i:uint = 0;
			var params:Object;
			var numButtons:uint = __registeredButtons.length;
			
			if( forceRemove ) { trace( "Popup FindMovieClipParams with forceRemove:", mc ); }
			
			for( ; i < numButtons ; i++ ) {
				if( __registeredButtons[ i ].mc == mc ) {
					params = __registeredButtons[ i ];
					if( forceRemove ) {
						__registeredButtons.splice( i, 1 );
					}
					return params;
				}
			}
			return null;
		}
		
		private static function showPopup( mc:MovieClip ):void {
			mc.visible = true;
			var params:Object = FindMovieClipParams( mc );
			
			//also go to in frames = a new param?
			if (params.inFrame) {
				mc.gotoAndPlay(params.inFrame);
			}
			ButtonCreator.CreateFromMovieClip(params.closeBtn, closePopup, { hover:"h", normal:"n", passMC:true } );
			if (params.showFunc) {
				params.showFunc(mc);
			}
		}
		
		private static function closePopup( mc:MovieClip ):void {
			var params:Object = FindMovieClipParams( mc );
			
			//go to out frames instead? = a new param
			if (params.outFrame) {
				mc.gotoAndPlay(params.outFrame);
				var mci:MovieClipInfo = new MovieClipInfo(mc);
				mci.addScriptAtEnd(mc, params.outFrame, function():void {
					mc.stop();
					mc.visible = false;
				});
			}
			else  {	mc.visible = false; }
			
			if( !params.persist ) {
				RemoveRegisteredMovieClip( mc );
			}
			if ( params.closeFunc) {
				params.closeFunc(mc);
			}
		
		}
	}
}