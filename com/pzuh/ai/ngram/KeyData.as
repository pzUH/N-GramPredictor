package com.pzuh.ai.ngram
{
	
	public class KeyData 
	{
		private var key:Array;
		private var count:int;
		
		public function KeyData(key:Array, count:int) 
		{
			this.key = key;
			this.count = count;
		}	
		
		public function increaseCount():void
		{
			count += 1;
		}
		
		public function removeSelf():void
		{
			for (var i:int = key.length - 1; i > 0; i--)
			{
				key.splice(i, 1);
			}
			
			key.length = 0;
			key = null;
		}
		
		public function getKey():Array
		{
			return key;
		}
		
		public function getCount():int
		{
			return count;
		}
	}
}