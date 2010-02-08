/*
 * Assumptions:
 * 	This class currently supports only convex polygons!
 * 	The first vector starts at 0,0 and the vectors are in an order
 * 	as if drawing the polygon with a pencil.
 */

package toolbox {
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class Polygon {
		
		public var x:Number;
		public var y:Number;
		
		public var edges:Vector.<Vector2D>;
		public var vectors:Vector.<Vector2D>;
		
		public function Polygon( numEdges:uint ) {
			edges = new Vector.<Vector2D>( numEdges );
			vectors = new Vector.<Vector2D>( numEdges );
		}
		
		public function constructFromEdges():void {
			vectors[ 0 ].x = edges[ 0 ].x;
			vectors[ 0 ].y = edges[ 0 ].y;
			for( var i:uint = 1 ; i < edges.length ; i++ ) {
				vectors[ i ].x = edges[ i ].x - edges[ i - 1 ].x;
				vectors[ i ].y = edges[ i ].y - edges[ i - 1 ].y;
			}
		}
		
		public function constructFromVectors():void {
			edges[ 0 ].x = vectors[ 0 ].x;
			edges[ 0 ].y = vectors[ 0 ].y;
			for( var i:uint = 1 ; i < vectors.length ; i++ ) {
				edges[ i ].x = edges[ i - 1 ].x + vectors[ i ].x;
				edges[ i ].y = edges[ i - 1 ].y + vectors[ i ].y;
			}
		}
		
		public function draw( sprite:Sprite, clear:Boolean = true, thickness:Number = 1, color:uint = 0xFFFFFF ):void {
			// clear any existing graphics
			if ( clear ) { sprite.graphics.clear(); }
			
			// go to our initial position
			var posX:Number = x;
			var posY:Number = y;
			trace( "draw", x, y, posX, posY );
			sprite.graphics.moveTo( posX, posY );
			
			// set up drawing
			sprite.graphics.lineStyle( thickness, color );
			
			// draw the edges
			for( var i:uint = 0 ; i < vectors.length ; i++ ) {
				posX += vectors[ i ].x;
				posY += vectors[ i ].y;
				sprite.graphics.lineTo( posX, posY );
			}
		}
		
		public function reset():void {
			if( edges.length > 0 ) {
				edges.splice( 0, edges.length );
			}
			if( vectors.length > 0 ) {
				vectors.splice( 0, vectors.length );
			}
		}
		
		public function destroy():void {
			reset();
			edges = null;
			vectors = null;
		}
	}
}