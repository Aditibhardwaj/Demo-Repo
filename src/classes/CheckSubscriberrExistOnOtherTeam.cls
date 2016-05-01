/*
 * Appirio Inc.
 * Name : CheckSubscriberExistOnOtherTeam
 * Description : a class that is called from a flow. This class accepts a list
 *        of team and check if subscriber exist on any other active team or not.
 * Created Date : [25/04/16]
 * Created By   : [Aditi Bhardwaj]
 * Date Modified            Modified By         Description of the update
 */

global class CheckSubscriberrExistOnOtherTeam  {
  global class ActionRequest{
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
    List<List<rC_Education__Team__c>> teamList = new List<List<rC_Education__Team__c>>();
    //List<rC_Education__Team__c> teamList = new List<rC_Education__Team__c>();
    for(integer i = 0; i < request.size(); i++){
          subscriberIdSet.add(request.get(i).subscriberId);
          teamMemberIdSet.add(request.get(i).teamMemberId);
          teamList.add(request.get(i).activeParentTeamList);
         
    }
     for(List<rC_Education__Team__c> team : teamList ){
        for(rC_Education__Team__c tm : team){
            teamIdSet.add(tm.id);
          }
      }
    List<List<rC_Bios__Relationship__c>> teamMemberList = new List<List<rC_Bios__Relationship__c>>();
    List<rC_Bios__Relationship__c> relationList = new List<rC_Bios__Relationship__c>();
    relationList = [SELECT id FROM rC_Bios__Relationship__c
                      WHERE id not in :teamMemberIdSet
                      AND rC_Education__User__c in :subscriberIdSet
                      AND rC_Education__Team__c in :teamIdSet];
    teamMemberList.add(relationList);
    return teamMemberList;
  }
}