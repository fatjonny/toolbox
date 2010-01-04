/*
 * Singleton class
 * Simply overrides the necessary functions
 */
package toolbox {
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	public class EventHandler extends EventDispatcher {
		
		//
		// CONSTRUCTOR
		//
		
		// singleton constructor
		// this way any elements don't need an instance passed to them they can just query FoodFuryGame
		public function EventHandler( caller:Function = null ):void {

			if( caller != EventHandler.getInstance ) {
				throw new Error( "EventHandler is a singleton class!" );
			}

			if( __instance != null ) {
				throw new Error( "Only one EventHandler instance should be created!" );
			}
		}
		
		//
		// PUBLIC FUNCTIONS
		//
		
		// ensures there is only one instance
		public static function getInstance():EventHandler {
			if( __instance == null ) {
				__instance = new EventHandler( arguments.callee );
			}
			return __instance;
		}
		
		public override function addEventListener( type:String, listener:Function, 
													useCapture:Boolean = false, priority:int = 0, 
													useWeakReference:Boolean = false ):void {
			
			super.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}
		
		public override function dispatchEvent( event:Event ):Boolean {
			return super.dispatchEvent( event );
		}
		
		public override function hasEventListener( type:String ):Boolean {
			return super.hasEventListener( type );
		}
		
		public override function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void {
			super.removeEventListener( type, listener, useCapture );
		}
		
		public override function willTrigger( type:String ):Boolean {
			return super.willTrigger( type );
		}
		
		//
		// PRIVATE VARIABLES
		//
		
		private static var __instance:EventHandler;
	}
}