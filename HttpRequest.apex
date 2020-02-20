HttpRequest req = new HttpRequest();
req.setEndpoint(System.URL.getSalesforceBaseURL().toExternalForm()+'/services/data/v45.0/sobjects');
req.setMethod('GET');
req.setHeader('Authorization', 'OAuth ' +UserInfo.getSessionId());
Http http = new Http();
HTTPResponse res = http.send(req);
//System.debug(res.getBody());
Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
List<Object> objects = (List<Object>)root.get('sobjects');
//System.debug(objects);
integer count=0;
Boolean check=false;
for (Object obj : objects) {
	Map<String, Object> i = (Map<String, Object>)obj;
	if((Boolean)i.get('queryable') && (Boolean)i.get('custom') && !(Boolean)i.get('customSetting') && (String.valueOf(i.get('name')) == 'Lost_Business__c' || check)){
		check=true;
		count++;
		if(count >98)
		{
			return;
		}
		HttpRequest req = new HttpRequest();
		req.setEndpoint(System.URL.getSalesforceBaseURL().toExternalForm()+'/services/data/v45.0/sobjects/'+i.get('name')+'/describe');
		req.setMethod('GET');
		req.setHeader('Authorization', 'OAuth ' +UserInfo.getSessionId());
		Http http = new Http();
		HTTPResponse res = http.send(req);
		//System.debug(res.getBody());
		Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
		List<Object> fields = (List<Object>)root.get('fields');
		//System.debug(fields);
		for (Object field : fields) {
			Map<String, Object> fld = (Map<String, Object>)field;
			if(fld.get('referenceTo') != null){
				List<Object> lstreference=(List<Object>)fld.get('referenceTo');
				if(lstreference.size() >0){
					for (Object ref : lstreference) {
						if('Node__c' ==String.valueOf(ref))
						{
							System.debug(i.get('name') + '-'+lstreference);
						}
					}
					
				}
			}
		}
	}
}