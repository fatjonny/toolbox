/*
 * 
 * 		elements of a dropdown MovieClip
 * 		--------------------------------
 * 		slot:		MovieClip that displays current selection
 * 					* tf: Textfield to fill in current selection text
 * 					* bg: MovieClip with frames for state (wrong, right, normal, hover)
 * 		option:		MovieClips that display possible options
 * 					* tf: TextField with option text
 * 					* bg: MovieClip with frames for state (normal, hover, wrong)
 * 
 * 		options array element
 * 		---------------------
 * 		{ text:"", correct:false }
 * 
 * 		param name		type		default
 * 		----------		----		-------
 * 		slotName		(String)	"slot"
 * 		slotTFName		(String)	"tf"
 * 		slotBGName		(String)	"bg"
 * 		optionName		(String)	"option"
 * 		optionTFName	(String)	"tf"
 * 		optionBGName	(String)	"bg"
 * 
 * 		rightCallback	(Function)	null
 * 		wrongCallback	(Function)	null
 * 		changeCallback	(Function)	null
 * 		openCallback	(Function)	null
 * 		
 * 		labelHover		(String)	"hover"
 * 		labelNormal		(String)	"normal"
 * 		labelRight		(String)	"right"
 * 		labelWrong		(String)	"wrong"
 * 
 * 		optionsExist	(Boolean)	false
 * 		noSlot			(Boolean)	false
 * 		showCorrect		(Boolean)	true
 * 		immediateAnswer	(Boolean)	false
 * 		closeOthers		(Boolean)	true
 * 		clearSlot		(Boolean)	true
 */

