@isTest
private class ContactServiceTest {
    private static List<Contact> contacts;
      // private static account acc;
    
    static Id contactHouseholdRecTypeId =
                 Schema.SObjectType.Contact.getRecordTypeInfosByName()
                 .get('Household').getRecordTypeId();
    static Id devRecordTypeId = 
                Schema.SObjectType.Account.getRecordTypeInfosByName()
                .get('Organization').getRecordTypeId();
                
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
    }
    
    private static testmethod void checkActiveContact(){
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
      con.RecordTypeId = contactHouseholdRecTypeId;
      con.rC_Bios__Preferred_Contact__c = true;
      con.rC_Bios__Deceased__c = false;
      Test.startTest();
      ContactService.resetIsRecursive();
      insert con;
      con.rC_Bios__Deceased_Date__c = System.today()-10;
      con.rC_Bios__Deceased_Day__c = '02';
      con.rC_Bios__Deceased_Month__c = '01';
      con.rC_Bios__Deceased_Year__c = '2016';
      con.rC_Bios__Deceased__c = true;
      con.Deceased_Source__c = 'Relative';
      ContactService.resetIsRecursive();
      update con;
      con.rC_Bios__Deceased_Date__c = null;
      con.rC_Bios__Deceased_Day__c = null;
      con.rC_Bios__Deceased_Month__c = null;
      con.rC_Bios__Deceased_Year__c = 'Unknown';
      con.rC_Bios__Deceased__c = false;
      ContactService.resetIsRecursive();
      update con;
      Test.stopTest();
      contact cont = [select rC_Bios__Deceased__c from contact where id = :con.id];
      //System.assertEquals(cont.rC_Bios__Deceased__c,con.rC_Bios__Deceased__c);
    }
    private static testmethod void updateSalutationPrefTest(){
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
    con.RecordTypeId = contactHouseholdRecTypeId;
    con.rC_Bios__Deceased__c = true;
    con.rC_Bios__Deceased_Date__c = System.today()-10;
    con.rC_Bios__Deceased_Day__c = '02';
    con.rC_Bios__Deceased_Month__c = '01';
    con.rC_Bios__Deceased_Year__c = '2016';
     con.Deceased_Source__c = 'Relative';
    insert con;

    rC_Bios__Preference__c pref = new rC_Bios__Preference__c();
    pref.rC_Bios__Category__c = 'Constituent Type';
    pref.rC_Bios__Subcategory__c = 'Grad Alum';
    pref.rC_Bios__Contact__c =  con.id;
    pref.rC_Bios__Primary__c = true;
    //pref.rC_Bios__Code_Value__c = 'US';
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
    con.rC_Bios__Deceased_Date__c = null;
    con.rC_Bios__Deceased_Day__c = null;
    con.rC_Bios__Deceased_Month__c = null;
    con.rC_Bios__Deceased_Year__c = 'Unknown';
    con.rC_Bios__Deceased__c = false;
    ContactService.resetIsRecursive();
    update con;
    System.assertEquals(con.rC_Bios__Deceased__c,false);
    Test.stopTest();
    

 }
 
 private static testmethod void updateChildSalutationRelTest(){
    List<Contact> conList = new List<contact>();
    List<Contact> conListToUpdate = new List<Contact>();
    createPrefixData();
    Account acc2 = new Account();
    acc2.Name = 'abc';
    //acc2.recordtypeId = devRecordTypeId;
    insert acc2;

    Account acc3 = new Account();
    acc3.Name = 'acc3';
    //acc2.recordtypeId = devRecordTypeId;
    insert acc3;

    Contact con = new Contact();
    con.Salutation = 'Mr.';
    con.FirstName = 'abc';
    con.LastName = 'xyz';
    con.rC_Bios__Middle_Name__c = 'rst';
    con.APP_Suffix__c = 'Jr.';
    con.rC_Bios__Gender__c = 'Male';
    con.AccountId = acc2.id;
    con.rC_Bios__Marital_Status__c = 'Married At Death';
    //con.SUID__c = 'Test';
    Test.startTest();
    conList.add(con);
    
    
    Contact con1 = new Contact();
    con1.Salutation = '';
    con1.FirstName = 'abc';
    con1.LastName = 'xyz'; 
    con1.rC_Bios__Middle_Name__c = 'diddy';
    con1.APP_Suffix__c = '||';
    con1.rC_Bios__Gender__c = 'Male';
    
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
   // rel1.rC_Bios__Stopping_Year__c = '2015';
    insert rel1;
    ContactService.resetIsRecursive();
    con.rC_Bios__Marital_Status__c = 'Widowed';
    update con;
    ContactService.resetIsRecursive();
    con.AccountId = acc3.id;
    delete conList ;
    Test.stopTest();
  
 }
 
 private static testmethod void CreateUpdatiHouseholdSalTest(){
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
    con.rC_Bios__Preferred_Contact__c = false;
    con.recordTypeId = contactHouseholdRecTypeId;
    con.rC_Bios__Deceased__c = false;
    Test.startTest();
    conList.add(con);
    insert con;
    con.LastName = 'ref';
    update con; 
    
    
   /* Contact con1 = new Contact();
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
                                                           WHERE rC_Bios__Contact__c =: con.id ]; 
                                                                                                                                                                                                                                                                                                                


    System.assert(salutaionList.size() >= 2);       
    

    List<String> householdList = new List<String>{'Household Pref Mail Name','Household Stacked Pref Mail Name'};
    List<rC_Bios__Salutation__c> householdSalList = [SELECT Id ,rC_Bios__Account__c,
                                                                 rC_Bios__Salutation_Line_1__c,
                                                                 Truncated__c
                                                                 From rC_Bios__Salutation__c
                                                                 WHERE rC_Bios__Account__c  = :acc2.Id
                                                                 AND
                                                                 rC_Bios__Salutation_Type__c in : householdList ];
                                                                                                                                                                                                                                                                                 
                                                                                 


    System.assertEquals(householdSalList.size() ,2) ;           
    
    ContactService.resetIsRecursive();
    con1.rC_Bios__Secondary_Contact__c = false;
    conListToUpdate.add(con1);
    update conListToUpdate;
    con.rC_Bios__Preferred_Contact__c = false;
    conListToUpdate.add(con);
    update con;
    ContactService.resetIsRecursive();
    con1.rC_Bios__Preferred_Contact__c = true;
    update con1;
    ContactService.resetIsRecursive();
    con.rC_Bios__Secondary_Contact__c = true;
    update con;
    
    ContactService.resetIsRecursive();
    delete con;
    
    
    Test.stopTest(); */
 } 

 private static testmethod void validateSUIDTest(){
    List<Contact> conList = new List<contact>();
    
    createPrefixData();
    Account acc2 = new Account();
    acc2.Name = 'abc';
    //acc2.recordtypeId = devRecordTypeId;
    insert acc2;

    Account acc3 = new Account();
    acc3.Name = 'acc3';
    //acc2.recordtypeId = devRecordTypeId;
    insert acc3;

    Contact con = new Contact();
    con.Salutation = 'Mr.';
    con.FirstName = 'abc';
    con.LastName = 'xyz';
    con.rC_Bios__Middle_Name__c = 'rst';
    con.APP_Suffix__c = 'Jr.';
    con.rC_Bios__Gender__c = 'Male';
    con.AccountId = acc2.id;
    con.rC_Bios__Marital_Status__c = 'Married At Death';
    con.SUID__c = 'Test';
    Test.startTest();
    conList.add(con);
    
    
    try{
    insert conList;
    } catch (Exception ex){
      System.debug(ex);
    }
  }
  private static testmethod void validateSUIDTest1(){
    List<Contact> conList = new List<contact>();
    
    createPrefixData();
    Account acc2 = new Account();
    acc2.Name = 'abc';
    //acc2.recordtypeId = devRecordTypeId;
    insert acc2;

    Account acc3 = new Account();
    acc3.Name = 'acc3';
    //acc2.recordtypeId = devRecordTypeId;
    insert acc3;

    Contact con1 = new Contact();
    con1.Salutation = '';
    con1.FirstName = 'abc';
    con1.LastName = 'xyz'; 
    con1.rC_Bios__Middle_Name__c = 'diddy';
    con1.APP_Suffix__c = '||';
    con1.rC_Bios__Gender__c = 'Male';
    con1.SUID__c = '98784848493';
    con1.AccountId = acc2.id;
    Test.startTest();
    try{
      insert con1;
      }Catch(Exception ex){}
    Test.stopTest();
  }
  private static testmethod void validateSUIDTest2(){
    List<Contact> conList = new List<contact>();
    
    createPrefixData();
    Account acc2 = new Account();
    acc2.Name = 'abc';
    //acc2.recordtypeId = devRecordTypeId;
    insert acc2;

    Account acc3 = new Account();
    acc3.Name = 'acc3';
    //acc2.recordtypeId = devRecordTypeId;
    insert acc3;
    Contact con1 = new Contact();
    con1.Salutation = '';
    con1.FirstName = 'abc';
    con1.LastName = 'xyz'; 
    con1.rC_Bios__Middle_Name__c = 'diddy';
    con1.APP_Suffix__c = '||';
    con1.rC_Bios__Gender__c = 'Male';
    con1.SUID__c = acc3.SUID__c;
    con1.AccountId = acc3.id;
    insert con1;

    Contact con2 = new Contact();
    con2.Salutation = '';
    con2.FirstName = 'abc';
    con2.LastName = 'xyz'; 
    con2.rC_Bios__Middle_Name__c = 'diddy';
    con2.APP_Suffix__c = '||';
    con2.rC_Bios__Gender__c = 'Male';
    con2.SUID__c = acc3.SUID__c;
    con2.AccountId = acc2.id;
    Test.startTest();
    try{
      insert con2;
      }Catch(Exception ex){}
    Test.stopTest();
  }
  
  
  private static testmethod void updateDecesedContactTest(){
     List<Contact> conList = new List<contact>();
     createPrefixData();
     Id contactToContactRelationship = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Contact').getRecordTypeId();
     
     RecordType_To_Role_Mapping__c recordRole = new RecordType_To_Role_Mapping__c();
     recordRole.Name = 'Spouse/Partner';
     recordRole.Record_Type_Name__c = 'Contact - Contact';
     
     insert recordRole;
     
     Account acc2 = new Account();
     acc2.Name = 'abc';
     //acc2.recordtypeId = devRecordTypeId;
     insert acc2;
     
     Contact con2 = new Contact();
     con2.Salutation = '';
     con2.FirstName = 'abc';
     con2.LastName = 'xyz'; 
     con2.rC_Bios__Middle_Name__c = 'diddy';
     con2.APP_Suffix__c = '||';
     con2.rC_Bios__Gender__c = 'Male';
     con2.AccountId = acc2.id;
     
     insert con2;
     
     rC_Bios__Relationship__c rel = new rC_Bios__Relationship__c();
     rel.rC_Bios__Contact_1__c = con2.id;
     rel.rC_Bios__Category__c = 'Family';
     rel.RecordTypeId = contactToContactRelationship;
     rel.rC_Bios__Role_1__c = 'Financial Advisor';
     rel.rC_Bios__Starting_Year__c = '2001';
     rel.rC_Bios__Active__c = true;
     insert rel;
     
     Test.startTest();
    try{
        con2.Status__c = 'Deceased';
        update con2;
      }Catch(Exception ex){}
    Test.stopTest();
     
     
  }
  
  
  
}