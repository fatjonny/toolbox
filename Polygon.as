/*
 * Assumptions:
 * 	This class currently supports only convex polygons!
 * 	When building: 0,0 is the rotation point (and the first point if setting edges first) and the 
 *  points are sequential around the edge of the polygon
 * TODO: add scale
 * TODO: test speed of forEach on vectors
 */

package toolbox {
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
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
			// loop through and update the points (vertices)
			points.forEach( function callback(item:Vector2D, index:int, vector:Vector.<Vector2D>):void { item.x += diff; }, null );
		}
		
		public function set y( newY:Number ):void {
			var diff:Number = newY - __y;
			__y = newY;
			// loop through and update the points (vertices)
			points.forEach( function callback(item:Vector2D, index:int, vector:Vector.<Vector2D>):void { item.y += diff; }, null );
		}
		
		// There are some problems with this function.
		// ie. the rotation point __x, __y is always going to be placed at the first point (__points[ 0 ])
		public function constructFromEdges():void {
			points[ 0 ].x = __x;
			points[ 0 ].y = __y;
			for( var i:uint = 1 ; i < edges.length ; i++ ) {
				points[ i ].x = points[ i - 1 ].x + edges[ i - 1 ].x;
				points[ i ].y = points[ i - 1 ].y + edges[ i - 1 ].y;
			}
		}
		
		// generates edges from the points (vertices)
		public function constructFromPoints():void {
			for( var i:uint = 0 ; i < points.length - 1 ; i++ ) {
				edges[ i ].x = points[ i + 1 ].x - points[ i ].x;
				edges[ i ].y = points[ i + 1 ].y - points[ i ].y;
			}
			edges[ points.length - 1 ].x = points[ 0 ].x - points[ points.length - 1 ].x;
			edges[ points.length - 1 ].y = points[ 0 ].y - points[ points.length - 1 ].y;
		}
		
		public function draw( sprite:Sprite, clear:Boolean = true, thickness:Number = 1, color:uint = 0xFFFFFF ):void {
			// clear any existing graphics
			if ( clear ) { sprite.graphics.clear(); }
			
			// go to our initial position
			sprite.graphics.moveTo( points[ 0 ].x, points[ 0 ].y );
			
			// set up drawing
			sprite.graphics.lineStyle( thickness, color );
			
			// draw the edges
			for( var i:uint = 1 ; i < points.length ; i++ ) {
				sprite.graphics.lineTo( points[ i ].x, points[ i ].y );
			}
			sprite.graphics.lineTo( points[ 0 ].x, points[ 0 ].y );
			sprite.graphics.lineStyle();
		}
		
		// rotates the polygon around it's rotation point
		public function rotate( radians:Number ):void {
			__mat.identity();
			__mat.translate( -1 * __x, -1 * __y );
			__mat.rotate( radians );
			__mat.translate( __x, __y );
			for( var i:uint = 0 ;  i < points.length ; i++ ) {
				__pt.x = points[ i ].x;
				__pt.y = points[ i ].y;
				__pt = __mat.transformPoint( __pt );
				points[ i ].x = __pt.x;
				points[ i ].y = __pt.y;
			}
			constructFromPoints();
		}
		
		public function reset():void {
			if( edges.length > 0 ) {
				edges.splice( 0, edges.length );
			}
			if( points.length > 0 ) {
				points.splice( 0, points.length );
			}
			__x = 0;
			__y = 0;
		}
		
		public function destroy():void {
			reset();
			edges = null;
			points = null;
			__mat = null;
			__pt = null;
		}
		
		private var __x:Number = 0;
		private var __y:Number = 0;
		// an effort to speed up rotations, create these only once
		private var __mat:Matrix = new Matrix();
		private var __pt:Point = new Point();
	}
}