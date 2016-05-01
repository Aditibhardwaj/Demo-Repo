/********************************************************************************************
* Trigger Name: AccountTrigger
* Author: Aditi Bhardwaj (Appirio)
* Date: [1/11/2016]
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
trigger SalutationTrigger on rC_Bios__Salutation__c (before insert, after insert,before update,
																										 after update, before delete,
																										 after delete) {
	SalutationTriggerHandler handler;
    if(trigger.isInsert && trigger.isAfter){
        handler = new SalutationTriggerHandler();
        handler.onAfterInsert(trigger.new);
    }
    if(trigger.isUpdate && trigger.isAfter){
        handler = new SalutationTriggerHandler();
        handler.onAfterUpdate(trigger.new,trigger.oldMap);
    }
    if(trigger.isDelete && trigger.isAfter){
        handler = new SalutationTriggerHandler();
        handler.onAfterDelete(trigger.old);
    }

}