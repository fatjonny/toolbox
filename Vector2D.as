/*
 * Currently untested.
 * TODO: find out if static methods are faster or slower than class methods
 */

package toolbox {
	
	public class Vector2D {
		
		public var x:Number;
		public var y:Number;
		
		public static function Add( vecA:Vector2D, vecB:Vector2D ):Vector2D {
			return new Vector2D( vecA.x + vecB.x, vecA.y + vecB.y );
		}
		
		public static function CrossProduct( vecA:Vector2D, vecB:Vector2D ):Number {
			return vecA.x * vecB.y - vecA.y * vecB.x;
		}
		
		public static function DotProduct( vecA:Vector2D, vecB:Vector2D ):Number {
			return vecA.x * vecB.x + vecA.y * vecB.y;
		}
		
		public static function Perpendicular( vecA:Vector2D ):Vector2D {
			return new Vector2D( -1 * vecA.y, vecA.x );
		}
		
		public static function ScalarMultiply( vec2d:Vector2D, scalar:Number ):Vector2D {
			return new Vector2D( vec2d.x * scalar, vec2d.y * scalar );
		}
		
		public static function Subtract( vecA:Vector2D, vecB:Vector2D ):Vector2D {
			return new Vector2D( vecA.x - vecB.x, vecA.y - vecB.y );
		}
		
		public function Vector2D( initialX:Number = 1, initialY:Number = 1 ) {
			x = initialX;
			y = initialY;
		}
		
		public function magnitude():Number {
			return Math.sqrt( x * x + y * y );
		}
		
		public function normalize():void {
			var inverseMag:Number = 1.0 / magnitude();
			x = x * inverseMag;
			y = y * inverseMag;
		}
		
		public function rotate( radians:Number ):void {
			var cosRadians:Number = Math.cos( radians );
			var sinRadians:Number = Math.sin( radians );
			var xT:Number = (x * cosRadians) - (y * sinRadians);
			var yT:Number = (y * cosRadians) + (x * sinRadians);
			x = xT;
			y = yT;
		}
	}
}