/********************************************************************************************
* Apex Class Name: MarriageComponentControlleTest
* Author: Appirio
* Date: [04/04/2016]
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
public without sharing class MarriageComponentController {

    public contact cont{get;set;}
    public boolean checkContact{get;set;}
    public contact detailContact{get;set;}
    public boolean displayPanel{get;set;}
    public Contact contactRecord {get; set;}

    
    // Constructor
    public MarriageComponentController(){
        cont = new Contact();
        cont.rC_Bios__Marital_Status__c = 'Married';
        checkContact = true;
        displayPanel = false;
        
        
        
    }

    //**************************************************************************************************************** 
    //Method to fetch the fields from Field Set.
    //****************************************************************************************************************
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.contact.FieldSets.rC_Bios__Account_ManageContacts.getFields();
    }


    
    //**************************************************************************************************************** 
    //Method to create new Contact and make changes in the existing contact  and Create Realtionship record
    //****************************************************************************************************************
    public PageReference saveOnClick(){
       
       
       
       try{
           Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
           Account houseHoldAccount = new Account(rC_Bios__Active__c = true ,
                                                    RecordTypeId = devRecordTypeId,
                                                    Name = 'New Account'    );
           
           insert houseHoldAccount;
           
           cont.AccountId = houseHoldAccount.Id;
           insert cont;
           contact contactToUpdate;
           if(contactRecord.rC_Bios__Preferred_Contact__c == true){
              contactToUpdate = new Contact(Id = contactRecord.Id , 
                                     Single_Household__c = contactRecord.AccountId ,
                                     AccountId = houseHoldAccount.Id ,
                                     rC_Bios__Secondary_Contact__c = true,
                                     rC_Bios__Marital_Status__c = 'Married');
           }else if(contactRecord.rC_Bios__Secondary_Contact__c == true){
             contactToUpdate  = new Contact(Id = contactRecord.Id , 
                                     Single_Household__c = contactRecord.AccountId ,
                                     AccountId = houseHoldAccount.Id ,
                                     rC_Bios__Preferred_Contact__c = true,
                                     rC_Bios__Marital_Status__c = 'Married'); 
           }
           
           
            upsert contactToUpdate;                         
               
                                                                
           createRelationship(contactToUpdate.Id ,cont.Id);
           
           PageReference pgRef = new PageReference('/' + contactToUpdate.id); 
           pgRef.setRedirect(true);
           return pgRef;  
           
           
       }
       catch(Exception e){
           System.debug('The following exception has occurred: ' + e.getMessage());
       }
       
       return null;
       
       
       
    }
    
    
    //**************************************************************************************************************** 
    //Method to make change in spouse contact and make changes in the existing contact  and Create Realtionship record
    //****************************************************************************************************************
     public PageReference saveForExistingContact(){
     
     //System.assert(false, '>>>' + contactRecord.AccountId + '@@@@' + detailContact);
     
     
     if(detailContact.rC_Bios__Marital_Status__c == 'Married'){
         
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The Selected contact is already Married'));
         return null;
         
     }
     
     
     try{
         
             Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
             Account houseHoldAccount = new Account(rC_Bios__Active__c = true ,
                                                    RecordTypeId = devRecordTypeId,
                                                    Name = 'New Account' );
           
             insert houseHoldAccount;
             contact contactToUpdate;
             if(contactRecord != null){
             
                      /*   if(contactRecord.rC_Bios__Preferred_Contact__c == true){
                             contactToUpdate = new Contact(Id = contactRecord.Id , 
                                                 Single_Household__c = contactRecord.AccountId ,
                                                 AccountId = houseHoldAccount.Id ,
                                                 rC_Bios__Marital_Status__c = 'Married');
                        }else if(contactRecord.rC_Bios__Secondary_Contact__c == true){
                            contactToUpdate = new Contact(Id = contactRecord.Id , 
                                                 Single_Household__c = contactRecord.AccountId ,
                                                 AccountId = houseHoldAccount.Id ,
                                                 rC_Bios__Marital_Status__c = 'Married');
                       }*/
                         
             
             
             contactToUpdate = new Contact(Id = contactRecord.Id , 
                                     Single_Household__c = contactRecord.AccountId ,
                                     AccountId = houseHoldAccount.Id ,
                                     rC_Bios__Marital_Status__c = 'Married'); 
                                     
             upsert contactToUpdate; 
             createRelationship(contactToUpdate.Id , detailContact.Id);
             
             }
             
             PageReference pgRef = new PageReference('/' + contactToUpdate.id); 
             pgRef.setRedirect(true);
             return pgRef;
         }catch(Exception e){
             System.debug('The following exception has occurred: ' + e.getMessage());
            }
     
        return null;
     
     
     
     }
    
    
    //**************************************************************************************************************** 
    //Method to redirect to contact page upon Cancel.
    //****************************************************************************************************************
    
    public PageReference cancelOnClick(){
         PageReference pgRef = new PageReference('/' + contactRecord.id); 
         pgRef.setRedirect(true);
         return pgRef;
    }
    
   //**************************************************************************************************************** 
    //Method to moderate the boolean variable to toggle panels 
    //****************************************************************************************************************
    
    public void findExistingContact(){
        //System.assert(false,'>>>' + checkContact);
        if(checkContact == true){
            displayPanel = true;
        }else{
             displayPanel = false;
        }
        
        
    }
    
    //**************************************************************************************************************** 
    //Method to fetch the spouse details upon select 
    //****************************************************************************************************************
    
    public void fetchspouseDetails(){
        //System.assert(false,'>>>' + cont.ReportsToId);
        detailContact = new Contact();
        detailContact = [Select Id, SUID__c , AccountId, Account.Name ,  Single_Household__c, rC_Bios__Work_Email__c , rC_Bios__Gender__c ,
                                            rC_Bios__Active__c , rC_Bios__Marital_Status__c ,rC_Bios__Work_Phone__c
                                            From Contact where Id = : cont.ReportsToId];
        
        //System.assert(false,'>>>' +detailContact);
        
        
    }
    
    //**************************************************************************************************************** 
    //Method to create the relation record between two contacts.
    //****************************************************************************************************************
    
    private void createRelationship(Id SpouseContactId , Id currentContactId){
        try{
            Id devRecordTypeId = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Contact').getRecordTypeId();
            rC_Bios__Relationship__c realtion = new rC_Bios__Relationship__c(rC_Bios__Category__c = 'Family' ,
                                                                            rC_Bios__Role_1__c = 'Partner' ,
                                                                            rC_Bios__Role_2__c = 'Spouse',
                                                                            rC_Bios__Contact_1__c = currentContactId,
                                                                            rC_Bios__Contact_2__c = SpouseContactId,
                                                                            rC_Bios__Active__c = true,
                                                                            RecordTypeId = devRecordTypeId);
        
        insert realtion;
            
        }catch(Exception e){
            
        }
        
        
        
        
        
        
        
    }
    
    
}