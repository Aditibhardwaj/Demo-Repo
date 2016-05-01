/**
* (c) 2016 Appirio, Inc
* Description : An apex Test for used for SUID_GeneratorServiceContact 
* Created By : Rahul Khanchandani
* Created Date : March 15th 2016
*/
@isTest
public class SUID_GeneratorServiceContactTest {
    	private static List <Account> accList;
   		private static List<Contact> conList;
    	public static testMethod void testUpdateSUIDonContact(){
    
     	 accList = new List<Account>();
	     for(Integer i=0;i<10;i++){
	    		accList.add(createAccountTestData(false,i));
	  	 }
	     insert accList;

	     conList = new List<Contact>();
	     for(Integer i=0;i<10;i++){
	     		conList.add(createContactTestData(accList[i].id,false,i));
	    	}
      	
      	Test.startTest();
      	insert conList;
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