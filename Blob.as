/*
 * A blob is the basic drawable unit in the toolbox.
 * We'll just go ahead and say it stands for 'BLitter OBject'.
 */

package toolbox
{
	
	import flash.geom.Point;
	
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
		
		public function update():void {}
		public function render():void {
			
		}
		
		public function addAnimation():void {}
		public function addBitmapData():void {}
		
		private var __animations:Object;
		private var __changed:Boolean;
		private var __currentAnimation:String;
		private var __currentAnimationFrame:uint;
		private var __previousPosition:Point;
	}
}