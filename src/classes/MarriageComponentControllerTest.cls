/********************************************************************************************
* Apex Class Name: MarriageComponentControlleTest
* Author: Rahul Khanchandani (Appirio)
* Date: [04/04/2016]
* Requirement Description: Test Class for MarriageComponentControlle (T-489404/S-372714)
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest
public class MarriageComponentControllerTest {
 
 public static testMethod void test(){
	MarriageComponentController mcc = new MarriageComponentController();
 	PageReference myPage = new Pagereference('/apex/Manage_Life_Event');
 	Test.setCurrentPage(myPage);  
 	Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
 	Account acc = new Account(Name = 'Test',RecordTypeId = devRecordTypeId,rC_Bios__Active__c= true);
 	insert acc;
 	Account acc1 = new Account(Name = 'Test Acc',RecordTypeId = devRecordTypeId);
 	insert acc1;
 	List<Contact> conList = new List<Contact>();
 	
 	  Contact con = new Contact(Salutation = 'Ms.',LastName = 'xyz',rC_Bios__Gender__c = 'Female',AccountId = acc.Id);
      conList.add(con);
      Contact conRecord = new Contact(Salutation = 'Mr.',LastName = 'abc',rC_Bios__Gender__c = 'Male',AccountId = acc1.Id,rC_Bios__Preferred_Contact__c = true);
      conList.add(conRecord);
      
      insert conList;
      mcc.cont = new Contact(Salutation = 'Ms.',LastName = 'xyz',rC_Bios__Gender__c = 'Female',AccountId = acc.Id);
      mcc.detailContact = conList[0];
      mcc.cont.ReportsToId = conList[0].Id;
      
  
  //myPage.getParameters().put('contactWithRelatedObject',conList[1].id);
      Contact conUpdate = new Contact(Id = conList[1].Id , 
                                         Single_Household__c = conList[1].AccountId ,
                                         AccountId = conList[0].AccountId ,
                                         rC_Bios__Secondary_Contact__c = true,
                                         rC_Bios__Marital_Status__c = 'Married');
      upsert conUpdate; 
      mcc.contactRecord = conList[1];
      mcc.cancelOnClick();
      mcc.saveOnClick();
      mcc.saveForExistingContact();
      mcc.findExistingContact();
      mcc.fetchspouseDetails();
      mcc.getFields();
 	
 }   
}