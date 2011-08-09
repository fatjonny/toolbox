/*
 * 		param name	type			default
 * 		----------	----			-------
 * 		placeBehind	(Boolean)		undefined
 * 		snap		(Boolean)		true
 * 		drag		(String)		undefined
 * 		-passEvent	(Boolean)		false
 * 		-passMC		(Boolean)		false
 * 		-passObj	(Object)		undefined
 * 		persist		(Boolean)		false
 * 		parent		(DisplayObject)	undefined
 * 		target		(MovieClip)		undefined
 * 		clickFunc	(Function)		undefined
 */

package toolbox {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	public class CursorCreator {

		//targetMC:MovieClip, func:Function
		public static function CreateCursor(mc:MovieClip, params:Object = null):void {
			if( mc == null ) { throw new Error( "CreateCursor error! null passed as a MovieClip" ); }
			if ( FindMovieClipParams( mc ) ) { RemoveRegisteredMovieClip( mc ); }
			
			trace("Set Cursor", mc.name);
			if (params == null) { params = { }; }	
			if (params["offsetX"] == null) { params["offsetX"] = 0; }
			if (params["offsetY"] == null) { params["offsetY"] = 0; }
			if ( params[ "snap" ] == null ) { params[ "snap" ]	= true; }
			
			params.mc = mc;
			__registeredButtons.push( params );
			__cursorMC = mc; 
			
			mc.stage.addEventListener(MouseEvent.MOUSE_MOVE, MovieClipEvents);
			Mouse.hide(); 
			mc.parent.addChild(mc);
			
			//click through
			mc.mouseEnabled = false;
			mc.mouseChildren = false;
			
			__parent = mc.stage;
			if( params.parent ) {
				__parent = params.parent as DisplayObject;
			}
			if( params.drag ) {
				mc.gotoAndPlay( params.drag );
			}
			if(params.clickFunc){
				params.target.addEventListener(MouseEvent.CLICK, MovieClipEvents);
			}
		}
		
		private static var __cursorMC:MovieClip;		//only one cursor at a time, and this is it
		private static var __parent:DisplayObject;
		
		private static function MovieClipEvents(e:MouseEvent):void {
			var mc:MovieClip = __cursorMC;
			var params:Object = FindMovieClipParams(mc);
			
			if( params == null ) {
				throw new Error( "Ack! CursorCreator MovieClipEvents called erroneously on " + mc );
			}
			if (e.type == MouseEvent.MOUSE_MOVE) {
				var stagePoint:Point = new Point( e.stageX, e.stageY );
				var targetPoint:Point = __parent.globalToLocal( stagePoint );
				mc.x = targetPoint.x + params.offsetX;
				mc.y = targetPoint.y + params.offsetY;
			}
			else if (e.type == MouseEvent.CLICK) {	
				if ( !params.persist ) {
					RemoveRegisteredMovieClip( mc );
					ResetCursor();
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
					params.clickFunc( e );
				}
				else if( params.passMC ) {
					params.clickFunc( params.mc );
				}
				else if( params.passObj ) {
					params.clickFunc( params.passObj );
				}
				else {
					params.clickFunc();
				}
			}
		}
		
		public static function ResetCursor():void {
			trace("Reset cursor");
			if(__cursorMC){
				__cursorMC.stage.removeEventListener(MouseEvent.MOUSE_MOVE, MovieClipEvents);
				__cursorMC.mouseEnabled = true;
				__cursorMC.mouseChildren = true;
				__cursorMC = null;
			}
			Mouse.show();
		}
		
		public static function RemoveRegisteredMovieClip( mc:MovieClip ):void {
			var params:Object = FindMovieClipParams( mc, true );
			if( params == null ) { return; }
			
			Mouse.show();
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