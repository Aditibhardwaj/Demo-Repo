// T-480623

public with sharing class AddParticipantController {
   public List<rC_Bios__Relationship__c> teamMemberList {get; set;}
   public rC_Education__Team__c team {get; set;}
   //public List<TeamMember> relationshipList{get;set;}
   public Contact_Report__c selectedContactReport;
   public String contactReportId;
   public static string memberRecordTypeId;
   public static string contactReportTeamId;
   public Boolean renderTeamPanel {get;set;}
   public string selectedType{get;set;}
   public Integer counter = 0;
   private List<rC_Education__Team__c> existingTeam;
   //public Map<Integer,TeamMember> finalMap {get;set;}
   //public Integer selectedIndex {get;set;}
   //public String selectedpicklistOption {get;set;}
   //public string selectedMember{get;set;}

     public addParticipantController(ApexPages.standardcontroller con){
      teamMemberList = new List<rC_Bios__Relationship__c>();
      system.debug('%%con%%'+con);
      if(ApexPages.currentPage().getParameters().get('id') != null){
          contactReportId = ApexPages.currentPage().getParameters().get('id');
      }
      else if(ApexPages.currentPage().getParameters().get('rpid') != null){
       contactReportId = ApexPages.currentPage().getParameters().get('rpid');
       system.debug('$rpid$$' +contactReportId);
      }
      system.debug('$$contactReportId$$' +contactReportId);
        memberRecordTypeId= [SELECT id FROM RecordType where sobjecttype = 'rC_Bios__Relationship__c' AND Name ='Contact Report' LIMIT 1].Id;

        renderTeamPanel = false;

        existingTeam = [Select Id FROM rC_Education__Team__c WHERE Contact_Report__c =: contactReportId LIMIT 1 ];
        renderTeamPanel = existingTeam.size() == 0;

        if(contactReportId != null){
          selectedContactReport = [Select Id, Name FROM Contact_Report__c WHERE ID =: contactReportId];
        }

        contactReportTeamId = [SELECT id FROM RecordType WHERE sobjecttype = 'rC_Education__Team__c' AND Name ='Contact Report' LIMIT 1].Id;
        team = new rC_Education__Team__c();
        team.Name = selectedContactReport.Name + ' - Participants';
        team.Contact_Report__c = selectedContactReport.Id;
        team.RecordTypeId = contactReportTeamId;
        team.rC_Education__Stage__c = 'Completed';
        team.rC_Education__Status__c = 'Inactive';

        for(Integer index = 0; index < 5; index++) {
          teamMemberList.add(new rC_Bios__Relationship__c(RecordTypeId = memberRecordTypeId, rC_Education__Team_Member__c = 'User'));
        }
     }



   public void insertMembers(){
    try {
        Boolean membersPresent = false;
      for(rC_Bios__Relationship__c teamMember : teamMemberList){
        if(teamMember.rC_Education__User__c != null || teamMember.rC_Bios__Contact_2__c != null){
          membersPresent = true;
          break;
        }
      }

      if(!membersPresent) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please add at least one team member.'));
      } else {
        if(existingTeam.size() == 0) {
          insert team;
        }
        else {
            team = existingTeam.get(0);
        }

        List<rC_Bios__Relationship__c> teamMembersNeedtoBeInserted = new List<rC_Bios__Relationship__c>();
        for(rC_Bios__Relationship__c teamMember : teamMemberList){
            if(teamMember.rC_Education__User__c != null || teamMember.rC_Bios__Contact_2__c != null){
              teamMember.rC_Education__Team__c = team.Id;
              teamMembersNeedtoBeInserted.add(teamMember);
            }
          }
        insert teamMembersNeedtoBeInserted;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Created Successfully.Thank you!'));
      }
   } catch(Exception ex) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error Encountered : '+ex));
   }
 }
}