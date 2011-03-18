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
 * 		{ text:"" }
 * 
 * 		param name		type		default
 * 		----------		----		-------
 * 		slotName		(String)	"slot"
 * 		slotTFName		(String)	"tf"
 * 		slotBGName		(String)	"bg"
 * 		optionName		(String)	"option"
 * 		optionTFName	(String)	"tf"
 * 		optionBGName	(String)	"bg"
 * 		rightCallback	(Function)	null
 * 		wrongCallback	(Function)	null
 * 		changeCallback	(Function)	null
 * 		
 * 		labelHover		(String)	"hover"
 * 		labelNormal		(String)	"normal"
 * 		labelRight		(String)	"right"
 * 		labelWrong		(String)	"wrong"
 * 
 * 		optionsExist	(Boolean)	false
 * 		noSlot			(Boolean)	false
 */

package toolbox {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class DropDownCreator {
		
		//public function DropDownCreator() {}
		
		public static function CreateFromMovieClip( mc:MovieClip, options:Array, params:Object = null ):void {
			var optionClass:Class;
			var dropdown:Object = { };
			var diffY:int;
			var i:uint;
			
			if( params == null ) { params = { }; }
			
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
			
			dropdown[ "optionsExist" ]		= params[ "optionsExist" ] as Boolean;
			dropdown[ "noSlot" ]			= params[ "noSlot" ] as Boolean;
			
			dropdown[ "mc" ] 				= mc;
			
			if( !(dropdown.optionsExist || dropdown.noSlot) ) {
				diffY = mc[ dropdown.optionName ].y - mc[ dropdown.slotName ].y;
			}
			
			// setup options
			for( i = 1 ; i <= options.length ; i++ ) {
				// only set text if the options already exist
				if( dropdown.optionsExist ) {
					mc[ dropdown.optionName + i ].tf.text = options[ (i-1) ].text;
				}
				// otherwise, create options and set text
				else {
					optionClass = getDefinitionByName( getQualifiedClassName( mc[ dropdown.optionName ] ) ) as Class;
					mc[ dropdown.optionName + i ] = new optionClass();
					mc[ dropdown.optionName + i ].y = mc[ dropdown.optionName ].y + ((i - 1) * diffY);
					mc[ dropdown.optionName + i ].tf.text = options[ (i - 1) ].text;
					mc.addChild( mc[ dropdown.optionName + i ] );
					mc[ dropdown.optionName ].visible = false;
				}
			}
			
			if( !dropdown.noSlot ) {
				mc[ dropdown.slotName ].addEventListener( MouseEvent.CLICK, mouseEvents );
				hideOptions( dropdown );
			}
			
			__registeredDropdowns.push( dropdown );
		}
		
		public static function RemoveRegisteredMovieClip( mc:MovieClip ):void {
			var dropdown:Object = findDropdown( mc, true );
			
			if( !dropdown.noSlot ) {
				dropdown.mc[ dropdown.slotName ].removeEventListener( MouseEvent.CLICK, mouseEvents );
			}
		}
		
		public static function RemoveAllDropDowns():void {
			
		}
		
		private static var __registeredDropdowns:Array = [];
		
		private static function mouseEvents( e:MouseEvent ):void {
			
		}
		
		private static function showOptions( dropdown:Object ):void {
			trace( "showOptions!" );
		}
		
		private static function hideOptions( dropdown:Object ):void {
			
		}
		
		private static function selectOption( dropdown:Object, optionNum:int ):void {
			
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
/*


		private var __currentDD:MovieClip;
		private var __numDDs:int = 1;
		private var __ddAnswers:Array = [];
		private var __ddNextFunc:Function;
		private var __ddOptions:Object;
		private var __ddMC:MovieClip;
		private var __ddMCButton:MovieClip;
		private var __ddPopup:Boolean = false;
		
		private function ddSetup( options:Object ):void {
			__ddOptions = options;
			
			ddCloseAll();
			//ddAddListeners();
		}
		
		private function ddCloseAll():void {
			var mc:MovieClip;
			for( var i:uint = 0 ; i < __ddOptions.dds.length ; i++ ) {
				mc = __ddOptions.dds[ i ];
				ddClose( mc );
			}
		}
		
		private function ddClose( mc:MovieClip ):void {
			var optionNum:int = 1;
			while( mc[ "option" + optionNum ] ) {
				mc[ "option" + optionNum ].visible = false;
				ButtonCreator.RemoveRegisteredMovieClip( mc[ "option" + optionNum ] );
				optionNum++;
			}
		}
		
		private function ddClicked( e:MouseEvent ):void {
			if( __currentDD ) { ddClosed( __currentDD ) };
			
			var mc:MovieClip = e.currentTarget as MovieClip;
			mc.parent.addChild( mc );
			var i:uint = 1;
			while( mc[ "option" + i ] && mc[ "option" + i ].optionText.text.length > 0 ) {
				mc[ "option" + i ].visible = true;
				if( !mc[ "option" + i ].disabled ) {
					ButtonCreator.CreateFromMovieClip( mc[ "option" + i ], ddOptionClicked, { passEvent:true, normalFunc:function( mcOption:MovieClip ):void { mcOption.chooser.gotoAndStop("normal"); }, hoverFunc:function( mcOption:MovieClip ):void { mcOption.chooser.gotoAndStop("hover"); } } );
				}
				i++;
			}
			__currentDD = mc;
		}
		
		private function ddClosed( mc:MovieClip ):void {
			ddClose( mc );
			
			if( mc.completed != true ) {
				ButtonCreator.CreateFromMovieClip( mc, ddClicked, { passEvent:true, normalFunc:function( mc:MovieClip ):void { mc.slot.chosen.gotoAndStop("normal"); }, hoverFunc:function( mc:MovieClip ):void { mc.slot.chosen.gotoAndStop("hover"); } } );
				//if( mc.slot.wrong && mc.slot.wrong == true ) { mc.slot.chosen.gotoAndStop("wrong"); }
			}
			__currentDD = null;
			
			if( __ddAnswers[ 0 ] && __ddAnswers[ 0 ].popup ) { 
				checkDD( __ddAnswers[ 0 ].mc, __ddAnswers[ 0 ].answer, __ddAnswers[ 0 ].popup );
			}
			else {
				allDDsFilled();
			}
		}
		
		private function ddOptionClicked( e:MouseEvent ):void {
			var mc:MovieClip = e.currentTarget as MovieClip;
			MovieClip(mc.parent).slot.slotText.text = mc.optionText.text;
			MovieClip(mc.parent).response = mc.response;
			e.stopPropagation();
			ddClosed( MovieClip(mc.parent) );
			if( __ddPopup && mc.chooser ) {
				mc.chooser.gotoAndStop( "wrong" );
				mc.disabled = true;
			}
		}
		
		private function allDDsFilled():void {
			var mc:MovieClip = __ddMC;
			
			if( __ddMCButton && __ddMCButton.visible ) { return; }
			var i:uint = 0;
			for( i = 0; i < __ddAnswers.length ;  i++ ) {
				if( __ddAnswers[ i ].mc.slot.slotText.text == "" ) {
					return;
				}
			}
			
			if( __ddMCButton ) {
				__ddMCButton.visible = true;
				ButtonCreator.CreateFromMovieClip( __ddMCButton, checkDDs, { normal:"N", hover:"H" } );
			}
		}
		
		private function checkDDs():void {
			var mc:MovieClip = __ddMC;
			
			var i:uint = 0;
			for( i = 0 ; i < __ddAnswers.length ; i++ ) {
				checkDD( __ddAnswers[ i ].mc, __ddAnswers[ i ].answer );
			}
			
			__ddMCButton.visible = false;
			
			
			var count:uint = 0;
			for( i = 0 ; i < __ddAnswers.length ; i++ ) {
				if( mc ) {
					ButtonCreator.RemoveRegisteredMovieClip( mc[ __ddAnswers[ i ].mc ] );
				}
				if( __ddAnswers[ i ].mc.slot.slotText.text == "" ) {
					//return;
				}
				else {
					count++;
				}
			}
			
			if( count != __numDDs ) {
				trace( "count != __numDDs", count, __numDDs );
				ButtonCreator.CreateFromMovieClip( __ddMCButton, checkDDs );
				hideWrong();
				return;
			}
			
			trace( "__ddNextFunc()" );
			__ddNextFunc();
		}
		
		private function checkDD( mc:MovieClip, correct:String, popup:String = "false" ):void {
			var popupMC:MovieClip;
			if( correct == "" || mc.slot.slotText.text == correct ) {
				mc.correct = true;
				if( popup == "true" ) {
					popupMC = __screen.right;
					popupMC.correct = true;
					popupMC.rightBox.feedbackText.htmlText = mc.response;
				}
				ButtonCreator.RemoveRegisteredMovieClip( mc );
			}
			else {
				if( popup == "true" ) {
					popupMC = __screen.wrong;
					popupMC.correct = false;
					popupMC.wrongBox.feedbackText.htmlText = mc.response;
				}
				var i:uint = 1;
				trace( "___CHECKDD___" );
				while( mc[ "option" + i ] ) {
					trace( "Option" + i );
					if( mc[ "option" + i ].optionText.text == mc.slot.slotText.text ) {
						mc[ "option" + i ].chooser.gotoAndStop( "wrong" );
						mc[ "option" + i ].disabled = true;
					}
					i++;
				}
				mc.slot.slotText.text = "";
				//mc.slot.chosen.gotoAndStop( "wrong" );
				//mc.slot.wrong = true;
			}
			
			if( popupMC ) {
				MovieClip( popupMC.parent ).addChild( popupMC );
				popupMC.visible = true;
				popupMC.gotoAndPlay( 1 );
				ButtonCreator.CreateFromMovieClip( popupMC.closeBtn, closePopup, { normal:"normal", hover:"hover", passMC:true } );
			}
		}
		
		private function closePopup( mc:MovieClip ):void {
			MovieClip(mc.parent).visible = false;
			MovieClip(mc.parent).gotoAndStop(1);
			if( MovieClip(mc.parent).correct ) {
				nextAction();
			}
		}
		
		private function hideWrong():void {
			var parent:MovieClip = __ddAnswers[ 0 ].mc.parent;
			for( var i:uint = 1 ; i < __ddAnswers.length ; i++ ) {
				if( __ddAnswers[ i ].mc.slot.slotText.text == "" ) {
					ButtonCreator.CreateFromMovieClip( __ddAnswers[ i ].mc, ddClicked, { passEvent:true } );
				}
			}
		}
*/