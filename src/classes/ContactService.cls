public class ContactService {
    
    private final static String CONSTITUENT_TYPE = 'Constituent Type';
    private static List<Contact> contactsToUpdate = new List<Contact>();
    static String contactHouseholdRecTypeId;
    static boolean stopRecursion = false;
    static boolean isRecursiveAfterInsert = false;
    static boolean isRecursiveAfterUpdate = false;
    static boolean isRecursiveBeforeInsert = false;
    static boolean isRecursiveBeforeUpdate = false;
    static boolean isRecursive = false;
    static boolean isSecondary = false;
    
    public static boolean  isAutomaticUpdate = false;
    static Map<String,Contact_Prefix_Mapping__c> prefixMap
                                            = Contact_Prefix_Mapping__c.getAll();
    static Map<String, List<Contact>> householdAccountIdToContactMap = new Map<String, List<Contact>>();
    static {
      contactHouseholdRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    }

    public static void resetIsRecursive(){
      isRecursive = false;
      isRecursiveAfterInsert = false;
      isRecursiveAfterUpdate = false;
      isRecursiveBeforeInsert = false;
      isRecursiveBeforeUpdate = false;
    }

    static Map<string, Contact> contactMap = new Map<string, Contact>();

    static Map<Id,List<Contact>> mapAccIdandActiveContacts = new Map<Id,List<Contact>>();
    

    // T-447553: NS- 11th Nov'15 - Added beforeInsert method
    public static void onBeforeInsert(List<Contact> contactNewList){
        
        for(Contact con: contactNewList){
         
            if(con.AccountId != null && contactHouseholdRecTypeId != null && con.RecordTypeId == contactHouseholdRecTypeId) {
                if(!mapAccIdandActiveContacts.containsKey(con.AccountId)) {
                    mapAccIdandActiveContacts.put(con.AccountId, new List<Contact>());
                }
                mapAccIdandActiveContacts.get(con.AccountId).add(con);
            }

            // Added By Aditi B :I-200978/S-368432
            if (con.rC_Bios__Preferred_Contact__c != true){
                  con.rC_Bios__Secondary_Contact__c = true;
            }
        }
        // method to validate active contacts
        checkActiveContacts(mapAccIdandActiveContacts.keySet(), contactNewList);
       if(isRecursiveBeforeInsert){
            return;
       }else{
            isRecursiveBeforeInsert = true;
       }
       //populateSuidOnContact(contactNewList);
        validateSuidOnContact(contactNewList);
        
        
        
        
    }

    private static void checkActiveContacts(Set<Id> accIds, List<Contact> contactNewList) {
        for(Contact con: [Select Id, AccountId, rC_Bios__Deceased__c From Contact Where AccountId in :accIds 
                                 And RecordTypeId = :contactHouseholdRecTypeId]) {
            if(con.rC_Bios__Deceased__c == false) {
                mapAccIdandActiveContacts.get(con.AccountId).add(con);    
            }
        }

        //Throw error if there exists more than 2 active contacts corresponding to same Account
        for(Contact con: contactNewList) {
            if(mapAccIdandActiveContacts.containsKey(con.AccountId)) {
                if(!con.rC_Bios__Deceased__c && mapAccIdandActiveContacts.get(con.AccountId).size() > 2)
                    con.addError(Label.Contact_Validation_Message);
            }
        }
    }


    public static void onAfterInsert(List<Contact> contactNewList){
      if(isRecursiveAfterInsert){
            return;
        }else{
            isRecursiveAfterInsert = true;
        }
        
      System.debug('***** contact new List1'+ contactNewList);
        SalutationUtility util = new SalutationUtility();
        List<rC_Bios__Salutation__c> salHouseHoldList = new List<rC_Bios__Salutation__c>();
        List<rC_Bios__Salutation__c> salutationList = new List<rC_Bios__Salutation__c>();
        for(Contact con : contactNewList){
            if(!con.rC_Bios__Deceased__c && contactHouseholdRecTypeId != null && con.RecordTypeId == contactHouseholdRecTypeId){
                if(!householdAccountIdToContactMap.containsKey(con.AccountId)){
                    householdAccountIdToContactMap.put(con.AccountId, new List<Contact>());
                }
                householdAccountIdToContactMap.get(con.AccountId).add(con);
            }
            contactMap.put(con.id, con);
        }
        System.debug('***** contact new List2'+ contactNewList);
        // fetchRelatedContacts(contactNewList, false);
        SalutationList = util.createChildSalutation(contactNewList);
        if(salutationList.size() > 0) {
            System.debug('***** list to insert'+ salutationList); 
            System.debug('***** contact new List4'+ contactNewList);
            Database.SaveResult[] salutationResult = Database.insert(salutationList, false); 
            System.debug('Salutation Inserted'); 
        }
        System.debug('***** contact new List5'+ contactNewList);
        System.debug('***** salHouseHoldList'+ salHouseHoldList);
        salHouseHoldList = util.createHouseholdSalutationOnAccount(contactNewList);

        if(salHouseHoldList.size () > 0){
          System.debug('***** contact new List6'+ contactNewList);
          System.debug('***** salHouseHoldList'+ salHouseHoldList);
           Database.SaveResult[] salutationResult = Database.insert(salHouseHoldList, false);
           isSecondary = true;  
           System.debug('household Salutation Inserted'); 
        }
        
        
        updateContactMaritalStatus(contactNewList);
        
        //Added By Aditi B : S-366710-[Contact Salutations Outside & Publication (Auto-Create)]
        System.debug('***** contact new List3'+ contactNewList);
        
        
        

    }
    public static void onBeforeUpdate(List<Contact> contactNewList, Map<Id, Contact> contactOldMap){
      List<Contact> conList = new list<Contact>();
      if(isRecursiveBeforeUpdate){
            return;
       }else{
            isRecursiveBeforeUpdate = true;
       }
       
      //populateSuidOnContact(contactNewList);

      for(Contact con : contactNewList){
        if(con.SUID__c != contactOldMap.get(con.id).SUID__c) {
          conList.add(con);
        }
      } 
      if(!conList.isEmpty()){
        validateSuidOnContact(conList);
      }
     /* if(isRecursiveBeforeUpdate){
            return;
       }else{
            isRecursiveBeforeUpdate = true;
       }
        householdAccountIdToContactMap = new Map<String, List<Contact>>();
        //Map<string, List<Contact>> accToContactMap = new Map<String, List<Contact>>();
        for(Contact c : contactNewList){
            System.debug('c.rC_Bios__Deceased__c=='+c.rC_Bios__Deceased__c);
            if(c.RecordTypeId == contactHouseholdRecTypeId && !c.rC_Bios__Deceased__c) {
               if(!householdAccountIdToContactMap.containsKey(c.AccountId)){
                  householdAccountIdToContactMap.put(c.AccountId, new List<Contact>()); 
               }
               householdAccountIdToContactMap.get(c.AccountId).add(c);
               
           }
        }

       fetchRelatedContacts(contactNewList, true);
        */
       
    }
    
    public static void onAfterUpdate(List<Contact> contactNewList, Map<Id, Contact> contactOldMap){
        //Map<string, List<Contact>> accToContactMap = new Map<String, List<Contact>>();
        Map<string, Contact> deceasedContactMap = new Map<string, Contact>();
        List<Id> accIdsToBeUpdated = new List<Id>();
        Set<Id> conIdSet = new Set<Id>();
         
       // if(!isSecondary){
        //Added by Aditi B :S-366710 -Contact Salutations Outside & Publication (Auto-Create)
        List<Contact> conList = new List<Contact>();
        List<Contact> householdConList = new List<Contact>();
        List<rC_Bios__Salutation__c> SalutationList = new List<rC_Bios__Salutation__c>();
        SalutationUtility util = new SalutationUtility();
        for(Contact con : contactNewList ){
            System.debug('contact Name updated' + con);
            //system.debug('Contact old'+);
          if(con.Salutation != contactOldMap.get(con.id).Salutation
            || con.No_Prefix__c != contactOldMap.get(con.id).No_Prefix__c 
            || con.FirstName != contactOldMap.get(con.id).FirstName
            || con.rC_Bios__Middle_Name__c != contactOldMap.get(con.id).rC_Bios__Middle_Name__c
            || con.APP_Suffix__c != contactOldMap.get(con.id).APP_Suffix__c
            || con.Prof_Suffix__c != contactOldMap.get(con.id).Prof_Suffix__c
            || con.LastName != contactoldMap.get(con.id).LastName
            || (con.rC_Bios__Marital_Status__c != contactoldMap.get(con.id).rC_Bios__Marital_Status__c
                && (con.rC_Bios__Marital_Status__c == 'Married At Death'
                    || con.rC_Bios__Marital_Status__c == 'Widowed'))
            || (con.rC_Bios__Gender__c != contactoldMap.get(con.id).rC_Bios__Gender__c
                && con.rC_Bios__Gender__c == 'Female')){
             
           
              conList.add(con);
          }
            
        }
        if(conList.size() > 0){
        SalutationList = util.updateChildSaluatationline1(conList);
        if(SalutationList.size() > 0) {
          System.debug('***** list to insert11'+ salutationList); 
         // salutationList = removeDuplicateSalutation(salutationList);  
          Database.SaveResult[] salutationResult = Database.Update(salutationList, false); 
          
        }
      } // End of S-366710

      // Added By : Aditi B -S-363333:Household Salutations: Outside (Auto-Create)
      List<Contact> contactToCreateSalList = new List<Contact>();
      List<rC_Bios__Salutation__c> newHouseHoldSalList = new List<rC_Bios__Salutation__c>();
      Set <Id> accIdSet = new Set<Id>();
      
      for(Contact coId : contactNewList ){
            accIdSet.add(coId.AccountId);
      }
      Map<Id,Account> accMap =
                     new Map<Id,Account>([SELECT Id,
                                            ( SELECT Id,
                                              rC_Bios__Salutation_Type__c 
                                              FROM
                                              rC_Bios__Salutations__r
                                              WHERE 
                                              rC_Bios__Salutation_Type__c = 'Household Stacked Pref Mail Name'
                                              OR
                                              rC_Bios__Salutation_Type__c = 'Household Pref Mail Name' )
                                        FROM Account
                                        WHERE Id in : accIdSet]); 
                                                                                        
      for(Contact cont : contactNewList){
        if( (cont.Salutation != contactOldMap.get(cont.id).Salutation 
            || cont.LastName != contactoldMap.get(cont.id).LastName 
            || cont.rC_Bios__Middle_Name__c != contactoldMap.get(cont.id).rC_Bios__Middle_Name__c 
            || cont.FirstName != contactoldMap.get(cont.id).FirstName 
            || cont.APP_Suffix__c != contactoldMap.get(cont.id).APP_Suffix__c 
            || cont.Prof_Suffix__c != contactoldMap.get(cont.id).Prof_Suffix__c 
            &&( cont.rC_Bios__Preferred_Contact__c == true 
                || cont.rC_Bios__Secondary_Contact__c == true) )
            
            || (cont.rC_Bios__Preferred_Contact__c == true 
                && cont.rC_Bios__Preferred_Contact__c 
                  != contactOldMap.get(cont.id).rC_Bios__Preferred_Contact__c )

            || (cont.rC_Bios__Secondary_Contact__c == true 
                  && cont.rC_Bios__Secondary_Contact__c
                    != contactOldMap.get(cont.id).rC_Bios__Secondary_Contact__c )
            || (cont.AccountId != null 
                && cont.AccountId != contactOldMap.get(cont.id).AccountId
                && accMap.size() >0 
                && accMap.get(cont.AccountId).rC_Bios__Salutations__r.size() > 0)){

                 householdConList.add(cont);
        }

        if((cont.AccountId != null 
              &&cont.AccountId != contactOldMap.get(cont.id).AccountId )
            
            
            && accMap.size() >0 ){
            
            if(accMap.get(cont.AccountId).rC_Bios__Salutations__r.size() == 0){
                contactToCreateSalList.add(cont);
              } 
              
        } 
      }
      
      if(householdConList.size() > 0){
          util.updateHouseHoldChildSalutations(householdConList);

      } // End of S-363333 

      if(contactToCreateSalList.size () >0 ){
        newHouseHoldSalList = util.createHouseholdSalutationOnAccount(contactToCreateSalList);
        
      }
      
      if(newHouseHoldSalList.size () > 0){
        Database.SaveResult[] salutationResults = Database.insert(newHouseHoldSalList, false);
      }
      System.debug('==isRecursive==' + isRecursive);
     //}
     
      list<Contact> listToProcess = new list<Contact>();
        
        for(Contact con : contactNewList){
            if(con.AccountId != contactOldMap.get(con.Id).AccountId){
                listToProcess.add(con);
            }
        }
                
          if(listToProcess.size() > 0){
              updateContactMaritalStatus(listToProcess);
  
          }   
             
     updateDecesedContact(contactNewList, contactOldMap);
     if(isRecursiveAfterUpdate){
            return;
          }
          else{
              isRecursiveAfterUpdate = true;
          }
          
           //updateContactMaritalStatus(contactNewList);
          
       // Populate conIdSet if contact's preferred or secondary flag updated    
      for(Contact cont : contactNewList){
        if(cont.rC_Bios__Preferred_Contact__c 
            != contactOldMap.get(cont.id).rC_Bios__Preferred_Contact__c
          || cont.rC_Bios__Secondary_Contact__c
            !=  contactOldMap.get(cont.id).rC_Bios__Secondary_Contact__c
          || cont.rC_Bios__Gender__c != contactOldMap.get(cont.id).rC_Bios__Gender__c
          || cont.SUID__c != contactOldMap.get(cont.id).SUID__c 
          || cont.AccountId != contactOldMap.get(cont.id).AccountId){

            conIdSet.add(cont.id);
        }
      }  
      if(conIdSet.size() > 0){
        fetchRelatedContacts(contactNewList, false);
      } 
      householdAccountIdToContactMap = new Map<String, List<Contact>>();
      for(Contact c : contactNewList){
          System.debug('=====c==='+c.RecordTypeId + '===' + contactHouseholdRecTypeId +'======' + contactOldMap.get(c.id).rC_Bios__Deceased__c);
         
         if(c.RecordTypeId == contactHouseholdRecTypeId && c.rC_Bios__Deceased__c && !contactOldMap.get(c.id).rC_Bios__Deceased__c) {
             if(!householdAccountIdToContactMap.containsKey(c.AccountId)){
                householdAccountIdToContactMap.put(c.AccountId, new List<Contact>()); 
             }
             householdAccountIdToContactMap.get(c.AccountId).add(c);
             if(c.rC_Bios__Preferred_Contact__c == true){
              accIdsToBeUpdated.add(c.AccountId);
             }
             deceasedContactMap.put(c.id, c);
         }
           
        }
        System.debug('=====householdAccountIdToContactMap==='+householdAccountIdToContactMap);
        System.debug('=====deceasedContactMap==='+deceasedContactMap);

        if(deceasedContactMap.size() >0 ) {
          setPrimaryContact(deceasedContactMap, contactNewList);
          fetchRelatedContacts(contactNewList, false);
        }
        
        for(Contact c : contactNewList){
            if(c.RecordTypeId == contactHouseholdRecTypeId && c.AccountId != contactOldMap.get(c.Id).AccountId && contactOldMap.get(c.Id).rC_Bios__Preferred_Contact__c == true ){
                    accIdsToBeUpdated.add(contactOldMap.get(c.Id).AccountId);
                   }
        }
        if(accIdsToBeUpdated.size() >0 ){
        updatedAccountPreferContacts(accIdsToBeUpdated);
      }
        isSecondary = false;
        
        
        
         
    }
   
    public static void onAfterDelete(List<Contact> contactNewList){
        Map<string, Contact> deceasedContactMap = new Map<string, Contact>();
        if(!isRecursive){
            isRecursive = true;
        }else{
            return;
        }
        householdAccountIdToContactMap = new Map<String, List<Contact>>();
        for(Contact c : contactNewList){
           if(c.RecordTypeId == contactHouseholdRecTypeId) {
               if(!householdAccountIdToContactMap.containsKey(c.AccountId)){
                  householdAccountIdToContactMap.put(c.AccountId, new List<Contact>()); 
               }
               householdAccountIdToContactMap.get(c.AccountId).add(c);
               
           }
           deceasedContactMap.put(c.id, c);
        }
        System.debug('=====' + householdAccountIdToContactMap);
        setPrimaryContact(deceasedContactMap, contactNewList);
        
        
    }
    private static void updatedAccountPreferContacts(List<Id> accIds){
        List<Account> accToBeUpdated = new List<Account>();
        for(Account acc: [SELECT ID,rC_Bios__Preferred_Contact__c FROM Account WHERE ID IN : accIds]){
            acc.rC_Bios__Preferred_Contact__c=null;
            accToBeUpdated.add(acc);
        }
        update accToBeUpdated;
    }
    private static void setPrimaryContact(Map<String, Contact> deceasedContactMap, List<contact> contactNewList){
        if(householdAccountIdToContactMap.size() > 0){
            fetchHouseholdContacts(contactNewList);
        }
        System.debug('=deceasedContactMap===' + deceasedContactMap.keySet());
        List<Contact> contactToupdate = new List<Contact>();
        for(String accId : householdAccountIdToContactMap.keySet()){
            if(householdAccountIdToContactMap.get(accId).size() > 1){
                for(Contact c : householdAccountIdToContactMap.get(accId)){
                    
                    if(!deceasedContactMap.containsKey(c.id)){
                        contactToupdate.add(new Contact(id = c.id, rC_Bios__Preferred_Contact__c= true, rC_Bios__Secondary_Contact__c = false));
                    } else{
                        contactToupdate.add(new Contact(id = c.id, rC_Bios__Preferred_Contact__c= false));
                    }
                }
            }
        }
        System.debug('====' + contactToupdate);
        if(contactToupdate.size() > 0 ){
            try{
                upsert contactToupdate;
            }catch(Exception e){
                System.debug('Exception is ***'+e);
            }
            
        }
        
    }
   
    private static void fetchHouseholdContacts(List<Contact> contactNewList){
        System.debug('contactNewList:::::'+contactNewList + '%%%%%%' +householdAccountIdToContactMap.keySet());
        
        for(Contact con : contactNewList){
            contactMap.put(con.id, con);
        }
        
        for(Contact con : [Select id, AccountId, SUID__c, rC_Bios__Gender__c,rC_Bios__Preferred_Contact__c
                            from contact 
                            where AccountId in :householdAccountIdToContactMap.keySet() 
                            AND rC_Bios__Deceased__c = false 
                            AND RecordTypeId = :contactHouseholdRecTypeId 
                            AND id not in :contactNewList] ){
           householdAccountIdToContactMap.get(con.AccountId).add(con);    
           contactMap.put(con.id, con);
        }
        
        
        
    }
    
    private static void fetchHouseholdContactsForFetchRelatedContacts(List<Contact> contactNewList){
        System.debug('contactNewList:::::'+contactNewList + '%%%%%%' +householdAccountIdToContactMap.keySet());
        for(Contact con : contactNewList){
            contactMap.put(con.id, con);
        }
        for(Contact con : [Select id, AccountId, SUID__c, rC_Bios__Gender__c,rC_Bios__Preferred_Contact__c
                            from contact 
                            where AccountId in :householdAccountIdToContactMap.keySet() 
                            AND rC_Bios__Deceased__c = false 
                            AND RecordTypeId = :contactHouseholdRecTypeId 
                          ]){
           householdAccountIdToContactMap.get(con.AccountId).add(con);    
           contactMap.put(con.id, con);
        }
        
        
    }
    
    private static void fetchRelatedContacts(List<Contact> contactNewList, Boolean isBefore){
        
        Map<Id, Contact> newMap = new Map<Id, Contact>();
        for(Contact con : contactNewList){
            newMap.put(con.Id, con);
        }
        
        
        Set<Id> accIds = new Set<Id>();
        for(Contact con: [Select AccountId from Contact where id in : contactNewList]) {
            accIds.add(con.AccountId);
        }
        System.debug(':::accIds'+accIds);
        Map<String, List<Contact>> accIdToContactMap = getAccIdToContactMap(accIds);
        System.debug('accIdToContactMap::::: ' + accIdToContactMap);
        
        contactsToUpdate = new List<Contact>();
        updateHouseHoldContacts(accIdToContactMap);
            
        System.debug('contactsToUpdate:::::: ' + contactsToUpdate);
        if(contactsToUpdate.size() > 0) {
            update contactsToUpdate;
        }
    }
    
    
    

    // method to get map between Account Id and related Active contact list
    private static Map<String, List<Contact>> getAccIdToContactMap(set<Id> accIds){
        Map<String, List<Contact>> accIdToContactMap = new Map<String, List<Contact>>();
        List<String> alums = new List<String>{'Alum','UG & Grad Alum', 'UG Alum', 'Grad Alum','Grad Student'};
        List<String> biosCodes = new List<String>{'US', 'GS', 'CT', 'UA', 'GA', 'NG','BT'};

        for(Contact con: [Select id, RecordType.Name, rC_Bios__Deceased__c,AccountId, rC_Bios__Gender__c,SUID__c,
                            rC_Bios__Secondary_Contact__c, rC_Bios__Preferred_Contact__c,
                            (Select id, rC_Bios__Category__c, rC_Bios__Primary__c, rC_Bios__Priority__c,
                                rC_Bios__Code_Value__c , rC_Bios__Subcategory__c
                                from rC_Bios__Preferences__r where rC_Bios__Category__c = : CONSTITUENT_TYPE 
                                AND rC_Bios__Priority__c != null 
                                AND rC_Bios__Code_Value__c in: biosCodes
                                order by rC_Bios__Priority__c ASC
                               ) 
                            from Contact where AccountId in :accIds AND rC_Bios__Deceased__c = false
                            AND RecordTypeId = :contactHouseholdRecTypeId]) {
            if(!accIdToContactMap.containsKey(con.AccountId)){
                  accIdToContactMap.put(con.AccountId, new List<Contact>()); 
               }
            accIdToContactMap.get(con.AccountId).add(con);
        } return accIdToContactMap;
    }
    
    
    
    // method to update related related household contacts as primary or secondary based on conditions
    private static void updateHouseHoldContacts(Map<String, List<Contact>> accIdToContactMap){
        for(String accId : accIdToContactMap.keySet()){
            //System.debug('>>>>>> ' + accIdToContactMap.get(accId).size());
            if(accIdToContactMap.get(accId).size() == 1){
                Contact con = accIdToContactMap.get(accId)[0];
                if(con.rC_Bios__Preferred_Contact__c != true) {
                    con.rC_Bios__Preferred_Contact__c = true;
                    con.rC_Bios__Secondary_Contact__c = false;
                    contactsToUpdate.add(con);
                }     
            }
            else if(accIdToContactMap.get(accId).size() == 2){
                Contact cnt1 = accIdToContactMap.get(accId)[0];
                Contact cnt2 = accIdToContactMap.get(accId)[1];
                // cnt1 is alum and cnt2 is not
                if((cnt1.rC_Bios__Preferences__r.size() > 0 && cnt2.rC_Bios__Preferences__r.size() == 0)) {
                    System.debug('***cnt1 size='+cnt1.rC_Bios__Preferences__r.size());
                    System.debug('***cnt2 size='+cnt2.rC_Bios__Preferences__r.size());
                    setContactPrimaryOrSecondary(cnt1, cnt2);
                }
                // cnt2 is alum and cnt1 is not
                else if((cnt2.rC_Bios__Preferences__r.size() > 0 && cnt1.rC_Bios__Preferences__r.size() == 0)) {
                    setContactPrimaryOrSecondary(cnt2, cnt1);
                }

                else if(cnt1.rC_Bios__Gender__c == 'Male' && cnt2.rC_Bios__Gender__c != 'Male') {
                   
                    setContactPrimaryOrSecondary(cnt1, cnt2);
                }
                else if(cnt2.rC_Bios__Gender__c == 'Male' && cnt1.rC_Bios__Gender__c != 'Male') {
                    
                    setContactPrimaryOrSecondary(cnt2, cnt1);
                }
                else if(cnt1.SUID__c!= null && cnt2.SUID__c != null) {
                    if(Integer.valueOf(cnt1.SUID__c) < Integer.valueOf(cnt2.SUID__c)) {
                        setContactPrimaryOrSecondary(cnt1, cnt2);
                    }
                    else {
                        setContactPrimaryOrSecondary(cnt2, cnt1);
                    }
                }
                else if(cnt1.SUID__c!= null && cnt2.SUID__c == null) {
                    setContactPrimaryOrSecondary(cnt1, cnt2);
                }
                else if(cnt1.SUID__c == null && cnt2.SUID__c != null) {
                    setContactPrimaryOrSecondary(cnt2, cnt1);
                } else if(cnt1.rC_Bios__Preferred_Contact__c == true
                          && cnt2.rC_Bios__Secondary_Contact__c == false){
                    
                    setContactPrimaryOrSecondary(cnt1, cnt2);
                } 
                
            }
        }
    }
    
    // Set contact primary or secondary
    private static void setContactPrimaryOrSecondary(Contact primaryContact, Contact secondaryContact) {
        if(primaryContact.rC_Bios__Preferred_Contact__c != true) {
            primaryContact.rC_Bios__Preferred_Contact__c = true;
            primaryContact.rC_Bios__Secondary_Contact__c = false;
            contactsToUpdate.add(primaryContact);
        }
        if(secondaryContact.rC_Bios__Secondary_Contact__c != true) {
            secondaryContact.rC_Bios__Secondary_Contact__c = true;
            secondaryContact.rC_Bios__Preferred_Contact__c = false;
            contactsToUpdate.add(secondaryContact);
        }
    }
    
     // Added By : Jyoti Agarwal  I-196548
        public static void onBeforeDelete(List<Contact> contactNewList,Map<Id,Contact> oldContactMap){
    
       
    
    
    
    }

  // Added By : Aditi B T-483017/S-397633
  // This method will check whether entered suid 
  // value is valid or not ,If entered value is not valid
  // this method will throw a validation error message
  public static void validateSuidOnContact(List<Contact> conList){
    Set<String> suidIdSet = new Set<String>();
    Boolean isValid;
    Set<String> suidSet = new Set<String>();
    Map<String, Integer> suidCountMap = new Map<String, Integer>();
    
    for(Contact con : conList){
        if(con.SUID__c != null ){ 
            suidSet.add(con.SUID__c);
            
            if(!suidCountMap.containsKey(con.SUID__c)){
                suidCountMap.put(con.SUID__c, 0); 
            }
            
            suidCountMap.put(con.SUID__c, suidCountMap.get(con.SUID__c) + 1);
            
        }
    }
    
    suidIdSet = getAllSuidsForContact(suidSet, conList);
    
    for(Contact con : conList ){
      if(con.SUID__c != null ){
        if(con.SUID__c.length() != 10){
          con.addError(Label.SUID_DIGIT_VALIDATION);
        } else if(suidIdSet.contains(con.SUID__c) 
                  || suidCountMap.get(con.SUID__c) > 1){
         
          con.addError(Label.DUPLICATE_SUID_MESSAGE);
          
        } else {
          isValid = SUID_GeneratorService.isValidSUIDbasedonCheckDigit(con.SUID__c, false);
          if(!isValid){
            con.addError(Label.SUID_CONTACT_VALIDATION_MESSAGE);
          } 
        }
      } 
    }
  } 

  
  // Added By : Aditi B T-483017/S-397633
  // This method get all contact SUID form org 
  // and return list of suids 
  public static Set<String> getAllSuidsForContact(Set<String> suidSet, 
                                                  List<Contact> newConList){
    List<Contact> conList = new List<Contact>();
    Set<String> suidIdSet = new Set<String>();
    Set<Id> accIdSet = new Set<Id>();
    List<Account> accountList = new List<Account>();

    /*
    for(Contact con : newConList){
      accIdSet.add(con.AccountId);
    }*/
    
    // get all contact suids 
    conList = [SELECT Id, SUID__C FROM Contact
                    WHERE SUID__c IN :suidSet
                    AND id NOT IN : newConList];

   
    // get all account suids                 
    accountList = [SELECT Id, SUID__C FROM Account
                    WHERE SUID__c IN :suidSet ];
                                    
   
    for (Contact con : conList) {
        suidIdSet.add(con.SUID__c);
    }

    for(Account acc : accountList){
      suidIdSet.add(acc.SUID__c);
    }

    return suidIdSet;

  }

  // Added By : Aditi B -  T-483017/S-397633
  // This method populates suid on contact 
  // when Suid is null at the time of insertion.
  /* 
  public static void populateSuidOnContact(List<Contact> conList){

    for(Contact con : conList){
      if(con.SUID__c == null && con.SUID_Pool_Value__c != null ){
        con.SUID__c = SUID_GeneratorService.getNextSUID(con.SUID_Pool_Value__c, '2');
        System.debug('*****'+ con.SUID__c);
      }
    }
  }*/
  
  
  
  public static void updateContactMaritalStatus(list<Contact> newList){
      
      
      Set<String> accountIdSet = new Set<String>();
      //Set<Id> listOfContactId = new Set<Id>();
      List<Contact> upDateToContact  = new List<Contact>();
      map<String,Integer> mapOfAccountToRelationCount = new map<String,Integer>();
      map<Id,Integer> contactIdToRelationShip = new map<Id,Integer>();
      List<rC_Bios__Relationship__c> realtionToBuild = new List<rC_Bios__Relationship__c>();
      map<String ,list<Contact>> accountIdToContactList = new map<String ,list<Contact>>(); 
      Id relationShipRecordtypeId = Schema.SObjectType.rC_Bios__Relationship__c.getRecordTypeInfosByName().get('Contact - Contact').getRecordTypeId();
      
      for(Contact cont :newList){
          
          if(cont.AccountId != null && cont.rC_Bios__Active__c  == true && cont.RecordTypeId == contactHouseholdRecTypeId)
            accountIdSet.add(cont.AccountId);
      }
      
      
      // process the old records
      for(Contact con : [Select Id , rC_Bios__Marital_Status__c,  AccountId , (Select Id,rC_Bios__Active__c from rC_Bios__Relationships_Contact_1__r WHERE rC_Bios__Active__c = true ) 
                                                        FROM Contact WHERE AccountId IN :accountIdSet]){
                        mapOfAccountToRelationCount.put(con.AccountId , con.rC_Bios__Relationships_Contact_1__r.size());                                    
          if(!accountIdToContactList.containsKey(con.AccountId)){ 
              accountIdToContactList.put(con.AccountId ,  new list<Contact>());
          }
          accountIdToContactList.get(con.AccountId).add(con);
          
      }
      
      
      for(String str : accountIdToContactList.keySet()){
          if(accountIdToContactList.get(str).size() == 2){
            Contact con = new Contact(Id = accountIdToContactList.get(str)[0].Id,
                                        rC_Bios__Marital_Status__c = 'Married' );
               upDateToContact.add(con);                        
            Contact con2 = new Contact(Id = accountIdToContactList.get(str)[1].Id,
                                        rC_Bios__Marital_Status__c = 'Married' );                           
               upDateToContact.add(con2);  
               
              if(mapOfAccountToRelationCount.get(str) == 0){
                  rC_Bios__Relationship__c rc = new rC_Bios__Relationship__c(RecordTypeId = relationShipRecordtypeId , 
                                                                        rC_Bios__Category__c = 'Family' , 
                                                                        rC_Bios__Role_1__c = 'Spouse/Partner',
                                                                        rC_Bios__Role_2__c = 'Spouse/Partner',
                                                                        rC_Bios__Contact_1__c = accountIdToContactList.get(str)[0].Id,
                                                                        rC_Bios__Contact_2__c = accountIdToContactList.get(str)[1].Id,
                                                                        rC_Bios__Active__c = true
                                                                        );
              
                  realtionToBuild.add(rc);
              }
              
              
              
              //System.assert(false,'>>>' + realtionToBuild);
              
          }
       }
       if(upDateToContact.size() > 0 && realtionToBuild.size() > 0){
           Database.update(upDateToContact, false);
           Database.insert(realtionToBuild, false);
       }
       
       
       
       
     }
     
     
     public static void updateDecesedContact(list<Contact> conlist , map<Id,Contact> oldMap){
         map<String,String> roleToRecordType = new map<String,String>(); 
         Set<String> contactIds = new Set<String>();
         list<rC_Bios__Relationship__c> relationshipToInactive = new list<rC_Bios__Relationship__c>();
         
         Map<String, RecordType_To_Role_Mapping__c> recordTypeRollSetting = RecordType_To_Role_Mapping__c.getAll();
         
         
         for(RecordType_To_Role_Mapping__c mR : recordTypeRollSetting.values()){
                roleToRecordType.put(mR.Name , mR.Record_Type_Name__c); 
         }
         
         
         
         
         
         
         for(Contact con :conlist ){
             //System.assert(false , con.Status__c + ' >>> ' + oldMap.get(con.Id).Status__c);
             if(con.Status__c == 'Deceased' && oldMap.get(con.Id).Status__c != con.Status__c ){
                 contactIds.add(con.Id);
             }
             
             
         }
         if(contactIds.size() > 0){
            
            for(rC_Bios__Relationship__c relation : [Select Id , rC_Bios__Active__c , RecordType.Name FROM rC_Bios__Relationship__c 
                                                    WHERE (RecordType.Name IN :roleToRecordType.values() AND rC_Bios__Role_1__c IN :roleToRecordType.KeySet()  
                                                            AND (rC_Bios__Contact_1__c IN :contactIds OR rC_Bios__Contact_2__c IN :contactIds) ) 
                                                        OR (RecordType.Name IN :roleToRecordType.values() AND rC_Bios__Role_1__c IN :roleToRecordType.KeySet() 
                                                            AND (rC_Bios__Contact_1__c IN :contactIds OR rC_Bios__Contact_2__c IN :contactIds))]){
                                                      
                                                      relation.rC_Bios__Active__c = false;
                                                      relationshipToInactive.add(relation);      
                                                        }
         
         
            //System.assert(false,relationshipToInactive);
             if(relationshipToInactive.size() > 0){
             database.update(relationshipToInactive, false);
         }
            
             
         }
         
         
         
         
         
     }
  
    
    
    
    
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
    
        
}