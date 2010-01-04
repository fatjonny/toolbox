/*
 * Static class
 * Attempts to render the screen at a specified interval
 * Dispatches an event at that interval
 */
package toolbox {

	import flash.events.*;
	import flash.utils.*;

	public class RenderClock {
		
		// public function RenderClock() {}
		
		public static function frameRendered( e:Event ):void {
			timeTick( null );
		}
		
		public static function start( hertz:int ):void {
			__msTarget = 1000 / hertz;
			destroy();
			__previousTime = getTimer();
			__timer = new Timer( __msTarget );
			__timer.addEventListener( TimerEvent.TIMER, timeTick );
			__timer.start();
		}
		
		public static function destroy():void {
			if( __timer != null ) {
				__timer.stop();
				__timer.removeEventListener( TimerEvent.TIMER, timeTick );
				__timer = null;
			}
		}
		
		private static var __previousTime:int;
		private static var __msTarget:Number;
		private static var __timer:Timer;
		
		private static function timeTick( e:TimerEvent ):void {
			__timer.reset();
			__timer.start();
			
			EventHandler.getInstance().dispatchEvent( new ToolboxEvent( ToolboxEvent.RENDERCLOCK_TICK ) );
			
			if( e != null ) {
				e.updateAfterEvent();
			}
		}
	}
}