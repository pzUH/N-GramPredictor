package 
{
	/*a simple demonstration of the nGram predictor class
	 * */
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import com.pzuh.ai.ngram.*;
	
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			var nGram:nGramPredictor = new nGramPredictor(3, 100);
			
			nGram.addData("R", "S", "S", "P", "S", "P", "S", "P", "S", "P");			
			
			var action:String= nGram.getNextAction() as String;
			
			trace("Predicted Action: " + action);
			
			trace("");
			trace("========================================");
			trace("");
			
			nGram.addData("S");
			
			action = nGram.getNextAction() as String;
			
			trace("Predicted Action: " + action);
			
			trace("");
			trace("========================================");
			trace("");
		}		
	}	
}