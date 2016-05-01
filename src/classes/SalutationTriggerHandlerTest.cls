/********************************************************************************************
* Trigger Name: SalutationUtilityTest
* Author: Aditi Bhardwaj (Appirio)
* Date: [1/11/2016]
* Requirement Description: Test Class for SalutationTriggerHandlerTest Class Created for S-366710,S-368426
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest
private class SalutationTriggerHandlerTest{
	static Id devRecordTypeId = 
								Schema.SObjectType.rC_Bios__Salutation__c.getRecordTypeInfosByName()
								.get('Name').getRecordTypeId();

	static Account acc;
	static Contact cont;
	static Contact cont1;		
	static List<Contact> contactList = new List<Contact>();					

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
	private static void createTestData(){
		createPrefixData();
		List<Account> accList = new List<Account>();
		acc = new Account(Name = 'abc');
		insert acc;
	 
	 //	List<Contact> conList = new List<Contact>();
		cont = new Contact(Salutation = 'Ms.',FirstName = 'abc',
																LastName = 'xyz1',
																rC_Bios__Middle_Name__c = 'rst2',
																APP_Suffix__c = 'Jr.',
																rC_Bios__Gender__c = 'Female',
																AccountId = acc.id);
																
		
		cont1 = new Contact(Salutation = 'Ms.',FirstName = 'abc',
															LastName = 'xyz',
															rC_Bios__Middle_Name__c = 'rst',
															APP_Suffix__c = 'Jr.',
															rC_Bios__Gender__c = 'Female',
															AccountId = acc.id);
															
		contactList.add(cont);
		contactList.add(cont1);
		insert contactList;
	}	

	private static testmethod void updatechildOnContactTest(){
		createPrefixData();
		List<Account> accList = new List<Account>();
		Account acc0 = new Account(Name = 'abc');
		Account acc1 = new Account(Name = 'abc');
	 	accList.add(acc0);
	 	accList.add(acc1);
	 	insert accList;

	 
		List<Contact> conList = new List<Contact>();
		Contact con0 = new Contact(Salutation = 'Ms.',FirstName = 'abc',
																LastName = 'xyz1',rC_Bios__Middle_Name__c = 'rst2',
																APP_Suffix__c = 'Jr.',rC_Bios__Gender__c = 'Female',
																AccountId = accList[0].id,
																rC_Bios__Marital_Status__c = 'Widowed');
		
		Contact con1 = new Contact(Salutation = 'Ms.',FirstName = 'abc',
															LastName = 'xyz',rC_Bios__Middle_Name__c = 'rst',
															APP_Suffix__c = 'Jr.',
															rC_Bios__Gender__c = 'Female',
															AccountId = accList[1].id,
															rC_Bios__Marital_Status__c = 'Widowed');
		conList.add(con0);
		conList.add(con1);
		insert conList;
		
		rC_Bios__Salutation__c sal = new rC_Bios__Salutation__c();
		sal.recordTypeId = devRecordTypeId;
		sal.rC_Bios__Contact__c = conList[0].id;
		sal.rC_Bios__Salutation_Type__c = 'Registration/Birth Name';
		sal.rC_Bios__First_Name__c = 'first';
		//sal.Override__c = true;
		sal.rC_Bios__Inside_Salutation__c = 'Inside Salutaion';
		sal.rC_Bios__Last_Name__c = 'Last';
		
		rC_Bios__Salutation__c sal1 = new rC_Bios__Salutation__c();
		sal1.recordTypeId = devRecordTypeId;
		sal1.rC_Bios__Contact__c = conList[0].id;
		sal1.rC_Bios__Salutation_Type__c = 'Standard Informal';
		sal1.rC_Bios__First_Name__c = 'first1';
		//sal1.Override__c = true;
		sal1.rC_Bios__Inside_Salutation__c = 'Inside Salutaion11';
		sal1.rC_Bios__Last_Name__c = 'Last1';
		
		Test.startTest();
		insert sal;
		insert sal1;
	 
		sal.rC_Bios__Salutation_Type__c = 'Formal Name';
		sal.rC_Bios__Inside_Salutation__c = 'Inside Salutaion1';
		//sal.Override__c = true;
		update sal;
	
		
		sal.rC_Bios__Salutation_Type__c = 'Standard Informal';
		sal.rC_Bios__Inside_Salutation__c = 'Inside Salutaion2';
		//sal.Override__c = true;
		update sal;
		
		
		delete sal;
		Test.StopTest();
	}

	private static testmethod void updateSalutationOnOverrideTest(){
		createTestData();
		SalutationTriggerHandler.isRecursive = false;
		
		List<rC_Bios__Salutation__c> salList = new List<rC_Bios__Salutation__c>();
		
		rC_Bios__Salutation__c sal = [SELECT id ,Override__c 
																	FROM rC_Bios__Salutation__c
																	WHERE rC_Bios__Contact__c = :contactList[0].id
																	AND rC_Bios__Salutation_Type__c = 'Formal Name'];


		rC_Bios__Salutation__c sal1 = [SELECT id ,Override__c 
																	FROM rC_Bios__Salutation__c
																	WHERE rC_Bios__Contact__c = :contactList[0].id
																	AND rC_Bios__Salutation_Type__c = 'Pref Mail Name'];
		salList.add(sal);
		salList.add(sal1);
		sal.Override__c = true;
		sal1.Override__c = true;
		update salList;
		Test.startTest();
		SalutationTriggerHandler.isRecursive = false;
		sal.Override__c = false;
		//update sal;
		sal1.Override__c = false;
		update salList;
		Test.stopTest();

		rC_Bios__Salutation__c updatedSal = [SELECT id,Auto_Updated__c
																				FROM rC_Bios__Salutation__c
																				WHERE id = :salList[0].id ];


		System.assertEquals(updatedSal.Auto_Updated__c , false);																		

	}

	private static testmethod void calculateManualAndAutomaticUpdateTest(){
		createTestData();
		SalutationTriggerHandler.isRecursive = false;
		contactService.isAutomaticUpdate = false;
		List<rC_Bios__Salutation__c> salList1 = new List<rC_Bios__Salutation__c>();
		
		rC_Bios__Salutation__c sal = [SELECT id ,Override__c,
																	rC_Bios__Inside_Salutation__c,
																	rC_Bios__Salutation_Line_1__c 
																	FROM rC_Bios__Salutation__c
																	WHERE rC_Bios__Contact__c = :contactList[1].id
																	AND rC_Bios__Salutation_Type__c = 'Formal Name'];


		rC_Bios__Salutation__c sal1 = [SELECT id ,Override__c,
																	rC_Bios__Inside_Salutation__c,
																	rC_Bios__Salutation_Line_1__c 
																	FROM rC_Bios__Salutation__c
																	WHERE rC_Bios__Contact__c = :contactList[1].id
																	AND rC_Bios__Salutation_Type__c = 'Pref Mail Name'];
		salList1.add(sal);
		salList1.add(sal1);
		
		SalutationTriggerHandler.isRecursive = false;
		sal.rC_Bios__Inside_Salutation__c = 'test';
		//update sal;
		sal1.rC_Bios__Salutation_Line_1__c = 'test123';
		Test.startTest();
		update salList1;

		SalutationTriggerHandler.isRecursive = false;
		contactService.isAutomaticUpdate = true;
		sal1.rC_Bios__Salutation_Line_1__c = 'test12345';
		update sal1;
		Test.stopTest();
		rC_Bios__Salutation__c updatedSal = [SELECT id,Auto_Updated__c 
																				FROM rC_Bios__Salutation__c
																				WHERE Id = :salList1[0].id];

		System.assertEquals(salList1[0].Auto_Updated__c,false);	
		rC_Bios__Salutation__c updatedSal1 = [SELECT id,Auto_Updated__c 
																				FROM rC_Bios__Salutation__c
																				WHERE Id = :sal1.id];																	
		System.assertEquals(updatedSal1.Auto_Updated__c,true);



	}


}