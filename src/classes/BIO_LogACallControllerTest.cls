/********************************************************************************************
* Apex Class Name: BIO_LogACallControllerTest
* Author: Appirio
* Date: [04/04/2016]
* Requirement Description: Test Class for BIO_LogACallController(T-488510/S-342662)
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest
private class BIO_LogACallControllerTest{
	
	static testMethod void bio_LogACallControllerTest() {
		List<Contact> conList = new List<Contact>();
		List<Contact> suidList = new List<Contact>();
 		Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
														.get('Household').getRecordTypeId();
		Account acc = new Account(Name = 'Test',
															RecordTypeId = devRecordTypeId,
															rC_Bios__Active__c= true);
		insert acc;

		
		 
		Contact con = new Contact(Salutation = 'Ms.',
																LastName = 'xyz',
																rC_Bios__Gender__c = 'Female',
																AccountId = acc.Id);
		conList.add(con);

		Contact conRecord = new Contact(Salutation = 'Mr.',
																		LastName = 'abc',
																		rC_Bios__Gender__c = 'Male',
																		AccountId = acc.Id,
																		rC_Bios__Preferred_Contact__c = true);
		conList.add(conRecord);

		insert conList;
		
		suidList = [SELECT id ,SUID__c FROM CONTACT WHERE id in :conList];
		String suid1= suidList[0].SUID__c;
		String suid2 = suidList[1].SUID__c;
		String suid ;
		PageReference pageRef = Page.BIO_LogACall;
    Test.setCurrentPage(pageRef);
    BIO_LogACallController interactionLog = new BIO_LogACallController();
    suid = suid1;
    suid += ','+ suid2;
   // suid += '9998989433';
    interactionLog.contactSuid = suid;
    interactionLog.onSave();
    interactionLog.onCancel();
    
    
   
  }
  static testMethod void bio_LogACallControllerTestInvalidSuid() {
  	
		PageReference pageRef = Page.BIO_LogACall;
    Test.setCurrentPage(pageRef);
    BIO_LogACallController interactionLog = new BIO_LogACallController();
     
    interactionLog.contactSuid = '6675894632';
    interactionLog.onSave();
    interactionLog.onCancel();
 
  }

        
}