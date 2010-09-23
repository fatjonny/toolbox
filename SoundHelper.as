/*
 * Sound Object Defaults
 * ---------------------
 *  loop:Boolean	(false)
 *  channel:String	("main")
 *  startAt:int		(0)
 *  onLoop:Function	()
 */

package toolbox {
	
	import flash.media.*;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import toolbox.EventHandler;
	
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
		
		public static function playSound( name:String, params:Object = null ):void {
			if( params == null ) { params = {}; }
			
			// set defaults
			if( !params.channel ) { params.channel = "main"; }
			
			// clear / initialize channel
			if( !__channel[ params.channel ] ) { initializeChannel( params.channel ); }
			else { stopChannel( params.channel ); }
			
			if( !__sound[ name ] ) {
				if( !__domain.hasDefinition( name ) ) {
					trace( "WARNING: unknown sound in playSound:", name );
					return;
				}
				var soundClass:Class = __domain.getDefinition( name ) as Class;
				__sound[ name ] = Sound( new soundClass );
			}
			
			__channel[ params.channel ].sound = name;
			
			if( params.startAt ) {
				__channel[ params.channel ].startAt = params.startAt;
			}
			
			if( params.onLoop ) {
				__channel[ params.channel ].onLoop = params.onLoop;
			}
			
			__channel[ params.channel ].content = __sound[ __channel[ params.channel ].sound ].play( __channel[ params.channel ].startAt );
			
			if( params.loop ) {
				__channel[ params.channel ].loop = params.loop;
				__channel[ params.channel ].content.addEventListener( Event.SOUND_COMPLETE, loopChannel );
			}
			else {
				__channel[ params.channel ].content.addEventListener( Event.SOUND_COMPLETE, clearChannel );
			}
		}
		
		public static function stopChannel( name:String ):void {
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
			if( __channel[ name ].content ) {
				__channel[ name ].content.stop();
				__channel[ name ].content = null;
			}
			__channel[ name ].sound = null;
			__channel[ name ].startAt = 0;
		}
		
		public static function pauseChannel( name:String ):void {
			if( __channel[ name ] && __channel[ name ].content ) {
				__channel[ name ].pausedAt = __channel[ name ].content.position;
				__channel[ name ].content.stop();
			}
		}
		
		public static function playChannel( name:String ):void {
			if( !__channel[ name ] ) { return; }
			
			if( __channel[ name ].pausedAt ) {
				__channel[ name ].content = __sound[ __channel[ name ].sound ].play( __channel[ name ].pausedAt );
				__channel[ name ].pausedAt = null;
			}
			else if( __channel[ name ].sound ) {
				__channel[ name ].content = __sound[ __channel[ name ].sound ].play( __channel[ name ].startAt );
			}
		}
		
		private static var __channel:Object = {};
		private static var __mute:Boolean = false;
		private static var __sound:Object = {};
		
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