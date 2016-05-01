/********************************************************************************************
* Class Name: SS_DisplayInteractionHistory_AC
* Author: Aditi Bhardwaj (Appirio)
* Date: [7/4/2016]
* Requirement Description: Extension class for SS_DisplayInteractionHistory page
* Date Modified                Modified By                  Description of the update
************************************************************************************************/

public with sharing class SS_DisplayInteractionHistory_AC {
    
    // List will hold data to display on page
    public List<DisplayInteractionHistoryWrapper> contactIntractionHistoryList {get;set;}
    
    
 
  // Constructor
  public SS_DisplayInteractionHistory_AC(ApexPages.StandardController stdController){
    String contactId;
    if(stdController != null){
            contactId = stdController.getId();
    }
    if(!String.isBlank(contactId)){
        contactIntractionHistoryList = populateInteractionHistory(contactId);
    }
  }

  // This method populates contactIntractionHistoryList with 
  // contact report and log a call activity records
  private List<DisplayInteractionHistoryWrapper> populateInteractionHistory(
        String contactId
    ){
    List<DisplayInteractionHistoryWrapper> tempHistoryList = 
            new List<DisplayInteractionHistoryWrapper>();
    
    List<Contact_Report__c> contactReportList = new List<Contact_Report__c>();
    List<Task> logACallActivityList = new List<Task>(); 
    contactIntractionHistoryList = new List<DisplayInteractionHistoryWrapper>();
    
    // Get contact report records
    contactReportList = [SELECT id,Purpose__c,Type__c   ,
                                                            Author__r.Name,Contact_Date__c
                                                FROM Contact_Report__c 
                                                WHERE Contact__c = :contactId
                                                ORDER BY Contact_Date__c ASC NULLS LAST
                                                LIMIT 50];

        
        // Get log a call activity records
        logACallActivityList = [SELECT id,Subject,ActivityDate,
                                                                        CreatedBy.Name,Status,Type
                                                        FROM Task
                                                        WHERE WhoId = :contactId
                                                        AND
                                                        Status = :SalutationConstants.COMPLETED
                                                        AND Subject = :SalutationConstants.CALL
                                                        ORDER BY ActivityDate   ASC NULLS LAST
                                                        LIMIT 50];                                      
        

        // Adding contact report records in temporary list
        
        for(Contact_Report__c temp : contactReportList){
            tempHistoryList.add(new DisplayInteractionHistoryWrapper(
                
                temp.id,
                'Contact Report',
                temp.Type__c,
                temp.Contact_Date__c,
                temp.Author__r.Name,
                temp.Purpose__c
                )
            );
        }
        
        // Adding logACallActivity records in temporary list
        
            for(Task temp : logACallActivityList){
                tempHistoryList.add(new DisplayInteractionHistoryWrapper(
                      temp.id,
                      'Activity',
                      temp.Subject,
                      temp.ActivityDate,
                      temp.CreatedBy.Name,
                      ''
                  )
                );
            }
    
        // Sorting records in list on the basis of date
        tempHistoryList.sort();

        // Populating contactIntractionHistoryList with 
        // first 50 records of temporary list
        
        for(Integer index = 0 ; index < 50  && index < tempHistoryList.size() ;index ++){
            
                contactIntractionHistoryList.add(tempHistoryList[index]);
        }

        return contactIntractionHistoryList;


  }

  
  
 // Wrapper class contains Payment History info to be display.
  public class DisplayInteractionHistoryWrapper implements Comparable {
        
    public id recordId {get;set;}
    public String recordType {get;set;}
    public String type {get;set;}
    public Date interactionDate {get; set;}
    public String author {get; set;}
    public String purpose {get; set;}
        
    
    // Constructor
    public DisplayInteractionHistoryWrapper(id recordId, String recordType, String type,
                                                                                    Date interactionDate,
                                                                                    String author, 
                                                                                    String purpose){
        this.recordId = recordId;
        this.recordType = recordType;                                                                    
        this.type = type;
        this.interactionDate = interactionDate;
        this.author = author;
        this.purpose =purpose;
     
    }

    // Performing sorting on basis of date
    public  Integer compareTo(Object objToCompare){
        if(interactionDate > (((DisplayInteractionHistoryWrapper)objToCompare).interactionDate)){
            return 1;
        }else if(interactionDate < (((DisplayInteractionHistoryWrapper)objToCompare).interactionDate)){
            return -1;  
        }else{
            return 0;
        }
        
       }

   

  }

  
}