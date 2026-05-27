List<String> userIds = new List<String>();
List<String> traceFlagIds = new List<String>();
String debugLevelId = '';

	//SOQL Query to get User by Name = SELECT FirstName,Id,LastName FROM User WHERE LastName = 'userLastName'

	/*API Call to get debug Levels in current environment
		   HttpRequest req = new HttpRequest();
		   Map<String, String> debugLevels = new Map<String, String>();
		   String developerName = '';
		   String debugLevelId = '';
		   req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID()); //Get user Session ID
		   req.setHeader('Content-Type', 'application/json');
		   req.setMethod('GET');
		   String SFdomainUrl=URL.getOrgDomainURL().toExternalForm();
		   string query='Select+DeveloperName,ID+from+DebugLevel';

		   req.setEndpoint(SFdomainUrl+'/services/data/v44.0/tooling/query/?q='+query);

		   Http h = new Http();
		   HttpResponse response = h.send(req);
		   //system.debug(response.getBody()); 
		   JSONParser parser = JSON.createParser(response.getBody());
		   //Loop through parser to get various value strings from the response body.
		   while (parser.nextToken() != null) {
				  if(String.valueOf(parser.getCurrentName()) == 'DeveloperName'  && String.valueOf(parser.getCurrentToken()) == 'VALUE_STRING'){
						 developerName = parser.getText();
				  }
				  if(String.valueOf(parser.getCurrentName()) == 'Id'  && String.valueOf(parser.getCurrentToken()) == 'VALUE_STRING'){
						 debugLevelId = parser.getText();
						 debugLevels.put(developerName, debugLevelId);
						 developerName = '';
						 debugLevelId = '';
				  }
              
				  //System.debug('Current Name is: ' + parser.getCurrentName() + ' Token is: ' + parser.getCurrentToken() + ' Token value is: ' + parser.getText());
		   }
		   System.debug(debugLevels); 

	*/

	//Only one debug level Id can be uncommented at a time, but you can add as many users to the userIds as you would like.

	//Prod values have not been captured yet.  Only left placeholders for when the values are populated.
	//Prod Values

		   //Debug Level IDs

				  //debugLevelId = '7dl2A0000000144QAA'    //workflow



		   //UserIds
				  //userIds.add('0052A000009Y17rQAC');//John


	//Dev1 Values

		   //Debug Level IDs                                      
				  debugLevelId = '7dlg5000001JyW9AAK';     //SFDC_DevConsole    
				  //debugLevelId = '7dlq0000000088NAAQ';   //TheWelkinSuite_005q0000005ZpRdAAK                           

		   //UserIds
				  userIds.add('005g5000007R1GvAAK');//John


	//Loop through users 
	for(String userId: userIds){
		   //First get any active debug logs
		   HttpRequest req = new HttpRequest();
		   req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID()); //Get user Session ID
		   req.setHeader('Content-Type', 'application/json');
		   req.setMethod('GET');
		   String SFdomainUrl=URL.getOrgDomainURL().toExternalForm();
       
		   string query='Select+ExpirationDate,TracedEntityId,ID+from+TraceFlag+WHERE+TracedEntityId+=+\''+userId+'\'';

		   req.setEndpoint(SFdomainUrl+'/services/data/v44.0/tooling/query/?q='+query);

		   Http h = new Http();
		   HttpResponse response = h.send(req);
		   system.debug(response.getBody()); 
		   JSONParser parser = JSON.createParser(response.getBody());
		   //Loop through parser to get various value strings from the response body.
		   while (parser.nextToken() != null) {
				  if((parser.getCurrentName()=='Id')  && String.valueOf(parser.getCurrentToken()) == 'VALUE_STRING'){
						 traceFlagIds.add(parser.getText());
						 System.debug(parser.getText());
						 //System.debug('Current Name is: ' + parser.getCurrentName() + ' Token is: ' + parser.getCurrentToken() + ' Token value is: ' + parser.getText());
				  }      
		   }

		   //Delete any existing trace flags for the user so that we do not have to worry about overlapping traces.
		   for(String debugLogId: traceFlagIds){
				  req.setMethod('DELETE');
				 req.setEndpoint(SFdomainUrl+'/services/data/v45.0/tooling/sobjects/TraceFlag/'+debugLogId+'/');
				  response = h.send(req);
				  system.debug(response.getBody()); 
		   }

		   //Create the new debug log
		   String payLoad = '{"DebugLevelId":"'+debugLevelId+'","StartDate":"'+String.valueOf(System.now().dateGmt())+'T'+String.valueOf(System.now().timeGmt())+'","ExpirationDate":"'+String.valueOf(System.now().addDays(1).dateGmt())+'T'+String.valueOf(System.now().addDays(1).timeGmt())+'","LogType":"USER_DEBUG","TracedEntityId":"'+userId+'"}';
		   req.setBody(payLoad);
		   req.setEndpoint(SFdomainUrl+'/services/data/v45.0/tooling/sobjects/TraceFlag/');
		   req.setMethod('POST');
       
		   response = h.send(req);
		   system.debug(response.getBody()); 
	}
