/**
* (c) 2016 Appirio, Inc
* Description : An apex Test for used for SUID_GeneratorServiceAccount 
* Created By : Rahul Khanchandani
* Created Date : March 15th 2016
*/
@isTest
public class SUID_GeneratorServiceAccountTest {
    private static List <Account> accList;
   private static List<Contact> conList;

   public static testMethod void testupdateSUIDonAccount(){
	    accList = new List<Account>();
	    for(Integer i=0;i<10;i++){
	    	accList.add(createAccountTestData(false,i));
	    }
	    Test.startTest();
	    insert accList;
	    Test.stopTest();
	  }
	  
	  public static Account createAccountTestData(boolean isInsert,Integer i){
	    	Account acc = new Account();
	    	acc.Name = 'Test Account'+i;
	    	if(isInsert){
	    		insert acc;	
	    	}
	    	return acc;
	   }
	    
}