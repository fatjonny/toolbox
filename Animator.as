/*
 * Static class
 * Runs at a set interval
 * Progresses animations to proper state
 */
package toolbox {
	
	import flash.utils.getTimer;
	
	public class Animator {
		
		//public function Animator() { }
		
		public static function addAnimation( animation:Animation, hertz:int ):uint {
			var msDelay:int = 1000 / hertz;
			return __animations.push( { animation:animation, nextTime:getTimer() + msDelay, msDelay:msDelay } ) - 1;
		}
		
		public static function removeAnimation( slotID:uint ):void {
			__animations.splice( slotID, 1 );
		}
		
		public static function restartAnimationTime( slotID:uint ):void {
			__animations[ i ].nextTime = getTimer() + __animations[ i ].msDelay;
		}
		
		public static function updateAnimations():void {
			var currTime:uint = getTimer();
			var info:Object;
			var len:uint = __animations.length;
			for( var i:uint = 0 ; i < len ; i++ ) {
				info = __animations[ i ];
				if( currTime >= info.nextTime ) {
					info.animation.nextFrame();
					info.nextTime = (currTime + info.msDelay) - (currTime - info.nextTime);
				}
			}
		}
		
		public static function destroy():void {
			for( var i:uint = 0 ; i < __animations.length ; i++ ) {
				__animations[ i ].animation = null;
				__animations[ i ] = null;
			}
			__animations.splice( 0, __animations.length );
		}
		
		private var __animations:Array = [];
	}
	
}