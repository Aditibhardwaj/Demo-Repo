/********************************************************************************************
* Trigger Name: OpportunityTrigger
* Author: Aditi Bhardwaj (Appirio)
* Date: [2/9/2016]
* Requirement Description: T-471530 [Auto create PROPOSAL name]
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
trigger OpportunityTrigger on Opportunity (before insert, after insert,before update, after update, before delete) {
	//OpportunityTriggerHandler handler ;
	if(trigger.isBefore && trigger.isInsert){
		//handler = new OpportunityTriggerHandler();
		OpportunityTriggerHandler.onBeforeInsert(trigger.new);
	}

}