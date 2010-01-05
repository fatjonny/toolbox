/*
 *
 */

package toolbox {
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	
	public class TileMap {
		
		public function TileMap() {
			
		}
		
		public function load( mapXML:XML, applicationDomain:ApplicationDomain ):void {
			clearTilesArray();
			
			__tileNames = new Array();
			
			__domain = applicationDomain;
			__XML = mapXML;
			
			// grab the map settings
			__tilesWide = __XML.settings.@tilesWide;
			__tilesHigh = __XML.settings.@tilesHigh;
			__tileWidth = __XML.settings.@tileWidth;
			__tileHeight = __XML.settings.@tileHeight;
			
			// calculate other settings
			__width = __tileWidth * __tilesWide;
			__height = __tileHeight * __tilesHigh;
			
			// loop through all tiles
			for each (var tileXML:XML in __XML.tile) {
				// add tile to tiles array if it isn't already there
                findTileOrInsert( { name:tileXML.@name } );
				// TODO: fix this... must insert at tileXML.@num!
				__tileNames.push( tileXML.@name );
            }
		}
		
		public function draw( mapBitmapData:BitmapData, mapX:int, mapY:int, width:int = 0, height:int = 0, offsetX:int = 0, offsetY:int = 0 ):void {
			
			// if no width, default to bitmap data width
			if( width == 0 ) {
				width = mapBitmapData.width;
			}
			
			// if no height, default to bitmap data height
			if( height == 0 ) {
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
			
			// about to start drawing, lock the bitmap data
			mapBitmapData.lock();
			
			while( y < height ) {
				x = 0;
				colCount = 0;
				while ( x < width ) {
					tileToFind = tileNum + colCount + (rowCount * __tilesWide) + 1;
					tileName = __tileNames[ tileToFind ];
					mapBitmapData.draw( __tiles[ findTile( tileName ) ].bitmapData, 
										new Matrix( 1, 0, 0, 1, offsetX + x, offsetY + y ) );
					x += __tileWidth;
					colCount++;
				}
				y += __tileHeight;
				rowCount++;
			}
			
			// done drawing, unlock the bitmapdata
			mapBitmapData.unlock();
		}
		
		public function get tileWidth():int		{ return __tileWidth; }
		public function get tileHeight():int	{ return __tileHeight; }
		public function get tilesWide():int		{ return __tilesWide; }
		public function get tilesHigh():int		{ return __tilesHigh; }
		
		// settings
		private var __tileWidth:int;
		private var __tileHeight:int;
		private var __tilesHigh:int;
		private var __tilesWide:int;
		private var __width:uint;
		private var __height:uint;
		
		// data
		private var __tiles:Array;
		private var __tileNames:Array;
		private var __domain:ApplicationDomain;
		private var __XML:XML;
		
		private function convertXYToTileNum( x:int, y:int, offset:Object = null ):int {
			
			if( x > __width || y > __height ) {
				throw new Error( "x{" + x + "} > __width{" + __width + "} or y{" + y + "} > __height{" + __height + "}" );
			}
			if( x < 0 || y < 0 ) {
				throw new Error( "x{" + x + "} < 0 or y{" + y + "} < 0" );
			}
			
			var tileColumn:int = x / __tileWidth;
			var tileRow:int = y / __tileHeight;
			
			if ( offset != null ) {
				offset.x = x - (tileColumn * __tileWidth);
				offset.y = y - (tileRow * __tileHeight);
			}
			return (tileRow * __tilesWide) + tileColumn;
		}
		
		private function clearTilesArray():void {
			// if the array exists and has content, empty it
			if( __tiles && __tiles.length > 0 ) {
				// TODO: remove the bitmapData from each element of the array first?
				__tiles.splice( 0, __tiles.length );
			}
			// otherwise create a new array
			else {
				__tiles = new Array();
			}
		}
		
		private function findTile( tileName:String ):uint {
			var tilesLength:uint = __tiles.length;
			// loop through the tiles until a match is found
			for ( var i:uint = 0 ; i < tilesLength ; i++ ) {
				if ( __tiles[ i ].name == tileName ) {
					return i;
				}
			}
			// or no match
			return uint.MAX_VALUE;
		}
		
		private function findTileOrInsert( tileObject:Object ):int {
			// find the tile
			var tileNum:uint = findTile( tileObject.name );
			// or insert
			if( tileNum == uint.MAX_VALUE ) {
				__tiles.push( tileObject );
				tileNum = __tiles.length - 1;
				
				// draw the movieclip of the tile to a bitmapdata object
				var tileClass:Class = __domain.getDefinition( "tile_" + tileObject.name  ) as Class;
				var tileMC:MovieClip = MovieClip( new tileClass );
				var data:BitmapData = new BitmapData( __tileWidth, __tileHeight );
				data.draw( tileMC );
				__tiles[ tileNum ].bitmapData = data;
			}
			return tileNum;
		}
	}
	
}