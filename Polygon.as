/*
 * Assumptions:
 * 	This class currently supports only convex polygons!
 * 	The first point starts at 0,0 and the points are sequential around
 *  the edge of the polygon
 * TODO: add rotation, scale
 * TODO: test speed of forEach on vectors
 */

package toolbox {
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class Polygon {

		public var edges:Vector.<Vector2D>;
		public var points:Vector.<Vector2D>;
		
		public function Polygon( numEdges:uint ) {
			edges = new Vector.<Vector2D>( numEdges );
			points = new Vector.<Vector2D>( numEdges );
			for( var i:uint = 0 ; i < numEdges ; i++ ) {
				edges[ i ] = new Vector2D();
				points[ i ] = new Vector2D();
			}
		}
		
		public function get x():Number { return __x; }
		public function get y():Number { return __y; }
		
		public function set x( newX:Number ):void {
			var diff:Number = newX - __x;
			__x = newX;
			edges.forEach( function callback(item:Vector2D, index:int, vector:Vector.<Vector2D>):void { item.x += diff; }, null );
			points.forEach( function callback(item:Vector2D, index:int, vector:Vector.<Vector2D>):void { item.x += diff; }, null );
		}
		
		public function set y( newY:Number ):void {
			var diff:Number = newY - __y;
			__y = newY;
			edges.forEach( function callback(item:Vector2D, index:int, vector:Vector.<Vector2D>):void { item.y += diff; }, null );
			points.forEach( function callback(item:Vector2D, index:int, vector:Vector.<Vector2D>):void { item.y += diff; }, null );
		}
		
		public function constructFromEdges():void {
			points[ 0 ].x = edges[ 0 ].x;
			points[ 0 ].y = edges[ 0 ].y;
			for( var i:uint = 1 ; i < edges.length ; i++ ) {
				points[ i ].x = edges[ i ].x - edges[ i - 1 ].x;
				points[ i ].y = edges[ i ].y - edges[ i - 1 ].y;
			}
		}
		
		public function constructFromPoints():void {
			edges[ 0 ].x = points[ 0 ].x;
			edges[ 0 ].y = points[ 0 ].y;
			for( var i:uint = 1 ; i < points.length ; i++ ) {
				edges[ i ].x = edges[ i - 1 ].x + points[ i ].x;
				edges[ i ].y = edges[ i - 1 ].y + points[ i ].y;
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
			for( var i:uint = 0 ; i < points.length ; i++ ) {
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
			if( points.length > 0 ) {
				points.splice( 0, points.length );
			}
		}
		
		public function destroy():void {
			reset();
			edges = null;
			points = null;
		}
		
		private var __x:Number = 0;
		private var __y:Number = 0;
		
	}
}