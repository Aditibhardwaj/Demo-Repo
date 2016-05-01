/********************************************************************************************
* Trigger Name: SalutationUtilityTest
* Author: Aditi Bhardwaj (Appirio)
* Date: [12/14/2015]
* Requirement Description: Test Class for SalutationUtility Class Created for S-366710,S-368426
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
@isTest
private class SalutationUtilityTest{
    static Id devRecordTypeId = 
                                Schema.SObjectType.Account.getRecordTypeInfosByName()
                                .get('Organization').getRecordTypeId();

    static Id hhRecordTypeId = 
                                Schema.SObjectType.Account.getRecordTypeInfosByName()
                                .get('Household').getRecordTypeId();                        
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
    Contact_Prefix_Mapping__c prefMapping5 = new Contact_Prefix_Mapping__c();
    prefMapping5.Name = 'Brigadier General';
    prefMapping5.Abbreviated_Prefix__c = 'Brig. Gen.';
    prefMapping5.Alternate_Prefix__c = 'General';
    insert prefMapping5;
    }
    
    private static testmethod void SalutationCreationAndUpdationOnAccountTest(){
        AccountTriggerHandler.isRecursiveForAfterInsert = false;
        AccountTriggerHandler.isRecursiveForAfterUpdate = false;
        AccountTriggerHandler.isRecursiveForBeforeUpdate = false;
        AccountTriggerHandler.isRecursiveForBeforeInsert = false;
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'abc';
        acc.recordtypeId = devRecordTypeId;
        accList.add(acc);

        Account acc1 = new Account();
        acc1.Name = 'Contact one two three four five contact six seven eigth nine ten';
        acc1.recordtypeId = devRecordTypeId;
        accList.add(acc1);
        
        insert accList;
        List<rC_Bios__Salutation__c> salList = [SELECT Id ,rC_Bios__Account__c
                                                From rC_Bios__Salutation__c
                                                WHERE rC_Bios__Account__c in :accList];


        System.assertEquals(salList.size(),4);
        AccountTriggerHandler.isRecursiveForAfterUpdate = false;
        AccountTriggerHandler.isRecursiveForBeforeUpdate = false;
        acc1.Name = 'xyz @123 testing testing testing testing 12345';
        update acc1;
        rC_Bios__Salutation__c sal = [SELECT Id ,rC_Bios__Account__c,
                                      rC_Bios__Salutation_Line_1__c 
                                      From rC_Bios__Salutation__c
                                      WHERE rC_Bios__Account__c =: acc1.id
                                      LIMIT 1];

       
        System.assertEquals(sal.rC_Bios__Salutation_Line_1__c ,acc1.Name);  
        AccountTriggerHandler.isRecursiveForAfterUpdate = false;
        AccountTriggerHandler.isRecursiveForBeforeUpdate = false;
        acc.Name    = 'testing record is here testing @123 last tesing testing @12345673 testing';
        update acc;

        rC_Bios__Salutation__c sal1 = [SELECT Id ,rC_Bios__Account__c,
                                      rC_Bios__Salutation_Line_1__c,
                                      Truncated__c 
                                      From rC_Bios__Salutation__c
                                      WHERE rC_Bios__Account__c  = :acc.Id
                                      AND
                                      rC_Bios__Salutation_Type__c = :SalutationConstants.ORGANIZATION_PREF_MAIL_NAME
                                      LiMIT 1];

        String accName = acc.Name;
        //accName = accName.replaceAll( '\\s+', ''); 
        accName = accName.left(60);
        System.assertEquals(sal1.rC_Bios__Salutation_Line_1__c ,accName);
        System.assertEquals(sal1.Truncated__c,true);
 }
 private static testmethod void SalutationCreationAndUpdationOnContactTest(){

    createPrefixData();
    Account acc = new Account();
    acc.Name = 'abc';
    acc.recordtypeId = devRecordTypeId;
    insert acc;

    Contact con = new Contact();
    con.Salutation = 'Mr.';
    con.FirstName = 'abc';
    con.LastName = 'xyz';
    con.rC_Bios__Middle_Name__c = 'rst';
    con.APP_Suffix__c = 'Jr.';
    con.rC_Bios__Gender__c = 'Male';
    con.AccountId = acc.id;
    Test.startTest();
    insert con;
    List<rC_Bios__Salutation__c> salutaionList = [SELECT Id ,rC_Bios__Account__c,
                                                  rC_Bios__Salutation_Line_1__c,
                                                  Truncated__c
                                                  From rC_Bios__Salutation__c
                                                  WHERE rC_Bios__Contact__c =: con.id
                                                  ];      


    System.assert(salutaionList.size() >= 2);       
    
    Contact con1 = new Contact();
    con1.Salutation = '';
    con1.FirstName = 'abc';
    con1.LastName = 'testing 123 @ last Contact Testing'; 
    con1.rC_Bios__Middle_Name__c = 'rst';
    con1.APP_Suffix__c = 'Jr.';
    con1.rC_Bios__Gender__c = 'female';
    con1.Prof_Suffix__c = 'C.P.A.';
    con1.AccountId = acc.id;
    insert con1;
    
    rC_Bios__Salutation__c bios1 = new rC_Bios__Salutation__c();
    bios1.rC_Bios__Contact__c = con1.id;
    bios1.rC_Bios__Salutation_Type__c = 'Pref Mail Name';
    insert bios1;
    
    rC_Bios__Salutation__c sal = [SELECT Id ,rC_Bios__Account__c,
                            rC_Bios__Salutation_Line_1__c,
                            Truncated__c
                            From rC_Bios__Salutation__c
                            WHERE rC_Bios__Contact__c =: con1.id
                            AND 
                            rC_Bios__Salutation_Type__c = :SalutationConstants.PREF_MAIL_NAME 
                            Limit 1];
                                                                                                                    

Test.stopTest();
    System.assertEquals(sal.Truncated__c,false);         
    String conlastname = con.FirstName;
    con.FirstName = 'test @first testing 1234567 yyyyy'; 
    con.LastName = 'aaa';
    
  ContactService.resetIsRecursive();

    update con; 
    
  con = [SELECT FirstName FROM Contact WHERE Id = :con.Id];


    //System.assertEquals(con.FirstName, conlastname);
    rC_Bios__Salutation__c sal1 = [SELECT Id ,rC_Bios__Account__c,
                                  rC_Bios__Salutation_Line_1__c,
                                  Truncated__c
                                  From rC_Bios__Salutation__c
                                  WHERE rC_Bios__Contact__c =: con.id
                                  AND 
                                  rC_Bios__Salutation_Type__c = :SalutationConstants.PREF_MAIL_NAME 
                                  Limit 1];
                                                                                                                    


    //System.assertEquals(sal1.Truncated__c,true);  
    
    ContactService.resetIsRecursive();
    con1.LastName = 'xyz';
    
    update con1;    
    
    rC_Bios__Salutation__c sal2 = [SELECT Id ,rC_Bios__Account__c,
                                  rC_Bios__Salutation_Line_1__c,
                                  Truncated__c
                                  From rC_Bios__Salutation__c
                                  WHERE rC_Bios__Contact__c =: con1.id
                                  AND 
                                  rC_Bios__Salutation_Type__c = :SalutationConstants.PREF_MAIL_NAME 
                                  Limit 1];

    System.assertEquals(sal2.Truncated__c,false);   
 } 
 
  private static testmethod void Creation_UpdationOfHouseholdSalutation(){
    List<Contact> conList = new List<contact>();
    List<Contact> conListToUpdate = new List<Contact>();
    createPrefixData();
    Account acc2 = new Account();
    acc2.Name = 'abc';
    acc2.recordtypeId = devRecordTypeId;
    insert acc2;

    Contact con = new Contact();
    con.Salutation = '';
    //con.FirstName = 'abc';
    con.LastName = 'xyz';
    con.rC_Bios__Middle_Name__c = 'rst';
    con.APP_Suffix__c = 'Jr.';
    con.rC_Bios__Gender__c = 'Male';
    con.AccountId = acc2.id;
    con.rC_Bios__Preferred_Contact__c = true;
    Test.startTest();
    conList.add(con);
    insert con;
    
    ContactService.resetIsRecursive();
    con.rC_Bios__Preferred_Contact__c = false;
    
    update con;
    Test.StopTest();
}   
    
    
    

 private static testmethod void CreationUpdationOfHouseholdSalutation(){
    List<Contact> conList = new List<contact>();
    List<Contact> conListToUpdate = new List<Contact>();
    createPrefixData();
    Account acc2 = new Account();
    acc2.Name = 'abc';
    acc2.recordtypeId = hhRecordTypeId;
    insert acc2;

    Contact con = new Contact();
    con.Salutation = '';
    //con.FirstName = 'abc';
    con.LastName = 'xyz';
    con.rC_Bios__Middle_Name__c = 'rst';
    con.APP_Suffix__c = 'Jr.';
    con.rC_Bios__Gender__c = 'Male';
    con.AccountId = acc2.id;
    con.rC_Bios__Preferred_Contact__c = true;
    Test.startTest();
    conList.add(con);
    
    
    Contact con1 = new Contact();
    con1.Salutation = '';
    //con1.FirstName = 'Donald';
    con1.LastName = 'duck testing 123 @ last Contact Testing'; 
    con1.rC_Bios__Middle_Name__c = 'diddy';
    con1.APP_Suffix__c = '||';
    con1.rC_Bios__Gender__c = 'female';
    con1.AccountId = acc2.id;
    con1.rC_Bios__Secondary_Contact__c = true;
    conList.add(con1);

    insert conList;
    List<rC_Bios__Salutation__c> salutaionList = [SELECT Id ,rC_Bios__Account__c,
                                                  rC_Bios__Salutation_Line_1__c,
                                                  Truncated__c
                                                  From rC_Bios__Salutation__c
                                                  WHERE rC_Bios__Contact__c =: con.id
                                                  ];      


    System.assert(salutaionList.size() >= 2);       
    

    List<String> householdList = new List<String>{'Household Pref Mail Name','Household Stacked Pref Mail Name'};
    List<rC_Bios__Salutation__c> householdSalList = [SELECT Id ,rC_Bios__Account__c,
                                                      rC_Bios__Salutation_Line_1__c,
                                                      Truncated__c
                                                      From rC_Bios__Salutation__c
                                                      WHERE rC_Bios__Account__c  = :acc2.Id
                                                      AND
                                                      rC_Bios__Salutation_Type__c in : householdList
                                                      ];      



    System.assertEquals(householdSalList.size() ,2) ;           
    
    ContactService.resetIsRecursive();
    con1.rC_Bios__Secondary_Contact__c = false;
    conListToUpdate.add(con1);
    update conListToUpdate;
    
    ContactService.resetIsRecursive();
    con.rC_Bios__Preferred_Contact__c = false;
    conListToUpdate.add(con);
    //Test.stopTest();
   // update con;
    //update conListToUpdate;
    //Test.startTest();
    ContactService.resetIsRecursive();
    con1.rC_Bios__Preferred_Contact__c = false;
    //update con1;
    ContactService.resetIsRecursive();
    con.rC_Bios__Secondary_Contact__c = true;
   // update con;
    Test.stopTest();
 } 
 /*private static testmethod void updateChildSalutationRelTest(){
    List<Contact> conList = new List<contact>();
    List<Contact> conListToUpdate = new List<Contact>();
    createPrefixData();
    Account acc2 = new Account();
    acc2.Name = 'abc';
    //acc2.recordtypeId = devRecordTypeId;
    insert acc2;

    Contact con = new Contact();
    con.Salutation = 'Mrs.';
    con.FirstName = 'abc';
    con.LastName = 'xyz';
    con.rC_Bios__Middle_Name__c = 'rst';
    con.APP_Suffix__c = 'Jr.';
    con.rC_Bios__Gender__c = 'Female';
    con.AccountId = acc2.id;
    con.rC_Bios__Marital_Status__c = 'Married At Death';
    Test.startTest();
    conList.add(con);
    
    
    Contact con1 = new Contact();
    con1.Salutation = '';
    con1.FirstName = 'abc';
    con1.LastName = 'xyz'; 
    con1.rC_Bios__Middle_Name__c = 'diddy';
    con1.APP_Suffix__c = '||';
    con1.rC_Bios__Gender__c = 'female';
    con1.AccountId = acc2.id;
    conList.add(con1);

    insert conList;

    rC_Bios__Relationship__c rel = new rC_Bios__Relationship__c();
    rel.rC_Bios__Contact_1__c = con.id;
    rel.rC_Bios__Contact_2__c = con1.id;
    rel.rC_Bios__Category__c = 'Family';
    rel.rC_Bios__Role_1__c = 'Deceased Partner';
    rel.rC_Bios__Role_2__c = 'Widow';
    rel.rC_Bios__Starting_Year__c = '2001';
    //rel.rC_Bios__Stopping_Year__c = '2006';
    insert rel;

    rC_Bios__Relationship__c rel1 = new rC_Bios__Relationship__c();
    rel1.rC_Bios__Contact_1__c = con.id;
    rel1.rC_Bios__Contact_2__c = con1.id;
    rel1.rC_Bios__Category__c = 'Family';
    rel1.rC_Bios__Role_1__c = 'Deceased Partner';
    rel1.rC_Bios__Role_2__c = 'Widow';
    rel1.rC_Bios__Starting_Year__c = '2007';
    //rel1.rC_Bios__Stopping_Year__c = '2015';
    insert rel1;
    ContactService.resetIsRecursive();
    con.rC_Bios__Marital_Status__c = 'Widowed';
    update con;
    Test.stopTest();

 } */
 private static testmethod void updateChildSalutationPrefTest(){
    Id devSalRecordTypeId = 
                                Schema.SObjectType.rC_Bios__Salutation__c.getRecordTypeInfosByName()
                                .get('Name').getRecordTypeId();
    createPrefixData();
    Account acc2 = new Account();
    acc2.Name = 'abc';
    //acc2.recordtypeId = devRecordTypeId;
    insert acc2;

    Contact con = new Contact();
    con.Salutation = 'Ms.';
    con.FirstName = 'abc';
    con.LastName = 'xyz';
    con.rC_Bios__Middle_Name__c = 'rst';
    con.APP_Suffix__c = 'Jr.';
    con.rC_Bios__Gender__c = 'Female';
    con.AccountId = acc2.id;
    insert con;

    rC_Bios__Preference__c pref = new rC_Bios__Preference__c();
    pref.rC_Bios__Category__c = 'Constituent Type';
    pref.rC_Bios__Subcategory__c = 'UG & Grad Alum';
    pref.rC_Bios__Contact__c =  con.id;
    pref.rC_Bios__Primary__c = true;
    insert pref;
    rC_Bios__Salutation__c sal = new rC_Bios__Salutation__c();
    sal.recordTypeId = devSalRecordTypeId;
    sal.rC_Bios__Contact__c = con.id;
    sal.rC_Bios__Salutation_Type__c = 'Registration/Birth Name';
    sal.rC_Bios__First_Name__c = 'first';
    sal.rC_Bios__Last_Name__c = 'Last';
    insert sal;

    Test.startTest();
    ContactService.resetIsRecursive();
    con.FirstName = 'test';
    update con;
    Test.stopTest();

 }
 private static testmethod void updateChildSalutationAlternatePrefixTest(){
   
    createPrefixData();
    List<contact> conlist = new List<Contact>();
    Account acc2 = new Account();
    acc2.Name = 'abc';
    //acc2.recordtypeId = devRecordTypeId;
    insert acc2;

    Contact con = new Contact();
    con.Salutation = 'Brigadier General';
    con.LastName = 'xyz';
    con.rC_Bios__Middle_Name__c = 'rst';
    con.APP_Suffix__c = 'Jr.';
    con.rC_Bios__Gender__c = 'Female';
    con.AccountId = acc2.id;
    conlist.add(con);

    Contact con1 = new Contact();
    con1.LastName = 'xyz';
    con1.rC_Bios__Middle_Name__c = 'rst';
    con1.rC_Bios__Gender__c = 'Female';
    con1.AccountId = acc2.id;
    conlist.add(con1);
    ContactService.resetIsRecursive();
    insert conList;
    Test.startTest();
    ContactService.resetIsRecursive();
    con.FirstName = 'test';
    update con;
    Test.stopTest();
   }
   
   private static testMethod void getHouseholdPrefMailNameLongTest(){
   	
   	createPrefixData();
    List<contact> conlist = new List<Contact>();
   	//When First and Middle name blank 
    Account acc = new Account();
    acc.Name = 'Test';
   
    insert acc;

    Contact con = new Contact();
    con.LastName = 'Test';
    con.APP_Suffix__c = 'Sr.';
    con.rC_Bios__Gender__c = 'Female';
    con.rC_Bios__Secondary_Contact__c = true;
    con.AccountId = acc.id;
    conlist.add(con);

    Contact con1 = new Contact();
    con1.LastName = 'Test';
    con1.APP_Suffix__c = 'VIII.';
    con1.rC_Bios__Gender__c = 'Male';
    con1.rC_Bios__Preferred_Contact__c = true;
    con1.AccountId = acc.id;
    conlist.add(con1);
    ContactService.resetIsRecursive();
     
     
   /* 
    Account acc1 = new Account();
    acc1.Name = 'Test1';
    insert acc1;
    
    Contact con2 = new Contact();
    con2.Salutation = 'Mrs.';
    con2.FirstName = 'H';
 		con2.rC_Bios__Middle_Name__c = 'abc';
    con2.LastName = 'Test1';
    con2.APP_Suffix__c = 'Jr.';
    con2.rC_Bios__Gender__c = 'Female';
    con2.rC_Bios__Marital_Status__c = 'Widowed';
    con2.rC_Bios__Secondary_Contact__c = true;
    con2.AccountId = acc1.id;
    conlist.add(con2);

    Contact con3 = new Contact();
    con3.Salutation = 'Cadet';
	  con3.FirstName = 'K';
 		con3.rC_Bios__Middle_Name__c = 'rst';
    con3.LastName = 'Test23';
    con3.APP_Suffix__c = 'Est.';
    con3.Prof_Suffix__c = 'LLD'; 
    con3.rC_Bios__Gender__c = 'Male';
    con3.rC_Bios__Marital_Status__c = 'Married At Death';
    con3.rC_Bios__Preferred_Contact__c = true;
    con3.AccountId = acc1.id;
    conlist.add(con3);
    ContactService.resetIsRecursive();
    
		Account acc2 = new Account();
    acc2.Name = 'Test2';
    insert acc2;
    
    Contact con4 = new Contact();
    con4.FirstName = 'A';
 		con4.rC_Bios__Middle_Name__c = 'geh';
    con4.LastName = 'Test2';
    con4.APP_Suffix__c = 'Sr.';
    con4.rC_Bios__Gender__c = 'Female';
    con4.rC_Bios__Secondary_Contact__c = true;
    con4.AccountId = acc2.id;
    conlist.add(con4);

    Contact con5 = new Contact();
    con5.Salutation = 'Admiral';
	  con5.FirstName = 'First';
 		con5.rC_Bios__Middle_Name__c = 'xyz';
    con5.LastName = 'Test23';
    con5.APP_Suffix__c = 'Est.';
  	con5.rC_Bios__Gender__c = 'Male';
    con5.rC_Bios__Preferred_Contact__c = true;
    con5.AccountId = acc2.id;
    conlist.add(con5);
    ContactService.resetIsRecursive();
    
 		Account acc3 = new Account();
    acc3.Name = 'Test3';
    insert acc3;
    
    Contact con6 = new Contact();
    con6.FirstName = 'Fe';
 	  con6.LastName = 'Jet';
    con6.APP_Suffix__c = 'Sr.';
    con6.rC_Bios__Gender__c = 'Female';
    con6.rC_Bios__Secondary_Contact__c = true;
    con6.AccountId = acc3.id;
    conlist.add(con6);

    Contact con7 = new Contact();
    con7.Salutation = 'Bishop';
	  con7.FirstName = 'Ma';
 		con7.LastName = 'Test23';
    con7.APP_Suffix__c = 'Jr.';
  	con7.rC_Bios__Gender__c = 'Male';
    con7.rC_Bios__Preferred_Contact__c = true;
    con7.AccountId = acc3.id;
    conlist.add(con7);
    ContactService.resetIsRecursive();
    
    */
    //When first name balnk and middle not 
    Account acc4 = new Account();
    acc4.Name = 'Test4';
    insert acc4;
    
    Contact con8 = new Contact();
    con8.FirstName = 'Fe';
    con8.rC_Bios__Middle_Name__c = 'abc';
 	  con8.LastName = 'Jet';
    con8.APP_Suffix__c = 'VII';
    con8.rC_Bios__Gender__c = 'Female';
    con8.rC_Bios__Secondary_Contact__c = true;
    con8.AccountId = acc4.id;
    conlist.add(con8);

    Contact con9 = new Contact();
    con9.Salutation = 'Bishop';
	  con8.rC_Bios__Middle_Name__c = 'mno';
 	  con9.LastName = 'Test23';
   	con8.APP_Suffix__c = 'VIII';
		con9.rC_Bios__Gender__c = 'Male';
    con9.rC_Bios__Preferred_Contact__c = true;
    con9.AccountId = acc4.id;
    conlist.add(con9);
    ContactService.resetIsRecursive();
    insert conList;
    
   }
}