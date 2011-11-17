/*
 * This is for a single object. 
 * Click and drag left or right to cause animation to happen
 * Frame is based on x location on screen
 * 
 * param name	Type		
 * ----------	----		
 * hideMouse	Boolean		
 * startFunc	Function	
 * forwardOnly	Boolean 	only animates forward along the timeline, not back.
 */

package toolbox {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.display.Stage;
	
	import caurina.transitions.Tweener;
	
	public class DragAnimator {
				
		//Originally distance based for HP, modified to be location-based for Grade 5 Science
		//goBackOnRelease, transitionType, and animByDistance really need to be part of a params obj.
		public static function setupAnimation(animatedMC:MovieClip, frameLabel:String, endFunc:Function, distToDrag:int = 0, goBackOnRelease:Boolean = false, transitionType:String = "linear", animByDistance:Boolean = false, params:Object = null):void {
			
			if ( params == null ) { params = { }; }
			
			animatedMC.addEventListener(MouseEvent.MOUSE_DOWN, clickMove);
			__frameLabel = frameLabel;
			__mc = animatedMC;
			__mci = new MovieClipInfo( __mc );
			__animByDistance = animByDistance;
			__goBackOnRelease = goBackOnRelease;
			__transitionType = transitionType;
			__endFunc = endFunc;		
			__initialFrame = __mci.startFrameForLabel(__frameLabel);
			__params = params;
			if (distToDrag != 0) {
				__dragRatio = distToDrag / __mci.numFramesInLabel(__frameLabel);
				trace(__dragRatio, distToDrag);
			}
		}
		
		//private
		
		
		private static var __mc:MovieClip;		
		private static var __mci:MovieClipInfo;
		
		private static var __goBackOnRelease:Boolean = false;
		private static var __mouseDiff:int = 0;
		private static var __mouseStartX:int = 0;
		private static var __animByDistance:Boolean = false;		
		private static var __dragRatio:int = 1; //pixels per frame
		private static var __frameLabel:String = "";
		private static var __endFunc:Function;
		private static var __params:Object; 
		private static var __initialFrame:int; //updates each time you click, if forwardOnly
				
		//mouse
		private static function clickMove(e:MouseEvent):void {
			trace("Mouse Clicked, initial frame =", __initialFrame);
			__direction = "";
			if (__params.forwardOnly == true) {
				if(__mc.currentFrame > __mci.startFrameForLabel(__frameLabel)){
					__initialFrame = __mc.currentFrame; 
				}
				else {
					__initialFrame = __mci.startFrameForLabel(__frameLabel);
				}
				__mc.gotoAndStop(__initialFrame);
			}
			else{
				__mc.gotoAndStop(__mci.startFrameForLabel(__frameLabel));
			}
			__mouseStartX = e.stageX;
			__mc.stage.addEventListener(MouseEvent.MOUSE_MOVE, drag);
			__mc.stage.addEventListener(MouseEvent.MOUSE_UP, releaseMove);
			//__mc.stage.addEventListener(Event.ENTER_FRAME, enterFrame);
			if (__params.startFunc) {
				__params.startFunc();
			}
		}
		
		private static function drag(e:MouseEvent):void {
			__mouseDiff = __mouseStartX - e.stageX;
			var frameNum:int = __initialFrame + Math.floor(__mouseDiff / __dragRatio);
			var maxFrame:int = __mci.startFrameForLabel(__frameLabel) + __mci.numFramesInLabel(__frameLabel); 
			trace(frameNum, maxFrame);
			if (frameNum > maxFrame) {
				frameNum = maxFrame; 
				__mc.gotoAndStop(frameNum);
				finish();
			}
			else if (frameNum < __mci.startFrameForLabel(__frameLabel)) {
				frameNum = __mci.startFrameForLabel(__frameLabel);
			}			
			else{
			if (__params.forwardOnly == true && frameNum < __mc.currentFrame) {
				//do nothing
				trace("Forward only, difference is", __mc.currentFrame - frameNum);
			}
			else {
				__mc.gotoAndStop(frameNum);
			}
			}
			if (__params.hideMouse) {
				Mouse.hide();
			}
			/*
			if(__animByDistance){
				if (__mouseDiff > deadzone) {
					__direction = "backward";
				}
				else if (__mouseDiff < - deadzone) {
					__direction = "forward";
				}
				else {
					__direction = "";
				}
			}
			else {
				if (__distToDrag > 0) {
					__dragRatio = __distToDrag / __mci.numFramesInLabel(__frameLabel);
					trace(__dragRatio);
					//begin at startframeforlabel, set frame based on that
				}				
			}*/
		}
		
		private static function finish():void {	
			trace("End of Frame");
			Mouse.show();
			__mc.removeEventListener(MouseEvent.MOUSE_DOWN, clickMove);
			__mc.stage.removeEventListener(MouseEvent.MOUSE_MOVE, drag);
			__mc.stage.removeEventListener(MouseEvent.MOUSE_UP, releaseMove);
			__endFunc();
			//__mc.stage.removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
				
		private static function releaseMove(e:MouseEvent):void {
			trace("Mouse Released");
			__mc.stage.removeEventListener(MouseEvent.MOUSE_MOVE, drag);
			__mc.stage.removeEventListener(MouseEvent.MOUSE_UP, releaseMove);
			//__mc.stage.removeEventListener(Event.ENTER_FRAME, enterFrame);
			if (__goBackOnRelease) {
				animateBack();
			}
			if (__params.hideMouse) {
				Mouse.show();
			}
			//gotoClosestView(); //if goBackOnRelease is on. - needs to use tweener
		}
		
		
		//animate
		
		//used for distance-based computation, not yet implemented.
		private static var __remainderTime:int = 0;
		private static var __lastTime:int = 0;		
		private static var __framesLeft:int = 0;
		private static var __msPerFrame:int = 0;
		private static var __direction:String = "";
		private static const deadzone:int = 10; 
			
		//this is only used for distance-based animation
		private static function enterFrame(e:Event):void {
			if(__mc.currentFrameLabel != __frameLabel){
				var currentTime:int = getTimer();
				if ( __lastTime == 0 ) { __lastTime = currentTime; } //init
				var timeDiff:int = currentTime - __lastTime;	
				__remainderTime += timeDiff;
				trace("remainder time",__remainderTime);
				
				while ( __remainderTime > __msPerFrame) {
					__remainderTime -= __msPerFrame;
					if(__direction == "forward"){
						__mc.nextFrame();
					}
					else if (__direction == "backward") {
						__mc.prevFrame();
					}
				}
				//looping around -- set if this is true.
				/*
				if (__mc.currentFrame == __mc.totalFrames && __direction == "forward") {
					__mc.gotoAndStop(1);
				}	
				if (__mc.currentFrameLabel == "view1" && __direction == "backward") {
					__mc.gotoAndStop(__mc.totalFrames);
				}*/
				__lastTime = currentTime;		
			}
			else {			
				__mc.stop();
				__lastTime = 0;
				__mc.stage.removeEventListener(Event.ENTER_FRAME, enterFrame);
			}
		}
		
		
		private static var __tweenCounter:Object = { };
		private static var __transitionType:String;
		
		private static function animateBack():void {
			setDirection();
			if (__mci.startFrameForLabel(__frameLabel) != __mc.currentFrame) {
				__tweenCounter.frame = __mc.currentFrame;
				//calculate time separately?
				Tweener.addTween(__tweenCounter, {frame:__mci.startFrameForLabel(__frameLabel), time:.5, transition:__transitionType, onUpdate:tweeny} );
				//special case for final frame so it loops around correctly
				/*if (Math.abs(__mc.currentFrame - __mc.totalFrames) < Math.abs(__mc.currentFrame - __mci.startFrameForLabel(__frameLabel))) { 
					__targetFrame = "view1";
					__direction = "forward";
					Tweener.addTween(tweenCounter, {frame:__shell.totalFrames, delay:.25, time:1, transition:"linear", onUpdate:tweeny, onComplete:gotoFirst} );
				}
				else {	
				//calculate time separately?
					Tweener.addTween(tweenCounter, {frame:__mci.startFrameForLabel(__frameLabel), time:1, transition:"linear", onUpdate:tweeny} );
				}*/
			}
		}
		
		private static function tweeny():void {
			if(__mc.currentFrame != __mci.startFrameForLabel(__frameLabel)){
				__mc.gotoAndStop(Math.floor(__tweenCounter.frame));
			}
			else {	
				__mc.stop();
			}
		}	
		
		private static function setDirection():void {
			if (__mci.startFrameForLabel(__frameLabel) > __mc.currentFrame) { 
				__direction = "forward"; 
			} 
			else if (__mci.startFrameForLabel(__frameLabel) < __mc.currentFrame) {
				__direction = "backward"; 
			}
		}
		
	}
}