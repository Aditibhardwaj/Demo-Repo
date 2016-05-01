/********************************************************************************************
* Trigger Name: RelationshipTriggerHandlerTest
* Author: Rahul Khanchandani (Appirio)
* Date: [15/02/2016]
* Requirement Description: Test Class for RelationshipTriggerHandler Class Created 
* Date Modified                Modified By                  Description of the update
***********************************************************************************************/
@isTest
public with sharing class RelationshipTriggerHandlerTest {
  private static List<Contact> conList;
  private static testmethod void testDublicateRelationship(){
    Id accountContactId = [Select Id From RecordType where SobjectType = 'rC_Bios__Relationship__c' 
                               AND Name ='Account - Contact' LIMIT 1].Id;
   
   
   try{
	    createTestData();
			rC_Bios__Relationship__c rel0 = new rC_Bios__Relationship__c();
	    rel0.RecordTypeId = accountContactId;
	    rel0.rC_Bios__Contact_1__c =conList[0].id;
	    rel0.rC_Bios__Contact_2__c = conList[1].id;
	    rel0.rC_Bios__Category__c = 'Employment';
	    rel0.rC_Bios__Role_1__c = 'Deceased Partner';
	    rel0.rC_Bios__Role_2__c = 'Widow';
	    rel0.rC_Bios__Starting_Year__c = '2001';
	    rel0.rC_Bios__Active__c = true;
	    rel0.rC_Bios__Primary__c   = true;
			Test.startTest();
	    insert rel0; 
	
	    rC_Bios__Relationship__c rel1 = new rC_Bios__Relationship__c();
	    rel1.RecordTypeId = accountContactId;
	    rel1.rC_Bios__Contact_1__c = conList[0].id;
	    rel1.rC_Bios__Contact_2__c = conList[1].id;
	    rel1.rC_Bios__Category__c = 'Employment';
	    rel1.rC_Bios__Role_1__c = 'Deceased Partner';
	    rel1.rC_Bios__Role_2__c = 'Widow';
	    rel1.rC_Bios__Starting_Year__c = '2007';
	    rel1.rC_Bios__Active__c = true;
	    rel1.rC_Bios__Primary__c   = true;
	    insert rel1;
	    Test.stopTest();
	  	}catch(Exception ex){
	  	  if(ex.getMessage().contains('An active primary employment record already exists.  There can only be one associated to a contact')){
	  			System.assert(true);
	  		}else{
	  			System.assert(false);
	  		}
    		System.debug(ex.getMessage());
    }
  }
  
  private static testMethod void checkDuplicatePartner(){
  	try{
  	  createTestData();
  	  rC_Bios__Relationship__c rel0 = new rC_Bios__Relationship__c();
	    rel0.rC_Bios__Contact_1__c = conList[0].id;
	    rel0.rC_Bios__Contact_2__c = conList[1].id;
	    rel0.rC_Bios__Category__c = 'Family';
	    rel0.rC_Bios__Role_2__c = 'Spouse/Partner';
	    rel0.rC_Bios__Starting_Year__c = '2005';
	    Test.startTest();
	    insert rel0;
	    
	    rC_Bios__Relationship__c rel1 = new rC_Bios__Relationship__c();
	    rel1.rC_Bios__Contact_1__c = conList[0].id;
	    rel1.rC_Bios__Contact_2__c = conList[1].id;
	    rel1.rC_Bios__Category__c = 'Family';
	    rel1.rC_Bios__Role_1__c = 'Spouse/Partner';
	    rel1.rC_Bios__Role_2__c = 'Spouse/Partner';
	    rel1.rC_Bios__Starting_Year__c = '2006';
	    insert rel1;
	    Test.stopTest();
		}
 		 catch(Exception ex){
  	 if(ex.getMessage().contains('There already exists active Spouse/Partner for this contact')){
	  			System.assert(true);
	  		}else{
	  			System.assert(false);
	  		}
  		System.debug(ex);
  	}
  }
  
  
  private static testMethod void updateMaritalCOntacts(){
  	try{
  	    Id contactToContactRelation;
        if(Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().containsKey('Contact - Contact')){
                   contactToContactRelation = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Contact').getRecordTypeId();
                }
   
  	    rC_Bios__Relationship__c rel0 = new rC_Bios__Relationship__c();
	    rel0.rC_Bios__Contact_1__c = conList[0].id;
	    rel0.rC_Bios__Contact_2__c = conList[1].id;
	    rel0.rC_Bios__Category__c = 'Family';
	    rel0.rC_Bios__Role_2__c = 'Spouse/Partner';
	    rel0.rC_Bios__Starting_Year__c = '2005';
	    rel0.RecordTypeId = contactToContactRelation;
	    Test.startTest();
	    insert rel0;
	    Test.stopTest();
		}
 		 catch(Exception ex){
  	 
 		 }
  	}
  
  
  
  
  
  private static  void createTestData(){
  	  conList = new List<Contact>();
  	  Account acc0 = new Account(Name = 'abc0');
	    insert acc0;
	    Account acc1 = new Account(Name = 'abc1');
	    insert acc1;
	    Account acc2 = new Account(Name = 'abc2');
	    insert acc2;
	    Account acc3 = new Account(Name = 'acc3');
	    insert acc3;
			Contact con = new Contact(Salutation = 'Mr.',FirstName = 'abc',LastName = 'xyz',rC_Bios__Middle_Name__c = 'rst',APP_Suffix__c = 'Jr.',rC_Bios__Gender__c = 'Male',AccountId = acc0.id,rC_Bios__Marital_Status__c = 'Married At Death');
	    Contact con1 = new Contact(Salutation = 'Mr.',FirstName = 'abc',LastName = 'xyz',rC_Bios__Middle_Name__c = 'diddy',APP_Suffix__c = '||',rC_Bios__Gender__c = 'Male',AccountId = acc1.id);
	    conList.add(con);
	    conList.add(con1);
			insert conList;
 }
}