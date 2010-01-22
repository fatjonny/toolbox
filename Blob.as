/*
 * A blob is the basic drawable unit in the toolbox.
 * We'll just go ahead and say it stands for 'BLitter OBject'.
 */

package toolbox
{
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Blob
	{
		// attributes
		public var x:Number;
		public var y:Number;
		public var width:uint;
		public var height:uint;
		
		// state variables
		public var active:Boolean;
		public var animated:Boolean;
		// visible refers to whether it is invisible, not to whether it is on screen
		public var visible:Boolean;
		
		public function Blob() {
			width = 0;
			height = 0;
			x = 0;
			y = 0;
			
			active = false;
			animated = false;
			visible = false;
			
			__animations = {};
			__changed = false;
			__previousPosition = new Point( x, y );
		}
		
		public function update( deltaTime:int ):void {
			// physics
			if( active ) {
				
			}
			
			// animation (after physics, in case there is an animation state change)
			if( animated ) {
				__currentAnimation.update( deltaTime );
			}
		}
		
		// assumes that surfaceBitmap is lock()ed and will be unlock()ed sometime afterwards
		public function render( surfaceBitmap:BitmapData, worldX:int = 0, worldY:int = 0 ):void {
			// skip if not visible
			if( !__bitmapData ) { return; }
			if( !visible ) { return; }
			
			// draw!
			if( animated ) {
				surfaceBitmap.copyPixels( __bitmapData, __currentAnimation.rect, new Point( x - worldX, y - worldY ), null, null, true );
			}
			else {
				surfaceBitmap.copyPixels( __bitmapData, __bitmapData.rect, new Point( x - worldX, y - worldY ), null, null, true );
			}
		}
		
		public function addAnimation( name:String, numFrames:int, fps:Number, offsetX:int = 0, offsetY:int = 0 ):void {
			if( __animations[ name ] != null ) { __animations[ name ].destroy(); }
			__animations[ name ] = new BlobAnimation( name, numFrames, fps, new Rectangle( offsetX, offsetY, width, height ) );
		}
		
		public function addBitmapData( bitmapData:BitmapData, width:uint = 0, height:uint = 0 ):void {
			__bitmapData = bitmapData;
			if( width == 0 ) { this.width = bitmapData.width; }
			else { this.width = width; }
			if( height == 0 ) { this.height = bitmapData.height; }
			else { this.height = height; }
		}
		
		public function playAnimation( name:String, startingFrame:int = 1 ):void {
			animated = true;
			if ( __animations[ name ] != null ) {
				__currentAnimation = __animations[ name ];
				__currentAnimation.currentFrame = startingFrame;
			}
			else {
				Report.warn( "Blob playAnimation " + name + " animation does not exist!" );
			}
			__currentAnimation.play();
		}
		
		public function rotateTo( rotation:Number ):void {
			;
		}
		
		public function destroy():void {
			if( __bitmapData ) {
				__bitmapData.dispose();
			}
			if( __currentAnimation ) {
				__currentAnimation.destroy();
			}
		}
		
		private var __animations:Object;
		private var __changed:Boolean;
		private var __currentAnimation:BlobAnimation;
		private var __previousPosition:Point;
		
		private var __bitmapData:BitmapData;
	}
}