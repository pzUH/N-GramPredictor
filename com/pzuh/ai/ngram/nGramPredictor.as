package com.pzuh.ai.ngram
{
	import com.pzuh.Basic;
	
	public class nGramPredictor
	{
		private var data:Array = new Array();
		private var nLength:int;
		private var maxDataNum:int;	
		
		public function nGramPredictor(nLength:int = 4, maxDataNum:int = 1000)
		{
			if ((nLength < 1) || (maxDataNum < 1))
			{
				throw new Error("ERROR: Either nLength and maxData value must be no less than 1");
				return;
			}
			
			this.nLength = nLength;			
			this.maxDataNum = maxDataNum;
		}
		
		public function addSingleData(data:*):void
		{
			if (this.data.length + 1 > maxDataNum) 
			{
				this.data.shift();
			}
			
			this.data.push(data);
		}
		
		public function addMultipleData(data:Array):void
		{
			if (this.data.length + data.length > maxDataNum)
			{
				if (this.data.length < 1) 
				{
					data.splice(0, data.length - maxDataNum);
				}
				else
				{
					this.data.splice(0, data.length);
				}
			}
			
			this.data = this.data.concat(data);
		}
		
		private function generateNGram():Array
		{
			/*suppose we have this data and configuration:
			 * nLength: 3
			 * maxData: infinity
			 * data collected: RPSRPRPRR
			*/
			
			//array that holds extracted data
			var nGramList:Array = new Array();
			
			//array that holds unique data and its count/frequency of appearance (KeyData)
			var nGramFreq:Array = new Array();
			
			/*extract the data and store them to nGramList array
			 * example:
			 * the tempData array will store this data:
				 * RPS, PSR, SRP, RPR, PRP, RPR, PRR
			 * */
			var dataLength:int = data.length - (nLength - 1);
			
			for (var dataIndex:int = 0; dataIndex < dataLength; dataIndex++)
			{
				var tempData:Array = data.slice(dataIndex, dataIndex + nLength);				
				nGramList.push(tempData);
			}
			
			/*remove duplicate & store to a new array
			 * example:
			 * pretty clear, the tempArray will store this data:
				 * RPS, PSR, SRP, RPR, PRP, PRR
			 * RPR data which appear twice is ommited, so we have unique data
			 * */
			var tempArray:Array = Basic.getUniqueArray(nGramList, true);
			
			/* create new KeyData from tempArray and store them to nGramFreq array
			 * so we have a unique data with its count of appearance
			 * but we set count of all data with 0, it will processed later
			 * */
			var tempArrayLength:int = tempArray.length;
			
			for (var tempIndex:int = 0; tempIndex < tempArrayLength; tempIndex++)
			{
				nGramFreq.push(new KeyData(tempArray[tempIndex], 0));
			}
			
			/*count the frequency of each KeyData
			 * pretty straight forward, just compare data on both array, if the data is identical, 
			 * increase the count for its respective KeyData
			 * */
			var nGramFreqLength:int = nGramFreq.length;
			var nGramListLength:int = nGramList.length;
			
			for (var i:int = 0; i < nGramFreqLength; i++)
			{
				for (var j:int = 0; j < nGramListLength; j++)
				{
					if (nGramFreq[i].getKey().toString() == nGramList[j].toString())
					{
						nGramFreq[i].increaseCount();
					}
				}
			}			
			
			return nGramFreq;
		}
		
		public function getNextAction():*
		{
			/*suppose we have this data and configuration:
			 * nLength: 3
			 * maxData: infinity
			 * data collected: RPSRPRPRR
			*/
			
			var nGramArray:Array = new Array();
			var actionArray:Array = new Array();
			var bestAction:KeyData;
			var lastData:Array;
			
			//if collected data is smaller than its specified nLength, prediction is not possible, return null
			if (data.length < nLength)
			{
				return null;
			}
			
			nGramArray = generateNGram();
			
			/*get last data pattern
			 * example: 
				 * if collected data is: RPSRPRPRR, 
				 * thw last data is: RR
			*/
			lastData = data.slice(data.length - (nLength - 1));
			
			//insert matching pattern to actionArray
			var nGramLength:int = nGramArray.length;
			
			for (var i:int = 0; i < nGramLength; i++)
			{
				/*Array to holds each last data from the generated nGram sets
				 * example:
					* nGram sets:
					 * RPS count 1, 
					 * PSR count 1, 
					 * SRP count 1, 
					 * RPR count 2, 
					 * PRP count 1, 
					 * PRR count 1
					 * 
					 * lastData form nGram sets: RP, PS, SR, PR
				 * */
				var nGramArrayPattern:Array;				
				nGramArrayPattern = nGramArray[i].getKey().slice(0, nGramArray[i].getKey().length - 1);
				
				/*check whether lastData from nGram sets is match with the last data
				 * example:
					 * if last data is RR, all nGram sets which have lastData RR will stored to actionArray
				 * */
				if (nGramArrayPattern.toString() == lastData.toString())
				{
					actionArray.push(nGramArray[i]);
				}
			}
			
			//if got no matching pattern, prediction is not possible, return null
			if (actionArray.length <= 0)
			{
				return null;
			}
			
			/*get most frequent pattern from actionArray by its count
			 * example:
				* suppose we have this sets in actionArray:
				 * RRP count 4,
				 * RRS count 3,
				 * RRR count 1
				 * 
				 * it will return RRP as bestAction
			 * */
			for (var j:int = 0; j < actionArray.length; j++)
			{
				if (bestAction == null)
				{
					bestAction = actionArray[j];
				}
				else
				{
					if (bestAction.getCount() < actionArray[j].getCount())
					{
						bestAction = actionArray[j];
					}
					else if (bestAction.getCount() == actionArray[j].getCount())
					{
						//if we got sets with same count, just randomize it to get the selected sets
						var rand:int = Basic.generateRandomSign();
						
						if (rand < 0)
						{
							bestAction = actionArray[j];
						}
					}
				}
			}	
			
			//return the final predicted action
			var predictedAction:Array = new Array();
			predictedAction = bestAction.getKey().slice(bestAction.getKey().length - 1);
			
			return predictedAction[0];
		}
		
		public function removeSelf():void
		{
			for (var i:int = data.length - 1; i > 0; i--)
			{
				data.splice(i, 1);
			}
			
			data.length = 0;			
			data = null;
		}
		
		public function setNLength(nLength:int):void
		{
			if (nLength > 0)
			{
				this.nLength = nLength;
			}
		}
		
		public function setMaxDataNum(num:int):void
		{
			if (num > 0)
			{
				maxDataNum = num;
			}
		}
		
		public function getNLength():int
		{
			return nLength;
		}
		
		public function getMaxDataNum():int
		{
			return maxDataNum;
		}
	}
}