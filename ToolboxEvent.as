/*
 * Adds a parameters object
 * Defines events specific to the toolbox
 */
package toolbox {
	
	import flash.events.Event;
	
	public class ToolboxEvent extends Event {
		
		//
		// CONSTRUCTOR
		//
		
		public function ToolboxEvent( type:String, bubbles:Boolean = false, 
									   cancelable:Boolean = false, paramObj:Object = undefined ) {
			
			// pass constructor parameters to the superclass constructor
			super( type, bubbles, cancelable );
			
			parameters = paramObj;
		}
		
		//
		// PUBLIC VARIABLES
		//
		
		public static const RENDERCLOCK_TICK:String 			= "toolboxEventRenderClockTick";
		
		public var parameters:Object;
		
		//
		// PUBLIC FUNCTIONS
		//
		
		public override function clone():Event {
			return new ToolboxEvent( type, bubbles, cancelable, parameters );
		}
		
		public override function toString():String {
			return formatToString( "ToolboxEvent", "type", "bubbles", "cancelable", "eventPhase", "parameters" );
		}
	}
}