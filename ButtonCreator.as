/*
 * buttonMode is assumed to be true unless specifically set false
 * 
 * 		param name	type		default
 * 		----------	----		-------
 *		buttonMode	(Boolean)	true
 * 		passEvent	(Boolean)	false
 * 		persist		(Boolean)	false
 */

package toolbox {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import toolbox.EventHandler;
	
	public class ButtonCreator {
		
		//public function ButtonCreator() {}
		
		public static function CreateFromMovieClip( mc:MovieClip, func:Function, params:Object = null ):void {
			if( params == null ) { params = { }; }
			params.mc = mc;
			params.func = func;
			__registeredButtons.push( params );
			if( params.buttonMode == undefined || params.buttonMode ) {
				mc.buttonMode = true;
			}
			mc.addEventListener( MouseEvent.CLICK, MovieClipEvents );
		}
		
		public static function RemoveRegisteredMovieClip( mc:MovieClip ):void {
			FindMovieClipParams( mc, true );
		}
		
		private static var __registeredButtons:Array = [];
		
		private static function MovieClipEvents( e:MouseEvent ):void {
			var params:Object = FindMovieClipParams( MovieClip( e.currentTarget ) );
			
			if( params == null ) {
				throw new Error( "Ack! ButtonCreator MovieClipEvents called erroneously on " + e.currentTarget );
			}
			
			if( !params.persist ) {
				e.currentTarget.buttonMode = false;
				e.currentTarget.removeEventListener( MouseEvent.CLICK, MovieClipEvents );
			}
			
			if( params.passEvent ) {
				params.func( e );
			}
			else {
				params.func();
			}
		}
		
		private static function FindMovieClipParams( mc:MovieClip, forceRemove:Boolean = false ):Object {
			var i:uint = 0;
			var params:Object;
			var numButtons:uint = __registeredButtons.length;
			for( ; i < numButtons ; i++ ) {
				if( __registeredButtons[ i ].mc == mc ) {
					params = __registeredButtons[ i ];
					if( !params.persist || forceRemove ) {
						__registeredButtons.splice( i, 1 );
					}
					return params;
				}
			}
			return null;
		}
	}
}