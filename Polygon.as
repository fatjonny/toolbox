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

		public var edges:Vector.<Vector2D>;
		public var vectors:Vector.<Vector2D>;
		
		public function Polygon( numEdges:uint ) {
			edges = new Vector.<Vector2D>( numEdges );
			vectors = new Vector.<Vector2D>( numEdges );
			for( var i:uint = 0 ; i < numEdges ; i++ ) {
				edges[ i ] = new Vector2D();
				vectors[ i ] = new Vector2D();
			}
		}
		
		public function get x():Number { return __x; }
		public function get y():Number { return __y; }
		
		public function set x( newX:Number ):void {
			var diff:Number = newX - __x;
			__x = newX;
			trace( "x", __x, newX, diff );
			edges.forEach( function callback(item:Vector2D, index:int, vector:Vector.<Vector2D>):void { item.x += diff; }, null );
			//vectors.forEach( function callback(item:Vector2D, index:int, vector:Vector.<Vector2D>):void { item.x += diff; }, null );
		}
		
		public function set y( newY:Number ):void {
			var diff:Number = newY - __y;
			__y = newY;
			edges.forEach( function callback(item:Vector2D, index:int, vector:Vector.<Vector2D>):void { item.y += diff; }, null );
			//vectors.forEach( function callback(item:Vector2D, index:int, vector:Vector.<Vector2D>):void { item.y += diff; }, null );
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
			//var posX:Number = __x;
			//var posY:Number = __y;
			//trace( "draw", x, y, posX, posY );
			//sprite.graphics.moveTo( posX, posY );
			sprite.graphics.moveTo( __x, __y );
			
			// set up drawing
			sprite.graphics.lineStyle( thickness, color );
			
			// draw the edges
			for( var i:uint = 0 ; i < vectors.length ; i++ ) {
				//posX += vectors[ i ].x;
				//posY += vectors[ i ].y;
				//sprite.graphics.lineTo( posX, posY );
				sprite.graphics.lineTo( edges[ i ].x, edges[ i ].y );
			}
			sprite.graphics.lineStyle();
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
		
		private var __x:Number = 0;
		private var __y:Number = 0;
		
	}
}