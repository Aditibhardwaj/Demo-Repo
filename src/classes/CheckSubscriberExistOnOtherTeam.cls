/*
 * Appirio Inc.
 * Name : CheckSubscriberExistOnOtherTeam
 * Description : a class that is called from a flow. This class accepts a list
 *        of team and check if subscriber exist on any other active team or not.
 * Created Date : [25/04/16]
 * Created By   : [Aditi Bhardwaj]
 * Date Modified            Modified By         Description of the update
 */

global class CheckSubscriberExistOnOtherTeam  {
 
  // This class contains invocable variables
  global class ActionRequest {
    @InvocableVariable(required=true)
    public String subscriberId;
    
    @InvocableVariable(required=true)   
    public String teamMemberId;

    @InvocableVariable(required=true)
    public List<rC_Education__Team__c> activeParentTeamList;
       
  }

  @InvocableMethod (label='CheckSubscriber' 
        description='return list of Team Member with same user/ subscriber')
  public static List<List<rC_Bios__Relationship__c>> CheckSubscriber( List<ActionRequest> request ) {
    Set<Id> subscriberIdSet = new Set<Id>();
    Set<Id> teamMemberIdSet = new Set<Id>();
    Set<Id> teamIdSet = new Set<Id>();
    // Get Record type id for team member record type
    Id teamMemberRecTypeId = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().
                                    get('Team Member').getRecordTypeId(); 

    // Get values from invocable input parameters   
    for(integer i = 0; i < request.size(); i++){
        subscriberIdSet.add(request.get(i).subscriberId);
        teamMemberIdSet.add(request.get(i).teamMemberId);
       
        for(rC_Education__Team__c tm : request.get(i).activeParentTeamList){
         teamIdSet.add(tm.id);
        }
    }
   
    List<List<rC_Bios__Relationship__c>> teamMemberList 
      = new List<List<rC_Bios__Relationship__c>>();
    Map<ID,list<rC_Bios__Relationship__c>> mapSubIdToRCBios 
    = new Map<ID,list<rC_Bios__Relationship__c>>();
   
    // Get all team members from other active teams on same parent  
    // where user is same. 
    List<rC_Bios__Relationship__c> relationList = new List<rC_Bios__Relationship__c>();
    for(rC_Bios__Relationship__c rcbios : [SELECT id, rC_Education__User__c 
                      FROM rC_Bios__Relationship__c
                      WHERE id not in :teamMemberIdSet
                      AND rC_Education__User__c in :subscriberIdSet
                      AND rC_Education__Team__c in :teamIdSet
                      AND RecordTypeId = :teamMemberRecTypeId]){
    
    // Populate Maps        
    if(!mapSubIdToRCBios.containsKey(rcbios.rC_Education__User__c))
      mapSubIdToRCBios.put(rcbios.rC_Education__User__c, new list<rC_Bios__Relationship__c>{rcbios});
    else
      mapSubIdToRCBios.put(rcbios.rC_Education__User__c, mapSubIdToRCBios.get(rcbios.rC_Education__User__c));
       
    }

    // Adding output to teamMemberList to make input and output size same
    for(integer i = 0; i < request.size(); i++){
        teamMemberList.add(mapSubIdToRCBios.get(request.get(i).subscriberId)); 
     } 
    
   return teamMemberList;
  }
}