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
	import toolbox.MovieClipInfo;
	
	public class MovieClipHelper
	{
		
		public function MovieClipHelper( movieClip:MovieClip, writeStats:Boolean = false ) {
			__clip = movieClip;
			__labels = __clip.currentLabels;
			__writeStats = writeStats;
			__info = new MovieClipInfo( __clip );
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
			var numFrames:int = __info.numFramesInLabel( frameLabelName );
			var startFrame:int = __info.startFrameForLabel( frameLabelName );
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
		private var __info:MovieClipInfo;
	}
}