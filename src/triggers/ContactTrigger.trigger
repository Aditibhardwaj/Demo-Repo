trigger ContactTrigger on Contact (before insert, after insert,before update, after update, before delete) {
    if(Trigger.isUpdate){
        if(Trigger.isBefore)
            ContactService.onBeforeUpdate(Trigger.New, Trigger.oldMap);
        if(Trigger.isAfter)
            ContactService.onAfterUpdate(Trigger.New, Trigger.oldMap);
    }else if(Trigger.isDelete){
        ContactService.onAfterDelete(Trigger.old);
    }else if(Trigger.isInsert && Trigger.isAfter){
        ContactService.onAfterInsert(Trigger.New);
    }else if(Trigger.isInsert && Trigger.isBefore){
        ContactService.onBeforeInsert(Trigger.New);
    }else if(Trigger.isDelete && Trigger.isBefore){
        //ContactService.onBeforeDelete(Trigger.old,trigger.oldMap);
    }
}