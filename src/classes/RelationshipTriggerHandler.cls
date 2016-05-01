/********************************************************************************************
* Trigger Name: RelationshipTriggerHandler
* Author: Jyoti Agarwal (Appirio)
* Date: [01/20/2016]
* Requirement Description: S-365176 
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
Public class RelationshipTriggerHandler{
   
    /* static Id relTeamMemberRecTypeId;
     static Id teamContactTeamRecTypeId;
     static Id teamAccountTeamRecTypeId;
    static {
       relTeamMemberRecTypeId =Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Team Member').getRecordTypeId();
   		  teamContactTeamRecTypeId =Schema.SObjectType.rC_Education__Team__c.getRecordTypeInfosByName().get('Contact Team').getRecordTypeId();
   		  teamAccountTeamRecTypeId =Schema.SObjectType.rC_Education__Team__c.getRecordTypeInfosByName().get('Account Team').getRecordTypeId();
    }
    */
    public void onBeforeInsert(List<rC_Bios__Relationship__c> relationList){
       
        duplicateRelationship(relationList);
        duplicatePartner(relationList);
        
    }
      public void onAfterInsert(List<rC_Bios__Relationship__c> relationList){
       performMaritalProcessOnContacts(relationList);
      //createEntitySubscription(relationList);
    }
    
   
    private void duplicateRelationship(List<rC_Bios__Relationship__c> relationList){
        
        Set<Id> conIdSet = new Set<Id>();
        Set<Id> existingRelationsContactId = new Set<Id>();
        
        Id accountContactId = [Select Id From RecordType where SobjectType = 'rC_Bios__Relationship__c' 
                               AND Name ='Account - Contact' LIMIT 1].Id;
                               
        for(rC_Bios__Relationship__c rel : relationList){
            
            if(rel.rC_Bios__Contact_1__c != null){
                
                conIdSet.add(rel.rC_Bios__Contact_1__c);
            }
        }
       
        for(rC_Bios__Relationship__c existingRelations : [Select Id,rC_Bios__Role_1__c,rC_Bios__Contact_1__c 
                                                          FROM rC_Bios__Relationship__c 
                                                          WHERE  rC_Bios__Contact_1__c
                                                          IN : conIdSet
                                                          AND  RecordTypeId =: accountContactId 
                                                          AND rC_Bios__Category__c = 'Employment'
                                                          AND rC_Bios__Active__c = true
                                                          AND rC_Bios__Primary__c = true]){
                                                            
                                   existingRelationsContactId.add(existingRelations.rC_Bios__Contact_1__c);                        
                                                             
        }
    
    if(existingRelationsContactId.size() > 0 ){
        for(rC_Bios__Relationship__c rel : relationList){
            
            if(rel.RecordTypeId == accountContactId && rel.rC_Bios__Category__c == 'Employment' 
                && rel.rC_Bios__Active__c  && rel.rC_Bios__Primary__c){
            
                if(rel.rC_Bios__Contact_1__c != null && conIdSet.contains(rel.rC_Bios__Contact_1__c) 
                  && existingRelationsContactId.contains(rel.rC_Bios__Contact_1__c)){
                    
                    rel.addError('An active primary employment record already exists.  There can only be one associated to a contact');
                 }
            }   
         }
    }   
 }

 
    private void duplicatePartner(List<rC_Bios__Relationship__c> relationList){
     
        Set<Id> contactSet = new Set<Id>();
        Set<Id> activeRelations = new Set<Id>();
        for(rC_Bios__Relationship__c rel : relationList){
            
            if(rel.rC_Bios__Contact_1__c != null && (rel.rC_Bios__Role_1__c == 'Spouse/Partner' 
               || rel.rC_Bios__Role_2__c == 'Spouse/Partner')){
                
                    contactSet.add(rel.rC_Bios__Contact_1__c );
                }
                
             if(rel.rC_Bios__Contact_2__c != null && (rel.rC_Bios__Role_1__c == 'Spouse/Partner' 
                 || rel.rC_Bios__Role_2__c == 'Spouse/Partner')){
                
                    contactSet.add(rel.rC_Bios__Contact_2__c );
                }
            
            }
          
        for(rC_Bios__Relationship__c relation : [SELECT Id,rC_Bios__Contact_1__c,
                                                 rC_Bios__Contact_2__c FROM rC_Bios__Relationship__c 
                                                 WHERE (rC_Bios__Contact_1__c IN : contactSet 
                                                 OR rC_Bios__Contact_2__c IN : contactSet)
                                                 AND (rC_Bios__Role_1__c = 'Spouse/Partner'
                                                 OR rC_Bios__Role_2__c = 'Spouse/Partner')
                                                 AND rC_Bios__Active__c = True]){
                                                             
                if(relation.rC_Bios__Contact_1__c != null)                       
                    activeRelations.add(relation.rC_Bios__Contact_1__c);

                if(relation.rC_Bios__Contact_2__c != null) 
                    activeRelations.add(relation.rC_Bios__Contact_2__c);                         
                                                 
        }
                                                
        for(rC_Bios__Relationship__c relList : relationList){
        
            if(relList.rC_Bios__Contact_1__c != null && activeRelations.contains(relList.rC_Bios__Contact_1__c )){
            
                relList.addError('There already exists active Spouse/Partner for this contact');
            }
            
            if(relList.rC_Bios__Contact_2__c != null && activeRelations.contains(relList.rC_Bios__Contact_2__c )){
            
                relList.addError('There already exists active Spouse/Partner for this contact');
            }       
       }
    }  
    
   /*	private void createEntitySubscription(List<rC_Bios__Relationship__c> relationList){
   		List<EntitySubscription> entitySubToBeInsert = new List<EntitySubscription>();
   		
      Set<Id> teamMemberIdSet = new Set<Id>();
   		Map<Id,rC_Education__Team__c> teamMemberMap = new Map<Id,rC_Education__Team__c> ();
   		for(rC_Bios__Relationship__c relList : relationList){
   			  teamMemberIdSet.add(relList.rC_Education__Team__c);
   		}
   		for(rC_Education__Team__c team : [select Id,rC_Education__Status__c,RecordTypeId from rC_Education__Team__c where Id IN :teamMemberIdSet]) {
   			  teamMemberMap.put(team.Id,team);
   		}
   		
   		EntitySubscription entitySubscription = new EntitySubscription();
      for(rC_Bios__Relationship__c relList : relationList){
        if(relList.rC_Education__Team__c!= null && relList.rC_Bios__Active__c && relList.RecordTypeId == relTeamMemberRecTypeId
        && teamMemberMap.get(relList.rC_Education__Team__c).rC_Education__Status__c =='Active' && 
         (teamMemberMap.get(relList.rC_Education__Team__c).RecordTypeId == teamContactTeamRecTypeId 
         || teamMemberMap.get(relList.rC_Education__Team__c).RecordTypeId == teamAccountTeamRecTypeId))
         {
        	if(relList.rC_Bios__Account_1__c != null){
	     			 entitySubscription = new EntitySubscription(parentId = relList.rC_Bios__Account_1__c, subscriberid =relList.ownerid);
	     			 entitySubToBeInsert.add(entitySubscription);
						}if(relList.rC_Bios__Contact_1__c != null){
	     		   entitySubscription = new EntitySubscription(parentId = relList.rC_Bios__Contact_1__r.id, subscriberid =relList.ownerid);
	     		   entitySubToBeInsert.add(entitySubscription);
	     			}
	     		}
	     }
	     if(entitySubToBeInsert.size() >0)
			 {  
			  	insert entitySubToBeInsert;
			 }
		}*/
		
		
		
		
		
		
		
		
		
		public void performMaritalProcessOnContacts(List<rC_Bios__Relationship__c> newList){
		
		    Set<Id> realtionIdToProcess = new Set<Id>();
		    list<rC_Bios__Relationship__c> realtionUnderSameAccount = new list<rC_Bios__Relationship__c>();
		    list<rC_Bios__Relationship__c> realtionUnderDifferentAccount = new list<rC_Bios__Relationship__c>();
		    
		    for(rC_Bios__Relationship__c rp :newList ){
		        realtionIdToProcess.add(rp.Id);
		    }
		    
		    
		    for(rC_Bios__Relationship__c rslation : [Select Id ,rC_Bios__Contact_1__c, rC_Bios__Contact_1__r.AccountId , rC_Bios__Category__c,
		                                                    rC_Bios__Contact_2__r.AccountId,rC_Bios__Contact_2__c,rC_Bios__Role_1__c,rC_Bios__Role_2__c,RecordType.Name 
		                                                            FROM rC_Bios__Relationship__c WHERE Id IN :realtionIdToProcess ]){
		                                                                      
		           if(rslation.rC_Bios__Contact_1__r.AccountId != rslation.rC_Bios__Contact_2__r.AccountId && 
		                                rslation.rC_Bios__Category__c == 'Family' && rslation.rC_Bios__Role_1__c == 'Spouse/Partner' && 
		                                rslation.rC_Bios__Role_2__c == 'Spouse/Partner' && rslation.RecordType.Name == 'Contact - Contact' ){
		                                    realtionUnderDifferentAccount.add(rslation);
		           }else if(rslation.rC_Bios__Contact_1__r.AccountId == rslation.rC_Bios__Contact_2__r.AccountId && 
		                                rslation.rC_Bios__Category__c == 'Family' && rslation.rC_Bios__Role_1__c == 'Spouse/Partner' && 
		                                rslation.rC_Bios__Role_2__c == 'Spouse/Partner' && rslation.RecordType.Name == 'Contact - Contact'){
		                                    realtionUnderSameAccount.add(rslation);
		           }
		                                                                
		                                                                
		                                                                
		        }
		        
		        System.debug('realtionUnderDifferentAccount >>' + realtionUnderDifferentAccount);
		        if(realtionUnderDifferentAccount.size() > 0){
		            updateTheMartialDetailsFromDifferentAccount(realtionUnderDifferentAccount);
		        }
		        
		        
		     
		}
		
		private void updateTheMartialDetailsFromSameAccount(list<rC_Bios__Relationship__c> relationList){
		    
		    
		    
		    
		    
		    
		    
		    
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		private void updateTheMartialDetailsFromDifferentAccount(list<rC_Bios__Relationship__c> relationList){
		    
		    Id devRecordTypeId;
		    map<String, list<String>> realtionIdToContactsAssociated = new map<String , List<String>>();
		    Set<Id> contactIdsAssociatedWithRelation = new Set<Id>();
		    map<Id ,Contact> mapofIdToContactDetails = new map<Id,Contact>();
		    list<Contact> contactsToUpsert = new list<Contact>();
		    list<Account> accountToUpsert = new list<Account>();
		    Set<String> accountToDeactivate = new Set<String>();
		    map<Id,Account> mapRelIdAndAccount = new map<Id,Account>(); 
		    
		    
		    // fetch recordType Ids 
		    if(Schema.SObjectType.Account.getRecordTypeInfosByName().containsKey('Household')){
		        devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
		    }
		    
		    
		    
		    for(rC_Bios__Relationship__c relation : relationList){
		            contactIdsAssociatedWithRelation.add(relation.rC_Bios__Contact_1__c);
    		        contactIdsAssociatedWithRelation.add(relation.rC_Bios__Contact_2__c);
    		        
    		        if(!realtionIdToContactsAssociated.containsKey(relation.Id)){
    		            realtionIdToContactsAssociated.put(relation.Id , new list<String>());
    		        }
    		        realtionIdToContactsAssociated.get(relation.Id).add(relation.rC_Bios__Contact_1__c);
    		        realtionIdToContactsAssociated.get(relation.Id).add(relation.rC_Bios__Contact_2__c);
    		}
		    
		    
		    if(contactIdsAssociatedWithRelation.size() > 0){
		     
		        for(Contact cont : [Select Id , Single_Household__c , AccountId , rC_Bios__Marital_Status__c FROM Contact
    		                                WHERE Id IN :contactIdsAssociatedWithRelation ]){
    		                                    
    		                     accountToDeactivate.add(cont.AccountId);                  
    		                     mapofIdToContactDetails.put(cont.Id,Cont);
    		                                    
    		                                    
    		       }
		        
		       // Create a new HouseHold Account for Contacts
		       for(String rel : realtionIdToContactsAssociated.KeySet()){
    		        
    		        Account account  = new Account(RecordTypeId = devRecordTypeId , 
    		                                            rC_Bios__Active__c = true ,
    		                                            Name = 'New Account');
    		       
    		        mapRelIdAndAccount.put(rel,account);
    		   }
    		   
    		   // If there exists any new Account
    		   if(mapRelIdAndAccount.values().size() > 0){
    		       database.insert(mapRelIdAndAccount.values(), false);
    		   }
    		   
		        
		       // account to deactivate
    		   for(String str : accountToDeactivate){
    		        
    		        Account acc = new Account(Id = str ,
    		                                  rC_Bios__Active__c = false );
    		                                  
    		        accountToUpsert.add(acc);
    		        
    		   }
    		   
    		   
    		   
    		   
    		   for(String rel : realtionIdToContactsAssociated.KeySet()){
    		      for(String str : realtionIdToContactsAssociated.get(rel)){
    		            if(mapofIdToContactDetails.containsKey(str)){
    		               Contact con = new Contact(Id = str, 
    		                                      Single_Household__c = mapofIdToContactDetails.get(str).AccountId ,
    		                                      AccountId = mapRelIdAndAccount.get(rel).Id ,
    		                                      rC_Bios__Marital_Status__c = 'Married');
    		                                      
    		                contactsToUpsert.add(con); 
    		            }
    		            
    		        }
    		    }
		     
		       // Update the Account and Contact 
    		    if(accountToUpsert.size() > 0){
    		        upsert accountToUpsert ;
    		    }
    		    if(contactsToUpsert.size() > 0){
    		        upsert contactsToUpsert ;
    		    } 
		        
		        
		        
		        
		        
		    }
		    
		    
		    
		    
		    
		    
		    
		    
		    
		    
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
}