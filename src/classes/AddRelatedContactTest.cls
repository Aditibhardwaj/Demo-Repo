/********************************************************************************************
* Apex Class Name: AddRelatedContactsTest
* Author: Rahul Khanchandani (Appirio)
* Date: [28/03/2016]
* Requirement Description: Test Class for AddRelatedContact (T-483161/S-347760)
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest 
public with sharing class AddRelatedContactTest {
	//private members
	private static String recTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
  
  //Testing Add Related Contacts on Contact Report  
  public static testMethod void testAddRelatedContactFromContactReport(){
    	//Creating Account
  	Account acc = new Account(Name = 'Test Account');
		insert acc;
		List<Contact> conList = new List<Contact>();
		Contact cnt0 =  new Contact(Salutation = 'Ms.',FirstName = 'Test' , LastName = ' Contact',
																 accountId = acc.id,rC_Bios__Gender__c = 'Female',
																 recordTypeId = recTypeId);
		Contact cnt1 =  new Contact(Salutation = 'Mr.',FirstName = 'Test1' , LastName = ' Contact1',
																 accountId = acc.id,rC_Bios__Gender__c = 'Male',
																 recordTypeId = recTypeId);
		conList.add(cnt0);
		conList.add(cnt1);
    insert conList;
    
		//Creating Contact Report Test Data
		Contact_Report__c  conReport= new Contact_Report__c();
    conReport.Contact_Date__c = System.today();
    conReport.Subject__c = 'Test Contact Report';
    conReport.Account__c = acc.Id;
    insert conReport;
    	
    Test.startTest();
    AddRelatedContacts.populateContactField(conReport.Id,'Contact_Report__c',
    																					conReport.Account__c,'','', 'Contact__c', 'Contact2__c');
  	Test.stopTest();
   		
   	Contact_Report__c resultContactReport = [SELECT contact__r.Name FROM Contact_Report__c WHERE Id =: conReport.Id LIMIT 1];
    System.assertEquals('Test1 Contact1',resultContactReport.contact__r.Name);
    
  }
  
 //Testing Add Related Contacts on Strategy
 	public static testMethod void testAddRelatedContactReportFromStrategy(){
		//Creating Account
		Account acc1 = new Account(Name = 'Test Account1');
			insert acc1;
		
		List<Contact> conList = new List<Contact>();
		
		//Creating Contact Associated with Inserted Account
		Contact cnt0 =  new Contact(Salutation = 'Ms.',FirstName = 'Test' , LastName = ' Contact',
																accountId = acc1.id,rC_Bios__Gender__c = 'Female',recordTypeId = recTypeId);
		
		Contact cnt1 =  new Contact(Salutation = 'Mr.',FirstName = 'Test1' , LastName = ' Contact1'   , 
																accountId = acc1.id,rC_Bios__Gender__c = 'Male',recordTypeId = recTypeId);
		conList.add(cnt0);
		conList.add(cnt1);
		insert conList;
			
		//Creating Strategy  Test Data
		Strategy__c  strategy= new Strategy__c();
		strategy.Name = 'Test Strategy Name';
		strategy.Goal__c = 'Test Strategy Goal';
		strategy.Account__c = acc1.Id;
		strategy.Prospect__c = conList[0].Id;
		insert strategy;
		
		Test.startTest();
		AddRelatedContacts.populateContactField(strategy.Id,'Strategy__c',strategy.Account__c,strategy.Prospect__c,'',
																					 'Prospect__c', 'Contact2__c');
		Test.stopTest(); 
		Strategy__c resultStrategy = [SELECT Contact2__r.Name FROM Strategy__c WHERE Id =: strategy.Id LIMIT 1];
    System.assertEquals('Test1 Contact1',resultStrategy.Contact2__r.Name);
 }
 
 //Testing Add Related Contacts on Strategy
	public static testMethod void testAddRelatedContactFromTeam(){
		//Creating Team  Test Data
		rC_Education__Team__c  team= new rC_Education__Team__c();
		team.Name = 'Test Team';
		team.Group__c = 'EDU - Education';
		team.Program__c  = 'PAR - Parents';
		team.Group__c = 'Research';
		insert team;
		
		Test.startTest();
		String result = AddRelatedContacts.populateContactField(team.Id,'rC_Education__Team__c','','','',
																														'rC_Education__Contact__c', 'Contact2__c');
		Test.stopTest();
		
		System.assertEquals('Please populate account first to populate the contact information',result);
 }

  //Testing Add Related Contacts on Contact Report  
  public static testMethod void testAddRelatedContactFromContactReport1(){
  	Id devRecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
								.get('Proposal').getRecordTypeId();
    //Creating Account
		Account acc1 = new Account(Name = 'Test Account1');
		insert acc1;
		
		List<Contact> conList = new List<Contact>();
			
		//Creating Contact Associated with Inserted Account
		Contact cnt0 =  new Contact(Salutation = 'Ms.',FirstName = 'Test' , LastName = ' Contact',
																	accountId = acc1.id,rC_Bios__Gender__c = 'Female',
																	recordTypeId = recTypeId);
			
		Contact cnt1 =  new Contact(Salutation = 'Mr.',FirstName = 'Test1' , 
																LastName = ' Contact1'   , accountId = acc1.id,
																rC_Bios__Gender__c = 'Male',recordTypeId = recTypeId);
		conList.add(cnt0);
		conList.add(cnt1);
		insert conList;
		//Creating Strategy For Associatiing With Opportunity
	/*	Strategy__c st = new Strategy__c();
  	st.Name = 'Test Strategy';
  	st.Account__c = acc1.Id;
  	st.Prospect__c = conList[0].Id;
  	st.Goal__c = 'Strategy Goal';
  	st.Plan__c = 'Strategy Plan';
  	insert st;
			
		//Creating Opportunity Test Data
		Opportunity opp = new Opportunity();
   	opp.Name = 'OppTest1';
   	opp.Group__c = 'OppTest';
   	opp.StageName = 'OppTest';
   	opp.CloseDate = System.today()+5;
   	opp.Account = acc1;
   	opp.rC_Giving__Primary_Contact__c = conList[0].id;
   	opp.Contact2__c = conList[1].id;
   	opp.Strategy__c= st.id;
   	opp.RecordTypeId = devRecordTypeId;
   	insert opp;
    	*/
    	
    	//Creating Contact Report Test Data
		Contact_Report__c  conReport= new Contact_Report__c();
    conReport.Contact_Date__c = System.today();
    conReport.Subject__c = 'Test Contact Report';
    conReport.Account__c = acc1.Id;
    conReport.Contact__c = conList[0].id;
    conReport.Contact2__c = conList[1].id;
    insert conReport;
    	
    Test.startTest();
    String resultError = AddRelatedContacts.populateContactField(conReport.Id,'Contact_Report__c',
    																					conReport.Account__c, conReport.Contact__c, conReport.Contact2__c, 'Contact__c', 'Contact2__c');
  	Test.stopTest();
    	
    	
   
    System.assertEquals('Both primary and secondary Contacts are already populated',resultError);
    
  }

 }