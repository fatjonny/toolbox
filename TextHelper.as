package toolbox 
{
	
	import flash.text.engine.*;
	import flash.display.MovieClip;
	
	/*
	 * 
	 */
	public class TextHelper
	{
		public static function displayText( text:String, mcName:String, fontSize:Number = 16, xPos:Number = 15, yPos:Number = 20, lineWidth:Number = 300, color:uint = 0x000000 ):MovieClip {
			var textMC:MovieClip = new MovieClip();
			
			var fontDescription:FontDescription = new FontDescription("Georgia");
			var format:ElementFormat = new ElementFormat(fontDescription);
			format.fontSize = fontSize;
			format.color = color;
			var textElement:TextElement = new TextElement( text, format );
			var textBlock:TextBlock = new TextBlock();
			textBlock.content = textElement;
			
			var textLine:TextLine = textBlock.createTextLine( null, lineWidth );
			while( textLine ) {
				textLine.x = xPos;
				textLine.y = yPos;
				yPos += textLine.height + 2;
				textMC.addChild( textLine );
				textLine = textBlock.createTextLine( textLine, lineWidth );
			}
			
			textMC.name = mcName;
			return textMC;
		}
	}

}