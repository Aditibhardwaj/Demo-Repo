global class URLGeneratorService {
 
 	// @description: A method that pupulates Team fields from account and contact 
 	//									Using Page Layout Field Id Custom Setting .
	 
	// @param: Id accountId
  // @return String Url
  webservice static String generateNewTeamUrlForAccount(Id accountId) {
    
    Account selectedAccount = [SELECT Id, Name FROM Account WHERE Id =: accountId LIMIT 1];
    
    Id accountTeamRecordTypeId = Schema.SObjectType.rC_Education__Team__c.getRecordTypeInfosByName().get('Account Team').getRecordTypeId();
    
    Schema.DescribeSObjectResult objectRes = rC_Education__Team__c.sObjectType.getDescribe();
    Map<String,Schema.SObjectField> fieldsMap = objectRes.fields.getMap();
    String keyPrefix = objectRes.getKeyPrefix();
    
    List<PageLayoutFieldIds__c> fieldIds = [Select Page_Layout_Field_Id__c,Field_API_Name__c From PageLayoutFieldIds__c 
                                           WHERE Object_Name__c = 'rC_Education__Team__c' And record_Type__c = 'Account Team'];
                                           
             
     Map<String,string> fieldValuesMap = new Map<String,string>();
     
     fieldValuesMap.put('rC_Education__Status__c','Active');
     fieldValuesMap.put('rC_Education__Stage__c','Discovery');
     //fieldValuesMap.put('Name', '');
     fieldValuesMap.put('Id',selectedAccount.Id);
     fieldValuesMap.put('rC_Education__Start_Date__c', Datetime.now().format('MM/dd/yyyy'));
     //fieldValuesMap.put(rC_Education__Account__c);
     
     String url = '/' +keyPrefix+ '/e?Name=' + 'DO NOT CHANGE (GRP-PGM)' +'&RecordType='+accountTeamRecordTypeId;                              
      for(PageLayoutFieldIds__c fieldId : fieldIds){
      if(fieldsMap.containsKey(fieldId.Field_API_Name__c)) {
          Schema.DisplayType fieldTypeName = fieldsMap.get(fieldId.Field_API_Name__c).getDescribe().getType();
              if(fieldTypeName != Schema.DisplayType.Reference) {
                if(fieldValuesMap.containsKey(fieldId.Field_API_Name__c)) {
                  url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c); 
                }
              }
              else {
                url += '&' + fieldId.Page_Layout_Field_Id__c + '_lkid' + '=' + selectedAccount.Id;
                url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + selectedAccount.Name;
              }
          
          
      }
         
     }                                     

    
    
    return url ;
    
    
    }
    // T-481877
    webservice static String generateSolicitationStrategyUrl(Id strategyId){
    
        Strategy__c selectedStrategy = [SELECT Id,Name,Account__c,Account__r.Name,Prospect__c,Prospect__r.Name FROM Strategy__c WHERE ID =: strategyId LIMIT 1];
        List<Account> accName = [SELECT Id, Name FROM Account WHERE Id =: selectedStrategy.Account__c LIMIT 1 ];
        
    Schema.DescribeSObjectResult objectRes = Strategy__c.sObjectType.getDescribe();
    Map<String,Schema.SObjectField> fieldsMap = objectRes.fields.getMap();
    String keyPrefix = objectRes.getKeyPrefix();
    
    Id solicitationStrategyId = Schema.SObjectType.Strategy__c.getRecordTypeInfosByName().get('Solicitation').getRecordTypeId();
    
    List<PageLayoutFieldIds__c> fieldIds = [Select Page_Layout_Field_Id__c,Field_API_Name__c From PageLayoutFieldIds__c 
                                           WHERE Object_Name__c = 'Strategy__c' AND record_Type__c = 'Solicitation'];
										   
	 Map<String,string> fieldValuesMap = new Map<String,string>();
     Map<String,string> lookupIDMap = new Map<String,String>();
     
     if(selectedStrategy.Account__c != null){
     fieldValuesMap.put('Account__c',selectedStrategy.Account__c);
     lookupIDMap.put('Account__c',selectedStrategy.Account__r.Name);
     }
     
     fieldValuesMap.put('Parent_Strategy__c',selectedStrategy.Id);
     lookupIDMap.put('Parent_Strategy__c',selectedStrategy.Name);
     
     fieldValuesMap.put('Parent_Strategy__c',selectedStrategy.Id);
     lookupIDMap.put('Parent_Strategy__c',selectedStrategy.Name);
     
     if(selectedStrategy.Prospect__c != null){
     fieldValuesMap.put('Prospect__c',selectedStrategy.Prospect__c);
     lookupIDMap.put('Prospect__c',selectedStrategy.Prospect__r.Name);
     }
     
     fieldValuesMap.put('Status__c','Draft');
     
    String url = '/' +keyPrefix+ '/e?RecordType=' + solicitationStrategyId + '&Name=' + selectedStrategy.Name + '-Strategy';
     for(PageLayoutFieldIds__c fieldId : fieldIds){
                     if(fieldsMap.containsKey(fieldId.Field_API_Name__c)) {
              
                      Schema.DisplayType fieldTypeName = fieldsMap.get(fieldId.Field_API_Name__c).getDescribe().getType();
                      
                          if(fieldTypeName != Schema.DisplayType.Reference) {
                            if(fieldValuesMap.containsKey(fieldId.Field_API_Name__c)) {
                              url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c); 
                            }
                          }
                         else {
                         
                          if(lookupIDMap.containsKey(fieldId.Field_API_Name__c) && fieldValuesMap.containsKey(fieldId.Field_API_Name__c)){
                            url += '&' + fieldId.Page_Layout_Field_Id__c + '_lkid' + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c);
                            url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + lookupIDMap.get(fieldId.Field_API_Name__c);
                            }
                          } 
                      
              }
     
     }
     url += '&nooverride=1';
     return url;
    
    }
    
    webservice static String generateNewTeamUrlForContact(Id contactId) {
    
	    Contact selectedContact = [SELECT Id, Account.Name,Name,Account.rC_Bios__Active__c,Account.RecordType.Name FROM Contact WHERE Id =: contactId LIMIT 1];
	    
	    Id contactTeamRecordTypeId = Schema.SObjectType.rC_Education__Team__c.getRecordTypeInfosByName().get('Contact Team').getRecordTypeId();
	    
	    Schema.DescribeSObjectResult objectRes = rC_Education__Team__c.sObjectType.getDescribe();
	    Map<String,Schema.SObjectField> fieldsMap = objectRes.fields.getMap();
	    String keyPrefix = objectRes.getKeyPrefix();
	    
	    List<PageLayoutFieldIds__c> fieldIds = [Select Page_Layout_Field_Id__c,Field_API_Name__c From PageLayoutFieldIds__c 
	                                           WHERE Object_Name__c = 'rC_Education__Team__c' And record_Type__c = 'Contact Team'];
	                                           
	     Map<String,string> fieldValuesMap = new Map<String,string>();
	     Map<String,string> lookupIDMap = new Map<String,String>();
	    	
	     fieldValuesMap.put('rC_Education__Status__c','Active');
	     fieldValuesMap.put('rC_Education__Stage__c','Discovery');
	     //fieldValuesMap.put('Name', '');
	     fieldValuesMap.put('Id',selectedContact.Id);
	     fieldValuesMap.put('rC_Education__Start_Date__c', Datetime.now().format('MM/dd/yyyy'));
	     //fieldValuesMap.put(rC_Education__Account__c);
			 
			  if(selectedContact.AccountId != null && selectedContact.Account.rC_Bios__Active__c && selectedContact.Account.RecordType.Name == 'Household'){
	     			fieldValuesMap.put('rC_Education__Account__c',selectedContact.AccountId);
	     			lookupIDMap.put('rC_Education__Account__c', selectedContact.Account.Name);
	    	}if(selectedContact.Id != null){
	    			fieldValuesMap.put('rC_Education__Contact__c',selectedContact.Id);
	     			lookupIDMap.put('rC_Education__Contact__c', selectedContact.Name);
	    	}
			  String url = '/' +keyPrefix+ '/e?Name=' + 'DO NOT CHANGE (GRP-PGM)' +'&RecordType='+contactTeamRecordTypeId;                              
		    for(PageLayoutFieldIds__c fieldId : fieldIds){
			    if(fieldsMap.containsKey(fieldId.Field_API_Name__c)) {
		          Schema.DisplayType fieldTypeName = fieldsMap.get(fieldId.Field_API_Name__c).getDescribe().getType();
		              if(fieldTypeName != Schema.DisplayType.Reference) {
			                if(fieldValuesMap.containsKey(fieldId.Field_API_Name__c)) {
		                  url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c); 
		                }
	          	    }
	            	  else {
	              		 if(lookupIDMap.containsKey(fieldId.Field_API_Name__c) && fieldValuesMap.containsKey(fieldId.Field_API_Name__c)){
	                	    url += '&' + fieldId.Page_Layout_Field_Id__c + '_lkid' + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c);
	                  	  url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + lookupIDMap.get(fieldId.Field_API_Name__c);
	               	}
	            	}
	  	    	}
     		}                                     
	   	 return url ;
    }
    
    // T-476861
    webservice static String generateContactReportUrlForContact(Id contactId) {
    
    Contact selectedContact = [SELECT Id, Name,AccountID FROM Contact WHERE Id =: contactId LIMIT 1];
    Account acc= [Select Id,NAme FROM ACCOUNT WHERE Id =: selectedContact.AccountID];
    
    Id contactTeamRecordTypeId = Schema.SObjectType.Contact_Report__c.getRecordTypeInfosByName().get('CR OOD User').getRecordTypeId();
    
    Schema.DescribeSObjectResult objectRes = Contact_Report__c.sObjectType.getDescribe();
    Map<String,Schema.SObjectField> fieldsMap = objectRes.fields.getMap();
    String keyPrefix = objectRes.getKeyPrefix();
    
    List<PageLayoutFieldIds__c> fieldIds = [Select Page_Layout_Field_Id__c,Field_API_Name__c From PageLayoutFieldIds__c 
                                           WHERE Object_Name__c = 'Contact_Report__c' And record_Type__c = 'CR OOD User'];
                                           
             
     Map<String,string> fieldValuesMap = new Map<String,string>();
     Map<String,string> lookupIDMap = new Map<String,String>();
     
     User currentuser=[Select Id,Name,Email from User where Id=:userinfo.getuserId()];
     lookupIDMap.put('Author__c',currentuser.Name);
     fieldValuesMap.put('Author__c',currentuser.id);
     
     fieldValuesMap.put('Account__c',acc.Id);
     lookupIDMap.put('Account__c',acc.Name);
    
     fieldValuesMap.put('Contact__c',selectedContact.id);
     lookupIDMap.put('Contact__c',selectedContact.Name);
     
     
     
     String url = '/' +keyPrefix+ '/e?RecordType='+contactTeamRecordTypeId;                              
      for(PageLayoutFieldIds__c fieldId : fieldIds){
              if(fieldsMap.containsKey(fieldId.Field_API_Name__c)) {
                      Schema.DisplayType fieldTypeName = fieldsMap.get(fieldId.Field_API_Name__c).getDescribe().getType();
                      
                          if(fieldTypeName != Schema.DisplayType.Reference) {
                            if(fieldValuesMap.containsKey(fieldId.Field_API_Name__c)) {
                              url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c); 
                            }
                          }
                         else {
                         
                          if(lookupIDMap.containsKey(fieldId.Field_API_Name__c) && fieldValuesMap.containsKey(fieldId.Field_API_Name__c)){
                            url += '&' + fieldId.Page_Layout_Field_Id__c + '_lkid' + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c);
                            url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + lookupIDMap.get(fieldId.Field_API_Name__c);
                            }
                          } 
                      
              }
     } 
     
    return url ;
    
    
    }
    
    // T-478498
     webservice static String generateProposalUrlForContact(Id contactId) {
    
    Contact selectedContact = [SELECT Id, Name,AccountID FROM Contact WHERE Id =: contactId LIMIT 1];
    
    
    
    List<rC_Bios__Relationship__c> activeRelation =  [Select Id,rC_Bios__Account_2__c FROM rC_Bios__Relationship__c 
                                                WHERE  rC_Bios__Contact_1__c =: selectedContact.Id 
                                                AND rC_Bios__Active__c = True  AND   rC_Bios__Account_2__c != null LIMIT 1];
    
                   
    Id proposalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Proposal').getRecordTypeId();
    
    Schema.DescribeSObjectResult objectRes = Opportunity.sObjectType.getDescribe();
    Map<String,Schema.SObjectField> fieldsMap = objectRes.fields.getMap();
    String keyPrefix = objectRes.getKeyPrefix();
    
    List<PageLayoutFieldIds__c> fieldIds = [Select Page_Layout_Field_Id__c,Field_API_Name__c From PageLayoutFieldIds__c 
                                           WHERE Object_Name__c = 'Opportunity' And record_Type__c = 'Proposal'];
                                         
     Map<String,string> fieldValuesMap = new Map<String,string>();
     Map<String,string> lookupIDMap = new Map<String,String>();
     
    
        if(activeRelation.size() > 0){                                              
                                                
        Account acc= [Select Id,NAme FROM ACCOUNT WHERE Id =: activeRelation[0].rC_Bios__Account_2__c];
        fieldValuesMap.put('AccountId',activeRelation[0].rC_Bios__Account_2__c);
        lookupIDMap.put('AccountId',acc.Name);
    }     
    
    
     fieldValuesMap.put('rC_Giving__Primary_Contact__c',selectedContact.id);
     lookupIDMap.put('rC_Giving__Primary_Contact__c',selectedContact.Name);
     
     String url = '/' +keyPrefix+ '/e?RecordType='+proposalRecordTypeId  ;                              
      for(PageLayoutFieldIds__c fieldId : fieldIds){
      
              if(fieldsMap.containsKey(fieldId.Field_API_Name__c)) {
              
                      Schema.DisplayType fieldTypeName = fieldsMap.get(fieldId.Field_API_Name__c).getDescribe().getType();
                      
                          if(fieldTypeName != Schema.DisplayType.Reference) {
                            if(fieldValuesMap.containsKey(fieldId.Field_API_Name__c)) {
                              url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c); 
                            }
                          }
                         else {
                         
                          if(lookupIDMap.containsKey(fieldId.Field_API_Name__c) && fieldValuesMap.containsKey(fieldId.Field_API_Name__c)){
                            url += '&' + fieldId.Page_Layout_Field_Id__c + '_lkid' + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c);
                            url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + lookupIDMap.get(fieldId.Field_API_Name__c);
                            }
                          } 
                      
              }
     } 
     url += '&nooverride=1';
    return url ;
    
    }
    
    //T-478499
    webservice static String generateProposalUrlForStrategy(Id strategyId) {
    
    Strategy__c selectedStrategy = [SELECT Id,Name,Prospect__c,Prospect__r.Name,Prospect__r.AccountId,Account__c,Account__r.Name FROM Strategy__c WHERE Id =: strategyId LIMIT 1];
    Account acc= [Select Id,Name FROM Account WHERE ID =: selectedStrategy.Prospect__r.AccountId ];
                  
    Id proposalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Proposal').getRecordTypeId();
    
    Schema.DescribeSObjectResult objectRes = Opportunity.sObjectType.getDescribe();
    Map<String,Schema.SObjectField> fieldsMap = objectRes.fields.getMap();
    String keyPrefix = objectRes.getKeyPrefix();
    
    List<PageLayoutFieldIds__c> fieldIds = [Select Page_Layout_Field_Id__c,Field_API_Name__c From PageLayoutFieldIds__c 
                                           WHERE Object_Name__c = 'Opportunity' And record_Type__c = 'Proposal'];
                                         
     Map<String,string> fieldValuesMap = new Map<String,string>();
     Map<String,string> lookupIDMap = new Map<String,String>();
     
    
     fieldValuesMap.put('rC_Giving__Primary_Contact__c',selectedStrategy.Prospect__c);
     lookupIDMap.put('rC_Giving__Primary_Contact__c',selectedStrategy.Prospect__r.Name);
     
     fieldValuesMap.put('AccountId',acc.Id);
     lookupIDMap.put('AccountId',acc.Name);
     
     fieldValuesMap.put('Name',selectedStrategy.Name);
     
     fieldValuesMap.put('Strategy__c',selectedStrategy.Id);
     lookupIDMap.put('Strategy__c',selectedStrategy.Name);
     
     String url = '/' +keyPrefix+ '/e?RecordType='+proposalRecordTypeId  ;                              
      for(PageLayoutFieldIds__c fieldId : fieldIds){
      
              if(fieldsMap.containsKey(fieldId.Field_API_Name__c)) {
              
                      Schema.DisplayType fieldTypeName = fieldsMap.get(fieldId.Field_API_Name__c).getDescribe().getType();
                      
                          if(fieldTypeName != Schema.DisplayType.Reference) {
                            if(fieldValuesMap.containsKey(fieldId.Field_API_Name__c)) {
                              url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c); 
                            }
                          }
                         else {
                         
                          if(lookupIDMap.containsKey(fieldId.Field_API_Name__c) && fieldValuesMap.containsKey(fieldId.Field_API_Name__c)){
                            url += '&' + fieldId.Page_Layout_Field_Id__c + '_lkid' + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c);
                            url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + lookupIDMap.get(fieldId.Field_API_Name__c);
                            }
                          } 
                      
              }
     } 
     url += '&nooverride=1';
    return url ;
    
    }
      
	  // @description: A method that pupulates Stratety fields of Type Engagement Using 
	  //						   Page Layout Field Id Custom Setting from account and contact .
	  // @param: String pool contactId 
	  // @param: String accountId
	  // @return String Url
    webservice static String generateEngagementStrategyUrl(String contactId,String accountId){
     	String selectedName = ''; 
     	String selectedAccountName = ''; 
     	Account selectedAccount;
     	Contact selectedContact;
    	try{
       	if(String.isNotBlank(contactId)) {
	     		selectedContact = [SELECT Id, Name, Account.Name,Account.rC_Bios__Active__c,Account.RecordType.Name FROM Contact 
		    										 WHERE ID = :contactId LIMIT 1];
		   	}
	     	if(String.isNotBlank(accountId)) {
		   		 selectedAccount = [SELECT Id,Name,rC_Bios__Active__c,RecordType.Name FROM Account WHERE ID = :accountId LIMIT 1];
		   	}
		   	Schema.DescribeSObjectResult objectRes = Strategy__c.sObjectType.getDescribe();
		    Map<String,Schema.SObjectField> fieldsMap = objectRes.fields.getMap();
		    String keyPrefix = objectRes.getKeyPrefix();
		    
		    Id engagementStrategyId = Schema.SObjectType.Strategy__c.getRecordTypeInfosByName().get('Engagement').getRecordTypeId();
		    
		    List<PageLayoutFieldIds__c> fieldIds = [Select Page_Layout_Field_Id__c,Field_API_Name__c From PageLayoutFieldIds__c 
		                                           WHERE Object_Name__c = 'Strategy__c' AND record_Type__c = 'Engagement'];
												   
			 	Map<String,string> fieldValuesMap = new Map<String,string>();
		    Map<String,string> lookupIDMap = new Map<String,String>();
		   	if(selectedContact != null && selectedContact.AccountId != null && selectedContact.Account.rC_Bios__Active__c && selectedContact.Account.RecordType.Name == 'Household'){
		     			fieldValuesMap.put('Account__c',selectedContact.AccountId);
		     			selectedAccountName =	correctUrl(selectedContact.Account.Name);
		     			lookupIDMap.put('Account__c', selectedAccountName);
		    }
		    if(selectedAccount != null && selectedAccount.rC_Bios__Active__c && selectedAccount.RecordType.Name == 'Household'){
		    			fieldValuesMap.put('Account__c',selectedAccount.Id);
		     			selectedAccountName =	correctUrl(selectedAccount.Name);
	    				lookupIDMap.put('Account__c', selectedAccountName);
		    }
		    if(selectedContact != null && contactId != null){
	    		selectedName = selectedContact.Name;
	    	}else if(selectedAccount != null) {
	    		selectedName = selectedAccount.Name;
	    	}
	    	selectedName = correctUrl(selectedName);
	    	
		   	String url = '/' +keyPrefix+ '/e?RecordType=' + engagementStrategyId + '&Name=' + selectedName + '-Engagement';
		    for(PageLayoutFieldIds__c fieldId : fieldIds){
		        if(fieldsMap.containsKey(fieldId.Field_API_Name__c)) {
		            Schema.DisplayType fieldTypeName = fieldsMap.get(fieldId.Field_API_Name__c).getDescribe().getType();
		                          if(fieldTypeName != Schema.DisplayType.Reference) {
		                            if(fieldValuesMap.containsKey(fieldId.Field_API_Name__c)) {
		                              url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c); 
		                            }
		                          }
		                         else {
		                          if(lookupIDMap.containsKey(fieldId.Field_API_Name__c) && fieldValuesMap.containsKey(fieldId.Field_API_Name__c)){
		                            url += '&' + fieldId.Page_Layout_Field_Id__c + '_lkid' + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c);
		                            url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + lookupIDMap.get(fieldId.Field_API_Name__c);
		                            }
		                          } 
		              }
		     }
		     url += '&nooverride=1';
		     System.debug('Url on generateEngagementStrategyUrl'+url);
		     return url;
	  	}	
     	catch(Exception e){
     		system.debug('TRACE: URLGeneratorService - generateEngagementStrategyUrl - ' + e.getMessage());
				system.debug('TRACE: URLGeneratorService - generateEngagementStrategyUrl - ' + e.getStackTraceString());
				return null;
      }
    }
    
    // @description: A method that pupulates Saluations fields Using Page Layout Field Id 
    //							 Custom Setting from account and contact.
	  // @param: String pool contactId 
	  // @param: String accountId
	  // @return String Url
	  
	  

    webservice static String generateNewSalutationUrl(String contactId,String accountId){
     	String selectedName = ''; 
     	String selectedAccountName = ''; 
     	Account selectedAccount;
     	Contact selectedContact;
     	boolean populateOnlyAccount = true;
      try{
       	if(String.isNotBlank(contactId)) {
	     		selectedContact = [SELECT Id, Name, Account.Name,Account.rC_Bios__Active__c,Account.RecordType.Name FROM Contact 
		    										 WHERE ID = :contactId LIMIT 1];
		   	}
	     	if(String.isNotBlank(accountId)) {
		   		 selectedAccount = [SELECT Id,Name,rC_Bios__Active__c,RecordType.Name FROM Account WHERE ID = :accountId LIMIT 1];
		   	}
		   	Schema.DescribeSObjectResult objectRes = rC_Bios__Salutation__c.sObjectType.getDescribe();
		    Map<String,Schema.SObjectField> fieldsMap = objectRes.fields.getMap();
		    String keyPrefix = objectRes.getKeyPrefix();
		    
		    Id salutationRecordId = Schema.SObjectType.rC_Bios__Salutation__c.getRecordTypeInfosByName().get('Salutation').getRecordTypeId();
		    
		    List<PageLayoutFieldIds__c> fieldIds = [Select Page_Layout_Field_Id__c,Field_API_Name__c From PageLayoutFieldIds__c 
		                                           WHERE Object_Name__c = 'rC_Bios__Salutation__c' AND record_Type__c = 'Salutation'];
												   
			 	Map<String,string> fieldValuesMap = new Map<String,string>();
		    Map<String,string> lookupIDMap = new Map<String,String>();
		    if(selectedContact != null){
		     			fieldValuesMap.put('rC_Bios__Contact__c',selectedContact.Id);
		     			lookupIDMap.put('rC_Bios__Contact__c', selectedContact.Name);
		     			populateOnlyAccount = false;
		    }
		    if(selectedAccount != null && populateOnlyAccount){
		    			fieldValuesMap.put('rC_Bios__Account__c',selectedAccount.Id);
		     			selectedAccountName =	correctUrl(selectedAccount.Name);
	    				lookupIDMap.put('rC_Bios__Account__c', selectedAccountName);
		    }
		    
		    if(selectedContact != null && contactId != null){
	    		selectedName = selectedContact.Name;
	    	}else if(selectedAccount != null) {
	    		selectedName = selectedAccount.Name;
	    	}
	    	selectedName = correctUrl(selectedName);
	    	/*CHanges : Changed Url from keyPrefix to Selecting Record Type Selection Page
                		Reason : I-209376
                		Modified By : Rahul Khanchandani 
        */
	      String url = '/setup/ui/recordtypeselect.jsp?ent='+Label.Salutation_Custom_Object_ID+'&Name=' + selectedName+'&save_new_url=/a0T/e?';
		   	for(PageLayoutFieldIds__c fieldId : fieldIds){
		         if(fieldsMap.containsKey(fieldId.Field_API_Name__c)) {
		             Schema.DisplayType fieldTypeName = fieldsMap.get(fieldId.Field_API_Name__c).getDescribe().getType();
		                    if(fieldTypeName != Schema.DisplayType.Reference) {
		                            if(fieldValuesMap.containsKey(fieldId.Field_API_Name__c)) {
		                            	url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c); 
		                            }
		                          }
		                         else {
		                          if(lookupIDMap.containsKey(fieldId.Field_API_Name__c) && fieldValuesMap.containsKey(fieldId.Field_API_Name__c)){
		                            url += '&' + fieldId.Page_Layout_Field_Id__c + '_lkid' + '=' + fieldValuesMap.get(fieldId.Field_API_Name__c);
		                            url += '&' + fieldId.Page_Layout_Field_Id__c + '=' + lookupIDMap.get(fieldId.Field_API_Name__c);
		                            url += '&retURL=/'+ fieldValuesMap.get(fieldId.Field_API_Name__c);
		                           }
		                          }  
		              }
		     }
		     url += '&nooverride=1';
		     System.debug('Url on generateNewSalutationUrl'+url);
		     return url;
	  	}	
     	catch(Exception e){
     		System.debug('TRACE: URLGeneratorService - generateNewSalutationUrl - ' + e.getMessage());
				System.debug('TRACE: URLGeneratorService - generateNewSalutationUrl - ' + e.getStackTraceString());
				return null;
      }
    }
    
    private static String correctUrl(String incorrectUrl){
    	String correctUrl;
    	if(incorrectUrl.contains('&')){
	    					correctUrl = incorrectUrl.substringBefore('&')+'%26'+incorrectUrl.substringAfter('&'); 
	    				}else{
	    					correctUrl = incorrectUrl;
	    				}
	    return correctUrl;
    }
 }