/*
 * Sound Object Defaults
 * ---------------------
 *  loop:Boolean	(false)		Uses an event listener to loop on sound complete
 *  channel:String	("main")	Sets channel for overlapping sounds
 *  startAt:int		(0)
 *  onLoop:Function	()
 *  fade:Number   (undefined)	decimal percent to fade per .25 sec
 *  gapless:Boolean	(false)		Makes playback gapless by using Flash's built in loop. DO NOT USE PAUSE OR RESTART WITH THIS. Redundant with loop, but does not interfere.
 */

package toolbox {
	
	import flash.media.*;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import toolbox.EventHandler;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class SoundHelper {
		
		//public function SoundHelper() {}
		
		public static function toggleMute():void {
			var volTransform:SoundTransform;
			__mute = !__mute;
			if( __mute ) {
				__oldVolume = SoundMixer.soundTransform.volume;
				volTransform = new SoundTransform(0, 0);
			}
			else {
				volTransform = new SoundTransform(__oldVolume, 0);
			}
			
			SoundMixer.soundTransform = volTransform;
		}
		
		public static function mute():void {
			if (__mute) { return; }
			else {
				trace("MUTE IT");
				__mute = true;
				__oldVolume = SoundMixer.soundTransform.volume;
				SoundMixer.soundTransform = new SoundTransform(0, 0);
			}
		}
		
		public static function unMute():void {
			if (!__mute) { return; }
			else {
				trace("UNMUTE IT to", __oldVolume);
				__mute = false;
				SoundMixer.soundTransform = new SoundTransform(__oldVolume, 0);
			}
		}
		
		public static function playSound( name:String, params:Object = null ):void {
			if( params == null ) { params = {}; }
			
			// set defaults
			if( !params.channel ) { params.channel = "main"; }
			if( !__sound[ name ] ) {
				if( !__domain.hasDefinition( name ) ) {
					trace( "WARNING: unknown sound in playSound:", name );
					return;
				}
				var soundClass:Class = __domain.getDefinition( name ) as Class;
				__sound[ name ] = Sound( new soundClass );
			}
			
			// clear / initialize channel
			if( !__channel[ params.channel ] ) { initializeChannel( params.channel ); }
			else { stopChannel( params.channel ); }
			
			__channel[ params.channel ].sound = name;
			
			if( params.startAt ) {
				__channel[ params.channel ].startAt = params.startAt;
			}
			
			if( params.onLoop ) {
				__channel[ params.channel ].onLoop = params.onLoop;
			}
			
			if (params.gapless) {
				__channel[ params.channel ].gapless = params.gapless;	
				__channel[ params.channel ].content = __sound[ __channel[ params.channel ].sound ].play( __channel[ params.channel ].startAt, int.MAX_VALUE);
			}
			else {				
				__channel[ params.channel ].content = __sound[ __channel[ params.channel ].sound ].play( __channel[ params.channel ].startAt );
			}
						
			
			if ( params.fade ) {
				__channel[ params.channel ].fade = params.fade;
				
				__trans = new SoundTransform(0, 0);
				__channel[params.channel].content.soundTransform = __trans;
				__timer = new Timer(250);
				__timer.addEventListener(TimerEvent.TIMER, fadeInFunc(params.channel));
				__timer.start();		
			}
			
			if( params.loop ) {
				__channel[ params.channel ].loop = params.loop;
				__channel[ params.channel ].content.addEventListener( Event.SOUND_COMPLETE, loopChannel );
			}
			else {
				__channel[ params.channel ].content.addEventListener( Event.SOUND_COMPLETE, clearChannel );
			}
		}
		
		private static function fadeInFunc(name:String):Function {
			return function (e:TimerEvent):void {
				__trans.volume += __channel[name].fade;
				if (__trans.volume >= .99) {
					__trans.volume = 1;
					__timer.stop();
					__timer.removeEventListener(TimerEvent.TIMER, fadeInFunc(name));
				}
				__channel[ name ].content.soundTransform = __trans;
				trace(name, "Volume", __trans.volume);
			}
		}
		
		public static function stopChannel( name:String ):void {
			if ( !__channel[ name ] ) { return; }
						
			if( __channel[ name ].loop == true ) {
				__channel[ name ].loop = false;
				if( __channel[ name ].content ) {
					__channel[ name ].content.removeEventListener( Event.SOUND_COMPLETE, loopChannel );
				}
			}
			else {
				if( __channel[ name ].content ) {
					__channel[ name ].content.removeEventListener( Event.SOUND_COMPLETE, clearChannel );
				}
			}
						
			if (__channel[name].fade) {		
				//stop any fade in
				__timer.stop();
				__timer.removeEventListener(TimerEvent.TIMER, fadeInFunc(name));		
				
				__timer = new Timer(250);
				__timer.addEventListener(TimerEvent.TIMER, fadeOutFunc(name, true));
				__timer.start();
			}
			else {
				if( __channel[ name ].content ) {
					__channel[ name ].content.stop();
					__channel[ name ].content = null;
				}
				__channel[ name ].sound = null;
				__channel[ name ].startAt = 0;				
			}
			
		}		
		
		private static function fadeOutFunc(name:String, stop:Boolean):Function {	
			return function (e:TimerEvent):void {
				__trans.volume -= __channel[name].fade;
				if (__trans.volume <= .001) {
					__trans.volume = 0;
					__timer.stop();
					__timer.removeEventListener(TimerEvent.TIMER, fadeOutFunc(name, stop));
					
					if(stop){
						if( __channel[ name ].content ) {
							__channel[ name ].content.stop();
							__channel[ name ].content = null;
						}
						__channel[ name ].sound = null;
						__channel[ name ].startAt = 0;	
					}
					else {						
						__channel[ name ].content.soundTransform = __trans;	
						__channel[ name ].content.stop();
					}
				}
				else{
					__channel[ name ].content.soundTransform = __trans;	
					trace(name, "Volume", __trans.volume);	
				}
			}
		}
		
		public static function pauseChannel( name:String ):void {
			if ( !__channel[ name ] ) { return; }
			
			if ( __channel[ name ] && __channel[ name ].content ) {
				if (__channel[name].fade) {	
					//stop any fade in
					__timer.stop();
					__timer.removeEventListener(TimerEvent.TIMER, fadeInFunc(name));		
					
					__timer = new Timer(250);
					__timer.addEventListener(TimerEvent.TIMER, fadeOutFunc(name, false));
					__timer.start();		
				}
				else {
					__channel[ name ].content.stop();
				}		
				__channel[ name ].pausedAt = __channel[ name ].content.position;	
			}
		}
		
		public static function playChannel( name:String ):void {
			if ( !__channel[ name ] ) { return; }
						
			if( __channel[ name ].pausedAt ) {
				__channel[ name ].content = __sound[ __channel[ name ].sound ].play( __channel[ name ].pausedAt );
				__channel[ name ].pausedAt = null;
			}
			else if( __channel[ name ].sound ) {
				__channel[ name ].content = __sound[ __channel[ name ].sound ].play( __channel[ name ].startAt );
			}
			
			if ( __channel[name].fade ) {	
				__trans = new SoundTransform(0, 0);
				__channel[name].content.soundTransform = __trans;
				__timer = new Timer(250);
				__timer.addEventListener(TimerEvent.TIMER, fadeInFunc(name));
				__timer.start();		
			}
		}
		
		public static function setApplicationDomain( appDomain:ApplicationDomain ):void {
			__domain = appDomain;
		}
		
		private static var __channel:Object = {};
		private static var __mute:Boolean = false;
		private static var __sound:Object = { };
		
		private static var __trans:SoundTransform;
		private static var __timer:Timer;
		
		private static var __oldVolume:Number;
		private static var __domain:ApplicationDomain = ApplicationDomain.currentDomain;
		
		private static function initializeChannel( name:String ):void {
			__channel[ name ] = {};
			__channel[ name ].loop = false;
			__channel[ name ].startAt = 0;
		}
		
		private static function loopChannel( e:Event ):void {
			var channelName:String = findChannelFromContent( SoundChannel( e.currentTarget ) );
			__channel[ channelName ].content.removeEventListener( Event.SOUND_COMPLETE, loopChannel );
			__channel[ channelName ].content = __sound[ __channel[ channelName ].sound ].play( __channel[ channelName ].startAt );
			__channel[ channelName ].content.addEventListener( Event.SOUND_COMPLETE, loopChannel );
			if( __channel[ channelName ].onLoop ) {
				__channel[ channelName ].onLoop();
			}
		}
		
		private static function clearChannel( e:Event ):void {
			var channelName:String = findChannelFromContent( SoundChannel( e.currentTarget ) );
			stopChannel( channelName );
		}
		
		private static function findChannelFromContent( soundChannel:SoundChannel ):String {
			for( var channelName:String in __channel ) {
				if( __channel[ channelName ].content == soundChannel ) {
					return channelName;
				}
			}
			return "";
		}
	}
}