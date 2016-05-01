//
// (c) 2016 Appirio, Inc.
//
// An apex class update SUID on Account (method gets invoked from process builder)
//
// 1st March, 2016     Sudhir Kumar Jagetiya       Original
//
public class SUID_GeneratorServiceAccount {
	@InvocableMethod
	// @description: A method that Update SUID on Account.
  // @param: List<Id> list of account ids that need to be updated with SUID
  // @return void
	public static void updateSUIDonAccount(List<Id> accountIds) {
    List<Account> accountNeedToBeUpdated = [SELECT Id, SUID_Pool_Value__c
                                              FROM Account
                                             WHERE Id IN:accountIds
                                               AND SUID_Pool_Value__c != null];
    for(Account acc : accountNeedToBeUpdated) {
      acc.SUID__c = SUID_GeneratorService.getNextSUID(acc.SUID_Pool_Value__c, '03');
    }
    update accountNeedToBeUpdated;
	}
}