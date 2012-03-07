/*Params
 * Name			Type		Usage
 * ----			----		-----
 * buttonMC		MovieClip	button that starts the popup
 * showFunc		function	Function to call when showing the popup. Passes popup movieclip.
 * closeFunc	function	Function to call when closing the popup. Passes popup movieclip.
 * persist		Boolean		Causes popup to stay around after closing, must be deleted manually
 * inFrame		String		popup opening animation
 * outFrame		String		popup closing animation
 * normal		String		frame for normal: should be same on button and closebtn.
 * hover		String		frame for hover: should be same on button and closebtn.
 */

package toolbox {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class PopupCreator {
		
		public static function createPopup( popupMC:MovieClip, closeBtn:MovieClip, params:Object = null ):void {
			
			if ( params == null ) { params = { }; }
			params.mc = popupMC;
			params.closeBtn = closeBtn;
			
			if (!params.persist) {
				params.persist = false;
			}
			__popups.push( params );			
			popupMC.visible = false;
			
			if(params.buttonMC){
				var buttonParams:Object = { };
				buttonParams.persist = params.persist;
				if (params.normal) { buttonParams.normal = params.normal; }
				if (params.hover) { buttonParams.hover = params.hover; }
				buttonParams.passMC = true;
				
				ButtonCreator.CreateFromMovieClip(params.buttonMC, showPopup, buttonParams );
			}
		}
		
		public static function removeAllRegisteredMovieclips():void {
			trace( "+- RemoveAllRegisteredMovieClips popups -+", __popups.length );
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
			ButtonCreator.RemoveRegisteredMovieClip(params.buttonMC);
			ButtonCreator.RemoveRegisteredMovieClip(params.closeBtn);
		}
		
		private static var __popups:Array = [];
		
		/*Can find it with the popup movieclip, button movieclip, or close button mc*/
		private static function FindMovieClipParams( mc:MovieClip, forceRemove:Boolean = false ):Object {
			var i:uint = 0;
			var params:Object;
			var numButtons:uint = __popups.length;
			
			if( forceRemove ) { trace( "Popup FindMovieClipParams with forceRemove:", mc ); }
			
			for( ; i < numButtons ; i++ ) {
				if( __popups[ i ].mc == mc ) {
					params = __popups[ i ];
					if( forceRemove ) {
						__popups.splice( i, 1 );
					}
					return params;
				}
				else if( __popups[ i ].buttonMC == mc ) {
					params = __popups[ i ];
					if( forceRemove ) {
						__popups.splice( i, 1 );
					}
					return params;
				}
				else if( __popups[ i ].closeBtn == mc ) {
					params = __popups[ i ];
					if( forceRemove ) {
						__popups.splice( i, 1 );
					}
					return params;
				}
			}
			return null;
		}
		
		private static function showPopup( mc:MovieClip ):void {
			var params:Object = FindMovieClipParams( mc );
			params.mc.visible = true;
			
			//also go to in frames = a new param?
			if (params.inFrame) {
				params.mc.gotoAndPlay(params.inFrame);
			}
			ButtonCreator.CreateFromMovieClip(params.closeBtn, closePopup, { hover:"h", normal:"n", passMC:true} );
			if (params.showFunc) {
				params.showFunc(params.mc);
			}
		}
		
		private static function closePopup( buttonMC:MovieClip ):void {
			var params:Object = FindMovieClipParams( buttonMC );
			
			//go to out frames instead? = a new param
			if (params.outFrame) {
				params.mc.gotoAndPlay(params.outFrame);
				var mci:MovieClipInfo = new MovieClipInfo(params.mc);
				mci.addScriptAtEnd(params.mc, params.outFrame, function():void {
					params.mc.stop();
					params.mc.visible = false;
				});
			}
			else  {	params.mc.visible = false; }
			
			if( !params.persist ) {
				RemoveRegisteredMovieClip( params.mc );
			}
			if ( params.closeFunc) {
				params.closeFunc(params.mc);
			}
		
		}
	}
}