/*
 * 
 */

package toolbox
{
	public class Report {
		public static function log( msg:String ):void {
			trace( msg );
		}
		
		public static function warn( msg:String ):void {
			trace( "WARN:", msg );
		}
		
		public static function error( msg:String ):void {
			throw new Error( msg );
		}
	}
}