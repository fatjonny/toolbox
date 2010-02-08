/*
 * Assumptions:
 * 	Convex polygons
 * 	All polygons fulfill edges.length == vectors.length
 * 	The optimized cases assume you pass in the correct polygons
 */

package toolbox {
		
	public class SATIntersection {	
		
		//public function SATIntersection() {}
		
		// general case
		public static function PolygonToPolygon( polyA:Polygon, polyB:Polygon ):Boolean {
			var polyANumEdges:uint = polyA.edges.length;
			var polyBNumEdges:uint = polyB.edges.length;
			var numTotalEdges:uint = polyANumEdges + polyBNumEdges;
			var min:Number;
			var max:Number;
			var dot:Number;
			
			var j:uint = 0;
			
			// for all edges
			for( var i:uint = 0 ; i < numTotalEdges ; i++ ) {
				// get separating axis
				if( i < polyANumEdges ) {
					__axis = Vector2D.Perpendicular(polyA.edges[ i ]).normalize();
				}
				else {
					__axis = Vector2D.Perpendicular(polyB.edges[ i - polyANumEdges ]).normalize();
				}
				
				// project all polyA vectors onto axis
				min = Number.MAX_VALUE;
				max = Number.MIN_VALUE;
				for( j = 0 ; j < polyANumEdges ; j++ ) {
					dot = Vector2D.DotProduct( polyA.vectors[ j ], __axis );
					if( dot < min ) { min = dot; }
					if( dot > max ) { max = dot; }
				}
				__polyAProjectionMax = max;
				__polyAProjectionMin = min;
				
				// project all polyB edges onto axis
				min = Number.MAX_VALUE;
				max = Number.MIN_VALUE;
				for( j = 0 ; j < polyBNumEdges ; j++ ) {
					dot = Vector2D.DotProduct( polyB.vectors[ j ], __axis );
					if( dot < min ) { min = dot; }
					if( dot > max ) { max = dot; }
				}
				__polyBProjectionMax = max;
				__polyBProjectionMin = min;
				
				// if the two projections don't overlap, no intersection
				if( __polyAProjectionMax < __polyBProjectionMin || __polyBProjectionMax < __polyAProjectionMin ) {
					return false;
				}
			}
			return true;
		}
		
		// optimized cases
		public static function RectangleToRectangle( polyA:Polygon, polyB:Polygon ):Vector2D {
			
		}
		
		public static function AABBToAABB( polyA:Polygon, polyB:Polygon ):Vector2D {
			
		}
		
		private static var __polyAProjectionMin:Number;
		private static var __polyAProjectionMax:Number;
		private static var __polyBProjectionMin:Number;
		private static var __polyBProjectionMax:Number;
		
		private static var __axis:Vector2D;
		
		private static function projectToAxis():void {
			
		}
	}
}