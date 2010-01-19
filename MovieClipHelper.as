/*
 * 
 */

package toolbox
{
	
	import flash.display.BitmapData;
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
											  scale:Number = 1 ):void {
			if( offset == null ) { offset = new Point(); }
			__clip.gotoAndStop( frame );
			var mat:Matrix = new Matrix();
			mat.translate( offset.x, offset.y );
			mat.scale( scale, scale );
			bitmapData.draw( __clip, mat );
			
			if( __writeStats ) {
				Report.log( "convertFrameToBitmap wrote: " + frame.toString() + " of " + __clip.name + " at " + offset.toString() +
							 " with a scale of " + scale );
			}
		}
		
		// assumes the bitmapData can fit all of the animation
		// if the animation hits the width of the bitmapData, moves down one row
		// TODO: take in the width and height of where the clip is supposed to fit to counteract the mc changing sizes
		public function convertAnimationToBitmap( frameLabelName:String, bitmapData:BitmapData, offset:Point = null,
												  scale:Number = 1 ):void {
			if( offset == null ) { offset = new Point(); }
			var numFrames:int = countFrameLabelFrames( frameLabelName );
			var startFrame:int = getFrameLabelFrame( frameLabelName );
			for( var i:int = 0 ; i < numFrames ; i++ ) {
				convertFrameToBitmap( startFrame + i, bitmapData, offset, scale );
				offset.x += __clip.width;
				if( offset.x + __clip.width > bitmapData.width ) {
					offset.x = 0;
					offset.y += __clip.height;
				}
				if( offset.y + __clip.height > bitmapData.height ) {
					Report.warn( "convertAnimationToBitmap " + __clip.name + " " + frameLabelName + 
								  " drawing [" + offset.y + " + " + __clip.height + "] beyond height of bitmapData "
								  + bitmapData.height );
				}
			}
		}
		
		private var __labels:Array;
		private var __clip:MovieClip;
		private var __writeStats:Boolean;
		
		private function countFrameLabelFrames( frameLabelName:String ):int {
			for( var i:uint = 0 ; i < __labels.length ; i ++ ) {
				if( FrameLabel( __labels[ i ] ).name == frameLabelName ) {
					if( i == __labels.length - 1 ) {
						return __clip.totalFrames - FrameLabel(__labels[ i ]).frame;
					}
					else {
						return FrameLabel(__labels[ i + 1 ]).frame - FrameLabel(__labels[ i ]).frame;
					}
				}
			}
			Report.error( "MovieClipHelper::countFrameLabelFrames " + __clip.name + " frame label " + frameLabelName + " not found." );
			return 0;
		}
		
		private function getFrameLabelFrame( frameLabelName:String ):int {
			for( var i:uint = 0 ; i < __labels.length ; i ++ ) {
				if( FrameLabel( __labels[ i ] ).name == frameLabelName ) {
					return FrameLabel( __labels[i] ).frame;
				}
			}
			Report.error( "MovieClipHelper::getFrameLabelFrame " + __clip.name + " frame label " + frameLabelName + " not found." );
			return 0;
		}
	}
}