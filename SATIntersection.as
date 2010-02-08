/*
 * Assumptions:
 * 	Convex polygons
 * 	All polygons fulfill edges.length == vectors.length
 * 	The optimized cases assume you pass in the correct polygons
 */

package toolbox {
		
	public class SATCollision {	
		
		//public function SATCollision() {}
		
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
		
		/* 
class Polygon:
	def __init__(self, points):
		"""points is a list of Vectors"""
		self.points = points
		
		# Build a list of the edge vectors
		self.edges = []
		for i in range(len(points)): # equal to Java's for(int i=0; i<points.length; i++)
			point = points[i]
			next_point = points[(i+1)%len(points)]
			self.edges.append(next_point - point)
	def project_to_axis(self, axis):
		"""axis is the unit vector (vector of magnitude 1) to project the polygon onto"""
		projected_points = []
		for point in self.points:
			# Project point onto axis using the dot operator
			projected_points.append(point.dot(axis))
		return Projection(min(projected_points), max(projected_points))
	def intersects(self, other):
		"""returns whether or not two polygons intersect"""
		# Create a list of both polygons' edges
		edges = []
		edges.extend(self.edges)
		edges.extend(other.edges)
		
		for edge in edges:
			axis = edge.normalize().perpendicular() # Create the separating axis (see diagrams)
			
			# Project each to the axis
			self_projection = self.project_to_axis(axis)
			other_projection = other.project_to_axis(axis)
			
			# If the projections don't intersect, the polygons don't intersect
			if not self_projection.intersects(other_projection):
				return False
		
		# The projections intersect on all axes, so the polygons are intersecting
		return True
		
class Projection:
	"""A projection (1d line segment)"""
	def __init__(self, min, max):
		self.min, self.max = min, max
	def intersects(self, other):
		"""returns whether or not self and other intersect"""
		return self.max > other.min and other.max > self.min
		*/
		
		
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