/*
 * Callbacks:
 * 
 * down( mc:MovieClip )
 * up( obj:Object, bestFit:MovieClip )
 * 
 * 		obj = { mc(MovieClip),
 * 				hitAreas(Array),
 * 				down(Function),
 * 				up(Function),
 * 				mostArea(Boolean),
 * 				snapBack(Boolean),
 * 				lockCenter(Boolean)
 * 			  }
 * 
 */

package toolbox {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class DraggableCreator {
		
		// public function DraggableCreator() {}
		
		public static function createDraggable( draggableMC:MovieClip, validHitAreas:Array, downFunc:Function, upFunc:Function, mostArea:Boolean = true, snapBack:Boolean = false, lockCenter:Boolean = false ):void {
			draggableMC.addEventListener( MouseEvent.MOUSE_DOWN, createDraggableDown );
			__draggable.push( { mc:draggableMC, hitAreas:validHitAreas, down:downFunc, up:upFunc, mostArea:mostArea, snapBack:snapBack, lockCenter:lockCenter } );
			
			if( snapBack ) {
				draggableMC.dragOrigX = draggableMC.x;
				draggableMC.dragOrigY = draggableMC.y;
				draggableMC.dragScaleX = draggableMC.scaleX;
				draggableMC.dragScaleY = draggableMC.scaleY;
			}
		}
		
		public static function removeDraggable( draggableMC:MovieClip ):void {
			if( __currentDraggable ) {
				// FILL IN!
			}
			
			for( var i:uint = 0 ; i < __draggable.length ; i++ ) {
				if( __draggable[ i ].mc == draggableMC ) {
					draggableMC.removeEventListener( MouseEvent.MOUSE_DOWN, createDraggableDown );
					__draggable.splice( i, 1 );
					return;
				}
			}
		}
		
		public static function removeAllDraggable():void {
			while( __draggable.length ) {
				__draggable[ 0 ].mc.removeEventListener( MouseEvent.MOUSE_DOWN, createDraggableDown );
				__draggable.splice( 0, 1 );
			}
		}
		
		public static function disableAll():void {
			for( var i:uint = 0 ; i < __draggable.length ; i++ ) {
				__draggable[ i ].mc.removeEventListener( MouseEvent.MOUSE_DOWN, createDraggableDown );
			}
		}
		
		public static function enableAll():void {
			for( var i:uint = 0 ; i < __draggable.length ; i++ ) {
				if( !__draggable[ i ].mc.hasEventListener( MouseEvent.MOUSE_DOWN ) ) {
					__draggable[ i ].mc.addEventListener( MouseEvent.MOUSE_DOWN, createDraggableDown );
				}
			}
		}
		
		//adds a separate area to use for the hit test
		public static function setDragHitArea( dragMC:MovieClip, hitMC:MovieClip):void {
			var draggable:Object = findDraggable(dragMC);
			draggable.dragHitMC = hitMC;
		}
		
		private static var __draggable:Array = [];
		private static var __currentDraggable:Object;
		
		private static function findDraggable( mc:MovieClip ):Object {
			for( var i:uint = 0 ; i < __draggable.length ; i++ ) {
				if( __draggable[ i ].mc == mc ) {
					return __draggable[ i ];
				}
			}
			return null;
		}
		
		private static function createDraggableDown( e:MouseEvent ):void {
			var mc:MovieClip = e.currentTarget as MovieClip;
			__currentDraggable = findDraggable( mc );
			if( !__currentDraggable.lockCenter ) { __currentDraggable.lockCenter = false; }
			mc.startDrag( __currentDraggable.lockCenter );
			mc.removeEventListener( MouseEvent.MOUSE_DOWN, createDraggableDown );
			mc.addEventListener( MouseEvent.MOUSE_UP, dropDraggable );
			__currentDraggable.down( mc );
		}
		
		private static function dropDraggable( e:MouseEvent ):void {
			var mostArea:Boolean = __currentDraggable.mostArea;
			var bestFit:MovieClip;
			var bestFitArea:Number = 0;
			var dragMC:MovieClip;
			if (__currentDraggable.dragHitMC != undefined) {
				trace("Check special hit area");
				dragMC = __currentDraggable.dragHitMC as MovieClip;
			}
			else {
				dragMC = __currentDraggable.mc as MovieClip;
			}
			for( var i:uint = 0 ; i < __currentDraggable.hitAreas.length ; i++ ) {
				var currentTest:MovieClip = __currentDraggable.hitAreas[ i ];
				if( currentTest && dragMC.hitTestObject( currentTest ) ) {
					if( !mostArea ) {
						bestFit = currentTest;
						break;
					}
					else {
						var srcRect:Rectangle = dragMC.getBounds( currentTest.stage );
						var testRect:Rectangle = currentTest.getBounds( currentTest.stage );
						var intersection:Rectangle = srcRect.intersection( testRect );
						var area:Number = intersection.width * intersection.height;
						if( area > bestFitArea ) {
							bestFit = currentTest;
							bestFitArea	= area;
						}
					}
				}
			}
			if( __currentDraggable.snapBack && !bestFit ) {
				__currentDraggable.mc.x = __currentDraggable.mc.dragOrigX;
				__currentDraggable.mc.y = __currentDraggable.mc.dragOrigY;
				__currentDraggable.mc.scaleX = __currentDraggable.mc.dragScaleX;
				__currentDraggable.mc.scaleY = __currentDraggable.mc.dragScaleY;
			}
			dragMC = __currentDraggable.mc as MovieClip; //reset for final checks
			removeDraggable( __currentDraggable.mc );
			__currentDraggable.up( __currentDraggable, bestFit );
			dragMC.stopDrag();
			dragMC.removeEventListener( MouseEvent.MOUSE_UP, dropDraggable );
			__currentDraggable = null;
		}
	}
}