/*
 * 
 */

package toolbox {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class DropDownCreator extends MovieClip {
		
		public function DropDownCreator( options:Array ) {
			__options = options;
			__background = new MovieClip();
			__listBackground = new MovieClip();
			build();
		}
		
		private var __options:Array;
		private var __elements:Array = [];
		private var __background:MovieClip;
		private var __listBackground:MovieClip;
		
		private function build():void {
			__background.graphics.clear();
			__listBackground.graphics.clear();
			var i:uint = 0;
			var maxWidth:Number = 0;
			var totalHeight:Number = 0;
			for( i = 0 ; i < __options.length ; i++ ) {
				__elements.push( TextHelper.displayText( __options[ i ], "option" + i, 14, 0, 0, 150 ) );
			}
			for( i = 0 ; i < __elements.length ; i++ ) {
				if( __elements[ i ].width > maxWidth ) {
					maxWidth = __elements[ i ].width;
				}
				totalHeight += __elements[ i ].height;
			}
			
			__listBackground.graphics.beginFill( 0xA5A5A5 );
			__listBackground.graphics.drawRect( 0, 0, maxWidth + 10, totalHeight + 10 );
			__listBackground.graphics.endFill();
			
			__background.graphics.beginFill( 0xA5A5A5, 0 );
			__background.graphics.drawRect( 0, 0, maxWidth + 10, __elements[ 0 ].height );
			
			var curHeight:Number = 5;
			for( i = 0 ; i < __elements.length ; i++ ) {
				curHeight += __elements[ i ].height;
				__elements[ i ].y += curHeight;
				__elements[ i ].x = 5;
				__listBackground.addChild( __elements[ i ] );
			}
			
			this.addChild( __listBackground );
		}
	}
}



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