package toolbox {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class DropDownCreator {
		
		//public function DropDownCreator() {}
		
		public static function CreateFromMovieClip( mc:MovieClip, options:Array, params:Object = null ):void {
			var optionSelect:Function;
			var slotSelect:Function;
			var optionClass:Class;
			var dropdown:Object = { open:false };
			var diffY:int;
			var i:uint;
			
			if( params == null ) { params = { }; }
			
			dropdown[ "options" ]			= options;
			
			dropdown[ "slotName" ] 			= params[ "slotName" ] || "slot";
			dropdown[ "slotTFName" ] 		= params[ "slotTFName" ] || "tf";
			dropdown[ "slotBGName" ] 		= params[ "slotBGName" ] || "bg";
			dropdown[ "optionName" ] 		= params[ "optionName" ] || "option";
			dropdown[ "optionTFName" ] 		= params[ "optionTFName" ] || "tf";
			dropdown[ "optionBGName" ] 		= params[ "optionBGName" ] || "bg";
			
			dropdown[ "rightCallback" ]		= params[ "rightCallback" ] as Function;
			dropdown[ "changeCallback" ]	= params[ "changeCallback" ] as Function;
			
			dropdown[ "labelHover" ]		= params[ "labelHover" ] || "hover";
			dropdown[ "labelNormal" ] 		= params[ "labelNormal" ] || "normal";
			dropdown[ "labelRight" ]		= params[ "labelRight" ] || "right";
			dropdown[ "labelWrong" ]		= params[ "labelWrong" ] || "wrong";
			
			if( params[ "optionsExist" ] != null ) {	dropdown[ "optionsExist" ]		= params[ "optionsExist" ] as Boolean; }
			else {										dropdown[ "optionsExist" ]		= false; }
			if( params[ "noSlot" ] != null ) {			dropdown[ "noSlot" ]			= params[ "noSlot" ] as Boolean; }
			else { 										dropdown[ "noSlot" ]			= false; }
			if( params[ "showCorrect" ] != null ) {		dropdown[ "showCorrect" ]		= params[ "showCorrect" ] as Boolean; }
			else {										dropdown[ "showCorrect" ]		= true;	}
			if( params[ "immediateAnswer" ] != null ) {	dropdown[ "immediateAnswer" ]	= params[ "immediateAnswer" ] as Boolean; }
			else {										dropdown[ "immediateAnswer" ]	= false; }
			if( params[ "closeOthers" ] != null ) { 	dropdown[ "closeOthers" ]		= params[ "closeOthers" ] as Boolean; }
			else {										dropdown[ "closeOthers" ]		= true; }
			if( params[ "clearSlot" ] != null ) {		dropdown[ "clearSlot" ]			= params[ "clearSlot" ] as Boolean; }
			else {										dropdown[ "clearSlot" ]			= true; }
			
			dropdown[ "mc" ] 				= mc;
			
			if( !(dropdown.optionsExist || dropdown.noSlot) ) {
				diffY = mc[ dropdown.optionName ].y - mc[ dropdown.slotName ].y;
				mc[ dropdown.optionName ].visible = false;
			}
			
			// setup options
			optionSelect = function( dropdown:Object, i:uint ):Function {
				return function():void { selectOption( dropdown, i ); };
			}
			slotSelect = function( dropdown:Object ):Function {
				return function():void { showOptions( dropdown ); };
			}
			
			for( i = 1 ; i <= options.length ; i++ ) {
				
				if( !dropdown.optionsExist ) {
					optionClass = getDefinitionByName( getQualifiedClassName( mc[ dropdown.optionName ] ) ) as Class;
					mc[ dropdown.optionName + i ] = new optionClass();
					mc[ dropdown.optionName + i ].y = mc[ dropdown.optionName ].y + ((i - 1) * diffY);
					mc.addChild( mc[ dropdown.optionName + i ] );
				}
				
				mc[ dropdown.optionName + i ].tf.text = options[ (i - 1) ].text;
				ButtonCreator.CreateFromMovieClip( dropdown.mc[ dropdown.optionName + i ], optionSelect(dropdown, i), { normalFunc:buttonFunc( mc[ dropdown.optionName + i ], dropdown.optionBGName, dropdown.labelNormal ), hoverFunc:buttonFunc( dropdown.mc[ dropdown.optionName + i ], dropdown.optionBGName, dropdown.labelHover ), persist:true } );
			}
			
			if( !dropdown.noSlot ) {
				ButtonCreator.CreateFromMovieClip( mc[ dropdown.slotName ], slotSelect(dropdown), { normalFunc:buttonFunc( dropdown.mc[ dropdown.slotName ], dropdown.slotBGName, dropdown.labelNormal ), hoverFunc:buttonFunc( dropdown.mc[ dropdown.slotName ], dropdown.slotBGName, dropdown.labelHover ) } );
				hideOptions( dropdown );
				if( dropdown.clearSlot ) {
					mc[ dropdown.slotName ][ dropdown.slotTFName ].text = "";
				}
			}
			
			__registeredDropdowns.push( dropdown );
		}
		
		public static function RemoveRegisteredMovieClip( mc:MovieClip ):void {
			var dropdown:Object = findDropdown( mc, true );
			var i:uint;
			
			if( !dropdown.noSlot ) {
				ButtonCreator.RemoveRegisteredMovieClip( dropdown.mc[ dropdown.slotName ] );
			}
			
			for( i = 1 ; i <= dropdown.options.length ; i++ ) {
				ButtonCreator.RemoveRegisteredMovieClip( dropdown.mc[ dropdown.optionName + i ] );
			}
		}
		
		public static function Validate( mc:MovieClip ):void {
			var dropdown:Object = findDropdown( mc, false );
			
			if( dropdown.showCorrect ) {
				ButtonCreator.RemoveRegisteredMovieClip( dropdown.mc[ dropdown.optionName + dropdown.currentOption ] );
				if( dropdown.status == "right" ) {
					dropdown.mc[ dropdown.optionName + dropdown.currentOption ][ dropdown.optionBGName ].gotoAndStop( dropdown.labelRight );
					if( !dropdown.noSlot ) {
						dropdown.mc[ dropdown.slotName ][ dropdown.slotBGName ].gotoAndStop( dropdown.labelRight );
					}
				}
				else {
					dropdown.mc[ dropdown.optionName + dropdown.currentOption ][ dropdown.optionBGName ].gotoAndStop( dropdown.labelWrong );
					if( !dropdown.noSlot ) {
						dropdown.mc[ dropdown.slotName ][ dropdown.slotBGName ].gotoAndStop( dropdown.labelWrong );
						ButtonCreator.RemoveRegisteredMovieClip( dropdown.mc[ dropdown.slotName ] );
						ButtonCreator.CreateFromMovieClip( dropdown.mc[ dropdown.slotName ], function():void { showOptions( dropdown ); }, { normalFunc:buttonFunc( dropdown.mc[ dropdown.slotName ], dropdown.slotBGName, dropdown.labelWrong ), hoverFunc:buttonFunc( dropdown.mc[ dropdown.slotName ], dropdown.slotBGName, dropdown.labelHover ) } );
					}
				}
			}
			
			if( !dropdown.noSlot ) {
				if( dropdown.status == "right" ) {
					ButtonCreator.RemoveRegisteredMovieClip( dropdown.mc[ dropdown.slotName ] );
				}
				else {
					dropdown.mc[ dropdown.slotName ][ dropdown.slotTFName ].text = "";
					dropdown.currentOption = null;
				}
			}
		}
		
		public static function GetDropdownStatus( mc:MovieClip ):Object {
			var dropdown:Object = findDropdown( mc, false );
			return dropdown.status;
		}
		
		public static function RemoveAllDropDowns():void {
			while( __registeredDropdowns.length ) {
				RemoveRegisteredMovieClip( __registeredDropdowns[ 0 ].mc );
			}
		}
		
		private static var __registeredDropdowns:Array = [];
		
		private static function showOptions( dropdown:Object ):void {
			var i:uint;
			for( i = 1 ; i <= dropdown.options.length ; i++ ) {
				dropdown.mc[ dropdown.optionName + i ].visible = true;
			}
			
			if( !dropdown.noSlot ) {
				for( i = 0 ; i < __registeredDropdowns.length ; i++ ) {
					if( __registeredDropdowns[ i ].open ) {
						hideOptions( __registeredDropdowns[ i ] );
					}
				}
				dropdown.open = true;
			}
		}
		
		private static function hideOptions( dropdown:Object ):void {
			var i:uint;
			var clickFunc:Function;
			for( i = 1 ; i <= dropdown.options.length ; i++ ) {
				dropdown.mc[ dropdown.optionName + i ].visible = false;
			}
			
			dropdown.open = false;
			ButtonCreator.CreateFromMovieClip( dropdown.mc[ dropdown.slotName ], function():void { showOptions( dropdown ); }, { normalFunc:buttonFunc( dropdown.mc[ dropdown.slotName ], dropdown.slotBGName, dropdown.labelNormal ), hoverFunc:buttonFunc( dropdown.mc[ dropdown.slotName ], dropdown.slotBGName, dropdown.labelHover ) } );
		}
		
		private static function selectOption( dropdown:Object, optionNum:int ):void {
			
			dropdown.currentOption = optionNum;
			dropdown.status = "wrong";
			if( dropdown.options[ optionNum - 1 ].correct ) {
				dropdown.status = "right";
			}
			
			if( !dropdown.noSlot ) {
				hideOptions( dropdown );
				dropdown.mc[ dropdown.slotName ][ dropdown.slotTFName ].text = dropdown.mc[ dropdown.optionName + optionNum ][ dropdown.optionTFName ].text;
			}
			
			if( dropdown.immediateAnswer ) {
				Validate( dropdown.mc );
			}
			
			if( dropdown.changeCallback ) { dropdown.changeCallback( dropdown.mc, dropdown.currentOption ); }
			
			if( dropdown.status == "right" ) {
				if( dropdown.rightCallback ) { dropdown.rightCallback( dropdown.mc, dropdown.currentOption ); }
			}
			else {
				if( dropdown.wrongCallback ) { dropdown.wrongCallback( dropdown.mc, dropdown.currentOption ); }
			}
		}
		
		private static function buttonFunc( mc:MovieClip, bgName:String, label:String ):Function {
			return function():void { mc[ bgName ].gotoAndStop( label ); };
		}
		
		private static function findDropdown( mc:MovieClip, forceRemove:Boolean ):Object {
			var i:uint;
			var dropdown:Object;
			var numDropdowns:uint = __registeredDropdowns.length;
			
			for( i = 0 ; i < numDropdowns ; i++ ) {
				if( __registeredDropdowns[ i ].mc == mc ) {
					dropdown = __registeredDropdowns[ i ];
					if( forceRemove ) {
						__registeredDropdowns.splice( i, 1 );
					}
					return dropdown;
				}
			}
			
			return null;
		}
	}
}
