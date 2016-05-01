/********************************************************************************************
* Trigger Name: OpportunityTriggerHandlerTest
* Author: Rahul Khanchandani (Appirio)
* Date: [11/02/2016]
* Requirement Description: Test Class for OpportunityTriggerHandler Class Created 
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest
public class OpportunityTriggerHandlerTest {
    private static testMethod void opportunityTriggerHandlerTest(){
 			Id devRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
								.get('Proposal').getRecordTypeId();
 			 User u = createUser('OOD User',false);
       insert u;
       System.runAs(u)
       {  
       		Account acc = new Account(Name = 'TestAcc');
       		Account acc1 = new Account(Name = 'TestAcc1');
       		insert acc;
       		insert acc1;
       	
       		List<Contact> conList = new List<Contact>();
					Contact con0 = new Contact(Salutation = 'Ms.',FirstName = 'abc',LastName = 'xyz1',rC_Bios__Middle_Name__c = 'rst2',APP_Suffix__c = 'Jr.',rC_Bios__Gender__c = 'Female',AccountId = acc.id,rC_Bios__Marital_Status__c = 'Widowed');
					Contact con1 = new Contact(Salutation = 'Ms.',FirstName = 'abc',LastName = 'xyz',rC_Bios__Middle_Name__c = 'rst',APP_Suffix__c = 'Jr.',rC_Bios__Gender__c = 'Female',AccountId = acc1.id,rC_Bios__Marital_Status__c = 'Widowed');
					conList.add(con0);
					conList.add(con1);
					insert conList;
       		
       		Strategy__c st = new Strategy__c();
       		st.Name = 'Test Strategy';
       		st.Account__c = acc.Id;
       		st.Prospect__c = conList[0].Id;
       		st.Goal__c = 'Strategy Goal';
       		st.Plan__c = 'Strategy Plan';
       		insert st;
       		
       		Strategy__c st1 = new Strategy__c();
       		st1.Name = 'Test Strategy1';
       		st1.Account__c = acc1.Id;
       		st1.Prospect__c = conList[1].Id;
       		st1.Goal__c = 'Strategy Goal1';
       		st1.Plan__c = 'Strategy Plan1';
       		insert st1;
       		
       		Opportunity opp = new Opportunity();
		    	opp.Name = 'OppTest1';
		    	opp.Group__c = 'OppTest';
		    	opp.StageName = 'OppTest';
		    	opp.CloseDate = System.today()+5;
		    	opp.RecordTypeId = devRecordTypeId;
		    	opp.Strategy__c= st.id;

					Opportunity opp1 = new Opportunity();
		    	opp1.Name = 'OppTest1OppTest1OppTest1OppTest1OppTest1OppTest1OppTest2OppTest3OppTest4OppTest5OppTest6';
		    	opp1.Group__c = 'OppTest,OppTest2,OppTest3,OppTest4';
		    	opp1.StageName = 'OppTest';
		    	opp1.CloseDate = System.today()+7;
		    	opp1.RecordTypeId = devRecordTypeId;
		    	opp1.Strategy__c= st1.id;

					List<Opportunity> resultOpportunityList = new List<Opportunity>();
					Test.startTest();
		    	insert opp;
		    	insert opp1;
		    	resultOpportunityList = [Select Name,Group__c from Opportunity];
		    	System.assertEquals(resultOpportunityList[0].Name,'OppTest1-OppTest');
       	}
    }
     public static User createUser(String profileName, Boolean isInsert){
        Profile p;
        List<Profile> listProfile = [SELECT Id FROM profile WHERE Name like :'%'+profileName+'%'];
        if(listProfile.size() > 0) {
            p = listProfile[0];
        } else {
            return null;
        }
        User testUser = new User(alias = 'testUser', email='standarduser' + Math.random()  + '@testorg.com',
                                emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
                                username='teststandarduser' + Math.random() + '@testorg.com', IsActive=true,
                                Extension='1234', CompanyName = 'test Company');
        if(isInsert){
            insert testUser;
        }
        return testUser;
    }
}