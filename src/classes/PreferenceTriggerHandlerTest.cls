/**
* (c) 2016 Appirio, Inc
* Description : An apex Test for used for PreferenceTriggerHandler 
* Created By : Rahul Khanchandani
* Created Date : March 15th 2016
*/
@isTest
private class PreferenceTriggerHandlerTest {
    private static List<Contact> contacts;
    static Id prefManagedRecTypeId =
                 Schema.SObjectType.rC_Bios__Preference__c.getRecordTypeInfosByName()
                 .get('Standard').getRecordTypeId();

		private static testMethod void testPreferences() {
    createTestData();
    try{
      //Created Preferences having Category = Constituent Type
      List<rC_Bios__Preference__c>  preferences = new List<rC_Bios__Preference__c>();
      preferences.add( new rC_Bios__Preference__c( rc_bios__Contact__c = contacts.get(0).id ,
      																						 rC_Bios__Category__c = 'Constituent Type', 
      																						 rC_Bios__Priority__c = 20, 
      																						 rC_Bios__SubCategory__c = 'Alum', 
      																						 recordTYpeId = prefManagedRecTypeId ));
      preferences.add( new rC_Bios__Preference__c( rc_bios__Contact__c = contacts.get(2).id,
                                                   rC_Bios__Category__c = 'Constituent Type',
                                                   rC_Bios__Priority__c = 10, 
                                                   rC_Bios__SubCategory__c = 'Alum', 
                                                   recordTYpeId = prefManagedRecTypeId ));
      preferences.add( new rC_Bios__Preference__c( rc_bios__Contact__c = contacts.get(3).id,
                                                   rC_Bios__Category__c = 'Constituent Type',
                                                   rC_Bios__Priority__c = 30,
                                                   rC_Bios__SubCategory__c = 'Alum', 
                                                   recordTYpeId = prefManagedRecTypeId ));
                                          
                                          
      preferences.add(new rC_Bios__Preference__c( rc_bios__Contact__c = contacts.get(5).id , 
      																						rC_Bios__Category__c = 'Constituent Type',
      																						rC_Bios__Priority__c = 30, 
      																						rC_Bios__SubCategory__c = 'Alum', 
      																						recordTYpeId = prefManagedRecTypeId));
     preferences.add(new rC_Bios__Preference__c( rc_bios__Contact__c = contacts.get(7).id , 
     																						  rC_Bios__Category__c = 'Association',
                                            		  rC_Bios__Priority__c = 30, 
                                            		  rC_Bios__SubCategory__c = 'Alum', 
                                            		  recordTYpeId = prefManagedRecTypeId));
     
      preferences.add(new rC_Bios__Preference__c( rc_bios__Contact__c = contacts.get(9).id , 
      																					  rC_Bios__Category__c = 'Constituent Type',
      																					  rC_Bios__Priority__c = 30,
      																					  rC_Bios__SubCategory__c = 'Alum', 
      																					  recordTYpeId = prefManagedRecTypeId));
   
      preferences.add(new rC_Bios__Preference__c( rc_bios__Contact__c = contacts.get(11).id , 
      																						rC_Bios__Category__c = 'Constituent Type',
      																						rC_Bios__Priority__c = 40, 
      																						rC_Bios__SubCategory__c = 'Alum', 
      																						recordTYpeId =prefManagedRecTypeId)); 
      
      preferences.add(new rC_Bios__Preference__c( rc_bios__Contact__c = contacts.get(13).id , 
      																						rC_Bios__Category__c = 'Constituent Type',
      																						rC_Bios__Priority__c = 50, 
      																						rC_Bios__SubCategory__c = 'Alum', 
      																						recordTYpeId =prefManagedRecTypeId)); 
  
      Test.startTest();
      insert preferences;
     	
      rC_Bios__Preference__c pref = new rC_Bios__Preference__c();
      pref.rc_bios__Contact__c = contacts.get(0).id ;
      pref.rC_Bios__Category__c = 'Constituent Type';
      pref.rC_Bios__Priority__c = 30;
      pref.rC_Bios__SubCategory__c = 'UG Alum';
      pref.recordTYpeId = prefManagedRecTypeId;
      insert pref;
     
      //Updating Preference
      PreferenceTriggerHandler.isPrimaryOnly = false;
      preferences.get(0).rC_Bios__Priority__c = 20;
      preferences.get(0).rC_Bios__SubCategory__c = 'Grad Alum';
      update preferences;
      PreferenceTriggerHandler.isPrimaryOnly = false;
      List<rC_Bios__Preference__c> resultPreferences = [select Id, rc_bios__Primary__c, rC_Bios__Priority__c, rc_bios__Contact__c from rC_Bios__Preference__c where rc_bios__Contact__c = :  contacts.get(0).id order by rC_Bios__Priority__c ASC];
      System.assert(resultPreferences.size() == 2, 'Original Size :'+resultPreferences.size());
     // System.assert(resultPreferences.get(0).rc_bios__Primary__c, 'Primary Flag :'+resultPreferences.get(0).rc_bios__Primary__c);
     /* resultPreferences[0].rC_Bios__Priority__c = resultPreferences[1].rC_Bios__Priority__c + 2;
      PreferenceTriggerHandler.isPrimaryOnly = false;
      update resultPreferences.get(0);
     */ 
      List<rC_Bios__Preference__c> updateResults = [select id , rC_Bios__Priority__c, rc_bios__Primary__c from rC_Bios__Preference__c where id = : resultPreferences.get(1).id];
     // System.assert(updateResults.get(0).rc_bios__Primary__c, 'Primary Flag :'+updateResults.get(0).rc_bios__Primary__c);
      delete updateResults;
      updateResults = [select id , rc_bios__Primary__c from rC_Bios__Preference__c where id = : resultPreferences.get(0).id];
      //System.assert(updateResults.get(0).rc_bios__Primary__c, 'Primary Flag :'+updateResults.get(0).rc_bios__Primary__c);*/ 
      Test.stopTest();
     }
      catch(Exception ex){
      		system.debug('TRACE: PreferenceTriggerHandlerTest - testPreferences - ' + ex.getMessage());
					system.debug('TRACE: PreferenceTriggerHandlerTest - testPreferences - ' + ex.getStackTraceString());
      			
      }
    }
    
