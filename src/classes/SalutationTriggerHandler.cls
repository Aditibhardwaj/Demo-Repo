/********************************************************************************************
* Trigger Name: SalutationTriggerHandler
* Author: Aditi Bhardwaj (Appirio)
* Date: [1/11/2016]
* Requirement Description: S-372561 [Contact Publication Salutation (Auto-Create) - Females Widowed or Married at Death]
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
Public class SalutationTriggerHandler{

	// This Method returns list of contact 
	// to pass in updateSalutation Methods 
	Map <Id,Account> accMap ;
	public static boolean isRecursive = false;
	public static boolean isOverrideUpdatedToFalse = false;
	public List<contact> getContactList(Set<Id> conIdSet){
		List<Contact> conList = new List<Contact>();
			conList = [SELECT Id,rC_Bios__Preferred_Contact__c,
													rC_Bios__Secondary_Contact__c,
													rC_Bios__Gender__c,
													No_Prefix__c,
													AccountId,
													Salutation,
													Prof_Suffix__c,
													FirstName,LastName,
													APP_Suffix__c,
													rC_Bios__Marital_Status__c,
													rC_Bios__Middle_Name__c
								FROM Contact
								WHERE Id in :ConIdSet];

			return conList;
	}



	// This Method performs After insert operations on Salutation object
	public void onAfterInsert(List<rC_Bios__Salutation__c> salutationList){
		List<Contact> conList = new List<Contact>();
		Set<Id> ConIdSet = new Set<Id>();
		SalutationUtility util = new SalutationUtility();
		Set<Id> accIdSet = new Set<Id>();
		// Added By Aditi B :T-467962/S-368432 
		// Update household inside salutation on update on parent account or contact
		for(rC_Bios__Salutation__c sal : salutationList){
			if(sal.rC_Bios__Salutation_Type__c == 'Standard Informal'){
				ConIdSet.add(sal.rC_Bios__Contact__c);
			}
			
		}
		conList = getContactList(ConIdSet);
		for(Contact con : conList ){
			accIdSet.add(con.AccountId);
		}
		if(accIdSet.size() > 0){
			accMap = new Map<id,Account>([SELECT Id,(SELECT id,
																								Override__c,
																								rC_Bios__Salutation_Line_1__c,
																								rC_Bios__Salutation_Type__c 
																								FROM 
																								rC_Bios__Salutations__r
																								WHERE 
																								rC_Bios__Salutation_Type__c 
																								= 'Household Standard Informal')
																		FROM Account
																		WHERE Id In : accIdSet]);
		}
		
		
		

		if(conList.size() >0 && accMap.size()>0){
			util.updateHouseHoldChildSalutations(conList);
		} // End of T-467962/S-368432 
		updateChildSalOnContact(salutationList);

	}

	// This Method performs After update operations on Salutation object
	public void onAfterUpdate(List<rC_Bios__Salutation__c> salutationList,
														Map<id,rC_Bios__Salutation__c> OldSalMap){
		// Added By Aditi B :T-467962/S-368432 
		// Update household inside salutation on update on parent account or contact

		SalutationUtility util = new SalutationUtility();
		List<Contact> conListToUpdate = new List<Contact>();
		Set<Id> conIdSetToUpdate = new Set<Id>();
		for (rC_Bios__Salutation__c sal : salutationList){
			if((sal.rC_Bios__Salutation_Type__c == 'Formal Name'
					&& sal.Override__c == true
					&& sal.rC_Bios__Inside_Salutation__c 
							!= oldSalMap.get(sal.id).rC_Bios__Inside_Salutation__c)
				|| (sal.rC_Bios__Salutation_Type__c == 'Standard Informal'
						&& sal.rC_Bios__Inside_Salutation__c 
							!= oldSalMap.get(sal.id).rC_Bios__Inside_Salutation__c)){
				
				conIdSetToUpdate.add(sal.rC_Bios__Contact__c);
			
			}

		}
		conListToUpdate = getContactList(conIdSetToUpdate);
		if(conListToUpdate.size() >0){
			util.updateHouseHoldChildSalutations(conListToUpdate);
		}// End of T-467962/S-368432
	
		calculateManualAndAutomaticUpdate(salutationList,OldSalMap);	
	 	if(isRecursive){
        return;
    }
    else{
        isRecursive = true;
    }
		
		updateSalutationOnOverride(salutationList,OldSalMap);
		
		
		
	}

	public void onAfterDelete(List<rC_Bios__Salutation__c> oldSalutationList){

		// Added By Aditi B :I-200683/S-368432 
		// Delete of Contact's "Standard Informal" Salutation Record 
		// should result in update of HH's Household Standard Informal
		
		SalutationUtility util = new SalutationUtility();
		List<Contact> conListToUpdate = new List<Contact>();
		Set<Id> conIdSetToUpdate = new Set<Id>();
		for (rC_Bios__Salutation__c sal : oldSalutationList){
				if(sal.rC_Bios__Salutation_Type__c == 'Standard Informal'){
							
					
					conIdSetToUpdate.add(sal.rC_Bios__Contact__c);
				
				}

		}
		conListToUpdate = getContactList(conIdSetToUpdate);
		if(conListToUpdate.size() >0){
			util.updateHouseHoldChildSalutations(conListToUpdate);
		}// End of I-200683/S-368432

	}
	
	// This Method will update child  salutation line 
	// on contact's publication child saluatation. 
	public void updateChildSalOnContact(List<rC_Bios__Salutation__c> salList){
		Id devRecordTypeId = 
								Schema.SObjectType.rC_Bios__Salutation__c.getRecordTypeInfosByName()
								.get('Name').getRecordTypeId();
		
		Set<Id> conIdSet = new Set<Id>();						
		List<Contact> conList = new List<Contact>();
		List<rC_Bios__Salutation__c>	salListToUpdate = new List<rC_Bios__Salutation__c>();
		Id conId;		

		// Get Parent contact Id		
		for(rC_Bios__Salutation__c sal : salList){
			if(sal.RecordTypeId == devRecordTypeId
					&& sal.rC_Bios__Salutation_Type__c == 'Registration/Birth Name'
					&&	sal.rC_Bios__Contact__c	!= null ){
					conIdSet.add(sal.rC_Bios__Contact__c);
			}
		}

		// Get contact information to pass
		conList = [SELECT Id,FirstName,LastName,Salutation,Prof_Suffix__c,
											rC_Bios__Middle_Name__c,APP_Suffix__c,rC_Bios__Gender__c,
											rC_Bios__Marital_Status__c,No_Prefix__c
							 FROM Contact 
							 where id in : conIdSet];
		
		if(conList.size() > 0){
			SalutationUtility util = new SalutationUtility();

			//Calling update method of Salutationutility 
			salListToUpdate = util.updateChildSaluatationline1(conList);

			// Update slautation record
			if(salListToUpdate.size() >0) {
				Database.SaveResult[] salutationResult = Database.Update(salListToUpdate, true); 
			}
		}
	}

	// Added By Aditi B :T-479317/S-368271
	// This method will trigger Salutation Recalculation 
	// when Override is change to False
	public void updateSalutationOnOverride(List<rC_Bios__Salutation__c> salutationList,
																					Map<id,rC_Bios__Salutation__c> OldSalMap	)	{

		SalutationUtility util = new SalutationUtility();
		List<Contact> conlist = new List<Contact>();
		Set<Id> conIdSet = new Set<Id>();
		Set<Id> accIdSet = new Set<Id>();
		List<contact> contactList = new List<Contact>();
		List<rC_Bios__Salutation__c> salutationListToUpdate = 
												new List<rC_Bios__Salutation__c>();

		
		for(rC_Bios__Salutation__c sal : salutationList){
			if(sal.Override__c == false && 
					oldSalMap.get(sal.id).Override__c != sal.Override__c){
					
					conIdSet.add(sal.rC_Bios__Contact__c);
					accIdSet.add(sal.rC_Bios__Account__c);
			}
		}

		if(!(accIdSet.isEmpty())){
			contactList = [SELECT id FROM CONTACT
										 WHERE AccountId in :accIdSet];
		 	for(Contact con :contactList){
		 		conIdSet.add(con.id);
		 	}
		}
		
		if(!(conIdSet.isEmpty())){
			conList = getContactList(conIdSet);
		}
		
		if(!conList.isEmpty()){
			salutationListToUpdate = util.updateChildSaluatationline1(conList);
			if( salutationListToUpdate.size() >0 ){
				//isOverrideUpdatedToFalse = true;
				Database.SaveResult[] salutationResult
									 = Database.Update(salutationListToUpdate, false); 
									 
			}
			
			
			if(!conList.isEmpty()){
			 util.updateHouseHoldChildSalutations(conList);
			}
			
			
		} // End of T-479317/S-368271
	}
	

	// Added by Aditi B : T-479315/S-385124
	// Modified By Aditi B : T-479314/S-387056
	// This Method update Override and Auto Update 
	// on salutation,when a User manually updates an Salutation
	 
	public void calculateManualAndAutomaticUpdate(List<rC_Bios__Salutation__c> salutationList,
																					Map<id,rC_Bios__Salutation__c> OldSalMap){
		List<rC_Bios__Salutation__c> salutationListToUpdate 
												= new List<rC_Bios__Salutation__c>();
										
		Set<Id> SalIdSet = new Set<Id>();	
		rC_Bios__Salutation__c salutationToUpdate;									
		for(rC_Bios__Salutation__c sal : salutationList){
			if((oldSalMap.get(sal.id).rC_Bios__Inside_Salutation__c 
						!= sal.rC_Bios__Inside_Salutation__c
				|| oldSalMap.get(sal.id).rC_Bios__Salutation_Line_1__c 
						!= sal.rC_Bios__Salutation_Line_1__c
				|| oldSalMap.get(sal.id).rC_Bios__Salutation_Line_2__c 
						!= sal.rC_Bios__Salutation_Line_2__c
				|| oldSalMap.get(sal.id).rC_Bios__Account__c 
						!= sal.rC_Bios__Account__c
				|| oldSalMap.get(sal.id).rC_Bios__Contact__c 
						!= sal.rC_Bios__Contact__c
				||  oldSalMap.get(sal.id).rC_Bios__Salutation_Type__c 
						!= sal.rC_Bios__Salutation_Type__c
				|| oldSalMap.get(sal.id).Salutation_Use__c 
						!= sal.Salutation_Use__c )){
				 
					
					if(contactService.isAutomaticUpdate == false){
						salutationToUpdate = new rC_Bios__Salutation__c();
						salutationToUpdate.id = sal.id;
						// Setting Override to true 
						salutationToUpdate.Override__c = true;
						// Setting Auto Update to false
						salutationToUpdate.Auto_Updated__c = false;
						
						salutationListToUpdate.add(salutationToUpdate);
						
					} else {
							salutationToUpdate = new rC_Bios__Salutation__c();
							salutationToUpdate.id = sal.id;
							// Setting Override to false
							salutationToUpdate.Override__c = false;
							// Setting Auto Update to true
						//	if(!isOverrideUpdatedToFalse){
								salutationToUpdate.Auto_Updated__c = true;
						//	}
							salutationListToUpdate.add(salutationToUpdate);
					}
			}
		}

	
		if(!salutationListToUpdate.isEmpty()){
			Database.SaveResult[] salutationResult
									 = Database.Update(salutationListToUpdate, false); 
		}

	}

	
}