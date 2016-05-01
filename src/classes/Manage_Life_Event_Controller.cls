public without sharing class Manage_Life_Event_Controller {
    
    private final Contact con;
    public boolean alreadyMarried{get;set;}
    public Contact contactWithRelatedObject{get;set;}
    public contact cont{get;set;}
    public boolean checkContact{get;set;}
    public contact detailContact{get;set;}
    public boolean displayPanel{get;set;}
    public Contact contactRecord {get; set;}
    //public rC_Bios__Relationship__c startDateAndEndDate{get;set;}
    public rC_Bios__Relationship__c marriageRelationship{get;set;}
    public rC_Bios__Relationship__c divorceRelationship{get;set;}
    
    
    public string nameOfSpouse{get;set;}
    
    public Manage_Life_Event_Controller(ApexPages.StandardController stdController) {
        this.con = (Contact)stdController.getRecord();
        //startDateAndEndDate = new rC_Bios__Relationship__c(); 
        marriageRelationship = new rC_Bios__Relationship__c();
        divorceRelationship = new rC_Bios__Relationship__c();
        alreadyMarried = false;
        contactWithRelatedObject = [Select Id , AccountId,FirstName, LastName ,rC_Bios__Secondary_Contact__c , rC_Bios__Preferred_Contact__c,
                                                            rC_Bios__Marital_Status__c FROM Contact Where Id = :con.Id ]; 
        cont = new Contact();
        cont.rC_Bios__Marital_Status__c = 'Married';
        checkContact = true;
        displayPanel = false;
        nameOfSpouse = '';
        
        if (contactWithRelatedObject.rC_Bios__Marital_Status__c == 'Married'){
                alreadyMarried = true;
        }
        
        //showerrorMessage();
        //divorceSpouseDetails();
        
        
    }
    
    
    public void spouseDetailBeforeMarriage(){
        
        for(Contact ctl : [Select FirstName , LastName FROM Contact Where AccountId = :contactWithRelatedObject.AccountId  AND Id != :contactWithRelatedObject.Id]){
            if(ctl.FirstName != null ){
                nameOfSpouse = ctl.FirstName + ' ' + ctl.LastName ;
            }else{
                nameOfSpouse =  ctl.LastName;
            }
            
        }
        
        //System.assert(false , '>>>>' + nameOfSpouse);
        
    }
    
    
    
    
    // Error Message Method
    public PageReference showerrorMessage(){
          if(alreadyMarried == true){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You are already Married. If this is valid, you must divorce first and then re-marry them.'));
              return null;
          }else if(alreadyMarried == false){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You can\'t divorced until you are married.'));
              return null;
          }
           return null;
            
        
    }
    
     
     //**************************************************************************************************************** 
    //Method to fetch the fields from Field Set Marriage Realtionsfields.
    //****************************************************************************************************************
    
    
   /* public List<Schema.FieldSetMember> getMarriageRelationFields() {
        return SObjectType.rC_Bios__Relationship__c.FieldSets.ADAPT_Life_Events_Marriage.getFields();
    }*/
    
    //**************************************************************************************************************** 
    //Method to fetch the fields from Field Set Divorce Realtionsfields.
    //****************************************************************************************************************
    
    
    /*public List<Schema.FieldSetMember> getDivorceRelationFields() {
        return SObjectType.rC_Bios__Relationship__c.FieldSets.ADAPT_Life_Events_Divorce.getFields();
    }*/


    
    
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
           Id contactToContactRelation;
           if(Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().containsKey('Contact - Contact')){
               contactToContactRelation = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Contact').getRecordTypeId();
            }
           Account houseHoldAccount = new Account(rC_Bios__Active__c = true ,
                                                    RecordTypeId = devRecordTypeId,
                                                    Name = cont.FirstName + ' ' + cont.LastName  );
           
           insert houseHoldAccount;
           
           cont.AccountId = houseHoldAccount.Id;
           
           insert cont;
           //startDateAndEndDate
           /*rC_Bios__Relationship__c relation = new rC_Bios__Relationship__c(RecordTypeId = contactToContactRelation ,	
                                                                 rC_Bios__Role_1__c = 'Spouse/Partner' ,
                                                                 rC_Bios__Role_2__c = 'Spouse/Partner' ,
                                                                 rC_Bios__Contact_1__c = con.Id ,
                                                                 rC_Bios__Contact_2__c = cont.Id,
                                                                 rC_Bios__Active__c = true,
                                                                 rC_Bios__Category__c = 'Family',
                                                                 rC_Bios__Starting_Month__c = startDateAndEndDate.rC_Bios__Starting_Month__c,
                                                                 rC_Bios__Starting_Day__c = startDateAndEndDate.rC_Bios__Starting_Day__c,
                                                                 rC_Bios__Starting_Year__c = startDateAndEndDate.rC_Bios__Starting_Year__c );
            insert relation;*/
            
            marriageRelationship.RecordtypeId = contactToContactRelation;
            marriageRelationship.rC_Bios__Role_1__c = 'Spouse/Partner';
            marriageRelationship.rC_Bios__Role_2__c = 'Spouse/Partner';
            marriageRelationship.rC_Bios__Contact_1__c = con.Id;
            marriageRelationship.rC_Bios__Contact_2__c = cont.Id;
            marriageRelationship.rC_Bios__Active__c = true;
            marriageRelationship.rC_Bios__Category__c = 'Family';
            
            insert marriageRelationship;
            
           
           PageReference pgRef = new PageReference('/' + con.id); 
           pgRef.setRedirect(true);
           return pgRef; 
         }
       catch(Exception e){
           System.debug('The following exception has occurred: ' + e.getMessage());
           ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Something wnet wrong. Please contact Administrator .'));
           //retrun 
       }
       
       return null; 
       
       
       
    }
    
    //**************************************************************************************************************** 
    //Method to make change in spouse contact and make changes in the existing contact  and Create Realtionship record
    //****************************************************************************************************************
     
    public PageReference saveForExistingContact(){
     
     if(detailContact.rC_Bios__Marital_Status__c == 'Married'){
         
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The Selected contact is already Married'));
         return null;
         
     }
     
     
     
     try{
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
            Id contactToContactRelation;
              if(Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().containsKey('Contact - Contact')){
                   contactToContactRelation = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Contact').getRecordTypeId();
            }
            
            
            marriageRelationship.RecordtypeId = contactToContactRelation;
            marriageRelationship.rC_Bios__Role_1__c = 'Spouse/Partner';
            marriageRelationship.rC_Bios__Role_2__c = 'Spouse/Partner';
            marriageRelationship.rC_Bios__Contact_1__c = con.Id;
            marriageRelationship.rC_Bios__Contact_2__c = detailContact.Id;
            marriageRelationship.rC_Bios__Active__c = true;
            marriageRelationship.rC_Bios__Category__c = 'Family';
            
            insert marriageRelationship;
            
            
            
             PageReference pgRef = new PageReference('/' + contactWithRelatedObject.id); 
             pgRef.setRedirect(true);
             return pgRef;
         }catch(Exception e){
             System.debug('The following exception has occurred: ' + e.getMessage());
             ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Something wnet wrong. Please contact Administrator .'));
            }
     
        return null;
     
     
     
     }
    
    
    
    
    
    
    
        
    //**************************************************************************************************************** 
    //Method to fetch the spouse details upon select 
    //**************************************************************************************************************** 
    public void fetchspouseDetails(){
        //System.assert(false,'>>>' + cont.ReportsToId);
        detailContact = new Contact();
        if(cont.ReportsToId != null){
            detailContact = [Select Id, SUID__c , AccountId, Account.Name , FirstName, LastName ,Single_Household__c, rC_Bios__Work_Email__c , rC_Bios__Gender__c ,
                                            rC_Bios__Active__c , rC_Bios__Marital_Status__c ,rC_Bios__Work_Phone__c
                                            From Contact where Id = : cont.ReportsToId]; 
        }
       
        
        //System.assert(false,'>>>' +detailContact);
        
        
    }
    
     

    
    //**************************************************************************************************************** 
    //Method to redirect to contact page upon Cancel.
    //****************************************************************************************************************
    
    public PageReference cancelOnClick(){
         PageReference pgRef = new PageReference('/' + contactWithRelatedObject.id); 
         pgRef.setRedirect(true);
         return pgRef;
    }
    
    
     
    //**************************************************************************************************************** 
    //Method to divorce two contact and inactive the realtionship betwwen them.
    //****************************************************************************************************************
    
    public PageReference divorceSpouseDetails(){
        
        
       try{
            
       list<Contact> contactUnderHouseHold = new list<Contact>();
       List<Account> accountsToUpdate = new List<Account>();
       List<Contact> contactsToUpdate = new List<Contact>();
       list<rC_Bios__Relationship__c> realtionToUpdate = new list<rC_Bios__Relationship__c>();
       map<String,String> houseHoldContactToAccountId = new map<String , String>();
       Id relationHosueHold;
       Id contactToContactRelation;
       if(Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().containsKey('Account - Contact')){
           relationHosueHold = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Account - Contact').getRecordTypeId();
       }
       if(Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().containsKey('Contact - Contact')){
           contactToContactRelation = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Contact').getRecordTypeId();
       }
       
       String ParentAccountId;
       Set<String> contactWithNoHouseHold = new Set<String>();
       
       
       // Query on Contact to find all the details of the contact (Spose , HouseHold Contact and Account)
       for(Contact con : [Select Id , AccountId , Single_Household__c,rC_Bios__Marital_Status__c,rC_Bios__Preferred_Contact__c FROM Contact 
                                Where AccountId = :contactWithRelatedObject.AccountId ]){
                                    ParentAccountId = con.AccountId;
                                    contactUnderHouseHold.add(con);
                                    // create a map of contactId to single houseHold Account
                                    if(con.Single_Household__c != null){
                                       houseHoldContactToAccountId.put(con.Id,con.Single_Household__c); 
                                    }
                                    // if one of the contact does not have houseHold 
                                    else if(con.Single_Household__c == null){
                                        contactWithNoHouseHold.add(con.Id);
                                    }
                                        
                                }
            
        
        
        //if any of the contact has the houseHold then 
        if(houseHoldContactToAccountId.values().size() > 0){
            // Update the houseHold Accounts for the contacts 
            for(Account acc : [Select Id , rC_Bios__Active__c FROM Account where (Id IN :houseHoldContactToAccountId.values()) OR (Id = :ParentAccountId) ]){
                if(acc.Id == ParentAccountId){
                    acc.rC_Bios__Active__c = false;
                }
                else{
                    acc.rC_Bios__Active__c = true;
                }
                
                accountsToUpdate.add(acc);
            }
            
            // Update the status of the contacts (Married Couples)
            for(Contact cont : contactUnderHouseHold){
               if(houseHoldContactToAccountId.get(cont.Id) != null){
                   cont.rC_Bios__Marital_Status__c = 'Formerly Married/Partnered' ;
                   //cont.rC_Bios__Preferred_Contact__c = true;
                   cont.AccountId = houseHoldContactToAccountId.get(cont.Id);
                   contactsToUpdate.add(cont);
               }
               
                
               // Create an Individual relationship for contacts 
               /*rC_Bios__Relationship__c rcRelationship = new rC_Bios__Relationship__c(rC_Bios__Account_1__c = ParentAccountId,
                                                                                               rC_Bios__Contact_1__c = cont.Id,
                                                                                               rC_Bios__Category__c = 'Family',
                                                                                               rC_Bios__Role_1__c = 'Former Married Household',
                                                                                               rC_Bios__Role_2__c = 'Former Married Household',
                                                                                               recordTypeId = relationHosueHold,
                                                                                               rC_Bios__Stopping_Day__c = startDateAndEndDate.rC_Bios__Starting_Day__c,
                                                                                               rC_Bios__Stopping_Month__c = startDateAndEndDate.rC_Bios__Starting_Month__c,
                                                                                               rC_Bios__Stopping_Year__c = startDateAndEndDate.rC_Bios__Starting_Year__c);
                realtionToUpdate.add(rcRelationship);*/
                
                
                rC_Bios__Relationship__c rcRelationship = divorceRelationship.clone(false,true);
                rcRelationship.rC_Bios__Account_1__c = ParentAccountId;
                rcRelationship.rC_Bios__Contact_1__c = cont.Id;
                rcRelationship.rC_Bios__Category__c = 'Family';
                rcRelationship.rC_Bios__Role_1__c = 'Former Married Household';
                rcRelationship.rC_Bios__Role_2__c = 'Former Married Household';
                rcRelationship.recordTypeId = relationHosueHold;
                realtionToUpdate.add(rcRelationship);
                
                System.assert(false,rcRelationship);
               
               if(cont.Id != con.Id){
                  /*rC_Bios__Relationship__c relation = new rC_Bios__Relationship__c(rC_Bios__Contact_1__c = con.Id ,
                                                                                   rC_Bios__Contact_2__c = cont.Id ,
                                                                                   rC_Bios__Role_1__c = 'Former Spouse/Partner',
                                                                                   rC_Bios__Role_2__c = 'Former Spouse/Partner',
                                                                                   rC_Bios__Category__c = 'Family',
                                                                                   RecordTypeId = contactToContactRelation,
                                                                                   rC_Bios__Stopping_Day__c = startDateAndEndDate.rC_Bios__Starting_Day__c,
                                                                                   rC_Bios__Stopping_Month__c = startDateAndEndDate.rC_Bios__Starting_Month__c,
                                                                                   rC_Bios__Stopping_Year__c = startDateAndEndDate.rC_Bios__Starting_Year__c); 
                    realtionToUpdate.add(relation);  */
                    
                   rC_Bios__Relationship__c relation = divorceRelationship.clone(false,true);
                   relation.rC_Bios__Contact_1__c = con.Id;
                   relation.rC_Bios__Contact_2__c = cont.Id;
                   relation.rC_Bios__Role_1__c = 'Former Spouse/Partner';
                   relation.rC_Bios__Role_2__c = 'Former Spouse/Partner';
                   relation.rC_Bios__Category__c = 'Family';
                   relation.RecordTypeId = contactToContactRelation;
                   
                   realtionToUpdate.add(relation); 
                    
                                                                                   
               }
               
                
            }
            
            
            // fetch the previous Relationship and deactive that 
            for(rC_Bios__Relationship__c rc : [Select Id , rC_Bios__Contact_1__c , rC_Bios__Active__c FROM rC_Bios__Relationship__c
                                                WHERE rC_Bios__Contact_1__c IN :houseHoldContactToAccountId.KeySet() OR rC_Bios__Contact_2__c IN :houseHoldContactToAccountId.KeySet()]){
                                                    rc.rC_Bios__Active__c = false;
                                                    
                                                    realtionToUpdate.add(rc);     
                                                }
            
            
            update accountsToUpdate;
         
         }
        // if one of the two contact does not have Single_HouseHold 
        if(houseHoldContactToAccountId.values().size() == 1){
            
           Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
           Account houseHoldAccount = new Account(rC_Bios__Active__c = true ,
                                                    RecordTypeId = devRecordTypeId,
                                                    Name = 'New Account');
           
            
            insert houseHoldAccount;
            for(Contact con : contactUnderHouseHold){
                
                if(contactWithNoHouseHold.contains(con.Id)){
                    
                    con.AccountId = houseHoldAccount.Id;
                    con.rC_Bios__Marital_Status__c = 'Formerly Married/Partnered';
                    contactsToUpdate.add(con);
                    
                }
                
            }
            
            // Avoid duplicate creation of Relationship thus used flag
            
            
            
            update contactsToUpdate;
            
        }// If no contact have single HouseHold Account
        if(contactWithNoHouseHold.size() == 2){
            list<Account> accountToInsert = new List<Account>();
            list<Contact> contactToProcess = new List<Contact>();
            
            // Create a realtionship between two contact .startDateAndEndDate
            for(Contact conId : contactUnderHouseHold){
                /*rC_Bios__Relationship__c rcRelationship = new rC_Bios__Relationship__c(rC_Bios__Account_1__c = ParentAccountId,
                                                                                           rC_Bios__Contact_1__c = conId.Id,
                                                                                           rC_Bios__Category__c = 'Family',
                                                                                           rC_Bios__Role_1__c = 'Former Married Household',
                                                                                           rC_Bios__Role_2__c = 'Former Married Household',
                                                                                           recordTypeId = relationHosueHold,
                                                                                           rC_Bios__Stopping_Day__c = startDateAndEndDate.rC_Bios__Starting_Day__c,
                                                                                           rC_Bios__Stopping_Month__c = startDateAndEndDate.rC_Bios__Starting_Month__c,
                                                                                           rC_Bios__Stopping_Year__c = startDateAndEndDate.rC_Bios__Starting_Year__c);
                realtionToUpdate.add(rcRelationship);*/
                
                
                rC_Bios__Relationship__c rcRelationship = divorceRelationship.clone(false,true);
                rcRelationship.rC_Bios__Account_1__c = ParentAccountId;
                rcRelationship.rC_Bios__Contact_1__c = conId.Id;
                rcRelationship.rC_Bios__Category__c = 'Family';
                rcRelationship.rC_Bios__Role_1__c = 'Former Married Household';
                rcRelationship.rC_Bios__Role_2__c = 'Former Married Household';
                rcRelationship.recordTypeId = relationHosueHold;
                realtionToUpdate.add(rcRelationship);
                
                
                
                
                if(conId.Id != con.Id){
                  /*rC_Bios__Relationship__c relation = new rC_Bios__Relationship__c(rC_Bios__Contact_1__c = con.Id ,
                                                                                   rC_Bios__Contact_2__c = conId.Id ,
                                                                                   rC_Bios__Category__c = 'Family',
                                                                                   rC_Bios__Role_1__c = 'Former Spouse/Partner',
                                                                                   rC_Bios__Role_2__c = 'Former Spouse/Partner',
                                                                                   RecordTypeId = contactToContactRelation,
                                                                                   rC_Bios__Stopping_Day__c = startDateAndEndDate.rC_Bios__Starting_Day__c,
                                                                                   rC_Bios__Stopping_Month__c = startDateAndEndDate.rC_Bios__Starting_Month__c,
                                                                                   rC_Bios__Stopping_Year__c = startDateAndEndDate.rC_Bios__Starting_Year__c); 
                    realtionToUpdate.add(relation); */ 
                    
                    
                    
                   rC_Bios__Relationship__c relation = divorceRelationship.clone(false,true);
                   relation.rC_Bios__Contact_1__c = con.Id;
                   relation.rC_Bios__Contact_2__c = cont.Id;
                   relation.rC_Bios__Role_1__c = 'Former Spouse/Partner';
                   relation.rC_Bios__Role_2__c = 'Former Spouse/Partner';
                   relation.rC_Bios__Category__c = 'Family';
                   relation.RecordTypeId = contactToContactRelation;
                   
                   realtionToUpdate.add(relation);   
                      
                                                                                   
               }
                
               
                
                
                
            }
                                                                          
            for(rC_Bios__Relationship__c rc : [Select Id , rC_Bios__Contact_1__c , rC_Bios__Active__c FROM rC_Bios__Relationship__c
                                                    WHERE rC_Bios__Contact_1__c IN :contactWithNoHouseHold OR rC_Bios__Contact_2__c IN :contactWithNoHouseHold LIMIT 1]){
                                                    rc.rC_Bios__Active__c = false;
                                                    
                                                    realtionToUpdate.add(rc);     
                                                }
            //System.assert(false, contactUnderHouseHold[0].Id + ' >>>' + contactUnderHouseHold[1].Id);
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
            
            Account houseHoldAccount = new Account(rC_Bios__Active__c = true ,
                                                    RecordTypeId = devRecordTypeId,
                                                    Name = 'New Account'    );
            accountToInsert.add(houseHoldAccount);                                        
            Account houseHoldAccount2 = new Account(rC_Bios__Active__c = true ,
                                                    RecordTypeId = devRecordTypeId,
                                                    Name = 'New Account'    );                                        
            
            accountToInsert.add(houseHoldAccount2);
            
            insert accountToInsert;
            
            
            
            Contact cont = new Contact(Id = contactUnderHouseHold[0].Id,
                                       AccountId = houseHoldAccount.Id,
                                       rC_Bios__Marital_Status__c = 'Formerly Married/Partnered'
                                       );
                contactToProcess.add(cont);                       
            Contact cont2 = new Contact(Id = contactUnderHouseHold[1].Id,
                                       AccountId = houseHoldAccount2.Id,
                                       rC_Bios__Marital_Status__c = 'Formerly Married/Partnered'
                                       );                           
            
                 contactToProcess.add(cont2);
                 update contactToProcess;
            
        }else if(contactUnderHouseHold.size() == 1){
            
            for(Contact cont : contactUnderHouseHold){
                cont.rC_Bios__Marital_Status__c = 'Formerly Married/Partnered';
            }
            
            contactsToUpdate.add(cont);
            
        }
        
        
        //System.assert(false,contactsToUpdate); 
         if(contactsToUpdate.size() > 0){
             upsert contactsToUpdate;
         }
         if(realtionToUpdate.size() > 0){
             upsert realtionToUpdate;
         }
         
            
         //return null;   
         PageReference pgRef = new PageReference('/' + contactWithRelatedObject.id); 
         pgRef.setRedirect(true);
         return pgRef;   
            
       
            
            
            
            
            
        }catch(Exception e){
           System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Something wnet wrong. Please contact Administrator .'));
        }
        
        return null;    
    }            
        
        
        
        
    
    
    
    
    
    
    
    
        

}