    //Creating Account and Contact Test Data     
    private static void createTestData(){
      	createPrefixData();
	  		String recTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
      	List<Account> accList = new List<Account>();
     		try{
			     Account acc = new Account(Name = 'Test Account');
			     Account acc1 = new Account(Name = 'Test Account1');
			     Account acc2 = new Account(Name = 'Test Account2');
			     Account acc3 = new Account(Name = 'Test Account3');
			     Account acc4 = new Account(Name = 'Test Account4');
			     Account acc5 = new Account(Name = 'Test Account5');
			     Account acc6 = new Account(Name = 'Test Account6');
			     Account acc7 = new Account(Name = 'Test Account7');
			      
			     accList.add(acc);
			     accList.add(acc1);
			     accList.add(acc2);
			     accList.add(acc3);
			     accList.add(acc4);
			     accList.add(acc5);
			     accList.add(acc6);
			     accList.add(acc7);
			     insert accList;
			      
			     contacts = new List<Contact>();
			     
			     Contact cnt0 =  new Contact(Salutation = 'Ms.',FirstName = 'Test' , LastName = ' Contact'   , accountId = acc.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId,rC_Bios__Preferred_Contact__c= false);
			     Contact cnt1 = new Contact(Salutation = 'Ms.',FirstName = 'Test' ,LastName = ' Contact'   , accountId = acc.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId,rC_Bios__Secondary_Contact__c= false);
			      
			     Contact cnt2 =  new Contact(Salutation = 'Ms.',FirstName = 'Test' , LastName = ' Contact'  , accountId = acc1.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId,rC_Bios__Preferred_Contact__c= false);
			      
			     Contact cnt3 =  new Contact(Salutation = 'Mr.',FirstName = 'Test' , LastName = ' Contact'  , accountId = acc2.id,rC_Bios__Gender__c = 'Male',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId);
			     Contact cnt4 =  new Contact(Salutation = 'Ms.',FirstName = 'Test' , LastName = ' Contact'  , accountId = acc2.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId);
			     
			     Contact cnt5=  new Contact(Salutation = 'Ms.',FirstName = 'Test' , LastName = ' Contact'  , accountId = acc3.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId);
			     Contact cnt6 =  new Contact(Salutation = 'Mr.',FirstName = 'Test' , LastName = ' Contact'  , accountId = acc3.id,rC_Bios__Gender__c = 'Male',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId);
			     
			     Contact cnt7 =  new Contact(Salutation = 'Ms.',FirstName = 'Test' , LastName = ' Contact'   , accountId = acc4.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId,rC_Bios__Preferred_Contact__c= false);
			     Contact cnt8 = new Contact(Salutation = 'Ms.',FirstName = 'Test' ,LastName = ' Contact'   , accountId = acc4.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId,rC_Bios__Secondary_Contact__c= false);
			      
			     Contact cnt9 =  new Contact(Salutation = 'Ms.',FirstName = 'Test' , LastName = ' Contact'   , accountId = acc5.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId,rC_Bios__Preferred_Contact__c= false);
			     Contact cnt10 = new Contact(Salutation = 'Ms.',FirstName = 'Test' ,LastName = ' Contact'   , accountId = acc5.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId,rC_Bios__Secondary_Contact__c= false);
			     
			     Contact cnt11 =  new Contact(Salutation = 'Ms.',FirstName = 'Test' , LastName = ' Contact'   , accountId = acc6.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId,rC_Bios__Preferred_Contact__c= false);
			     Contact cnt12 = new Contact(Salutation = 'Ms.',FirstName = 'Test' ,LastName = ' Contact'   , accountId = acc6.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId,rC_Bios__Secondary_Contact__c= false);
			     
			     Contact cnt13 =  new Contact(Salutation = 'Ms.',FirstName = 'Test' , LastName = ' Contact'   , accountId = acc7.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId,rC_Bios__Preferred_Contact__c= true);
			     Contact cnt14 = new Contact(Salutation = 'Ms.',FirstName = 'Test' ,LastName = ' Contact'   , accountId = acc7.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',recordTypeId = recTypeId,rC_Bios__Secondary_Contact__c= false);
			     
			     contacts.add(cnt0);
			     contacts.add(cnt1);
			     contacts.add(cnt2);
			     contacts.add(cnt3);
			     contacts.add(cnt4);
			     contacts.add(cnt5);
			     contacts.add(cnt6);
			     contacts.add(cnt7);
			     contacts.add(cnt8);
			     contacts.add(cnt9);
			     contacts.add(cnt10);
			     contacts.add(cnt11);
			     contacts.add(cnt12);
			     contacts.add(cnt13);
			     contacts.add(cnt14);
			       
			      insert contacts;
			    
  			}catch(Exception ex){
		       	system.debug('TRACE: PreferenceTriggerHandlerTest - createTestData - ' + ex.getMessage());
						system.debug('TRACE: PreferenceTriggerHandlerTest - createTestData - ' + ex.getStackTraceString());
     		}
    }
   //Creating Prefix Data for Contacts     
   private static void createPrefixData(){
       Contact_Prefix_Mapping__c prefMapping = new Contact_Prefix_Mapping__c();
	   prefMapping.Name = 'Mr.';
	   prefMapping.Abbreviated_Prefix__c = 'Mr.';
	   insert prefMapping; 
	
	   Contact_Prefix_Mapping__c prefMapping1 = new Contact_Prefix_Mapping__c();
	   prefMapping1.Name = 'Ms.';
	   prefMapping1.Abbreviated_Prefix__c = 'Ms.';
	   insert prefMapping1;
	
	   Contact_Prefix_Mapping__c prefMapping2 = new Contact_Prefix_Mapping__c();
	   prefMapping2.Name = 'Mr/s.';
	   prefMapping2.Abbreviated_Prefix__c = 'Mr/s.';
	   insert prefMapping2;
	
	   Contact_Prefix_Mapping__c prefMapping3 = new Contact_Prefix_Mapping__c();
	   prefMapping3.Name = 'Mrs.';
	   prefMapping3.Abbreviated_Prefix__c = 'Mrs.';
	   insert prefMapping3;
	 
    	Contact_Prefix_Mapping__c prefMapping4 = new Contact_Prefix_Mapping__c();
    	prefMapping4.Name = 'Mx.';
    	prefMapping4.Abbreviated_Prefix__c = 'Mx.';
    	insert prefMapping4;
   }
   
   
   
   private static testMethod void createPreferenceRecord(){
       String recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
       Account accnt = new Account(Name = 'Test Account', 
                                    RecordTypeId = recTypeId);
       
       insert accnt;
       Contact cnt =  new Contact(Salutation = 'Ms.',FirstName = 'Test' , LastName = ' Contact'   ,
                                    accountId = accnt.id,rC_Bios__Gender__c = 'Female',Prof_Suffix__c = 'A.I.A.',
                                    rC_Bios__Preferred_Contact__c= false);
	
	   insert cnt;
	   
	   rC_Bios__Preference__c prf = new rC_Bios__Preference__c(rC_Bios__Account__c = accnt.Id,
	                                                            rC_Bios__Category__c = 'Research Rating',
	                                                            rC_Bios__Comments__c = 'test' ,
	                                                             Rating_Range__c = '$10K-$24K'); 
	                                                             
	   insert prf;
	   
	   
	   prf.Charter_Member__c = true;
	   
	   update prf;
	   
	   /*prf.rC_Bios__Category__c = 'Analytics';
	   prf.rC_Bios__Subcategory__c = 'OOD';
	   prf.Score_Segment__c = '1233';
	   update prf;*/
	    		     
   }
   
   
   
   
   

}