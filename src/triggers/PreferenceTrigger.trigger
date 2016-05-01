/*
** @author : (c) 2015 Appirio, Inc.[ Vivek Ojha]
** @date : 10/22/2015
** @description : Preference Trigger for all CRUD events. 
** @summary : There are 7 trigger events. 3 BEFORE Events (Insert, Update, Delete), 4 AFTER Events (Insert, Update, Delete, Undelete).
**            Best Practice for trigger development in SF dictates there should be only one trigger class created for each sObject. Using 
**            this template provides single source for all sObject trigger events as well as control over the execution order. 
*/
trigger PreferenceTrigger on rC_Bios__Preference__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
       // declare handler  
    PreferenceTriggerHandler handler;
          
  
    if(Trigger.isDelete && Trigger.isBefore){
        // before delete event  
         PreferenceTriggerHandler.onBeforeDelete(Trigger.old,Trigger.oldMap);
    }else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
        PreferenceTriggerHandler.onAfterInsert(Trigger.new);        
    }else if(Trigger.isUpdate && Trigger.isAfter){
        PreferenceTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);    
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        PreferenceTriggerHandler.onAfterDelete(Trigger.old);    
    }
    
      if(Trigger.isInsert && Trigger.isBefore){
        PreferenceTriggerHandler.onBeforeInsert(Trigger.new);         
    }
   
    else if(Trigger.isUpdate && Trigger.isBefore){
       PreferenceTriggerHandler.onBeforeUpdate(Trigger.new ,Trigger.oldMap); 
       
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        // after delete event 
        // event not implemented
        PreferenceTriggerHandler.onAfterDelete(Trigger.oldMap);
        
        
    }
     /*else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event  
        // event not implemented
    }
    
    else if(Trigger.isUnDelete){ 
        // undelete event  
        // event not implemented      
    }   */
}