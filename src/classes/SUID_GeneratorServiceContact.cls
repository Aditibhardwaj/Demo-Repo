//
// (c) 2016 Appirio, Inc.
//
// An apex class update SUID on Contact (method gets invoked from process builder)
//
// 1st March, 2016     Sudhir Kumar Jagetiya       Original
//
public class SUID_GeneratorServiceContact {
	@InvocableMethod
	// @description: A method that Update SUID on Contact.
  // @param: List<Id> list of contact ids that need to be updated with SUID
  // @return void
	public static void updateSUIDonContact(List<Id> contactIds) {
    List<Contact> contactNeedToBeUpdated = [SELECT Id, SUID_Pool_Value__c
                                              FROM Contact
                                             WHERE Id IN:contactIds
                                               AND SUID_Pool_Value__c != null];
    for(Contact con : contactNeedToBeUpdated) {
        con.SUID__c = SUID_GeneratorService.getNextSUID(con.SUID_Pool_Value__c, '02');
    }
    update contactNeedToBeUpdated;
	}
}