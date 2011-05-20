/*
 * 		param name	type		default
 * 		----------	----		-------
 * 		placeBehind	(Boolean)	undefined
 * 		snap		(Boolean)	true
 * 		drag		(String)	undefined
 * 		passEvent	(Boolean)	false
 * 		passMC		(Boolean)	false
 * 		passObj		(Object)	undefined
 * 		persist		(Boolean)	false
 */

package toolbox {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	public class CursorCreator {
				
		public static function CreateCursor(mc:MovieClip, targetMC:MovieClip, func:Function, params:Object = null):void {
			if( mc == null ) { throw new Error( "CreateCursor error! null passed as a MovieClip" ); }
			if ( FindMovieClipParams( mc ) ) { RemoveRegisteredMovieClip( mc ); }
			
			if (params == null) { params = { }; }			
			if ( params[ "snap" ] == null ) { params[ "snap" ]	= true; }
			
			params.mc = mc;
			params.target = targetMC;
			params.func = func;
			__registeredButtons.push( params );
			__cursorMC = mc; 
			mc.stage.addEventListener(MouseEvent.MOUSE_MOVE, MovieClipEvents);
			Mouse.hide(); 
			mc.parent.addChild(mc);
			//click through
			mc.mouseEnabled = false;
			mc.mouseChildren = false;
			
			if( params.drag ) {
				mc.gotoAndPlay( params.drag );
			}
			params.target.addEventListener(MouseEvent.CLICK, MovieClipEvents);
		}
		
		private static var __cursorMC:MovieClip;		//only one cursor at a time, and this is it
		
		private static function MovieClipEvents(e:MouseEvent):void {
			var mc:MovieClip = __cursorMC;
			var params:Object = FindMovieClipParams(mc);
						
			if( params == null ) {
				throw new Error( "Ack! CursorCreator MovieClipEvents called erroneously on " + mc );
			}			
			if (e.type == MouseEvent.MOUSE_MOVE) {
				mc.x = e.stageX;
				mc.y = e.stageY;
			}
			else if (e.type == MouseEvent.CLICK) {	
				if ( !params.persist ) {
					//click through disabled
					mc.mouseEnabled = true;
					mc.mouseChildren = true;
					RemoveRegisteredMovieClip( mc );
					mc.stage.removeEventListener(MouseEvent.MOUSE_MOVE, MovieClipEvents);
					Mouse.show();
				}
				if (params.placeBehind) {
					params.target.parent.addChild(params.target);
				}				
				params.target.removeEventListener(MouseEvent.CLICK, MovieClipEvents);
					
				// will get overridden by any sounds in params.func
				SoundHelper.playSound( "ClickSound" );
				if (params.snap) {
					mc.x = params.target.x;
					mc.y = params.target.y;
				}
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