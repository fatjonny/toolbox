/*
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
 * 		group		(String)	""
 * 		removeGroup	(Boolean)	false
 */

package toolbox {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
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
		
		public static function DisableRegisteredMovieClip(mc:MovieClip):void {			
			var params:Object = FindMovieClipParams( mc );
			if ( params == null ) { return; }
			
			mc.buttonMode = false;
			mc.removeEventListener( MouseEvent.CLICK, MovieClipEvents );
			mc.removeEventListener( MouseEvent.MOUSE_OVER, MovieClipEvents );
			mc.removeEventListener( MouseEvent.MOUSE_OUT, MovieClipEvents );
		}
		
		public static function ReenableRegisteredMovieClip(mc:MovieClip):void {
			var params:Object = FindMovieClipParams( mc );
			if ( params == null ) { return; }
			if( params.normal ) {
				mc.gotoAndStop( params.normal );
			}
			if (params.normalFunc) {
				params.normalFunc(mc);
			}
			mc.buttonMode = true;
			mc.addEventListener( MouseEvent.CLICK, MovieClipEvents );
			mc.addEventListener( MouseEvent.MOUSE_OVER, MovieClipEvents );
			mc.addEventListener( MouseEvent.MOUSE_OUT, MovieClipEvents );
		}
		
		public static function DisableGroupMovieClips(group:String):void {
			var params:Object;
			var i:uint = 0;
			var count:uint = 0;
			while( i < __registeredButtons.length ) {
				params = __registeredButtons[ i ];
				if( params.group == group ) {
					DisableRegisteredMovieClip( params.mc );
					count++;
				}
				i++;
			}
			trace( "+- DisableGroupRegisteredMovieClips -+",group,count );
			//trace( "~~~~~~~~~~", count );
		}
		
		public static function ReenableGroupMovieClips(group:String):void {
			var params:Object;
			var i:uint = 0;
			var count:uint = 0;
			while( i < __registeredButtons.length ) {
				params = __registeredButtons[ i ];
				if( params.group == group ) {
					ReenableRegisteredMovieClip( params.mc );
					count++;
				}
				i++;
			}
			//trace( "~~~~~~~~~~", count );
			trace( "+- EnableGroupRegisteredMovieClips -+",group,count );
		}
		
		public static function RemoveAllGroupRegisteredMovieClips( group:String ):void {
			var params:Object;
			var i:uint = 0;
			var count:uint = 0;
			trace( "+- RemoveAllGroupRegisteredMovieClips -+",group );
			while( i < __registeredButtons.length ) {
				params = __registeredButtons[ i ];
				if( params.group == group ) {
					RemoveRegisteredMovieClip( params.mc );
					count++;
				}
				else {
					i++;
				}
			}
			trace( "+--------------------------------------+", count );
		}
		
		public static function RemoveAllRegisteredMovieClips():void {
			trace( "+- RemoveAllRegisteredMovieClips -+", __registeredButtons.length );
			while( __registeredButtons.length ) {
				RemoveRegisteredMovieClip( __registeredButtons[ 0 ].mc );
			}
			trace( "+---------------------------------+" );
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
				
				if( params.removeGroup ) {
					RemoveAllGroupRegisteredMovieClips( params.group );
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
				mc.addEventListener( MouseEvent.MOUSE_OUT, MovieClipEvents );
				if( params.hover ) {
					mc.gotoAndPlay( params.hover );
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
				mc.removeEventListener( MouseEvent.MOUSE_OUT, MovieClipEvents );
				if( params.normal ) {
					mc.gotoAndPlay( params.normal );
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