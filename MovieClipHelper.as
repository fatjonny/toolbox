/*
 * 
 */

package toolbox
{
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import toolbox.Report;
	
	public class MovieClipHelper
	{
		
		public function MovieClipHelper( movieClip:MovieClip, writeStats:Boolean = false ) {
			__clip = movieClip;
			__labels = __clip.currentLabels;
			__writeStats = writeStats;
		}
		
		public function convertFrameToBitmap( frame:Object, bitmapData:BitmapData, offset:Point = null,
											  scale:Number = 1, rotation:Number = 0 ):void {
			if( offset == null ) { offset = new Point(); }
			__clip.gotoAndStop( frame );
			var mat:Matrix = new Matrix();
			mat.translate( -1 * (__clip.width / 2), -1 * (__clip.height / 2 ) );
			mat.rotate( 2 * Math.PI * (rotation / 360) );
			mat.translate( __clip.width / 2, __clip.height / 2 );
			mat.translate( offset.x, offset.y );
			mat.scale( scale, scale );
			bitmapData.draw( __clip, mat, null, BlendMode.NORMAL );
			
			if( __writeStats ) {
				Report.log( "convertFrameToBitmap wrote: " + frame.toString() + " of " + __clip.name + " at " + offset.toString() +
							 " with a scale of " + scale );
			}
		}
		
		// assumes the bitmapData can fit all of the animation
		// if the animation hits the width of the bitmapData, moves down one row
		// TODO: take in the width and height of where the clip is supposed to fit to counteract the mc changing sizes
		public function convertAnimationToBitmap( frameLabelName:String, bitmapData:BitmapData, offset:Point = null,
												  scale:Number = 1, rotation:Number = 0 ):void {
			if( offset == null ) { offset = new Point(); }
			var numFrames:int = countFrameLabelFrames( frameLabelName );
			var startFrame:int = getFrameLabelFrame( frameLabelName );
			for( var i:int = 0 ; i < numFrames ; i++ ) {
				convertFrameToBitmap( startFrame + i, bitmapData, offset, scale, rotation );
				offset.x += __clip.width;
				if( offset.x + __clip.width > bitmapData.width ) {
					offset.x = 0;
					offset.y += __clip.height;
				}
				if( offset.y + __clip.height > bitmapData.height ) {
					Report.warn( "convertAnimationToBitmap " + __clip.name + " " + frameLabelName + 
								  " drawing [" + offset.y + " + " + __clip.height + "] beyond height of bitmapData " +
								  bitmapData.height );
				}
			}
		}
		
		private var __labels:Array;
		private var __clip:MovieClip;
		private var __writeStats:Boolean;
		
		// loop through frames until a new label is found
		private function countFrameLabelFrames( frameLabelName:String ):int {
			// look in the list of all labels for this one
			for( var i:uint = 0 ; i < __labels.length ; i ++ ) {
				// found it!
				if( FrameLabel( __labels[ i ] ).name == frameLabelName ) {
					// if it is the last label
					if( i == __labels.length - 1 ) {
						// make sure to include the last frame
						return __clip.totalFrames - FrameLabel(__labels[ i ]).frame + 1;
					}
					else {
						// count up to the next label
						return FrameLabel(__labels[ i + 1 ]).frame - FrameLabel(__labels[ i ]).frame;
					}
				}
			}
			Report.error( "MovieClipHelper::countFrameLabelFrames " + __clip.name + " frame label " + frameLabelName + " not found." );
			return 0;
		}
		
		private function getFrameLabelFrame( frameLabelName:String ):int {
			for( var i:uint = 0 ; i < __labels.length ; i++ ) {
				if( FrameLabel( __labels[ i ] ).name == frameLabelName ) {
					return FrameLabel( __labels[ i ] ).frame;
				}
			}
			Report.error( "MovieClipHelper::getFrameLabelFrame " + __clip.name + " frame label " + frameLabelName + " not found." );
			return 0;
		}
	}
}