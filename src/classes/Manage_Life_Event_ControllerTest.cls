/********************************************************************************************
* Apex Class Name: Manage_Life_Event_ControllerTest
* Author: Appirio
* Date: [04/04/2016]
* Requirement Description: Test Class for MarriageComponentControlle (T-489404/S-372714)
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest

private class Manage_Life_Event_ControllerTest {
    static testMethod void testOne() {
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
     	List<Account> accList = new List<Account>();
     	Account acc = new Account(Name = 'Test',RecordTypeId = devRecordTypeId,rC_Bios__Active__c= true);
     	accList.add(acc);
     	Account acc1 = new Account(Name = 'Test Acc',RecordTypeId = devRecordTypeId);
     	accList.add(acc1);
     	Account acc2 = new Account(Name = 'Married Account',RecordTypeId = devRecordTypeId);
     	accList.add(acc2);
     	Account acc3 = new Account(Name = 'Married Account',RecordTypeId = devRecordTypeId);
     	accList.add(acc3);
     	insert accList;
     	
     	List<Contact> conList = new List<Contact>();
     	Contact con = new Contact(Salutation = 'Ms.',LastName = 'xyz',rC_Bios__Gender__c = 'Female',AccountId = acc.Id);
        conList.add(con);
        Contact conRecord = new Contact(Salutation = 'Mr.',LastName = 'abc',rC_Bios__Gender__c = 'Male',AccountId = acc1.Id);
        conList.add(conRecord);
        Contact conRecord2 = new Contact(Salutation = 'Mr.',LastName = 'abc',rC_Bios__Gender__c = 'Male',AccountId = acc2.Id,rC_Bios__Marital_Status__c = 'Married');
        conList.add(conRecord2);
        Contact conRecord3 = new Contact(Salutation = 'Mr.',LastName = 'abc',rC_Bios__Gender__c = 'Male',AccountId = acc2.Id,rC_Bios__Marital_Status__c = 'Married');
        conList.add(conRecord3);
        Contact conRecord4 = new Contact(Salutation = 'Mr.',LastName = 'abc',rC_Bios__Gender__c = 'Male',AccountId = acc3.Id,
                                            rC_Bios__Marital_Status__c = 'Married',Single_Household__c = acc.Id);
        conList.add(conRecord4);
        Contact conRecord5 = new Contact(Salutation = 'Mr.',LastName = 'abc',rC_Bios__Gender__c = 'Male',AccountId = acc3.Id,
                                        rC_Bios__Marital_Status__c = 'Married',Single_Household__c = acc1.Id);
        conList.add(conRecord5);
        insert conList;
        Manage_Life_Event_Controller controller = new Manage_Life_Event_Controller(new ApexPages.StandardController(conList[0]));
        controller.getFields();
        controller.cont.LastName = 'Test';
        controller.cont.rC_Bios__Gender__c = 'Male';
        controller.saveOnClick();
        controller.showerrorMessage();
        controller.cancelOnClick();
        controller.cont.ReportsToId = conList[1].Id;
        controller.fetchspouseDetails();
        controller.saveForExistingContact();
        controller.spouseDetailBeforeMarriage();
        Manage_Life_Event_Controller controller2 = new Manage_Life_Event_Controller(new ApexPages.StandardController(conList[2]));
        controller2.divorceSpouseDetails();
        test.startTest();
        Manage_Life_Event_Controller controller3 = new Manage_Life_Event_Controller(new ApexPages.StandardController(conList[4]));
        controller3.divorceSpouseDetails();
        test.stopTest();
        
        
        
        
        
        
        
        
    }
}