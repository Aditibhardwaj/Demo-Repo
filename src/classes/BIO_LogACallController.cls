/********************************************************************************************
* Trigger Name: BIO_LogACallController
* Author: Aditi Bhardwaj (Appirio)
* Date: [3/30/2016]
* Requirement Description: T-488510 [Create multiple Log A Call VF page]
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
public class BIO_LogACallController {

	// get set data members 
	public Task sobjTask {get;set;}
	public String contactSuid {get;set;}
	
	// Constructor
	public BIO_LogACallController(){
			
		setTaskDefaultData();

	}

	// This Method set default values 
	// for fields on Log a call page
	private void setTaskDefaultData(){
		sobjTask = new Task();
		sobjTask.OwnerId = UserInfo.getUserId();
		sobjTask.Subject = 'Call';
	}

	// This Method insert new task on 
	// all contacts whose suid match with 
	// suid in contactSUID text box
	public void onSave(){
		List<String> suidList = contactSuid.split(',');
		Set<Id> conIdSet = new Set<Id>();
		//Map<id,Contact> conMap = new Map<id,Contact>();
		Map<String,String> suidMap = new Map<String,String>();
		
		/*conMap = [SELECT id, SUID__c,(SELECT id,ActivityDate FROM Task
																 WHERE subject = 'call' ORDERBY ActivityDate LIMIT 1) 
							FROM Contact WHERE SUID__c in : suidList];
		*/
		// get contacts
		for(Contact con : [ SELECT id, SUID__c
												FROM Contact 
												WHERE SUID__c in : suidList]){
			conIdSet.add(con.Id);
			suidMap.put(con.SUID__c, con.id);
		}

		// Check If SUID exist or not
		if(validateSuid(suidMap, suidList)){
			createLogActivity(conIdSet);
		}
	}

	// Reset all values
	public void onCancel(){
		setTaskDefaultData();
	}

	// This Method creates task on contacts
	public void createLogActivity(Set<Id> conIdSet) {
		Task clonedTask;
		List<Task> newTaskList = new List<Task>();
		for(Id conId : conIdSet ){
			clonedTask = sobjTask.clone(false, false);
			clonedTask.whoId = conId;
			
			newTaskList.add(clonedTask);	
		}

		try{
			
			if(!newTaskList.isEmpty()){
					Database.UpsertResult[] taskResult = Database.upsert(newTaskList, false);
			}
		} Catch(Exception ex){
				
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+ex.getMessage()));
		}

	}

	// This method validates the entered SUID
	// If SUID is Valid i.e all SUID exist in org
	// then it return true else return false.
	public boolean validateSuid(MAp<String,String> suidMap, List<String> suidList){
		String suidsNotFound = '';
		
		for(String suid : suidList){
			if(!suidMap.containsKey(suid)){
				if(String.isBlank(suidsNotFound)){
					suidsNotFound = suid;	
				}else{
					suidsNotFound += ', '+suid;
				}
			} 
		}
		
		if(String.isBlank(suidsNotFound)){
			return true;
		}else{

			ApexPages.Message myMsg
					 = new ApexPages.Message(ApexPages.Severity.ERROR,label.SUID_NOT_FOUND+suidsNotFound);
            ApexPages.addMessage(myMsg);

       return false;     
			
		}

	}

}