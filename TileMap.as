/*
 * Critical assumptions made about map format:
 * Tile num is always sorted in ascending order
 * 
 * Sample Map:
 * <?xml version="1.0" ?>
 * <map>
 *  <settings tilesWide="2" tilesHigh="2" tileWidth="50" tileHeight="50" tilePrefix="tile_" />
 *  <tile num="2" name="grass1" />
 *  <tile num="4" name="tree1" />
 * </map>
 */

package toolbox {
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	
	public class TileMap {
		
		public function TileMap() { __internalPoint = new Point();  }
		
		public function load( mapXML:XML, applicationDomain:ApplicationDomain ):void {
			// clear or initialize
			clearOrInitTileClassesArray();
			clearOrInitTilesArray();
			
			__domain = applicationDomain;
			__XML = mapXML;
			
			// grab the map settings
			__tilesWide = __XML.settings.@tilesWide;
			__tilesHigh = __XML.settings.@tilesHigh;
			__tileWidth = __XML.settings.@tileWidth;
			__tileHeight = __XML.settings.@tileHeight;
			__tilePrefix = __XML.settings.@tilePrefix;
			
			// calculate other settings
			__width = __tileWidth * __tilesWide;
			__height = __tileHeight * __tilesHigh;
			
			// loop through all tiles
			var lastInsert:uint = 0;
			var numAttributes:int = 0;
			for each (var tileXML:XML in __XML.tile) {
				// add tile class to tileClasses array if it isn't already there
                findTileClassOrInsert( tileXML.@name );
				
				// add empty string for tiles that don't exist in this tilemap
				while( lastInsert != (tileXML.@num - 1) ) {
					__tiles.push( "" );
					lastInsert++;
				}
				
				// create a tile object and add all of the XML tile attributes to it
				var tile:Object = { name:"", num:"" };
				var attrName:String = "";
				numAttributes = tileXML.attributes().length();
				for ( var i:uint = 0 ; i < numAttributes ; i++ ) {
					attrName = tileXML.attributes()[ i ].name();
					tile[ attrName ] = tileXML.attributes()[ i ];
				}
				
				__tiles.push( tile );
				
				lastInsert++;
            }
		}
		
		public function loadArray( objects:Array, attribute:String ):void {
			var numTiles:uint = __tiles.length;
			
			for( var i:uint = 0 ; i < numTiles ; i++ ) {
				if( __tiles[ i ][ attribute ] ) {
					// sets __internalPoint
					convertTileNumToXY( i );
					objects.push( { name:__tiles[ i ][ attribute ], tile:(i+1), x:__internalPoint.x, y:__internalPoint.y } );
					trace( "loadArray", i, attribute, __tiles[ i ][ attribute ], __internalPoint.x, __internalPoint.y );
				}
			}
		}
		
		// assumes that mapBitmap is lock()ed and will be unlock()ed sometime afterwards
		public function draw( mapBitmapData:BitmapData, mapX:int, mapY:int, width:int = 0, height:int = 0, offsetX:int = 0, offsetY:int = 0 ):void {
			
			// if no width, default to bitmap data width
			if( width == 0 ) {
				width = mapBitmapData.width;
			}
			
			if( width > mapBitmapData.width ) {
				width = mapBitmapData.width;
			}
			
			// if no height, default to bitmap data height
			if( height == 0 ) {
				height = mapBitmapData.height;
			}
			
			if( height > mapBitmapData.height ) {
				height = mapBitmapData.height;
			}
			
			var x:int = 0;
			var y:int = 0;
			var colCount:int = 0;
			var rowCount:int = 0;
			var tileToFind:int = 0;
			var tileName:String;
			
			// store the x & y offset into the tile
			var offset:Object = { x:0, y:0 };
			var tileNum:int = convertXYToTileNum( mapX, mapY, offset );
			
			offsetX += -1 * offset.x;
			offsetY += -1 * offset.y;
			
			// loop through rows
			while( offsetY + y < height ) {
				x = 0;
				colCount = 0;
				// loop through columns
				while ( x < width ) {
					// find tile
					tileToFind = tileNum + colCount + (rowCount * __tilesWide) + 1;
					//trace( "tileToFind", tileToFind );
					if( tileToFind > (__tilesWide * __tilesHigh) || (offsetX + x >= __width) ) {
						break;
					}
					tileName = __tiles[ (tileToFind-1) ][ "name" ];
					
					// if the tile is in the tilemap
					if ( tileName != "" ) {
						// draw tile
						mapBitmapData.draw( __tileClasses[ findTileClassNum( tileName ) ].bitmapData, 
											new Matrix( 1, 0, 0, 1, offsetX + x, offsetY + y ) );
					}
					
					// go to next column
					x += __tileWidth;
					colCount++;
				}
				// go to next row
				y += __tileHeight;
				rowCount++;
			}
		}
		
		public function getTileAttributes( mapX:int, mapY:int ):Object {
			// return the attributes object of the tile at X, Y
			return __tiles[ convertXYToTileNum( mapX, mapY ) ];
		}
		
		public function destroy():void {
			clearOrInitTileClassesArray();
			clearOrInitTilesArray();
			__domain = null;
			__XML = null;
		}
		
		public function get tileWidth():int		{ return __tileWidth; }
		public function get tileHeight():int	{ return __tileHeight; }
		public function get tilesWide():int		{ return __tilesWide; }
		public function get tilesHigh():int		{ return __tilesHigh; }
		
		public function get tilePrefix():String { return __tilePrefix; }
		
		// settings
		private var __tileWidth:int;
		private var __tileHeight:int;
		private var __tilesHigh:int;
		private var __tilesWide:int;
		private var __width:uint;
		private var __height:uint;
		private var __tilePrefix:String;
		
		// data
		private var __tileClasses:Array;
		private var __tiles:Array;
		private var __domain:ApplicationDomain;
		private var __XML:XML;
		
		private var __internalPoint:Point;
		
		private function convertXYToTileNum( x:int, y:int, offset:Object = null ):int {
			
			// ensure x,y are in the map
			if( x > __width || y > __height ) {
				throw new Error( "x{" + x + "} > __width{" + __width + "} or y{" + y + "} > __height{" + __height + "}" );
			}
			if( x < 0 || y < 0 ) {
				throw new Error( "x{" + x + "} < 0 or y{" + y + "} < 0" );
			}
			
			// get column and row
			var tileColumn:int = x / __tileWidth;
			var tileRow:int = y / __tileHeight;
			
			if ( offset != null ) {
				// get remainder if requested
				offset.x = x - (tileColumn * __tileWidth);
				offset.y = y - (tileRow * __tileHeight);
			}
			
			// calculate tile number
			return (tileRow * __tilesWide) + tileColumn;
		}
		
		// uses __internalPoint to avoid creating a new point every call
		private function convertTileNumToXY( tileNum:int ):void {
			var height:int = int(tileNum / __tilesWide);
			__internalPoint.x = (tileNum - (height * __tilesWide)) * __tileWidth;
			__internalPoint.y = height * __tileHeight;
		}
		
		private function clearOrInitTilesArray():void {
			// if the array exists and has content, empty it
			if( __tiles && __tiles.length > 0 ) {
				// clear the tile objects
				for( var i:uint = 0 ; i < __tiles.length ; i++ ) {
					__tiles[ i ] = null;
				}
				__tiles.splice( 0, __tiles.length );
			}
			// otherwise create a new array
			else {
				__tiles = new Array();
			}
		}
		
		private function clearOrInitTileClassesArray():void {
			// if the array exists and has content, empty it
			if( __tileClasses && __tileClasses.length > 0 ) {
				// clean up the bitmapData
				for( var i:uint = 0 ; i < __tileClasses.length ; i++ ) {
					__tileClasses[ i ].bitmapData.dispose();
					__tileClasses[ i ].bitmapData = null;
				}
				__tileClasses.splice( 0, __tileClasses.length );
			}
			// otherwise create a new array
			else {
				__tileClasses = new Array();
			}
		}
		
		private function findTileClassNum( tileName:String ):uint {
			var tilesLength:uint = __tileClasses.length;
			// loop through the tiles until a match is found
			for ( var i:uint = 0 ; i < tilesLength ; i++ ) {
				if ( __tileClasses[ i ].name == tileName ) {
					return i;
				}
			}
			// or no match
			return uint.MAX_VALUE;
		}
		
		private function findTileClassOrInsert( className:String ):int {
			// find the tile
			var tileNum:uint = findTileClassNum( className );
			// or insert
			if( tileNum == uint.MAX_VALUE ) {
				// draw the movieclip of the tile to a bitmapdata object
				var tileClass:Class = __domain.getDefinition( __tilePrefix + className  ) as Class;
				var tileMC:MovieClip = MovieClip( new tileClass );
				var data:BitmapData = new BitmapData( __tileWidth, __tileHeight );
				data.draw( tileMC );
				
				// insert
				var tileClassObject:Object = { name:className, bitmapData:data };
				__tileClasses.push( tileClassObject );
				tileNum = __tileClasses.length - 1;
			}
			return tileNum;
		}
	}
}