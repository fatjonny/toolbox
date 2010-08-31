/*
 * 
 */

package toolbox {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class RolloverCreator {
		
		// public function RolloverCreator() {}
		
		public static function createRollover( rollover:MovieClip, toShow:MovieClip, persist:Boolean = false, doneFunc:Function = null, hoverMC:MovieClip = null ):void {
			rollover.addEventListener( MouseEvent.MOUSE_OVER, showRollover );
			if( !hoverMC ) { hoverMC = rollover; }
			__rollovers.push( { mc:rollover, hoverMC:hoverMC, toShow:toShow, persist:persist, done:doneFunc } );
		}
		
		public static function removeAll():void {
			while( __rollovers.length ) {
				__rollovers[ 0 ].mc.removeEventListener( MouseEvent.MOUSE_OVER, showRollover );
				__rollovers.splice( 0, 1 );
			}
		}
		
		private static var __rollovers:Array = [];
		
		private static function findRollover( mc:MovieClip, hoverMC:Boolean = false ):Object {
			for( var i:uint = 0 ; i < __rollovers.length ; i++ ) {
				if( !hoverMC && __rollovers[ i ].mc == mc ) {
					return __rollovers[ i ];
				}
				else if( __rollovers[ i ].hoverMC == mc ) {
					return __rollovers[ i ];
				}
			}
			return null;
		}
		
		private static function showRollover( e:MouseEvent ):void {
			var obj:Object = findRollover( e.currentTarget as MovieClip );
			var mc:MovieClip = obj.mc;
			obj.hoverMC.addEventListener( MouseEvent.MOUSE_OUT, hideRollover );
			obj.toShow.visible = true;
		}
		
		private static function hideRollover( e:MouseEvent ):void {
			var obj:Object = findRollover( e.currentTarget as MovieClip, true );
			var mc:MovieClip = obj.mc;
			obj.toShow.visible = false;
			obj.hoverMC.removeEventListener( MouseEvent.MOUSE_OUT, hideRollover );
			if( !obj.persist ) {
				mc.removeEventListener( MouseEvent.MOUSE_OVER, showRollover );
			}
			if( obj.done != null ) {
				obj.done( mc, obj.toShow );
			}
		}
	}
}