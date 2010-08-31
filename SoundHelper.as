/*
 * 
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
			__frontChannel.soundTransform = volTransform;
			__ambientChannel.soundTransform = volTransform;
			
			SoundMixer.soundTransform = volTransform;
		}
		
		public static function playSound( sndName:String ):void {
			if( __frontChannel != null ) {
				__frontChannel.stop();
			}
			if( !__domain.hasDefinition( sndName ) ) { 
				trace( "WARNING: unknown sound in playSound:", sndName );
				return;
			}
			__frontChannel = Sound( new (__domain.getDefinition( sndName ) as Class) ).play(0);
			
			if( __mute ) {
				var volTransform:SoundTransform;
				volTransform = new SoundTransform(0, 0);
				__frontChannel.soundTransform = volTransform;
			}
		}
		
		public static function playAmbient( ambName:String ):void {
			if( __ambientChannel != null ) {
				__ambientChannel.stop();
				__ambientChannel.removeEventListener( Event.SOUND_COMPLETE, loopAmbient );
			}
			if( !ambName ) { return; }
			__ambientName = ambName;
			__ambientChannel = Sound( new (__domain.getDefinition( ambName ) as Class) ).play(0);
			__ambientChannel.addEventListener( Event.SOUND_COMPLETE, loopAmbient );
			
			if( __mute ) {
				var volTransform:SoundTransform;
				volTransform = new SoundTransform(0, 0);
				__ambientChannel.soundTransform = volTransform;
			}
		}
		
		public static function stopAmbient():void {
			__ambientChannel.stop();
			__ambientChannel.removeEventListener( Event.SOUND_COMPLETE, loopAmbient );
			__ambientChannel = null;
		}
		
		private static function loopAmbient( e:Event ):void {
			__ambientChannel.stop();
			__ambientChannel.removeEventListener( Event.SOUND_COMPLETE, loopAmbient );
			__ambientChannel = Sound( new (__domain.getDefinition( __ambientName ) as Class) ).play(0);
			__ambientChannel.addEventListener( Event.SOUND_COMPLETE, loopAmbient );
			
			if( __mute ) {
				var volTransform:SoundTransform;
				volTransform = new SoundTransform(0, 0);
				__ambientChannel.soundTransform = volTransform;
			}
		}
		
		private static var __oldVolume:Number;
		private static var __domain:ApplicationDomain = ApplicationDomain.currentDomain;
		private static var __playing:Array = [];
		private static var __sounds:Object = {};
		private static var __mute:Boolean = false;
		private static var __ambientChannel:SoundChannel;
		private static var __ambientName:String;
		private static var __frontChannel:SoundChannel;
	}
}