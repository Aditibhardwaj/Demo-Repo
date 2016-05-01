/**
* (c) 2016 Appirio, Inc
* Description : An apex Test class used for testing SUID_GeneratorService 
*/
@isTest
public class SUID_GeneratorServiceTest {
//Method To test getNextSUID By Using Account SUID
  public static testMethod void testgetNextSUIDAccount(){
    
        List<Account> accList = new List<Account>();
        for(Integer i=0;i<10;i++){
                accList.add(createAccountTestData(false,i));
          }
          insert accList;
        Account accResult = [SELECT Id,Name,SUID_Pool_Value__c FROM Account WHERE Id =: accList[0].Id];
        Test.startTest();
        String resultAccSUID = SUID_GeneratorService.getNextSUID(accResult.SUID_Pool_Value__c,'4');
        Test.stopTest();
        if(String.isNotBlank(resultAccSUID)){
             System.assert(resultAccSUID.length() == 10, 'Original Size :'+resultAccSUID.length());
        }
     
  }
  //Method To test getNextSUID By Using Contact SUID
  public static testMethod void testgetNextSUIDByContact(){
    
        List<Account> accList = new List<Account>();
        accList = new List<Account>();
          for(Integer i=0;i<10;i++){
            accList.add(createAccountTestData(false,i));
          }
          insert accList;
          List<Contact> conList = new List<Contact>();
          for(Integer i=0;i<10;i++){
                conList.add(createContactTestData(accList[i].id,false,i));
          }
        insert conList;
        Contact conResult = [SELECT Id,Name,SUID_Pool_Value__c FROM Contact WHERE Id =: conList[0].Id];
        Test.startTest();
        String resultConSUID = SUID_GeneratorService.getNextSUID(conResult.SUID_Pool_Value__c,'4');
        Test.stopTest();
        if(String.isNotBlank(resultConSUID)){
             System.assert(resultConSUID.length() == 10, 'Original Size :'+resultConSUID.length());
        }
  }
  //Creating Account Test Data
   public static Account createAccountTestData(boolean isInsert,Integer i){
            Account acc = new Account();
            acc.Name = 'Test Account'+i;
            if(isInsert){
                insert acc; 
            }
            return acc;
       }
      //Creating Contact Test Data
      public static Contact createContactTestData(Id accId,boolean isInsert,Integer i){
                Contact con = new Contact();
                con.Salutation = 'Ms.';
                con.FirstName = 'Test'+i; 
                con.LastName = 'Test 0'+i;
                con.accountId = accId;
                con.rC_Bios__Gender__c='Female';
                if(isInsert){
                    insert con; 
                }
                return con;
       }
      
}