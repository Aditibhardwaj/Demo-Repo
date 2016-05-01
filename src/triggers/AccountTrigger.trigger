/********************************************************************************************
* Trigger Name: AccountTrigger
* Author: Aditi Bhardwaj (Appirio)
* Date: [12/10/2015]
* Requirement Description: S-368426 [Organization Salutations: Outside & Publication (Auto-Create)]
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
trigger AccountTrigger on Account (before insert, after insert,before update, after update, before delete) {
    AccountTriggerHandler handler;
    if(trigger.isInsert && trigger.isAfter){
        handler = new AccountTriggerHandler();
        handler.onAfterInsert(trigger.new);

    } else if (trigger.isUpdate &&trigger.isAfter) {
	    	handler = new AccountTriggerHandler();
	      handler.onAfterUpdate(trigger.new,trigger.oldMap);
    
    } else if (trigger.isUpdate && trigger.isBefore){
    		handler = new AccountTriggerHandler();
        handler.onBeforeUpdate(trigger.new,trigger.oldMap);
	     

    } else if (trigger.isInsert && trigger.isBefore){
    		handler = new AccountTriggerHandler();
	      handler.onBeforeInsert(trigger.new);
    	
    } 

}