/********************************************************************************************
* Trigger Name: OpportunityTriggerHandler
* Author: Aditi Bhardwaj (Appirio)
* Date: [2/9/2016]
* Requirement Description: T-471530 [Auto create PROPOSAL name]
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
public with sharing class OpportunityTriggerHandler{
	Static Id devRecordTypeId = 
								Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
								.get('Proposal').getRecordTypeId();
   
	Static Profile p = [SELECT Id FROM Profile WHERE Name = '1.0-OOD User' LIMIT 1 ];
	public static void onBeforeInsert(List<Opportunity> oppNewList){
		String oppName;
		// T-471530 [Auto create PROPOSAL name]
		if(userinfo.getProfileId() == p.id ){
			for(Opportunity opp : oppNewList ){
				if(opp.RecordTypeId == devRecordTypeId){
					oppName = !String.isEmpty(opp.Name)? opp.Name+'-' : '';
					oppName += !String.isEmpty(opp.Group__c) && !String.isEmpty(opp.Name) ? opp.Group__c :'';
					oppName = oppName.replaceAll(';','-');
					if(oppName.length()>120){
						opp.Name = oppName.left(120);
					} else {
						opp.Name = oppName;
					}

				}
			}
		}

	}

}