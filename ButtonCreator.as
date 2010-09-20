/*
 * buttonMode is assumed to be true unless specifically set false
 * 
 * 		param name	type		default
 * 		----------	----		-------
 *		buttonMode	(Boolean)	true
 * 		children	(Boolean)	false
 * 		passEvent	(Boolean)	false
 * 		passMC		(Boolean)	false
 * 		passObj		(Object)	undefined
 * 		persist		(Boolean)	false
 * 		normal		(String)	""
 * 		normalFunc	(Function)	null
 * 		hover		(String)	""
 *		hoverSound	(String)	""
 * 		hoverFunc	(Function)	null
 * 		disabled	(String)	""
 */

package toolbox {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import toolbox.EventHandler;
	
	public class ButtonCreator {
		
		//public function ButtonCreator() {}
		
		public static function CreateFromMovieClip( mc:MovieClip, func:Function, params:Object = null ):void {
			if( mc == null ) { throw new Error( "CreateFromMovieClip error! null passed as a MovieClip" ); }
			if( FindMovieClipParams( mc ) ) { RemoveRegisteredMovieClip( mc ); }
			
			if( params == null ) { params = { }; }
			params.mc = mc;
			params.func = func;
			__registeredButtons.push( params );
			if( params.buttonMode == undefined || params.buttonMode ) {
				mc.buttonMode = true;
			}
			mc.mouseChildren = false;
			mc.mouseEnabled = true;
			if( params.children ) { mc.mouseChildren = true; }
			mc.addEventListener( MouseEvent.CLICK, MovieClipEvents );
			if( params.normal ) {
				mc.gotoAndStop( params.normal );
			}
			if( params.normalFunc ) { 
				params.normalFunc( mc );
			}
			if( params.hover || params.hoverFunc ) { 
				mc.addEventListener( MouseEvent.MOUSE_OVER, MovieClipEvents );
			}
		}
		
		public static function RemoveRegisteredMovieClip( mc:MovieClip ):void {
			var params:Object = FindMovieClipParams( mc, true );
			if( params == null ) { return; }
			
			mc.buttonMode = false;
			mc.mouseChildren = true;
			mc.removeEventListener( MouseEvent.CLICK, MovieClipEvents );
			mc.removeEventListener( MouseEvent.MOUSE_OVER, MovieClipEvents );
			mc.removeEventListener( MouseEvent.MOUSE_OUT, MovieClipEvents );
			if( params.normal ) {
				mc.gotoAndStop( params.normal );
			}
			if( params.normalFunc ) {
				params.normalFunc( mc );
			}
		}
		
		private static var __registeredButtons:Array = [];
		
		private static function MovieClipEvents( e:MouseEvent ):void {
			var mc:MovieClip = MovieClip( e.currentTarget );
			var params:Object = FindMovieClipParams( mc );
			
			if( params == null ) {
				throw new Error( "Ack! ButtonCreator MovieClipEvents called erroneously on " + mc );
			}
			
			if( e.type == MouseEvent.CLICK ) {
				if( !params.persist ) {
					RemoveRegisteredMovieClip( mc );
				}
				
				// will get overridden by any sounds in params.func
				SoundHelper.playSound( "ClickSound" );
				
				if( params.passEvent ) {
					params.func( e );
				}
				else if( params.passMC ) {
					params.func( params.mc );
				}
				else if( params.passObj ) {
					params.func( params.passObj );
				}
				else {
					params.func();
				}
			}
			else if( e.type == MouseEvent.MOUSE_OVER ) {
				if( params.hover ) {
					mc.gotoAndPlay( params.hover );
					mc.addEventListener( MouseEvent.MOUSE_OUT, MovieClipEvents );
				}
				if( params.hoverFunc ) {
					params.hoverFunc( mc );
				}
				if( params.hoverSound ) {
					SoundHelper.playSound( params.hoverSound );
				}
				else {
					SoundHelper.playSound( "ButtonHover" );
				}
			}
			else if( e.type == MouseEvent.MOUSE_OUT ) {
				if( params.normal ) {
					mc.gotoAndPlay( params.normal );
					mc.removeEventListener( MouseEvent.MOUSE_OUT, MovieClipEvents );
				}
				if( params.normalFunc ) {
					params.normalFunc( mc );
				}
			}
		}
		
		private static function FindMovieClipParams( mc:MovieClip, forceRemove:Boolean = false ):Object {
			var i:uint = 0;
			var params:Object;
			var numButtons:uint = __registeredButtons.length;
			
			if( forceRemove ) { trace( "FindMovieClipParams with forceRemove:", mc ); }
			
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
	}
}