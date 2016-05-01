/**
* (c) 2016 Appirio, Inc
*
* Description: an apex Test class that has some methods to test different webservice URLGeneratorService.
* Created By: Rahul Khanchandani
* Created Date: March 13th 2016
*/
@isTest
public class URLGeneratorServiceTest {
	// Private Data Members.
	private static String recTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
	private static List<Account> accList;
	private static List<Contact> contactsList;
	private static List<Strategy__c> stList ;
	private static List<PageLayoutFieldIds__c> pageLayoutList;

	// Test Method to check that Team Fields of Type Account Team are being polulated from Account using Custom Setting Data.
	public static testMethod void testGenerateNewTeamUrlForAccount() {
		createAccountContactTestData();
		Id accountId = accList[0].id;

    Test.startTest();

 	  String newteamUrlAccount = URLGeneratorService.generateNewTeamUrlForAccount(accountId); 

  	Test.stopTest();
		
		Id accountTeamRecordTypeId = Schema.SObjectType.rC_Education__Team__c.getRecordTypeInfosByName().get('Account Team').getRecordTypeId();
	  String keyPrefix = rC_Education__Team__c.sObjectType.getDescribe().getKeyPrefix();
		   	
		Account accountResult = [SELECT Name FROM Account WHERE Id = :acclist[0].Id LIMIT 1];
		Contact contactResult = [SELECT Name FROM Contact WHERE Id = :contactsList[0].Id LIMIT 1];
		String expectedNewteamUrlAccount = '/' + keyPrefix + '/e?Name=DO NOT CHANGE (GRP-PGM)&RecordType=' + accountTeamRecordTypeId +
																				'&'+ pageLayoutList[4].Page_Layout_Field_Id__c +'_lkid='+ accountResult.Id +
																				'&'+ pageLayoutList[4].Page_Layout_Field_Id__c +'='+ accountResult.Name +
																				'&'+ pageLayoutList[11].Page_Layout_Field_Id__c +'=Active&'+ pageLayoutList[12].Page_Layout_Field_Id__c +
																				'='+ Datetime.now().format('MM/dd/yyyy')+'&'+pageLayoutList[13].Page_Layout_Field_Id__c +'=Discovery';
		 
		System.assertEquals(expectedNewteamUrlAccount,newteamUrlAccount);
	}
	// Test Method to check that Strategy Fields of Type Solicitation are being polulated from Strategy using Custom Setting Data.  
	public static testMethod void testGenerateSolicitationStrategyUrl(){
		createStrategyTestData();
	  Id strategyId = stList[0].id;
	  
		Test.startTest();
		String solicitationStrategyUrl = URLGeneratorService.generateSolicitationStrategyUrl(strategyId); 
	 	Test.stopTest();
	  	
	 	Id solicitationStrategyId = Schema.SObjectType.Strategy__c.getRecordTypeInfosByName().get('Solicitation').getRecordTypeId();
   	String keyPrefix = Strategy__c.sObjectType.getDescribe().getKeyPrefix();
		Account accountResult = [SELECT Name FROM Account WHERE Id =: acclist[0].Id LIMIT 1];
		Contact contactResult = [SELECT Name FROM Contact WHERE Id =: contactsList[0].Id LIMIT 1];
		String expectedsolicitationStrategyUrl = '/'+ keyPrefix +'/e?RecordType='+ solicitationStrategyId +
																							'&Name='+ stList[0].Name +'-Strategy&'+ pageLayoutList[5].Page_Layout_Field_Id__c +
																							'_lkid='+ contactResult.Id +'&'+ pageLayoutList[5].Page_Layout_Field_Id__c +'='+ contactResult.Name +
																							'&'+ pageLayoutList[6].Page_Layout_Field_Id__c +'_lkid='+ accountResult.Id +
																							'&'+ pageLayoutList[6].Page_Layout_Field_Id__c +'='+ accountResult.Name +'&nooverride=1';
	  
		System.assertEquals(expectedsolicitationStrategyUrl,solicitationStrategyUrl);
  }
  // Test Method to check that Team Fields of Type Contact Team are being polulated from Contact using Custom Setting Data.  
  public static testMethod void testGenerateNewTeamUrlForContact(){
		createAccountContactTestData();
		ID contactId = contactsList[0].id;
		
		Test.startTest();
		String newTeamUrlContact = URLGeneratorService.generateNewTeamUrlForContact(contactId); 
	  Test.stopTest();	
	  	
	  Id contactTeamRecordTypeId = Schema.SObjectType.rC_Education__Team__c.getRecordTypeInfosByName().get('Contact Team').getRecordTypeId();
    Schema.DescribeSObjectResult objectRes = rC_Education__Team__c.sObjectType.getDescribe();
    String keyPrefix = objectRes.getKeyPrefix();
	  Contact contactResult = [SELECT Name FROM Contact WHERE Id =: contactsList[0].Id LIMIT 1];
		String expectedNewTeamUrlContact = '/'+ keyPrefix +'/e?Name=DO NOT CHANGE (GRP-PGM)&RecordType='+ contactTeamRecordTypeId +
																					'&'+ pageLayoutList[3].Page_Layout_Field_Id__c +'_lkid='+ contactResult.Id +
																					'&'+ pageLayoutList[3].Page_Layout_Field_Id__c +'='+ contactResult.Name +
																					'&'+ pageLayoutList[14].Page_Layout_Field_Id__c +'=Active&'+ pageLayoutList[15].Page_Layout_Field_Id__c +
																					'='+ Datetime.now().format('MM/dd/yyyy') +'&'+ pageLayoutList[16].Page_Layout_Field_Id__c +'=Discovery';
	  
		System.assertEquals(expectedNewTeamUrlContact,newTeamUrlContact);
	}
	// Test Method to check that Team Fields of Type Contact Team are being polulated from Contact using Custom Setting Data.  
  public static testMethod void testGenerateProposalUrlForStrategy(){
		createStrategyTestData();
	  Id strategyId = stList[0].id;
		  
	  Test.startTest();
	 	String proposalUrlStrategy = URLGeneratorService.generateProposalUrlForStrategy(strategyId); 
	 	Test.stopTest();
	  	  	
	 	Id proposalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Proposal').getRecordTypeId();
  	Schema.DescribeSObjectResult objectRes = Opportunity.sObjectType.getDescribe();
   	String keyPrefix = objectRes.getKeyPrefix();
	 	Account accountResult = [SELECT Name FROM Account WHERE Id =: acclist[0].Id LIMIT 1];
		Contact contactResult = [SELECT Name FROM Contact WHERE Id =: contactsList[0].Id LIMIT 1];
		String expectedProposalUrlStrategy = '/'+keyPrefix+'/e?RecordType='+proposalRecordTypeId+
																					'&'+pageLayoutList[9].Page_Layout_Field_Id__c+'_lkid='+contactResult.Id+
																					'&'+pageLayoutList[9].Page_Layout_Field_Id__c+'='+contactResult.Name+
																					'&'+pageLayoutList[10].Page_Layout_Field_Id__c+'_lkid='+accountResult.Id+
																					'&'+pageLayoutList[10].Page_Layout_Field_Id__c+'='+accountResult.Name+'&nooverride=1';
	 
		System.assertEquals(expectedProposalUrlStrategy,proposalUrlStrategy);
	}
	// Test Method to check that Contact Report Fields of Type CR OOD User are being polulated from Contact and Account using Custom Setting Data.  
  public static testMethod void testGenerateContactReportUrlForContact(){
	 	createAccountContactTestData();
	  Id contactId = contactsList[0].id;
	      
    Test.startTest();
    String contactReportUrlForContact = URLGeneratorService.generateContactReportUrlForContact(contactId); 
 	  Test.stopTest();
	   	  
 	  Id contactTeamRecordTypeId = Schema.SObjectType.Contact_Report__c.getRecordTypeInfosByName().get('CR OOD User').getRecordTypeId();
 		Schema.DescribeSObjectResult objectRes = Contact_Report__c.sObjectType.getDescribe();
    String keyPrefix = objectRes.getKeyPrefix();
    Account accountResult = [SELECT Name FROM Account WHERE Id =: acclist[0].Id LIMIT 1];	
    Contact contactResult = [SELECT Name FROM Contact WHERE Id =: contactsList[0].Id LIMIT 1];
    String expectedContactReportUrlForContact = '/'+ keyPrefix +'/e?RecordType='+ contactTeamRecordTypeId +
    																							'&'+ pageLayoutList[7].Page_Layout_Field_Id__c +'_lkid='+ accountResult.Id +
    																							'&'+ pageLayoutList[7].Page_Layout_Field_Id__c +'='+ accountResult.Name +
    																							'&'+ pageLayoutList[8].Page_Layout_Field_Id__c +'_lkid='+ contactResult.Id +
    																							'&'+ pageLayoutList[8].Page_Layout_Field_Id__c +'='+ contactResult.Name;
		System.assertEquals(expectedContactReportUrlForContact,contactReportUrlForContact);
	}
	 //Test Method to check that Opportunity Fields are being polulated using Custom Setting Data from contact and account
	public static testMethod void testGenerateProposalUrlForContact(){
	      
		createRelationshipTestData();
		Id contactId = contactsList[0].id;
		Test.startTest();	
	  String proposalUrlForContact = URLGeneratorService.generateProposalUrlForContact(contactId);
	  Test.stopTest(); 
	      
	  Schema.DescribeSObjectResult objectRes = Opportunity.sObjectType.getDescribe();
		String keyPrefix = objectRes.getKeyPrefix();
		Id proposalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Proposal').getRecordTypeId();
   
		Contact contactResult = [SELECT Name FROM Contact WHERE Id =: contactsList[0].Id LIMIT 1];
		String expectedProposalUrlForContact = '/'+keyPrefix+'/e?RecordType='+proposalRecordTypeId+
																								'&'+pageLayoutList[9].Page_Layout_Field_Id__c+'_lkid='+contactResult.Id+
																								'&'+pageLayoutList[9].Page_Layout_Field_Id__c+'='+contactResult.Name+
																								'&nooverride=1';
		
		System.assertEquals(expectedProposalUrlForContact,proposalUrlForContact);
	}
	    //Test Method to check that Strategy Fields are polulated being using Custom Setting Data from contact and account
    	public static testMethod void testGenerateEngagementStrategyUrl(){
    	
		    createAccountContactTestData();
		    String contactId = contactsList[0].id;
		    String accountId = accList[0].id;
	      Test.startTest();
		    String engagementStrategyUrl = URLGeneratorService.generateEngagementStrategyUrl(contactId,accountId); 
		   	Test.stopTest();
		  	
		  	Schema.DescribeSObjectResult objectRes = Strategy__c.sObjectType.getDescribe();
				String keyPrefix = objectRes.getKeyPrefix();
			  Id engagementStrategyId = Schema.SObjectType.Strategy__c.getRecordTypeInfosByName().get('Engagement').getRecordTypeId();
		   	
		   	Account accountResult = [SELECT Name FROM Account WHERE Id =: acclist[0].Id LIMIT 1];
				Contact contactResult = [SELECT Name FROM Contact WHERE Id =: contactsList[0].Id LIMIT 1];
				String expectedEngagementStrategyUrl = '/'+keyPrefix+'/e?RecordType='+engagementStrategyId+
																						  '&Name='+contactResult.Name+'-Engagement&'+pageLayoutList[2].Page_Layout_Field_Id__c+
																						  '_lkid='+accountResult.Id+'&'+pageLayoutList[2].Page_Layout_Field_Id__c+
																						  '='+accountResult.Name+'&nooverride=1';
		 		System.assertEquals(expectedEngagementStrategyUrl,engagementStrategyUrl);
	    }
	    //Test Method to check that Salutation Fields are polulated using Custom Setting Data from contact and account
	    public static testMethod void testGenerateNewSalutationUrl(){
    	
	      createAccountContactTestData();
	      String contactId = contactsList[0].id;
	      String accountId = accList[0].id;
				
				Test.startTest();
				String newSalutationUrl = URLGeneratorService.generateNewSalutationUrl(contactId,accountId);
				Test.stopTest();
				
				Schema.DescribeSObjectResult objectRes = rC_Bios__Salutation__c.sObjectType.getDescribe();
				String keyPrefix = objectRes.getKeyPrefix();
				Id salutationRecordId = Schema.SObjectType.rC_Bios__Salutation__c.getRecordTypeInfosByName().get('Salutation').getRecordTypeId();
				
				Contact contactResult = [SELECT Name FROM Contact WHERE Id =: contactsList[0].Id LIMIT 1];
				String expectedNewSalutationUrl = '/setup/ui/recordtypeselect.jsp?ent='+Label.Salutation_Custom_Object_ID+
																					'&Name='+contactResult.Name+
																				'&save_new_url=/a0T/e?&'+pageLayoutList[1].Page_Layout_Field_Id__c+'_lkid='+contactResult.Id+
																				'&'+pageLayoutList[1].Page_Layout_Field_Id__c+'='+contactResult.Name+
																				'&retURL=/'+contactResult.Id+'&nooverride=1';
				System.assertEquals(expectedNewSalutationUrl,newSalutationUrl);
	    
	    } 
	    
