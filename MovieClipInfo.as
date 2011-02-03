/*
 * 
 */

package toolbox
{
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	
	import toolbox.Report;
	
	public class MovieClipInfo
	{
		
		public function MovieClipInfo( movieClip:MovieClip ) {
			__totalFrames = movieClip.totalFrames;
			__name = movieClip.name;
			__frameInfo = { };
			
			fillLabelInfo( movieClip.currentLabels );
		}
		
		public function labelNames():Array { return __names; }
		public function mcName():String { return __name; }
		public function numLabels():uint { return __names.length; }
		public function numFramesInLabel( labelName:String ):int { return __frameInfo[ labelName ].numFrames; }
		// if using with addFrameScript remember to subtract 1
		public function startFrameForLabel( labelName:String ):int { return __frameInfo[ labelName ].startFrame; }
		
		public function addScript( movieClip:MovieClip, labelName:String, funcToCall:Function, endOfLabel:Boolean = false ):void {
			if( endOfLabel == false ) {
				movieClip.addFrameScript( startFrameForLabel( labelName ) - 1, funcToCall );
			}
			else {
				movieClip.addFrameScript( startFrameForLabel( labelName ) + numFramesInLabel( labelName ) - 2, funcToCall );
			}
		}
		
		public function hasLabel( label:String ):Boolean {
			for( var i:uint = 0 ; i < __names.length ; i++ ) {
				if( __names[ i ] == label ) {
					return true;
				}
			}
			return false;
		}
		
		private var __name:String;
		private var __names:Array;
		private var __frameInfo:Object;
		private var __totalFrames:int;
		
		private function fillLabelInfo( currentLabels:Array ):void {
			var labelName:String;
			var labelFrameCount:int;
			__names = new Array( currentLabels.length );
			for( var i:uint = 0 ; i < currentLabels.length ; i++ ) {
				labelName = FrameLabel( currentLabels[ i ] ).name;
				__names[ i ] = labelName;
				
				if( i == currentLabels.length - 1 ) {
					// make sure to include the last frame
					labelFrameCount = __totalFrames - FrameLabel( currentLabels[ i ] ).frame + 1;
				}
				else {
					// count up to the next label
					labelFrameCount = FrameLabel(currentLabels[ i + 1 ]).frame - FrameLabel(currentLabels[ i ]).frame;
				}
				__frameInfo[ labelName ] = { startFrame:FrameLabel( currentLabels[ i ] ).frame, numFrames:labelFrameCount };
			}
		}
	}
}