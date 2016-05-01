/********************************************************************************************
* Trigger Name: AccountTriggerTest
* Author: Jyoti Agarwal(Appirio)
* Date: [01/07/2016]
* Requirement Description: Test Class for AccountTriggerHandler
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/

@isTest
private class AccountTriggerTest{
  static Id devRecordTypeId = 
                Schema.SObjectType.Account.getRecordTypeInfosByName()
                .get('Organization').getRecordTypeId();
                
    private static testmethod void createChildSalutationTest(){
     List<Account> accList = new List<Account>();
     Account acc = new Account();
     acc.Name = 'abc';
     acc.recordtypeId = devRecordTypeId;
     accList.add(acc);
     
     Test.startTest();
     
     insert acc;
     acc.Name = 'Test';
     update acc;
     
     List<rC_Bios__Salutation__c> salList = [SELECT ID FROM rC_Bios__Salutation__c WHERE rC_Bios__Account__c =: acc.Id ];
     system.assertEquals(salList.size(),2 );
     
     Test.StopTest();
     
     
    
    }   
}