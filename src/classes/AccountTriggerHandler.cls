/********************************************************************************************
* Trigger Name: AccountTriggerHandler
* Author: Aditi Bhardwaj (Appirio)
* Date: [12/10/2015]
* Requirement Description: S-368426 [Organization Salutations: Outside & Publication (Auto-Create)]
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
Public class AccountTriggerHandler{
	public static boolean isRecursiveForAfterInsert = false;
	public static boolean isRecursiveForAfterUpdate = false;
	public static boolean isRecursiveForBeforeUpdate = false;
	public static boolean isRecursiveForBeforeInsert = false;

	public void onBeforeInsert(List<Account> acclist){
		if(isRecursiveForBeforeInsert){
			return;
		} else {
			isRecursiveForBeforeInsert = true;
		
		}
		//populateSuidOnAccount(acclist);
		validateSuidOnAccount(accList,false);
	    
	}
	
	
	public void onBeforeUpdate(List<Account> acclist,  Map<Id, Account> accountOldMap){
		List<Account> accountList = new List<Account>();
		if(isRecursiveForBeforeUpdate){
			return;
		} else {
			isRecursiveForBeforeUpdate = true;
		
		}
		
		//populateSuidOnAccount(acclist);
		for(Account acc : acclist){
			if(acc.SUID__c != accountOldMap.get(acc.id).SUID__c) {
				accountList.add(acc);
			}
		}
		if(!accountList.isEmpty()){
			validateSuidOnAccount(accountList,true);
		}
		
	}

	public void onAfterInsert(List<Account> acclist){
		
		if(isRecursiveForAfterInsert){
			
			return;
		} else {
			
			isRecursiveForAfterInsert = true;
		
		}
	
		SalutationUtility util = new SalutationUtility();
		List<SObject> acntList = new List<Account>();
		List<rC_Bios__Salutation__c> SalutationList = new List<rC_Bios__Salutation__c>();
		Id devRecordTypeId = 
									Schema.SObjectType.Account.getRecordTypeInfosByName()
									.get('Organization').getRecordTypeId();
 		for(Account acc : accList){
			if(acc.RecordTypeId == devRecordTypeId){
				acntList.add(acc);
			}
		}
		if(acntList.size() >0){
			SalutationList = util.createChildSalutation(acntList);
			if(SalutationList.size() > 0) {
				
				Database.SaveResult[] salutationResult = Database.insert(salutationList, true); 
				
			}
			
		}

		
		//populateSuidOnAccount(accList);
		//validateSuidOnAccount(accList,false);
		
		
		
	}

	public void onAfterUpdate(List<Account> acclist,Map<id,Account> oldMap){
		
		if(isRecursiveForAfterUpdate){
      return;
    }else{
        isRecursiveForAfterUpdate = true;
    }
		SalutationUtility util = new SalutationUtility();
		List<SObject> acntList = new List<Account>();
		List<rC_Bios__Salutation__c> SalutationList = new List<rC_Bios__Salutation__c>();
		Id devRecordTypeId = 
									Schema.SObjectType.Account.getRecordTypeInfosByName()
									.get('Organization').getRecordTypeId();
		for(Account acc : accList) {
			if(acc.Name != null && oldMap.get(acc.id).Name != acc.Name
				&& acc.RecordTypeId == devRecordTypeId ){
				acntList.add(acc);
			}
		}

		if(acntList.size() > 0){
			SalutationList = util.updateChildSaluatationline1(acntList);
			if(SalutationList.size() > 0) {
				
				Database.SaveResult[] salutationResult = Database.Update(salutationList, true); 
				contactService.isAutomaticUpdate = true;
			}
		}
	}
	
	// Added By : Aditi B T-483014/S-397633
	// This method will check whether entered suid 
	// value is valid or not ,If entered value is not valid
	// this method will throw a validation error message
	public void validateSuidOnAccount(List<Account> accList,Boolean isupdate){
		Set<String> suidIdSet = new Set<String>();
		Boolean isValid;
		Set<String> suidSet = new Set<String>();
		Map<String, Integer> suidCountMap = new Map<String, Integer>();
		
		for(Account acc : accList){
		    if(acc.SUID__c != null ){ 
		        suidSet.add(acc.SUID__c);
		        
		        if(!suidCountMap.containsKey(acc.SUID__c)){
		            suidCountMap.put(acc.SUID__c, 0); 
		        }
		        
		        suidCountMap.put(acc.SUID__c, suidCountMap.get(acc.SUID__c) + 1);
		        
		    }
		}
		
		suidIdSet = getAllSuidsForAccount(suidSet, accList,isupdate);
		
		for(Account acc : accList ){
			if(acc.SUID__c != null ){
				if(acc.SUID__c.length() != 10){
					acc.addError(Label.SUID_DIGIT_VALIDATION);
				} else if(suidIdSet.contains(acc.SUID__c) 
									|| suidCountMap.get(acc.SUID__c) > 1){
					acc.addError(Label.DUPLICATE_SUID_MESSAGE);
					
				} else {
					isValid = SUID_GeneratorService.isValidSUIDbasedonCheckDigit(acc.SUID__c, true);
					if(!isValid){
						acc.addError(Label.SUID_ACCOUNT_VALIDATION_MESSAGE);
					}	
				}
			} 
		}
	}	

	// Added By : Aditi B T-483014/S-397633
	// This method get all account SUID form org 
	// and return list of suids 
	public Set<String> getAllSuidsForAccount(Set<String> suidSet,	
																						List<Account> newAccList,
																						Boolean isUpdate){
		List<Account> accountList = new List<Account>();
		Set<String> suidIdSet = new Set<String>();
		List<Contact> conList = new List<Contact>();
		
		// get all account suids 
		accountList = [SELECT Id, SUID__C FROM Account
										WHERE SUID__c IN :suidSet
										AND id NOT IN : newAccList];

		
		//if(isUpdate) {
		conList = [SELECT Id, SUID__C FROM Contact
								WHERE SUID__c IN :suidSet];
									
		/*}	else {
			conList = [SELECT Id, SUID__C FROM Contact
								WHERE SUID__c IN :suidSet
								AND AccountId NOT IN : newAccList];	
		}		*/

		System.debug('ConList****'+ conList);			
		for (Account acc : accountList) {
			suidIdSet.add(acc.SUID__c);
		}

		for(Contact con : conList){
			suidIdSet.add(con.SUID__c);
		}

		System.debug('****SUID ID SET'+suidIdSet);
		return suidIdSet;

	}

	// Added By : Aditi B - T-483014/S-397633
	// This method populates suid on account 
	// when Suid is null at the time of insertion.
	
	/*
	public void populateSuidOnAccount(List<Account> accList){

	 	for(Account acc : accList){
 			if(acc.SUID__c == null && acc.SUID_Pool_Value__c != null ){
				acc.SUID__c = SUID_GeneratorService.getNextSUID(acc.SUID_Pool_Value__c, '3');
				System.debug('*****'+acc.SUID__c);
 			}
	 	}
	}*/

}