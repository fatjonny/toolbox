/*
 * Assumptions:
 * 	This class assumes convex polygons!
 * 	The optimized cases assume you pass in the correct polygons!
 */

package toolbox {
		
	public class SATCollision {
		
		//public function SATCollision() {}
		
		// general case
		public static function PolygonToPolygon( polyA:Polygon, polyB:Polygon ):Boolean {
			
			return true;
		}
		
		// optimized cases
		public static function RectangleToRectangle( polyA:Polygon, polyB:Polygon ):Vector2D {
			
		}
		
		public static function AABBToAABB( polyA:Polygon, polyB:Polygon ):Vector2D {
			
		}
	}
}