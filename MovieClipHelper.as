/*
 * 
 */

package toolbox
{
	
	import flash.display.MovieClip;
	
	public class MovieClipHelper
	{
		
		public function MovieClipHelper( movieClip:MovieClip ) {
			
		}
		
		/*
			__labels = __character.currentLabels;
			
			var scale:Number = 0.5;
			
			var i:uint = 0;
			for ( i = 0 ; i < __labels.length ; i++ ) {
				__bitmapDatas.push( new BitmapData( bounds.width * countFramesInLabel( __labels[ i ].name ) * scale, bounds.height * scale ) );
				convertFrameToBitmap( FrameLabel( __labels[ i ] ).name, __bitmapDatas[ i ], scale );
				var bitmap:Bitmap = new Bitmap( __bitmapDatas[ i ] );
				//this.addChild( bitmap );
				bitmap.x = 50;
				bitmap.y = 100 + (bounds.height + 5) * i * scale;
			}
		
		
		private function countFramesInLabel( frameLabel:String ):uint {
			var count:uint = 0;
			__character.gotoAndStop( frameLabel );
			var currentFrame:int = __character.currentFrame;
			while ( __character.currentLabel == frameLabel ) {
				count++;
				__character.gotoAndStop( __character.currentFrame + 1 );
				if ( currentFrame == __character.currentFrame ) {
					break;
				}
			}
			trace( frameLabel, count );
			return count;
		}
		
		private function convertFrameToBitmap( frameLabel:String, bitmapData:BitmapData, scale:Number ):void {
			var i:uint = 0;
			__character.gotoAndStop( frameLabel );
			trace( frameLabel );
			var currentFrame:int = __character.currentFrame;
			while( __character.currentLabel == frameLabel ) {
				trace( __character.currentFrame );
				var mat:Matrix = new Matrix();
				mat.translate( 41 + (82 * i), bitmapData.height );
				mat.scale( scale, scale );
				bitmapData.draw( __character, mat );
				__character.gotoAndStop( __character.currentFrame + 1 );
				i++;
				if ( currentFrame == __character.currentFrame ) {
					break;
				}
			}
		} */
	}
}