/********************************************************************************************
* Apex Class Name: AddRelatedContacts
* Author: Rahul Khanchandani (Appirio)
* Date: [28/03/2016]
* Requirement Description: Webservice to update Primary and Secondary Contact (T-483161/S-347760)
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
global class AddRelatedContacts {
  // @description: A method that populates Primary and Secondary Contact on Related Account.
  // @param: String recordId
  // @param: String objectName
  // @param: String accountId
  // @param: String firstContactId
  // @param: String secondContactId
  // @param: String firstContactAPIName
  // @param: String secondContactAPIName
  // @return String errormsg
   webservice static String populateContactField(String recordId, String objectName, 
 																								String accountId, String firstContactId, 
 																								String secondContactId,
																							 	String firstContactAPIName,
																						  	String secondContactAPIName) {
 		String errormsg;
 		try{
 			//If Account is not present on Object
 			if(String.isBlank(accountId)) {
 				return errormsg =  Label.Populate_Account_First;
			}
			//Displaying Error Message If both contact and contact2 is present on object
			if(String.isNotBlank(firstContactId) && String.isNotBlank(secondContactId)){ 
				return	errormsg = Label.Primary_Secondary_Contact_Already_Populated;
			}
			String contactId = String.isNotBlank(firstContactId) ?
												 firstContactId : secondContactId;
			List<Contact> conList;
			if(String.isNotBlank(contactId)) {
					//Get Second Contact Associated With Respective Account
					conList  = [SELECT Id FROM Contact 
											WHERE AccountId = :accountId 
											AND Id !=: contactId LIMIT 1];
				
					if(conList.size() == 0){
						return errormsg = Label.NO_SECONDARY_CONTACT;
				}
			}
			else {
				//Get All Contact Associated with respective account
				conList = [SELECT Id FROM Contact WHERE AccountId = :accountId LIMIT 2];
				if(conList.size() == 0){ 
						return errormsg = Label.NO_PRIMARY_AND_SECONDARY_CONTACT;
				}
			}
			//Created New Reference for the Object
			sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
			if(conList.size() == 1) {
				//Updating Second Account Name
				if(String.isNotBlank(firstContactId) ) {
					sObj.put(secondContactAPIName, conList.get(0).Id);
				}else {
					//Updating First Account Name
					sObj.put(firstContactAPIName, conList.get(0).Id);
				}
				sObj.put('Id',recordId);
				update sObj;
			} 
			//Updating Both First and Second Contact Name
			else if(conList.size() == 2) {
				sObj.put(secondContactAPIName, conList.get(0).Id);
				sObj.put(firstContactAPIName, conList.get(1).Id);
				sObj.put('Id',recordId);
				update sObj;
			}
		}
		catch(Exception e){
 			system.debug('TRACE: AddRelatedContacts - populateContactField - ' + e.getMessage());
			system.debug('TRACE: AddRelatedContacts - populateContactField - ' + e.getStackTraceString());
 		}
 		return errormsg;
 } 
}