	    public static void createAccountContactTestData(){
  			//Creating Account
    		accList = new List<Account>();
	    	Account acc = new Account(Name = 'Test Account');
	    	accList.add(acc);
	      insert accList;
	      
	     	//Creating Contact
	      contactsList = new List<Contact>();
	    	Contact cnt0 =  new Contact(Salutation = 'Ms.',FirstName = 'Test 1 ' , LastName = 'Test 2'
	    															,accountId = acc.id,rC_Bios__Gender__c = 'Female',recordTypeId = recTypeId,
	    															rC_Bios__Preferred_Contact__c= false);
	     	Contact cnt1 =  new Contact(Salutation = 'Mr.',FirstName = 'Test 1 ' , LastName = 'Test 1'
	     															, accountId = acc.id,rC_Bios__Gender__c = 'Male',recordTypeId = recTypeId,
	     																rC_Bios__Preferred_Contact__c= false);
	      contactsList.add(cnt0);
	      contactsList.add(cnt1);
	      insert contactsList;
	      createPageLayoutFieldsIdsCustomSettingTestData();
	        
    	}
    	//Creating Relationship Test Data
	    public static void createRelationshipTestData(){
    		 
	    	createAccountContactTestData();
				rC_Bios__Relationship__c rel = new rC_Bios__Relationship__c();
			  rel.rC_Bios__Contact_1__c = contactsList[0].id;
			  rel.rC_Bios__Contact_2__c = contactsList[1].id;
			  rel.rC_Bios__Category__c = 'Family';
			  rel.rC_Bios__Role_1__c = 'Deceased Partner';
			  rel.rC_Bios__Role_2__c = 'Widow';
			  rel.rC_Bios__Starting_Year__c = '2001';
			  insert rel;
    	}
			//Creating Strategy Test Data
	    public static void createStrategyTestData(){
		  
	     		createAccountContactTestData();
       		stList = new List<Strategy__c>();
       		Strategy__c st = new Strategy__c();
       		st.Name = 'Test Strategy';
       		st.Account__c = accList[0].Id;
       		st.Prospect__c = contactsList[0].Id;
       		st.Goal__c = 'Strategy Goal';
       		st.Plan__c = 'Strategy Plan';
       		stList.add(st);
       		insert stList;
    	}
	    //Creating "Page Layout Fields Ids" CustomSetting Test Data
	    public static  void createPageLayoutFieldsIdsCustomSettingTestData(){
	       
	      pageLayoutList = new List<PageLayoutFieldIds__c>();
				PageLayoutFieldIds__c pageLayout = new PageLayoutFieldIds__c(Name = 'Salutation Account Lookup Name',
																																		Page_Layout_Field_Id__c ='	CF00N1a000005HTlJ',
																					 													Field_API_Name__c = 'rC_Bios__Account__c',record_Type__c = 'Salutation',
																					 													Object_Name__c = 'rC_Bios__Salutation__c');
		    pageLayoutList.add(pageLayout);
		  
		  	PageLayoutFieldIds__c pageLayout1 = new PageLayoutFieldIds__c(Name = 'Salutation Contact Lookup Name',
		  																																Page_Layout_Field_Id__c = 'CF00N1a000005HTlL',
	    																																Field_API_Name__c = 'rC_Bios__Contact__c',record_Type__c = 'Salutation',
	    																																Object_Name__c = 'rC_Bios__Salutation__c');
		     pageLayoutList.add(pageLayout1);
		  
	    
	    	PageLayoutFieldIds__c pageLayout2 = new PageLayoutFieldIds__c(Name = 'Strategies Account Lookup Name',Page_Layout_Field_Id__c = 'CF00N63000000KdfI',
	    	Field_API_Name__c = 'Account__c',record_Type__c = 'Engagement',Object_Name__c = 'Strategy__c');
		    pageLayoutList.add(pageLayout2);
		 
	    
	    	PageLayoutFieldIds__c pageLayout3 = new PageLayoutFieldIds__c(Name = 'Contact Lookup Name',Page_Layout_Field_Id__c = 'CF00N1a000005HUMx',
	    	Field_API_Name__c = 'rC_Education__Contact__c',record_Type__c = '	Contact Team',Object_Name__c = 'rC_Education__Team__c');
		     pageLayoutList.add(pageLayout3);
		 
	      PageLayoutFieldIds__c pageLayout4 = new PageLayoutFieldIds__c(Name = 'Account Lookup Name',Page_Layout_Field_Id__c = '00N63000000KC8j',
	    	Field_API_Name__c = 'rC_Education__Account__c',record_Type__c = 'Account Team',Object_Name__c = 'rC_Education__Team__c');
		    pageLayoutList.add(pageLayout4);
		
	  	
	  		PageLayoutFieldIds__c pageLayout5 = new PageLayoutFieldIds__c(Name = 'Solicitation Strategy Contact',Page_Layout_Field_Id__c = 'CF00N63000000KIvZ',
	    	Field_API_Name__c = 'Prospect__c',record_Type__c = 'Solicitation',Object_Name__c = 'Strategy__c');
		    pageLayoutList.add(pageLayout5);
		 
	  		PageLayoutFieldIds__c pageLayout6 = new PageLayoutFieldIds__c(Name = 'Solicitation Strategy Account',Page_Layout_Field_Id__c = 'CF00N63000000KdfI',
	    	Field_API_Name__c = 'Account__c',record_Type__c = 'Solicitation',Object_Name__c = 'Strategy__c');
		     pageLayoutList.add(pageLayout6);
		 
		 
		 		PageLayoutFieldIds__c pageLayout7 = new PageLayoutFieldIds__c(Name = 'Contact Report Account Lookup',Page_Layout_Field_Id__c = 'CF00N63000000LGfW',
	    	Field_API_Name__c = 'Account__c',record_Type__c = 'CR OOD User',Object_Name__c = 'Contact_Report__c');
		     pageLayoutList.add(pageLayout7);
		 
	  		PageLayoutFieldIds__c pageLayout8 = new PageLayoutFieldIds__c(Name = 'Contact report contact lookup',Page_Layout_Field_Id__c = 'CF00N63000000LGfb',
	    	Field_API_Name__c = 'Contact__c',record_Type__c = 'CR OOD User',Object_Name__c = 'Contact_Report__c');
		     pageLayoutList.add(pageLayout8);
	   
	   
	   		PageLayoutFieldIds__c pageLayout9 = new PageLayoutFieldIds__c(Name = 'Strategy Proposal Contact Lookup',Page_Layout_Field_Id__c = 'CF00N1a000005HTu5',
	    	Field_API_Name__c = 'rC_Giving__Primary_Contact__c',record_Type__c = 'Proposal',Object_Name__c = 'Opportunity');
		     pageLayoutList.add(pageLayout9);
		 
	  		PageLayoutFieldIds__c pageLayout10 = new PageLayoutFieldIds__c(Name = 'Strategy Proposal Account Lookup',Page_Layout_Field_Id__c = 'opp4',
	    	Field_API_Name__c = 'AccountId',record_Type__c = 'Proposal',Object_Name__c = 'Opportunity');
		     pageLayoutList.add(pageLayout10);
		     
		    
		    PageLayoutFieldIds__c pageLayout11 = new PageLayoutFieldIds__c(Name = 'Account Team Status',Page_Layout_Field_Id__c = '00N1a000005HUN2',
	    	Field_API_Name__c = 'rC_Education__Status__c',record_Type__c = 'Account Team',Object_Name__c = 'rC_Education__Team__c');
		     pageLayoutList.add(pageLayout11);
		    
		    PageLayoutFieldIds__c pageLayout12 = new PageLayoutFieldIds__c(Name = 'Account Team Start Date',Page_Layout_Field_Id__c = '00N1a000005HUN1',
	    	Field_API_Name__c = 'rC_Education__Start_Date__c',record_Type__c = 'Account Team',Object_Name__c = 'rC_Education__Team__c');
		     pageLayoutList.add(pageLayout12);
		    
		    PageLayoutFieldIds__c pageLayout13 = new PageLayoutFieldIds__c(Name = 'Account Team',Page_Layout_Field_Id__c = '00N63000000KC8j',
	    	Field_API_Name__c = 'rC_Education__Stage__c',record_Type__c = 'Account Team',Object_Name__c = 'rC_Education__Team__c');
		     pageLayoutList.add(pageLayout13);
		  
		  
		     PageLayoutFieldIds__c pageLayout14 = new PageLayoutFieldIds__c(Name = 'Contact Team Status',Page_Layout_Field_Id__c = '00N1a000005HUN2',
	    	Field_API_Name__c = 'rC_Education__Status__c',record_Type__c = 'Contact Team',Object_Name__c = 'rC_Education__Team__c');
		     pageLayoutList.add(pageLayout14);
		    
		    PageLayoutFieldIds__c pageLayout15 = new PageLayoutFieldIds__c(Name = 'Contact Team Start Date',Page_Layout_Field_Id__c = '00N1a000005HUN1',
	    	Field_API_Name__c = 'rC_Education__Start_Date__c',record_Type__c = 'Contact Team',Object_Name__c = 'rC_Education__Team__c');
		     pageLayoutList.add(pageLayout15);
		    
		    PageLayoutFieldIds__c pageLayout16 = new PageLayoutFieldIds__c(Name = 'Contact team Stage',Page_Layout_Field_Id__c = '00N63000000KC8j',
	    	Field_API_Name__c = 'rC_Education__Stage__c',record_Type__c = 'Contact Team',Object_Name__c = 'rC_Education__Team__c');
		     pageLayoutList.add(pageLayout16);
		  
		    insert  pageLayoutList;
	    }
}