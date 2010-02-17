package toolbox 
{
	
// Internal Player Actions (outlined here: http://help.adobe.com/en_US/Flex/4.0/UsingFlashBuilder/WS6f97d7caa66ef6eb1e63e3d11b6c4d0d21-7edf.html)
// [generate]		: The just-in-time (JIT) compiler generates AS3 machine code.
// [mark]			: Flash Player marks live objects for garbage collection.
// [newclass]		:
// [pre-render]		: Flash Player prepares to render objects (including the geometry calculations and display list
//						traversal that happens before rendering).
// [reap]			: Flash Player reclaims DRC (deferred reference counting) objects.
// [render]			: Flash Player renders objects in the display list (pixel by pixel).
// [sweep]			: Flash Player reclaims memory of unmarked objects.
// [verify]			: The JIT compiler performs ActionScript 3.0 bytecode verification.
// [event_typeEvent]: Flash Player dispatches the specified event.

// Undocumented:
// [abc-decode]
// [avm1]
// [io]
// [newclass]
// [parse-query-string]
// <anonymous>

    import flash.sampler.*
    import flash.system.*
    import flash.utils.*

    public class Profiler
    {
        public function Profiler() {
			__newSamples = new Vector.<NewObjectSample>;
			__deleteSamples = new Vector.<DeleteObjectSample>;
			__internalSamples = new Vector.<Sample>;
			
			__deletedSampleIDs = new Vector.<Number>;
			__leakedSamples = new Vector.<int>;
			
			__functions = { };
		}
		
		public function start():void {
			__startTime = getTimer();
			startSampling();
		}
		
		public function stop():void {
			pauseSampling();
			__stopTime = getTimer();
			collect();
			stopSampling();
		}
		
		public function collect():void {
			var samples:Object = getSamples();
			var nos:NewObjectSample;
			var dos:DeleteObjectSample;
			
			var stackSize:int;
			var functionName:String;
			var i:int;
			
			var lastTime:Number;
			
			var s:Sample;
			for each( s in samples ) {
				if( isNaN( __startTimeMicro ) ) { __startTimeMicro = s.time; }
				if( s is NewObjectSample ) {
					nos = NewObjectSample( s );
					__newSamples.push( nos );
				}
				else if( s is DeleteObjectSample ) {
					dos = DeleteObjectSample( s );
					__deleteSamples.push( dos );
					__deletedSampleIDs.push( dos.id );
				}
				else if( s is Sample ) {
					__internalSamples.push( s );
				}
				else {
					throw new Error( "Unknown object encountered. Not a Sample. " + s );
				}
				
				__functions[ "__NO_STACK__" ] = { duration:0, cumulative:0 };
				if( s.stack ) {
					if( isNaN( lastTime ) ) { lastTime = s.time; }
					stackSize = s.stack.length;
					for( i = 0 ; i < stackSize ; i++ ) {
						functionName = StackFrame( s.stack[ i ] ).name;
						if( __functions[ functionName ] ) {
							if( i == 0 ) {
								__functions[ functionName ].duration += s.time - lastTime;
							}
							else {
								__functions[ functionName ].cumulative += s.time - lastTime;
							}
						}
						else {
							if( i == 0 ) {
								__functions[ functionName ] = { duration:(s.time - lastTime), cumulative:0 };
							}
							else {
								__functions[ functionName ] = { duration:0, cumulative:(s.time - lastTime) };
							}
						}
					}
				}
				else {
					__functions[ "__NO_STACK__" ].duration += s.time - lastTime;
				}
				lastTime = s.time;
			}
			
			__stopTimeMicro = lastTime;
			
			var j:int;
			var found:Boolean;
			var newLen:int = __newSamples.length;
			var newID:Number;
			for( i = 0 ; i < newLen ; i++ ) {
				found = false;
				newID = __newSamples[ i ].id;
				for( j = 0 ; j < __deletedSampleIDs.length ; j++ ) {
					if( newID == __deletedSampleIDs[ j ] ) {
						__deletedSampleIDs.splice( j, 1 );
						found = true;
						break;
					}
				}
				if( !found ) {
					__leakedSamples.push( i );
				}
			}
		}
		
		public function numNewSamples():int { return __newSamples.length; }
		public function numDeleteSamples():int { return __deleteSamples.length; }
		public function numInternalSamples():int { return __internalSamples.length; }
		public function numLeakedSamples():int { return __leakedSamples.length; }
		
		public function traceObject( obj:Object ):void {
			trace( "=OBJECT=" );
			var members:Object = getMemberNames( obj );
			
			for each( var qname:QName in members ) {
				trace( qname.toString() );
				if ( isGetterSetter( obj, qname ) ) {
					trace( getGetterInvocationCount( obj, qname ), getSetterInvocationCount( obj, qname ) );
				}
				else {
					// if -1, it is a class?
					trace( getInvocationCount( obj, qname ) );
				}
			}
		}
		
		public function traceFunctions():void {
			trace( "=FUNCTIONS=" );
			var total:Number = 0;
			for ( var func:String in __functions ) {
				trace( func, ":", __functions[ func ].duration, ":", __functions[ func ].cumulative );
				total += __functions[ func ].duration;
			}
			trace( "Total (microseconds): ", total );
			trace( "Other Total (microseconds): ", (__stopTimeMicro - __startTimeMicro) );
			trace( "TimerTotal (miliseconds): ", (__stopTime - __startTime) );
		}
		
		public function traceAverageFPS():void {
			var len:int = __internalSamples.length;
			var firstEnterFrame:Number = -1;
			var lastEnterFrame:Number;
			var numEnterFrames:int = 0;
			for( var i:int = 0 ; i < len ; i++ ) {
				trace( StackFrame(__internalSamples[ i ].stack[ 0 ]).name );
				if( StackFrame(__internalSamples[ i ].stack[ 0 ]).name == "[enterFrameEvent]" ) {
					if( firstEnterFrame == -1 ) {
						firstEnterFrame = __internalSamples[ i ].time;
					}
					lastEnterFrame = __internalSamples[ i ].time;
					numEnterFrames++;
				}
			}
			var microRunning:Number = lastEnterFrame - firstEnterFrame;
			var msPerFrame:Number = microRunning / numEnterFrames / 1000;
			trace( "microRunning", microRunning, "msPerFrame: ", msPerFrame, "fps:", int(1000/msPerFrame) );
		}
		
		public function traceInteral():void {
			var len:int = __internalSamples.length;
			for( var i:int = 0 ; i < len ; i++ ) {
				trace( "=INTERNAL=", __internalSamples[ i ].time, "=" );
				for( var j:int = 0 ; j < __internalSamples[ i ].stack.length ; j++ ) {
					trace( __internalSamples[ i ].stack[ j ] );
				}
			}
		}
		
		public function traceLeaked():void {
			var len:int = __leakedSamples.length;
			var newSample:NewObjectSample;
			var totalLeaked:Number = 0;
			for( var i:int = 0 ; i < len ; i++ ) {
				newSample = __newSamples[ __leakedSamples[ i ] ];
				trace( "=LEAKED=", newSample.time, "="  );
				trace( getQualifiedClassName( newSample.type ) );
				if( newSample.stack ) {
					for( var j:int = 0 ; j < newSample.stack.length ; j++ ) {
						trace( newSample.stack[ j ] );
					}
				}
				if( newSample.object ) {
					trace( "size: ", getSize( newSample.object ) );
					totalLeaked += getSize( newSample.object );
				}
			}
			trace( "Total Leaked:", totalLeaked, System.totalMemory );
		}
		
		private var __functions:Object;
		
		private var __startTime:int;
		private var __stopTime:int;
		private var __startTimeMicro:Number;
		private var __stopTimeMicro:Number;
		
		private var __newSamples:Vector.<NewObjectSample>;
		private var __deleteSamples:Vector.<DeleteObjectSample>;
		private var __internalSamples:Vector.<Sample>;
		
		private var __deletedSampleIDs:Vector.<Number>;
		private var __leakedSamples:Vector.<int>;
		
	}
}