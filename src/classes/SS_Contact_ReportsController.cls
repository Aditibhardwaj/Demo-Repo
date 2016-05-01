/*
 * Appirio Inc.
 * Name : SS_Contact_ReportsController
 * Description : Controller class for SS_Contact_Reports VF page
 * Created Date : [27/04/16]
 * Created By   : [Aditi Bhardwaj]
 * Date Modified            Modified By         Description of the update
 */
public class SS_Contact_ReportsController{

	// get set data members 
	public Contact_Report__c sObjcontactReport {get;set;}
	public Contact_Report__c contactReportForParticipant {get;set;}
	
	public String accName {get;set;}
	public String conName {get;set;}
	public List<Participant> participantList{get;set;}
	public List<TaskWrapper> taskList{get;set;}
	public TaskWrapper taskNewRec{get;set;}
	public List<SS_ContactReport_DefaultTasks__c> defaultTaskList{get;set;}

	// this variable used to remove participant
	public Integer removeIndex {get;set;}
	

	
	// Constructor
	public SS_Contact_ReportsController(ApexPages.StandardSetController  stdController){
			
		setDefaultData();
		
	}
	
	public void setDefaultData(){
		defaultTaskList = new List<SS_ContactReport_DefaultTasks__c>();
		
		
		sobjcontactReport = new Contact_Report__c();
		contactReportForParticipant = new Contact_Report__c();
		taskNewRec =  new TaskWrapper(new task (), false);
		
		String conId = ApexPages.currentPage().getParameters().get('id');
		
		participantList = new List<Participant>();
		taskList = new List<TaskWrapper>();
		defaultTaskList = [SELECT Subject__c,Comments__c FROM SS_ContactReport_DefaultTasks__c ];

		for(SS_ContactReport_DefaultTasks__c defaultTask :defaultTaskList){
				Task ss_task = new Task ();
				ss_task.subject = defaultTask.subject__C;
				ss_task.Priority = 'Normal';
				ss_task.Status = '	Not Started';
				ss_task.Description = defaultTask.Comments__c;
				TaskWrapper taskWrap = new TaskWrapper(ss_task,false);
				taskList.add(taskWrap);
		}
		// here we intialize the data
		if(String.isNotBlank(conId)){
		   for(Contact con : [SELECT Id, AccountId, Account.Name, Name FROM Contact WHERE Id =: conId LIMIT 1]){
		     sobjcontactReport.Account__c = con.AccountId;
		     sobjcontactReport.Contact__c = con.Id;
		     accName = con.Account.Name;
		     conName = con.Name;
		     
		     break;
		     
		   }
		}
		
		
		
		
	}
	
	public PageReference submitAction(){
		
		List<Task> taskListToInsert = new List<Task>();
		if(sobjcontactReport	!= null){
			Database.insert(sobjcontactReport, true); 
		
		    if(!tasklist.isEmpty()){
    			for(TaskWrapper twrap : taskList){
    				if(twrap.isCreate == true){
    					tWrap.sobjTask.WhatId = sobjcontactReport.id;
    					taskListToInsert.add(tWrap.sobjTask);
    				}
    			}

    		}
    		if(!taskListToInsert.isEmpty()){
    			Database.insert(taskListToInsert, true);
    		}
    		
    		return new PageReference('/'+sobjcontactReport.id);
    		
		    
		}
		
		System.debug('***** submit action is here we call this from action function for final submission');
		
		
		return null;
	
	}
 	public class Participant {
	 	public String type {get;set;}
	 	public String member {get;set;}
	 	
	 	public Participant(
    	 	    String type,
    	 	    String member
	 	    ){
	 		
	 		this.type = type ;
	 		this.member = member;
	 		

	 	}

 	}

 	public PageReference addParticipant(){
 	    
 	    
 	    Participant newParticipant;
 	    
 	    System.debug(contactReportForParticipant);
 	    if(contactReportForParticipant.Author__c != null){
     	    for(User usr : [SELECT Name FROM User WHERE Id = :contactReportForParticipant.Author__c LIMIT 1]){
     	    
         		newParticipant = new Participant(
         		    contactReportForParticipant.Type__c,
         		    usr.Name
         	    );
         	    
         		participantList.add(newParticipant);
         		break;
     	    }
     	    contactReportForParticipant.Type__c = '';
 	        contactReportForParticipant.Author__c = null; 
 	    }
 	    
 	    
 	    
 		System.debug('***Participant'+participantList );
 		return null;
 	}

 	public PageReference removeParticipantAction(){
 	    
 	    system.debug('remove index >>>>');
        system.debug(removeIndex);
        if(removeIndex <= participantList.size()){
            participantList.remove(removeIndex);    
        }    
        
        system.debug(participantList);
        
        return null;
 	}

 	// Wrapper class to create task
 	public class TaskWrapper {
	 	public Task sobjTask {get;set;}
	 	public Boolean isCreate {get;set;}
	 	public SS_ContactReport_DefaultTasks__c defaultTask {get;set;}
	 	TaskWrapper(){}
	 	public TaskWrapper(
    	 	    Task sobjTask,
    	 	    Boolean isCreate
	 	    ){
	 		
	 		this.sobjTask = sobjTask ;
	 		this.isCreate = isCreate;
	 		

	 	}

 	}

	public PageReference createTask(){
   
    TaskWrapper newTask;
    System.debug(contactReportForParticipant);
    	newTask = new TaskWrapper(
     		  taskNewRec.sobjTask,
     		  true
   	    );
     	    
   		taskList.add(newTask);
   		
 	    taskNewRec.sobjTask.subject ='';
  	 	taskNewRec.sobjTask.Description ='';
     	taskNewRec.sobjTask.status ='';
     	taskNewRec.sobjTask.Priority ='';
     	taskNewRec.sobjTask.ActivityDate =System.today();
   		System.debug('***newTask'+taskList );
		return null;
 	}
	
}