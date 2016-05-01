/********************************************************************************************
* Trigger Name: RelationTrigger 
* Author: Jyoti Agarwal (Appirio)
* Date: [1/20/2016]
* Requirement Description: S-365176
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
trigger RelationshipTrigger on rC_Bios__Relationship__c (before insert, before update,after insert,after update) {

   RelationshipTriggerHandler handler;
   
    if(trigger.isInsert && trigger.isBefore){
        handler = new RelationshipTriggerHandler ();
        handler.onBeforeInsert(trigger.new);

    }
    if(trigger.isInsert && trigger.IsAfter){
        handler = new RelationshipTriggerHandler ();
      	handler.onAfterInsert(trigger.new);
 		} 
 }