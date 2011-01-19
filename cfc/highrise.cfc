component{

	public function init(required string apiurl, required string username,  required string password){
    	variables.apiurl = arguments.apiurl;
    	variables.username = arguments.username;
    	variables.password = arguments.password;
    	variables.objSecurity = createObject("java", "java.security.Security");
		variables.storeProvider = objSecurity.getProvider("JsafeJCE");
    	return This;
    }
    
    public function showCase(required string id){
    	var urlToSend = variables.apiurl & "/kases/" & id;
 		var XML = makeHTTPCall(urlToSend);
  		var result = convertKaseXMLToCaseObject(XML['kase']);
		return result;
    }
    
    public function listOpenCases(){
    	var urlToSend = variables.apiurl & "/kases/open";
 		var XML = makeHTTPCall(urlToSend);
 		var results = ArrayNew(1);
 		var i = 0;
 		
 		for (i =1; i <= ArrayLen(XML.kases.kase); i++){
 			var kase = convertKaseXMLToCaseObject(XML.kases.kase[i]);
 			arrayAppend (results,kase);
 		}
 		
		return results;
    }
    
    
    
    private function makeHTTPCall(required string url){
    	var httpObj = new http();
    	httpObj.setUrl(arguments.url);
    	httpObj.setUsername(variables.username);
    	httpObj.setPassword(variables.password);
    	httpObj.addParam(name="Accept",type="header", value="application/xml");
    	httpObj.addParam(name="Content-Type",type="header", value="application/xml");
		
		/* Remove JsafeJCE Provider */
		objSecurity.removeProvider("JsafeJCE");
		var result = httpObj.send().getPrefix();
		/*  Put JsafeJCE Provider back (not sure if this is needed.) */
		objSecurity.insertProviderAt(storeProvider, 1);	
		
		var XML = XMLParse(result.fileContent);	
		
		return XML;
    }
    
     private function convertKaseXMLToCaseObject(required any kaseXML){
		var kase = new kase();
		
		
		if (len(kaseXML['author-id'].XMLText) > 0){
			kase.setAuthor_id(kaseXML['author-id'].XMLText);
		}	
		kase.setBackground(kaseXML['background'].XMLText); 
		
		if (len(kaseXML['closed-at'].XMLText) > 0){
			kase.setClosed_at(convertZuluTime(kaseXML['closed-at'].XMLText));
		}
		if (len(kaseXML['created-at'].XMLText) > 0){
			kase.setCreated_at(convertZuluTime(kaseXML['created-at'].XMLText));
		}
		
		if (len(kaseXML['group-id'].XMLText) > 0){
			kase.setGroup_id(kaseXML['group-id'].XMLText);
		}	
		kase.setId(kaseXML['id'].XMLText);
		kase.setName(kaseXML['name'].XMLText);
		kase.setVisible_to(kaseXML['visible-to'].XMLText);
		    	
    	return kase;
    }
    
    private function convertZuluTime(required string dateTimeString){
   		var date = GetToken(dateTimeString,1,"T");
		var time = Replace(GetToken(dateTimeString,2,"T"), "Z", "", "ALL");
		var ZuluTime = ParseDateTime(date & " " & time) ;
		var outputDAteTime = DateConvert("utc2Local",ZuluTime);
    	return outputDAteTime;
    }

}