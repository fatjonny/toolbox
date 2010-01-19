/*
 * BlobAnimation stores information about the animation, not the animation itself
 */

package toolbox {
	
	import flash.geom.Rectangle;
	
	public class BlobAnimation {
		
		public var name:String;
		
		public function BlobAnimation( name:String, numFrames:int, fps:int, firstFrame:Rectangle, stripMaxX:int = 2880, stripMinX:int = 0 ) {
			__numFrames = numFrames;
			__fps = fps;
			__msToAdvance = 1000 / __fps;
			__firstFrame = firstFrame;
			__stripMinX = stripMinX;
			__stripMaxX = stripMaxX;
			
			resetFramePosition();
		}
		
		public function play( currentTimeBias:int = 0 ):void {
			__msLeft = __msToAdvance + currentTimeBias;
		}
		
		public function update( deltaTime:int ):void {
			__msLeft -= deltaTime;
			while( __msLeft < 0 ) {
				__currentFrameNum++;
				if( __currentFrameNum > __numFrames ) {
					__currentFrameNum = 1;
					resetFramePosition();
				} else {
					advanceFramePosition();
				}
				
				trace( "currentFrameNum", __currentFrameNum );
				
				__msLeft += __msToAdvance;
			}
		}
		
		public function get currentFrame():int {
			return __currentFrameNum;
		}
		
		public function get rect():Rectangle {
			return __currentFrame;
		}
		
		public function set currentFrame( frame:int ):void {
			__currentFrameNum = frame;
			__msLeft = __msToAdvance;
			resetFramePosition();
			for( var i:int = 1 ; i < frame ; i++ ) {
				advanceFramePosition();
			}
		}
		
		public function destroy():void { }
		
		private var __currentFrameNum:int;
		private var __fps:int;
		private var __msToAdvance:int;
		private var __msLeft:int;
		private var __numFrames:int;
		private var __firstFrame:Rectangle;
		private var __currentFrame:Rectangle;
		private var __stripMinX:int;
		private var __stripMaxX:int;
		
		private function advanceFramePosition():void {
			__currentFrame.x += __currentFrame.width;
			if( __currentFrame.x + __currentFrame.width > __stripMaxX ) {
				__currentFrame.x = __stripMinX;
				__currentFrame.y += __currentFrame.height;
			}
		}
		
		private function resetFramePosition():void {
			__currentFrame = new Rectangle( __firstFrame.x, __firstFrame.y, __firstFrame.width, __firstFrame.height );
		}
	}	
}