/*
** @author : (c) 2015 Appirio, Inc.[ Vivek Ojha]
** @date : 10/22/2015
** @description : Preference Trigger Handler written for T-439460(Validations on Removal of CT) 
*/
public with sharing class PreferenceTriggerHandler  {


    private final static String CONSTITUENT_TYPE = 'Constituent Type';
    private static List<Contact> contactsToUpdate = new List<Contact>();
    public  static boolean isPrimaryOnly = false;
    public static boolean firstRunBeforeInsert = true; 
    static String contactHouseholdRecTypeId;
    static String accountOrganizationalRecTypeId;
    static {
      contactHouseholdRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
      
      // Added By Aditi : T-492190/S-399176
      accountOrganizationalRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
    }
    public static void onBeforeInsert(List<rC_Bios__Preference__c> newPreferences){
        if(firstRunBeforeInsert == true){
            copyOnlySingleActivePreferenceToContact(newPreferences , true , null);
        }
        
    }
    public static void onBeforeUpdate(List<rC_Bios__Preference__c> newPreferences , map<Id,rC_Bios__Preference__c> oldmap){
        if(firstRunBeforeInsert == true){
            copyOnlySingleActivePreferenceToContact(newPreferences , false , oldmap);
        }
        
    }
    
    
    public static void onAfterInsert(List<rC_Bios__Preference__c> newPreferences){
        System.debug('newPreferences:::: ' + newPreferences);
        calculateCTPrimary(newPreferences, null, true);
    }
    
    
    public static void onAfterUpdate(List<rC_Bios__Preference__c> newPreferences, Map<Id, rC_Bios__Preference__c> oldPreferenceMap){
        if(!isPrimaryOnly){
            calculateCTPrimary(newPreferences, oldPreferenceMap, false);
        }
    }
    public static void onAfterDelete(map<Id,rC_Bios__Preference__c> oldmap){
            deleteRequestRatingRecord(oldmap);
        
    }
    
    //method to capture before delete event of Preference.
    public static void onBeforeDelete(List<rC_Bios__Preference__c> delPreference,Map<Id, rC_Bios__Preference__c> oldMap){
        //List of Ids to capture contact Ids related to Preference
        List<Id> contIds= new List<Id>();
        //Map to capture contact with its all realted Preference.
        map<Id,List<rC_Bios__Preference__c>> mapContPref = new map<Id,List<rC_Bios__Preference__c>>();
        //check if Preference going be deleted are of Type 'CT' than process those records only as per T-439460.
        for(rC_Bios__Preference__c pref : delPreference){
            if(pref.rC_Bios__Category__c == 'Constituent Type'){
                contIds.add(pref.rC_Bios__Contact__c);
            }
        }
        //if records of category type CT are found than only process them.
        if(contIds.size()>0){
            //fetch all the records of Preference related to those contacts and type CT.
            for(rC_Bios__Preference__c Pref : [Select Id , rC_Bios__Category__c ,rC_Bios__Contact__c,rC_Bios__Primary__c 
                                                        FROM rC_Bios__Preference__c Where rC_Bios__Contact__c IN : contIds 
                                                        AND rC_Bios__Category__c='Constituent Type']){
                if(!mapContPref.containsKey(Pref.rC_Bios__Contact__c)){
                    mapContPref.put(Pref.rC_Bios__Contact__c,new List<rC_Bios__Preference__c>());
                }
                mapContPref.get(Pref.rC_Bios__Contact__c).add(Pref);
            }
        }
        for(Id cid : contIds){
            //check to see if the record going to be deleted of Type CT is last related record of Contact. 
            //If so Given a validation error. else nothing to do.
            if(mapContPref.get(cid).size()== 1){
                rC_Bios__Preference__c actualRecord = oldMap.get(mapContPref.get(cid)[0].Id);
                actualRecord.addError(Label.CONSTITUENT_TYPE_REQUIRED);
                
                 
                
            }
        }
       restrictDeletionOfCTFromOrgAccount(delPreference,oldMap); 
    }
    
    public static void onAfterDelete(List<rC_Bios__Preference__c> oldPreferences){
        calculateCTPrimary(oldPreferences , null, false);
    }
    
    public static void calculateCTPrimary(List<rC_Bios__Preference__c> newPreferences, Map<Id, rC_Bios__Preference__c> oldPreferenceMap, Boolean isInsert){
        isPrimaryOnly = true;
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Map<Id, Contact>> accountContactMap = new Map<Id, Map<Id, Contact>>();
        List<rC_Bios__Preference__c> preferencesForUpdate = new List<rC_Bios__Preference__c>();

        Map<Id, List<rC_Bios__Preference__c>> mapContactIdandPreferences = new Map<Id, List<rC_Bios__Preference__c>>();

        System.debug(':::newPreferences'+newPreferences);
        System.debug(':::oldPreferenceMap'+oldPreferenceMap);
        for(rC_Bios__Preference__c pre : newPreferences){
            if(oldPreferenceMap == null && pre.rC_Bios__Category__c == CONSTITUENT_TYPE && pre.rC_Bios__Contact__c != null && pre.rC_Bios__Priority__c != null){
                contactIds.add(pre.rC_Bios__Contact__c);
            }else if(oldPreferenceMap != null && pre.rC_Bios__Category__c == CONSTITUENT_TYPE && (pre.rC_Bios__Contact__c !=    oldPreferenceMap.get(pre.id).rC_Bios__Contact__c || pre.rC_Bios__Priority__c != oldPreferenceMap.get(pre.id).rC_Bios__Priority__c)){
                if(pre.rC_Bios__Contact__c != null){
                    contactIds.add(pre.rC_Bios__Contact__c);
                }
                if(oldPreferenceMap.get(pre.id).rC_Bios__Contact__c != null){
                    contactIds.add(oldPreferenceMap.get(pre.id).rC_Bios__Contact__c);
                }
            }
        }
        System.debug(':::contactIds'+contactIds);
        
        Set<Id> accIds = new Set<Id>();
        for(Contact con: [Select AccountId from Contact where id in : contactIds]) {
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
        // Added by Aditi B :T-474427 -Update Preference Trigger Code 
        // to recalculate primary Constituent Type on new CT
        
        if(!contactIds.isEmpty()){
            for(Contact con : [select id, RecordType.Name, rC_Bios__Deceased__c,AccountId,
                                     (Select id, rC_Bios__Category__c, rC_Bios__Primary__c, 
                                      rC_Bios__Priority__c
                                      from rC_Bios__Preferences__r 
                                      where 
                                      rC_Bios__Category__c = : CONSTITUENT_TYPE 
                                      AND rC_Bios__Priority__c != null 
                                      order by rC_Bios__Priority__c ASC) 
                              from Contact where id in : contactIds]){
            Integer i = 0;
            System.debug('::con.rC_Bios__Preferences__r'+con.rC_Bios__Preferences__r);
            for(rC_Bios__Preference__c biosPreference : con.rC_Bios__Preferences__r){
                if( i ==0 && !biosPreference.rC_Bios__Primary__c){
                    biosPreference.rC_Bios__Primary__c = true;
                    preferencesForUpdate.add(biosPreference);
                }else if(i > 0 && biosPreference.rC_Bios__Primary__c){
                    biosPreference.rC_Bios__Primary__c = false;
                    preferencesForUpdate.add(biosPreference);
                }
                i++;
            }
        
          }
        }
        if(!preferencesForUpdate.isEmpty()){
            isPrimaryOnly = true;
            List<Database.SaveResult> saveResults = Database.update(preferencesForUpdate , false);
        }// End of T-474427 
      }

    // method to get map between Account Id and related Active contact list
    private static Map<String, List<Contact>> getAccIdToContactMap(set<Id> accIds){
        Map<String, List<Contact>> accIdToContactMap = new Map<String, List<Contact>>();
        List<String> alums = new List<String>{'Alum','UG & Grad Alum', 'UG Alum', 'Grad Alum'};
        List<String> biosCodes = new List<String>{'US', 'GS', 'CT', 'UA', 'GA', 'NG'};

        for(Contact con: [Select id, RecordType.Name, rC_Bios__Deceased__c,AccountId, rC_Bios__Gender__c,SUID__c, 
                            rC_Bios__Secondary_Contact__c, rC_Bios__Preferred_Contact__c,
                            (Select id, rC_Bios__Category__c, rC_Bios__Primary__c, rC_Bios__Priority__c,
                                rC_Bios__Code_Value__c , rC_Bios__Subcategory__c
                                from rC_Bios__Preferences__r where rC_Bios__Category__c = : CONSTITUENT_TYPE 
                                AND rC_Bios__Priority__c != null 
                                AND rC_Bios__Subcategory__c in: alums
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
                	/*CHanges : Changed Integer.valueOf(cnt1.SUID__c) to Decimal.valueOf(cnt1.SUID__c)
                		Reason : facing exception System.TypeException: Invalid integer:
                		Modified By : Rahul Khanchandani 
                	*/
                    if(Decimal.valueOf(cnt1.SUID__c) < Decimal.valueOf(cnt2.SUID__c)) {
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
                }
                else if(cnt1.rC_Bios__Preferred_Contact__c == true
                          && cnt2.rC_Bios__Secondary_Contact__c == false){
                    System.debug('***Cnt1 This is else part :='+cnt1.rC_Bios__Preferred_Contact__c);
                    System.debug('***cnt2 This is else part :='+cnt2.rC_Bios__Secondary_Contact__c);
                    setContactPrimaryOrSecondary(cnt1, cnt2);
                } 
            }
        }
    }

  // Added by Aditi B : T-492190/S-399176
  // This Method will restrict user form deleting 
  // preference record with category = CONSTITUENT_TYPE 
  // from organization account 
  public static void restrictDeletionOfCTFromOrgAccount (
    List<rC_Bios__Preference__c> delPreference,
    Map<Id, rC_Bios__Preference__c> oldMap) {
    
    // Set Contains Org Accounts
    // Where category = CONSTITUENT_TYPE 
    Set<Id> accountIdSet = new Set<Id>();
    
    // Populate accountIdSet 
    for(rC_Bios__Preference__c pref : delPreference){
      if(pref.rC_Bios__Category__c == SalutationConstants.CONSTITUENT_TYPE) {
        accountIdSet.add(pref.rC_Bios__Account__c);
      }
    }

    // Restrict deletion of prefernce record
    for(rC_Bios__Preference__c pref : [SELECT Id,rC_Bios__Account__r.RecordTypeId
                                       FROM rC_Bios__Preference__c
                                       WHERE rC_Bios__Account__c In : accountIdSet]){
      if(pref.rC_Bios__Account__r.RecordTypeId == accountOrganizationalRecTypeId ){
         rC_Bios__Preference__c actualRecord = oldMap.get(pref.id);
         actualRecord.addError(Label.RESTRICT_DELETION_OF_PREFERENCE); 
      }
    }

  }
  
  private static void copyOnlySingleActivePreferenceToContact(List<rC_Bios__Preference__c> preference, boolean isInsert, Map<Id,rC_Bios__Preference__c> oldmap){
      firstRunBeforeInsert = false;
      Set<Id> accountIdToProcess = new Set<Id>();
      list<rC_Bios__Preference__c> relationToDelete = new list<rC_Bios__Preference__c>();
      map<String,List<String>> accountIdToAllContacts = new map<String,List<String>>();
      map<String , list<rC_Bios__Preference__c>> acountIdToPreference = new map<String , list<rC_Bios__Preference__c>>();
      list<rC_Bios__Preference__c> relationToCreate = new list<rC_Bios__Preference__c>();
      map<String,String> mapOfAccountIdToRelationId = new map<String,String>();
      set<String> nonResearchAccountId = new set<String>();
      map<String,List<rC_Bios__Preference__c>> mapAccIdAndPreference = new Map<String,List<rC_Bios__Preference__c>>();
      map<String,List<rC_Bios__Preference__c>> mapAccIdAndContactPreference = new map<String,List<rC_Bios__Preference__c>>();
      
      // fetch the Account for the relavent records
      for(rC_Bios__Preference__c prf : preference){
          if(prf.rC_Bios__Account__c != null && prf.rC_Bios__Category__c == 'Research Rating'){
              accountIdToProcess.add(prf.rC_Bios__Account__c);
          }
          
          // accountId which have preference records which are previously Research rating category
          if(prf.rC_Bios__Account__c != null && oldmap != null && prf.rC_Bios__Category__c != oldmap.get(prf.Id).rC_Bios__Category__c 
                                            && oldmap.get(prf.Id).rC_Bios__Category__c == 'Research Rating'){
             nonResearchAccountId.add(prf.rC_Bios__Account__c);                                   
          }
          
      }
      
      
      if( nonResearchAccountId.size() > 0){
          
          //deleteNonRequestRatingRecord(nonResearchAccountId);
          
      }
      
      // fetch all the contact Id under that account
      for(Contact con : [Select Id , AccountId , Account.RecordType.Name from Contact
                            WHERE accountId IN :accountIdToProcess AND Account.RecordType.Name = 'Household']){
                                
                    if(!accountIdToAllContacts.containsKey(con.AccountId)){
                        accountIdToAllContacts.put(con.AccountId , new list<String>());
                    }         
                    accountIdToAllContacts.get(con.AccountId).add(con.Id);            
      }
      
      
      
      
      
      // fetch the preference existing in database will work on  --- relationToCreate
      if(!isInsert){
          
         // updated preferences -- trigger.new 
          for(rC_Bios__Preference__c prf : preference){
              
              if(accountIdToAllContacts.containsKey(prf.rC_Bios__Account__c)){
                  
                  if(!mapAccIdAndPreference.containsKey(prf.rC_Bios__Account__c)){
                      mapAccIdAndPreference.put(prf.rC_Bios__Account__c,new list<rC_Bios__Preference__c>());
                  }
                    mapAccIdAndPreference.get(prf.rC_Bios__Account__c).add(prf);
                  
                  
              }
              
              
          }
          
          // old records from database
          for(rC_Bios__Preference__c pr: [Select Id , rC_Bios__Contact__c,rC_Bios__Contact__r.AccountId FROM rC_Bios__Preference__c 
                                                Where rC_Bios__Contact__r.AccountId IN: accountIdToAllContacts.KeySet() 
                                                AND rC_Bios__Category__c = 'Research Rating']){
              
                if(!mapAccIdAndContactPreference.containsKey(pr.rC_Bios__Contact__r.AccountId)){
                    mapAccIdAndContactPreference.put(pr.rC_Bios__Contact__r.AccountId,new list<rC_Bios__Preference__c>());
                }
                mapAccIdAndContactPreference.get(pr.rC_Bios__Contact__r.AccountId).add(pr);
          }
          
          //System.assert(false , mapAccIdAndContactPreference);
          
          for(string str : mapAccIdAndPreference.Keyset()){
              
              if(mapAccIdAndContactPreference.containsKey(str)){
                  for(rC_Bios__Preference__c prrf : mapAccIdAndContactPreference.get(str)){
                      rC_Bios__Preference__c refrence;
                      refrence = mapAccIdAndPreference.get(str)[0].clone(false, true);
                      refrence.Id = prrf.Id;
                      relationToCreate.add(refrence);
                  }
                  
              }
              
              
              
              
          }
          
       }
      // fetch the existing records under account if any exists , and throw error for them if new preference is added -- only Insert
      if(isInsert){
          acountIdToPreference = new map<String , list<rC_Bios__Preference__c>>();
          for(rC_Bios__Preference__c reltion : [Select Id , rC_Bios__Account__c From rC_Bios__Preference__c 
                                            where rC_Bios__Account__c IN :accountIdToAllContacts.KeySet() AND rC_Bios__Category__c = 'Research Rating']){
          
              if(!acountIdToPreference.containsKey(reltion.rC_Bios__Account__c)){
                  acountIdToPreference.put(reltion.rC_Bios__Account__c , new list<rC_Bios__Preference__c>());
              }
              acountIdToPreference.get(reltion.rC_Bios__Account__c).add(reltion);
          }
      
      
      
          // populate the new records and throw error if any exists
          for(rC_Bios__Preference__c relation : preference ){
              if(acountIdToPreference.containsKey(relation.rC_Bios__Account__c)){
                  if(acountIdToPreference.get(relation.rC_Bios__Account__c).size() > 0  ){
                      relation.addError('You already have Preference of Category type Research Rating');
                  }
              }else if(!acountIdToPreference.containsKey(relation.rC_Bios__Account__c)){
                  acountIdToPreference.put(relation.rC_Bios__Account__c , new list<rC_Bios__Preference__c>());
                  acountIdToPreference.get(relation.rC_Bios__Account__c).add(relation);
              }
          }
      
      }
      
      for(String str : acountIdToPreference.keySet()){
          if(acountIdToPreference.get(str)[0].Id == null && isInsert && accountIdToAllContacts.containsKey(str)){
              for(String contId  : accountIdToAllContacts.get(str)){
                    rC_Bios__Preference__c reflation;
                    reflation = acountIdToPreference.get(str)[0].clone(false,true);
                    reflation.rC_Bios__Contact__c = contId;
                    reflation.rC_Bios__Account__c = null;
                    relationToCreate.add(reflation);
                }
          }
      }
      
      
      
      //System.assert(false,relationToCreate); 
  
      if(relationToCreate.size() > 0){
          database.upsert(relationToCreate, false);
          //upsert relationToCreate;
      }
      
      
  }
  
  
  private static void deleteNonRequestRatingRecord(Set<String> accountIds){
      
     list<rC_Bios__Preference__c> prefToDelete = new list<rC_Bios__Preference__c>();
      
      for(rC_Bios__Preference__c prff : [Select Id ,rC_Bios__Contact__r.AccountId FROM rC_Bios__Preference__c 
                                            Where rC_Bios__Contact__r.AccountId IN :accountIds]){
                              prefToDelete.add(prff);                      
                        }
      
      if(prefToDelete.size() > 0){
          database.delete(prefToDelete, false);
      }
      
      
  }
  
  //*******************************************************************************************************
  //
  //*******************************************************************************************************
  
  private static void deleteRequestRatingRecord( map<Id,rC_Bios__Preference__c> prefrences){
      List<rC_Bios__Preference__c> relationsToDelete = new List<rC_Bios__Preference__c>();
      Set<Id> accountIds = new Set<Id>();
      for(rC_Bios__Preference__c rcPrf : prefrences.values()){
          if(rcPrf.rC_Bios__Account__c != null){
              accountIds.add(rcPrf.rC_Bios__Account__c);
          }
      }
      
     for(rC_Bios__Preference__c rpf : [Select Id, rC_Bios__Contact__r.AccountId FROM rC_Bios__Preference__c
                                        WHERE rC_Bios__Contact__r.AccountId IN :accountIds ]){
          
          relationsToDelete.add(rpf);
          
      }
      
      
      if(relationsToDelete.size() > 0){
          database.delete(relationsToDelete, false); 
      } 
      
  }
  
  
  
  
  
  
  
}