/********************************************************************************************
* Class Name: SalutationUtility
* Author: Aditi Bhardwaj (Appirio)
* Date: [12/10/2015]
* Requirement Description: S-368426 [Organization Salutations: Outside & Publication (Auto-Create)]
* Date Modified                Modified By                  Description of the update

***********************************************************************************************/
Public class SalutationUtility {

	 Map<Id,Contact> salMap = new Map<id,Contact>();
	 Map<Id,Contact> prefMap = new Map<id,Contact>(); 
	 List<String> subCategoryList = new List<String>{'UG & Grad Alum', 'UG Alum',
													'Grad Student', 'UG Student',
													'Non-Grad'};
													
	 Map<Id,Account> accMap = new Map<Id,Account>();		
	 Map<Id,Contact> childSalMap = new Map<Id,Contact>();
	 Map<Id,contact> relationShipMap = new Map<id,Contact>();
	 Map<Id,contact> deceasedPartnerMap = new Map<Id,Contact>();
	 Map<Id,contact> formalChildSalMap = new Map<Id,Contact>();
	 Map<Id,contact> informalStandardSalMap = new Map<Id,Contact>();															
	
	 // Get custom setting data for contact prefix mapping
	 Map<String,Contact_Prefix_Mapping__c> prefixMap = Contact_Prefix_Mapping__c.getAll();
     
   Id accountHouseholdRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().
																		get('Household').getRecordTypeId(); 
     
	//Method populates Maps for creating household salutations		
	public void populateHouseHoldMaps(List<Sobject> sobjList){
		Set<Id> accIdSet = new Set<Id>();	
		Set<Id> conIdSet = new Set<Id>();	

		
		// Get account ids 	
		for(Contact cont : (List<Contact>)sobjList){
				accIdSet.add(cont.AccountId);
			}

		
		// Map contains accounts and child Preferred and Secondary contact's
		accMap = new Map<id,Account>([SELECT Id,RecordtypeId, (SELECT Id,
																												rC_Bios__Preferred_Contact__c,
																												rC_Bios__Secondary_Contact__c,
																												FirstName,LastName,
																												No_Prefix__c,
																												rC_Bios__Middle_Name__c ,
																												rC_Bios__Gender__c
																												FROM Contacts 
																												WHERE rC_Bios__Preferred_Contact__c = true 
																												OR
																												rC_Bios__Secondary_Contact__c = true)
																	FROM Account 
																	WHERE Id in : accIdSet]);
		

		// Get child contact id
		for(Account acc : accMap.values()){
			for(Contact cont :accMap.get(acc.id).Contacts) {
					conIdSet.add(cont.id);
			}
		}

		
		// Map contains contact and child salutation records
		childSalMap = new Map<id,Contact>([SELECT id,rC_Bios__Preferred_Contact__c,
																							rC_Bios__Secondary_Contact__c,
																							Prof_Suffix__c,
																							APP_Suffix__c,rC_Bios__Gender__c,
																							FirstName,LastName,
																							rC_Bios__Middle_Name__c ,
																							Salutation,
																							No_Prefix__c,
																							AccountId,
																							(SELECT id,
																								Override__c,
																								rC_Bios__Salutation_Line_1__c,
																								rC_Bios__Salutation_Type__c 
																								FROM 
																								rC_Bios__Salutations__r)
																								
																			FROM Contact
																			WHERE (rC_Bios__Preferred_Contact__c = true 
																			OR
																			rC_Bios__Secondary_Contact__c = true)
																			AND 
																			Id in : conIdSet]);

		formalChildSalMap = 
						new Map<Id,Contact>([SELECT	id,rC_Bios__Preferred_Contact__c,
																				rC_Bios__Secondary_Contact__c,
																				rC_Bios__Gender__c,
																				No_Prefix__c,
																				Salutation,LastName,rC_Bios__Middle_Name__c,
																				(SELECT 	id,rC_Bios__Contact__c,
																										rC_Bios__Salutation_Type__c,
																										Override__c,
																										rC_Bios__Inside_Salutation__c
																										FROM
																										rC_Bios__Salutations__r 
																										WHERE
																										rC_Bios__Salutation_Type__c 
																												= :SalutationConstants.FORMAL_NAME
																										LIMIT 1)
																									
																From Contact
																WHERE Id in : conIdSet]);
																				
																																					
		informalStandardSalMap = 
									new Map<Id,Contact>([SELECT	id,rC_Bios__Preferred_Contact__c,
																							rC_Bios__Secondary_Contact__c,
																							Salutation,LastName,
																							No_Prefix__c,
																							rC_Bios__Gender__c,
																							rC_Bios__Middle_Name__c,
																							(SELECT 	id,rC_Bios__Contact__c,
																										rC_Bios__Salutation_Type__c,
																										Override__c,
																										rC_Bios__Inside_Salutation__c
																										FROM
																										rC_Bios__Salutations__r 
																										WHERE
																										rC_Bios__Salutation_Type__c 
																												= :SalutationConstants.STANDARD_INFORMAL
																										LIMIT 1)
																									
																			From Contact
																			WHERE Id in : conIdSet]);

		
		

	}		


	// Method to create chiold saluatation on sobject
	public List<rC_Bios__Salutation__c> createChildSalutation(List<SObject> sobjList){
		String objName = sObjList[0].getSObjectType().getDescribe().getName();
		List<rC_Bios__Salutation__c> salutationList = new List<rC_Bios__Salutation__c>();
		
		
		if(sobjList.isEmpty()){
				return null;
		}
    

		for(SObject sObj : sobjList){
			if(objName == 'Account'){
				salutationList.add(createSalutation(sObj,SalutationConstants.ORGANIZATION_PREF_MAIL_NAME,
																			 SalutationConstants.OUTSIDE_ORGANIZATION));
				salutationList.add(createSalutation(sObj,SalutationConstants.ORGANIZATION_PUBLICATION_NAME,
																		 				SalutationConstants.PUBLICATION_ORGANIZATION));
			}
			
			
			//Added By Aditi B :S-367721-Contact Salutations: Inside (Auto-Create)
			if(objName == 'Contact'){
				salutationList.add(createSalutation(sObj,SalutationConstants.FORMAL_NAME ,
																						SalutationConstants.INSIDE_CONTACT));
				salutationList.add(createSalutation(sObj, SalutationConstants.PREF_MAIL_NAME,
									 													SalutationConstants.OUTSIDE_CONTACT));
				salutationList.add(createSalutation(sObj, SalutationConstants.PUBLICATION_NAME, 
																						SalutationConstants.PUBLICATION_CONTACT));
				
				// Added By Aditi B : T-486876/S-370558 - Contact Salutations Outside (Long) 
				salutationList.add(createSalutation(sObj,SalutationConstants.PREF_MAIL_NAME_LONG, 
																							SalutationConstants.OUTSIDE_CONTACT));
			}
			
		}
		return salutationList;
	}

	// This Method creates household child saluatation record on account 
	public List<rC_Bios__Salutation__c> createHouseholdSalutationOnAccount(List<Sobject> sobjList){
		List<rC_Bios__Salutation__c> salHouseHoldList = new List<rC_Bios__Salutation__c>();
		String objName = sObjList[0].getSObjectType().getDescribe().getName();

		if(objName == 'Contact'){ 
			populateHouseHoldMaps(sobjList);
			
			for(SObject sObj : sobjList){
    			if(accMap.get(''+sobj.get('AccountId')).Contacts.size () > 1
    				&& sobj.get('rC_Bios__Preferred_Contact__c') != true
    				&& accMap.get(''+sobj.get('AccountId')).RecordtypeId == accountHouseholdRecTypeId ) {
    				
    				salHouseHoldList.add(createSalutation(sObj, SalutationConstants.HOUSEHOLD_STACKED_PREF_MAIL_NAME,
    																							SalutationConstants.OUTSIDE_HOUSEHOLD	));

    				salHouseHoldList.add(createSalutation(sObj,SalutationConstants.HOUSEHOLD_PREF_MAIL_NAME,
    																							SalutationConstants.OUTSIDE_HOUSEHOLD	));

    				salHouseHoldList.add(createSalutation(sObj,SalutationConstants.HOUSEHOLD_FORMAL,
    																							SalutationConstants.INSIDE_HOUSEHOLD));

    				salHouseHoldList.add(createSalutation(sObj,SalutationConstants.HOUSEHOLD_FIRST_NAME,
    																							SalutationConstants.INSIDE_HOUSEHOLD));

    				salHouseHoldList.add(createSalutation(sObj,SalutationConstants.HOUSEHOLD_STANDARD_INFORMAL,
    																							SalutationConstants.INSIDE_HOUSEHOLD));

    				// Added By Aditi B :T-486876/S-370558
    				salHouseHoldList.add(createSalutation(sObj,SalutationConstants.HOUSEHOLD_STACKED_PREF_MAIL_NAME_LONG,
    																							SalutationConstants.OUTSIDE_HOUSEHOLD));

    				// Added By Aditi B :T-486878/S-370555
    				salHouseHoldList.add(createSalutation(sObj,SalutationConstants.HOUSEHOLD_PREF_MAIL_NAME_LONG,
    																							SalutationConstants.OUTSIDE_HOUSEHOLD));

    			}
    		}
			
		}
		
		
		
		
		return salHouseHoldList;	
	}

	// This Method create child salutation records for parent account or contact	
	public rC_Bios__Salutation__c createSalutation(Sobject sObj, String type,String salutationUse ){
		String objName = sObj.getSObjectType().getDescribe().getName();
		String accName;
		String conName;
		String salutationLine;
	  rC_Bios__Salutation__c salObj = new rC_Bios__Salutation__c();
	  salObj.Salutation_Use__c = salutationUse;
	  salObj.rC_Bios__Salutation_Type__c = type;     
		salObj.Auto_Created__c = true;
		salObj.Override__c = false;
	  SalObj.rC_Bios__Is_Active__c = true;

	  if(objName == 'Account'){
	  	 accName = ''+sObj.get('Name');
	  	 if(accName.length() >= 60){
	  		String acntName = getAccountName(accName,type);
	  		salObj.rC_Bios__Salutation_Line_1__c = acntName;
	  		if(type == SalutationConstants.ORGANIZATION_PREF_MAIL_NAME){
					salObj.Truncated__c = true; 
				} else {
					salObj.Truncated__c = false;
				}
				salObj.rC_Bios__Account__c = ''+sObj.get('id');
	  	} else {
	  		salObj.rC_Bios__Salutation_Line_1__c = accName;
				salObj.Truncated__c = False;
				salObj.rC_Bios__Account__c = ''+sObj.get('id');
	  	}
	  	
	    
	  } else if(objName == 'Contact'){
		  	String salLine1;
		  	String salLine;
		  	String salLineLong;
	  		Contact con = (Contact) sobj;
	  		if(type == SalutationConstants.HOUSEHOLD_STACKED_PREF_MAIL_NAME ){
					salObj.rC_Bios__Salutation_Line_1__c = gethouseholdSalutationLine(con.AccountId,true);
	  			salObj.rC_Bios__Salutation_Line_2__c = gethouseholdSalutationLine(con.AccountId,false);
	  			salObj.rC_Bios__Account__c = ''+sObj.get('AccountId');
	  			} else if(type == SalutationConstants.HOUSEHOLD_PREF_MAIL_NAME
	  								|| type == SalutationConstants.HOUSEHOLD_PREF_MAIL_NAME_LONG ){
	  					
	  					// Modified By Aditi B :T-486878/S-370555
	  					if(type == SalutationConstants.HOUSEHOLD_PREF_MAIL_NAME){
		  					salLine1 = gethouseholdSalutationLine(con.AccountId,true);
		  					salLine1 += +' '+'and'+' '+ gethouseholdSalutationLine(con.AccountId,false);
	  					} else {
	  						// Added By Aditi B :T-486878/S-370555
	  						salLine1 = '';	
		  					salLine1 = getHouseholdPrefMailNameLong(con.AccountId);
	  					}
	  					
	  					if(salLine1.length() > 60){
	  							salLine1 = salLine1.left(60);
	  							salObj.rC_Bios__Salutation_Line_1__c = salLine1; 
	  							salObj.Truncated__c = true;
	  					} else {
	  							salObj.rC_Bios__Salutation_Line_1__c = salLine1;
	  							salObj.Truncated__c = False;
									
	  					}
	  					salObj.rC_Bios__Account__c = ''+sObj.get('AccountId');
	  					
	  				} else if (type == SalutationConstants.HOUSEHOLD_FORMAL) {
									salObj.rC_Bios__Inside_Salutation__c 
														= getHouseholdInsideFormalSalutation(con.AccountId);
									salObj.rC_Bios__Account__c = ''+sObj.get('AccountId');
	  				} else if (type == SalutationConstants.HOUSEHOLD_FIRST_NAME) {
  								salObj.rC_Bios__Inside_Salutation__c 
  													= getInsideFirstNameSalutation(con.AccountId);
  								salObj.rC_Bios__Account__c = ''+sObj.get('AccountId');
	  				} else if (type == SalutationConstants.HOUSEHOLD_STANDARD_INFORMAL){
	  							salObj.rC_Bios__Inside_Salutation__c 
	  												= getInsideStandardInformalSalutation(con.AccountId);
	  							salObj.rC_Bios__Account__c = ''+sObj.get('AccountId');

	  				} else if(type == SalutationConstants.HOUSEHOLD_STACKED_PREF_MAIL_NAME_LONG ){
							salObj.rC_Bios__Salutation_Line_1__c 
														= gethouseholdSalLine1ForPrefLong(con.AccountId,true);
			  			salObj.rC_Bios__Salutation_Line_2__c
			  									 = gethouseholdSalLine1ForPrefLong(con.AccountId,false);
			  			
			  			salObj.rC_Bios__Account__c = ''+sObj.get('AccountId');
		  			
		  			} else if(type == SalutationConstants.FORMAL_NAME ){ //Added By Aditi B :S-367721-Contact Salutations: Inside (Auto-Create)
									salObj.rC_Bios__Inside_Salutation__c = getContactName(con,type); 
									salObj.rC_Bios__Contact__c = ''+sobj.get('id');
	  				} else {
						  	conName = getContactName(con,type);
						  	if( type == SalutationConstants.PREF_MAIL_NAME ) {
					  				if(conName.length() > 40 ){
						  					conName = conName.left(40);
						  					salObj.Truncated__c = true;
						  			}
						  	} else{
						  				
						  				salObj.Truncated__c = false;
			  					}
						  	
						  	
						  	salObj.rC_Bios__Salutation_Line_1__c = conName;
						  	salObj.rC_Bios__Contact__c = ''+sobj.get('id');
						  	
							}
	  				

		  				
		  	
			}	
	        

	  return salObj;
	      
	}

	// This Method returns value of salutation line 1 and line 2 
	// on preffered and secondary contact for household account
	  
	public String gethouseholdSalutationLine(String id, Boolean isPrimary){
		String salLine;
		if(accMap.size() >0 && ChildSalMap.size()>0){
			for(Contact con : accMap.get(id).Contacts){
				for(rC_Bios__Salutation__c sal : childSalMap.get(con.id).rC_Bios__Salutations__r){
					if(isPrimary && con.rC_Bios__Preferred_Contact__c == true 
						&& sal.rC_Bios__Salutation_Type__c == SalutationConstants.PREF_MAIL_NAME){
								salLine = sal.rC_Bios__Salutation_Line_1__c;
				      	break;
					} else if( !isPrimary && con.rC_Bios__Secondary_Contact__c == true 
									&& sal.rC_Bios__Salutation_Type__c == SalutationConstants.PREF_MAIL_NAME){
										salLine = sal.rC_Bios__Salutation_Line_1__c;
										break;

						}
				}
				if(String.isNotBlank(salLine)){
					break;	
				}

			}
		}
		return salLine;
	}
	
	// This Method returns value of salutation line 1 and 2
	// on preffered and secondary contact for Household 
	// Stacked Pref Mail Name Long account 
	  
	public String gethouseholdSalLine1ForPrefLong(String id, Boolean isPrimary){
		String salLine;
		if(accMap.size() >0 && ChildSalMap.size()>0){
			for(Contact con : accMap.get(id).Contacts){
				for(rC_Bios__Salutation__c sal : childSalMap.get(con.id).rC_Bios__Salutations__r){
					if(isPrimary && con.rC_Bios__Preferred_Contact__c == true 
						&& sal.rC_Bios__Salutation_Type__c == SalutationConstants.PREF_MAIL_NAME_LONG){
								salLine = sal.rC_Bios__Salutation_Line_1__c;
				      	break;
					} else if( !isPrimary && con.rC_Bios__Secondary_Contact__c == true 
									&& sal.rC_Bios__Salutation_Type__c == SalutationConstants.PREF_MAIL_NAME_LONG){
										salLine = sal.rC_Bios__Salutation_Line_1__c;
										break;

						}
				}
				if(String.isNotBlank(salLine)){
					break;	
				}

			}
		}
		return salLine;
	}


	// This Method returns value of Salutation Line 1
	// for householdPrefMailNameLong salutation
	public string getHouseholdPrefMailNameLong (String id){
		String salLine;
		String maleConId;
		String femaleConId;
		String conMalePrefix;
		String conFemalePrefix;
		String middleName;
		String suffix;
		if(accMap.size() >0 && !childSalMap.isEmpty() ){
			for(Contact con : accMap.get(id).Contacts){
				if(con.rC_Bios__Gender__c == 'Female'){
						femaleConId = con.id;
				} else if(con.rC_Bios__Gender__c == 'Male'){
						maleConId = con.id;
				}
			}

				

			if(!String.isEmpty(maleConId) && !String.isEmpty(femaleConId)
					&& childSalMap.get(maleConId).Lastname 
														== childSalMap.get(femaleConId).Lastname 
					&& String.isEmpty(childSalMap.get(femaleConId).Prof_Suffix__c)
					&& (String.isEmpty(childSalMap.get(femaleConId).Salutation)
							|| childSalMap.get(femaleConId).Salutation 
														== prefixMap.get('Ms.').Name
							|| childSalMap.get(femaleConId).Salutation 
														== prefixMap.get('Mrs.').Name)
					&& !childSalMap.get(maleConId).No_Prefix__c ){

				conMalePrefix = String.isEmpty(childSalMap.get(maleConId).Salutation) 
											||childSalMap.get(maleConId).Salutation == 'The Honorable'?
											getContactPrefix(childSalMap.get(maleConId)):
											prefixMap.containsKey(maleConId) ?
											prefixMap.get(maleConId).Alternate_Prefix__c:
											childSalMap.get(maleConId).Salutation;

				conFemalePrefix = 	String.isEmpty(childSalMap.get(femaleConId).Salutation)
											||childSalMap.get(femaleConId).Salutation == 'The Honorable'?
											getContactPrefix(childSalMap.get(femaleConId)) :
											prefixMap.containsKey(femaleConId) ?
											prefixMap.get(femaleConId).Alternate_Prefix__c:
											childSalMap.get(femaleConId).Salutation;		
				
				middleName = String.isEmpty(childSalMap.get(maleConId).FirstName) 
										|| 	childSalMap.get(maleConId).FirstName.length() == 1
										|| (childSalMap.get(maleConId).FirstName.length() == 2
												&& childSalMap.get(maleConId).FirstName.indexOf('.',1) == 1	)
									 	? childSalMap.get(maleConId).rC_Bios__Middle_Name__c : '';

			 
			 	suffix = !String.isEmpty(childSalMap.get(maleConId).APP_Suffix__c) 
			 						? (childSalMap.get(maleConId).APP_Suffix__c.left(2) == 'Jr' 
			 							|| childSalMap.get(maleConId).APP_Suffix__c.left(2) == 'Sr') 
			 						 ?','+' '+childSalMap.get(maleConId).APP_Suffix__c 
			 						 : ' '+childSalMap.get(maleConId).APP_Suffix__c : '';
				
				salLine = !String.isEmpty(conMalePrefix)?
									 conMalePrefix + ' and '+' '+ prefixMap.get('Mrs.').Name+' ':'';
				salLine += !String.isEmpty(childSalMap.get(maleConId).FirstName) 
									|| !String.isEmpty(childSalMap.get(maleConId).FirstName)
											&&childSalMap.get(maleConId).FirstName.length() == 1
									|| (!String.isEmpty(childSalMap.get(maleConId).FirstName)
											&& childSalMap.get(maleConId).FirstName.length() == 2
											&& childSalMap.get(maleConId).FirstName.indexOf('.',1) == 1	)
  								?  childSalMap.get(maleConId).FirstName :'';
				
				salLine += !String.isEmpty(childSalMap.get(maleConId).rC_Bios__Middle_Name__c) ?
										!String.isEmpty(middleName) ? ' '+middleName :
										' '+childSalMap.get(maleConId).rC_Bios__Middle_Name__c.left(1).toUpperCase() +'.':'';

  			if(!childSalMap.get(maleConId).No_Prefix__c){
  				salLine += ' ' + childSalMap.get(maleConId).LastName;
  			}
  			salLine += !String.isEmpty(getSuffix(childSalMap.get(maleConId)) ) 
  									? ''+suffix : '';
				System.debug('****ConName,when last name same'+salLine);

				
			
			} else {
				 salLine = gethouseholdSalLine1ForPrefLong(id,true) + +' '+'and'+' '+ 
				 gethouseholdSalLine1ForPrefLong(id,false);
		  					 
				 System.debug('****ConName,when last name different'+salLine);
			}
		
		}
		return salLine;
	}

	// This Method calculates the value of inside salutation 
	// for household salutation with type = 'Household Formal'
	public string getHouseholdInsideFormalSalutation (String id){
	
		String insideSal;
		String preferredConId;
		String secondaryConId;
		String insideSalPref;
		String insideSalSec;
		String conPrefPrefix;
		String conSecPrefix;
		if(accMap.size() >0 && formalChildSalMap.size()>0){
			for(Contact con : accMap.get(id).Contacts){
				if(con.rC_Bios__Preferred_Contact__c == true){
						preferredConId = con.id;
				} else if(con.rC_Bios__Secondary_Contact__c == true){
						secondaryConId = con.id;
				}
			}
			
			conPrefPrefix = String.isEmpty(formalChildSalMap.get(preferredConId).Salutation) 
											||formalChildSalMap.get(preferredConId).Salutation == 'The Honorable'?
											getContactPrefix(formalChildSalMap.get(preferredConId)):
											prefixMap.containsKey(preferredConId) ?
											prefixMap.get(preferredConId).Alternate_Prefix__c:
											formalChildSalMap.get(preferredConId).Salutation;

			conSecPrefix = 	String.isEmpty(formalChildSalMap.get(secondaryConId).Salutation)
											||formalChildSalMap.get(secondaryConId).Salutation == 'The Honorable'?
											getContactPrefix(formalChildSalMap.get(secondaryConId)) :
											prefixMap.containsKey(secondaryConId) ?
											prefixMap.get(secondaryConId).Alternate_Prefix__c:
											formalChildSalMap.get(secondaryConId).Salutation;							
			

			if( preferredConId != null && secondaryConId != null 
					&& formalChildSalMap.get(preferredConId).rC_Bios__Salutations__r.size() >0
					&& formalChildSalMap.get(secondaryConId).rC_Bios__Salutations__r.size() >0 ){
				
				if((formalChildSalMap.get(preferredConId).LastName 
								!= formalChildSalMap.get(secondaryConId).LastName) 
						|| String.isEmpty(conPrefPrefix)
						|| String.isEmpty(conSecPrefix)
						|| ((formalChildSalMap.get(preferredConId).rC_Bios__Salutations__r[0].Override__c)
								|| (formalChildSalMap.get(secondaryConId).rC_Bios__Salutations__r[0].Override__c))
						||	(conPrefPrefix == 'Ms.'
								||conSecPrefix == 'Ms.')){

						insideSalPref = formalChildSalMap.get(preferredConId).rC_Bios__Salutations__r[0].rC_Bios__Inside_Salutation__c;
						insideSalSec = 	formalChildSalMap.get(secondaryConId).rC_Bios__Salutations__r[0].rC_Bios__Inside_Salutation__c;	  
						insideSal = insideSalPref + ' '+ 'and'+ ' '+ insideSalSec;
						
						
				} else if (conPrefPrefix == 'Mrs.'){
							insideSal = conSecPrefix + ' ' +
													'and'+ ' '+ conPrefPrefix + 
													' '+ formalChildSalMap.get(secondaryConId).LastName;
													
													
				}	else if(conSecPrefix == 'Mrs.'){
							insideSal = conPrefPrefix + ' ' +
													'and'+ ' '+ conSecPrefix + 
													' '+ formalChildSalMap.get(preferredConId).LastName;
													
				} else if (conPrefPrefix 
											== conSecPrefix ){
							if(conPrefPrefix == 'Dr.'){
									insideSal = 'Drs.' + ' '+formalChildSalMap.get(preferredConId).LastName;
							} else if (conPrefPrefix == 'Professor') {
									insideSal = 'Professors' + ' '+formalChildSalMap.get(preferredConId).LastName;
									
							}	else {
								insideSal = conPrefPrefix +' ' +
														'and'+' '+conSecPrefix+ ' '+
														formalChildSalMap.get(preferredConId).LastName;

														
								}
																		
					} else {
								insideSal = conPrefPrefix +' ' +
														'and'+' '+conSecPrefix+ ' '+
														formalChildSalMap.get(preferredConId).LastName;
									
														
					}
			}
		}
		return insideSal;
	}

	// This Method returns the value of inside salutation 
	// for household salutation with type ='Household First Names'
	public String getInsideFirstNameSalutation(String id){
		String conName;
		String secondaryConName;
		String preferredConName;
		if(accMap.size() >0 && formalChildSalMap.size()>0){
			for(Contact con : accMap.get(id).Contacts){

				conName = !String.isEmpty(con.FirstName) && con.FirstName.length() >1
										 && con.FirstName.indexOf('.',1) != 1? con.FirstName :'';
				conName += String.isEmpty(conName) && !String.isEmpty(con.rC_Bios__Middle_Name__c) 
										&& con.rC_Bios__Middle_Name__c.length() >1 
										&& con.rC_Bios__Middle_Name__c.indexOf('.',1) != 1? con.rC_Bios__Middle_Name__c :'';
				if(formalChildSalMap.get(con.id).rC_Bios__Salutations__r.size() > 0){						
					conName += 	String.isEmpty(conName) ?formalChildSalMap.get(con.id).rC_Bios__Salutations__r[0].rC_Bios__Inside_Salutation__c :'';			
				}
				if(con.rC_Bios__Preferred_Contact__c == true){
						preferredConName = conName;
						conName = '';
				} else if(con.rC_Bios__Secondary_Contact__c == true){
						secondaryConName = conName;
						conName ='';
				}
			}
			conName = preferredConName+' '+ 'and'+' '+secondaryConName;

		}

		return conName;
	}


	private String getInsideInformal(String id,
																	String preferredConName,
																	String secondaryConName ){
		

		String conName;
		String secConName;
		String prefConName;
		if(accMap.size() >0 && formalChildSalMap.size()>0){
			for(Contact con : accMap.get(id).Contacts){

				conName = !String.isEmpty(con.FirstName) && con.FirstName.length() >1
									&& con.FirstName.indexOf('.',1) != 1? con.FirstName :'';
				conName += String.isEmpty(conName) && !String.isEmpty(con.rC_Bios__Middle_Name__c) 
										&& con.rC_Bios__Middle_Name__c.length() >1
										&& con.rC_Bios__Middle_Name__c.indexOf('.',1) != 1? con.rC_Bios__Middle_Name__c :'';
				if(formalChildSalMap.get(con.id).rC_Bios__Salutations__r.size() > 0){						
					conName += 	String.isEmpty(conName) ?formalChildSalMap.get(con.id).rC_Bios__Salutations__r[0].rC_Bios__Inside_Salutation__c :'';			
				}
				if(con.rC_Bios__Preferred_Contact__c == true){
						prefConName = conName;
						conName = '';
				} else if(con.rC_Bios__Secondary_Contact__c == true){
						secConName = conName;
						conName ='';
				}
			}
			if(preferredConName != Null && secondaryConName == Null){
					conName = preferredConName+' '+ 'and'+' '+secConName;
			} else if(preferredConName == Null && secondaryConName != Null){
					conName = prefConName+' '+ 'and'+' '+secondaryConName;
				} else {
					conName = prefConName+' '+ 'and'+' '+secConName;
				}

		}

		return conName;
	}

	// This Method returns the value of inside salutation 
	// for household salutation with type = 'Household Standard Informal'
	public String getInsideStandardInformalSalutation(String id){
		String conName;
		String secondaryConName;
		String preferredConName;
		if(accMap.size() >0 && informalStandardSalMap.size()>0){
			for(Contact con : accMap.get(id).Contacts){
				if(informalStandardSalMap.get(con.id).rC_Bios__Salutations__r.size() > 0){
					conName = informalStandardSalMap.get(con.id).rC_Bios__Salutations__r[0].rC_Bios__Inside_Salutation__c ;
					if(con.rC_Bios__Preferred_Contact__c == true){
							preferredConName = conName;
							conName = '';
					} else if(con.rC_Bios__Secondary_Contact__c == true){
							secondaryConName = conName;
							conName ='';
					}
				}	
			}
			
		}	
		if(preferredConName != null && secondaryConName != null){
				conName = preferredConName+' '+ 'and'+' '+secondaryConName;
		} else {
					conName = getInsideInformal(id,preferredConName,secondaryConName);
		}
		
		return conName;
	}

	// Method return prefix for salutation line
	public String getPrefix(Contact con){

		if(!String.isEmpty(con.Prof_Suffix__c)){
					return '';
			} 

		if((String.isEmpty(con.Salutation) 
			&& (String.isEmpty(con.FirstName)
				|| String.isEmpty(con.LastName))) 
					|| (String.isEmpty(con.Salutation) 
						&& (!String.isEmpty(con.FirstName) 
							|| !String.isEmpty(con.LastName)) )
					&& !(con.No_Prefix__c)){

				if(con.rC_Bios__Gender__c == 'Male'){
					//return 'Mr.';
					return prefixMap.get('Mr.').Abbreviated_Prefix__c;
				} else if(con.rC_Bios__Gender__c == 'Female'){
					//return 'Ms.';
					return prefixMap.get('Ms.').Abbreviated_Prefix__c;

				} else if(con.rC_Bios__Gender__c == 'Other'){
						return prefixMap.get('Mx.').Abbreviated_Prefix__c;

				} else {
						return prefixMap.get('Mr/s.').Abbreviated_Prefix__c;

				}
				
		} else if(!String.isEmpty(con.Salutation) 
							&& String.isEmpty(con.Prof_Suffix__c)
							&& !(con.No_Prefix__c)){
				if(prefixMap.containsKey(con.Salutation)){
					return prefixMap.get(con.Salutation).Abbreviated_Prefix__c;
				} else {
					return con.Salutation;
				}
				
			} else {
					return '';
			}
	}


	

	// Method return firstname for salutation line
	public String getFirstName(Contact con){
		return con.FirstName;
	}

	// Method return lastname for salutation line
	public String getLastName(Contact con){
		return con.LastName;
	}

	// Method return MiddleName for salutation line
	public String getMiddleName(Contact con){
		if(String.isEmpty(con.FirstName) 
			|| (con.FirstName.length() == 1)
			|| (con.FirstName.length() == 2
					&& con.FirstName.indexOf('.',1) == 1) ){
			return con.rC_Bios__Middle_Name__c;
		}else {
			return '';
		}
	}

	// Method return suffix for salutation line
	public String getSuffix(Contact con){

		if(String.isEmpty(con.APP_Suffix__c)){
			return '';
		}else if (con.APP_Suffix__c.left(2) == 'Jr' || con.APP_Suffix__c.left(2) == 'Sr'){
			return ','+' '+con.APP_Suffix__c;	
		} else {
			return ' '+con.APP_Suffix__c;	
		}
		
	}

	// Method return pro-suffix for salutation line
	public String getProSuffix(Contact con){
		if(String.isEmpty(con.Prof_Suffix__c)){
			return '';
		}else{
			return ','+' '+con.Prof_Suffix__c;	
		}
		
	}

	// This Method contains logic to create 
	// salutation line from parent account's name
	public String getAccountName(String accName,String type){
		
		if(type == SalutationConstants.ORGANIZATION_PREF_MAIL_NAME ){
			//accName = accName.replaceAll( '\\s+', '');
			accName = accName.left(60);
			return accName;
		} else {
			return accName;
		}
	}

	// This Method contains logic to create 
	// salutation line from parent contact's name
	public String getContactName(Contact con, String type){
		List<String> maritalStatusList = new List<string>{'Widowed','Married At Death'};
		String prefix = getPrefix(con);
  	String firstName = getFirstName(con);
  	String lastName = getLastName(con);
  	String middleName = getMiddleName(con);
  	String suffix = getSuffix(con);
  	String proSuffix = getProSuffix(con);
  	String pubMiddleName ;
  	String prefixPrefLong;
  	if(con.rC_Bios__Middle_Name__c != null){
  		pubMiddleName = con.rC_Bios__Middle_Name__c;
  	}else {
  		pubMiddleName = '';
  	}
  	String conName ;

  	if (type == SalutationConstants.PREF_MAIL_NAME){
  			conName =	!(con.No_Prefix__c)?prefix:'';
  			conName += !String.isEmpty(firstName )? ' '+firstName : '';
  			conName += !String.isEmpty(middleName ) ? ' '+middleName : '';
  			conName += !String.isEmpty(lastName ) ? ' '+lastName : '';
  			conName += !String.isEmpty(suffix ) ? ''+suffix : '';
  			conName += !String.isEmpty(proSuffix ) ? ''+proSuffix : ''; 
  			//conName = conName.replaceAll( '\\s+', '');
  			/*if(conName.length() > 40 ){
  					
  					conName = conName.left(40);
  			}*/
 			return conName;
  			
  	} else if (type == SalutationConstants.PUBLICATION_NAME){
  			
  			if(con.rC_Bios__Gender__c == 'Female' ){
  				
  				if(salMap.size() > 0 
  					&& salMap.get(con.id).rC_Bios__Salutations__r.size() >0 
  					&& salMap.containsKey(con.id) 
						&& prefMap.get(con.id).rC_Bios__Preferences__r.size()> 0 
						&& prefMap.containsKey(con.id)){
  						
  						if(!String.isEmpty(salMap.get(con.id).rC_Bios__Salutations__r[0].rC_Bios__First_Name__c)
  							&& salMap.get(con.id).rC_Bios__Salutations__r[0].rC_Bios__Last_Name__c != con.LastName){
  								
  								conName = salMap.get(con.id).rC_Bios__Salutations__r[0].rC_Bios__First_Name__c + 
  													' ' +salMap.get(con.id).rC_Bios__Salutations__r[0].rC_Bios__Last_Name__c + 
  													' ' + con.LastName;
  													
  								//conName = conName.replaceAll( '\\s+', '');					
  								return conName;					 
  						} 

  				} else if (relationshipMap.size () >0 ){
  					system.debug('Inside relationship Map');

  						if((con.rC_Bios__Marital_Status__c == 'Widowed'
									||con.rC_Bios__Marital_Status__c == 'Married At Death')
									&& con.Salutation == prefixMap.get('Mrs.').Abbreviated_Prefix__c
									&&((relationshipMap.get(con.id).rC_Bios__Relationships_Contact_1__r.size () >0
											&& con.FirstName == deceasedPartnerMap.get(relationshipMap.get(con.id).
																																rC_Bios__Relationships_Contact_1__r[0]
																																.rC_Bios__Contact_2__c).FirstName
											&& con.LastName == deceasedPartnerMap.get(relationshipMap.get(con.id).
																																rC_Bios__Relationships_Contact_1__r[0]
																																.rC_Bios__Contact_2__c).LastName)																	
											|| (salMap.size() >0 
													&& salMap.get(con.id).rC_Bios__Salutations__r.size() > 0 
													&& con.FirstName != salMap.get(con.id).rC_Bios__Salutations__r[0].rC_Bios__First_Name__c))){

  										conName =  prefixMap.get('Mrs.').Abbreviated_Prefix__c+' ';
											conName += !String.isEmpty(firstName)? firstname + ' ' : '';
							  			conName += !String.isEmpty(pubMiddleName ) ? pubMiddleName.left(1)+'.' +' ' : '';
							  			conName += !String.isEmpty(lastName)? lastName : '';
							  			conName += !String.isEmpty(suffix)? suffix : '';
							  			//conName = conName.replaceAll( '\\s+', '');	
							  			System.debug('contact name - Female'+conName);
							  			return conName;
  					}
  				}	
  			} 
		  			
		  			conName =	 !String.isEmpty(firstName)? firstname + ' ' : '';
		  			conName += !String.isEmpty(pubMiddleName ) ? pubMiddleName.left(1)+'.' +' ' : '';
		  			conName += !String.isEmpty(lastName)? lastName : '';
		  			conName += !String.isEmpty(suffix)? suffix : '';
		  			//conName = conName.replaceAll( '\\s+', '');	
		  			return conName;
		  		
					
  			
  		} else if (type == SalutationConstants.FORMAL_NAME ){ //Added By Aditi B :S-367721-Contact Salutations: Inside (Auto-Create)
  			String conPrefix = '';
  			
  			
  			if((String.isEmpty(con.Salutation) || con.Salutation == 'The Honorable')
  					&& !(con.No_Prefix__c)){
  				conPrefix = getContactPrefix(con);
  			}

  			if(conPrefix == ''){
  					conName =  !String.isEmpty(con.Salutation)  ? 
												prefixMap.containsKey(con.Salutation)?
  										 	prefixMap.get(con.Salutation).Alternate_Prefix__c + ' ': con.Salutation+' ':'';	
				} else {
						conName = !String.isEmpty(conPrefix) ? conPrefix + ' ':'' ;	
				}  			
  			conName += String.isEmpty(conName)? (!String.isEmpty(con.FirstName)? con.FirstName+' ':''):'';
  			conName += String.isEmpty(conName)?(!String.isEmpty(con.rC_Bios__Middle_Name__c)? con.rC_Bios__Middle_Name__c + ' ':''):'';
  			conName += con.LastName;
  			//conName = conName.replaceAll( '\\s+', '');	
  			
  			return conName;// end of S-367721

  		} else if (type == SalutationConstants.PREF_MAIL_NAME_LONG ){ // Added By Aditi B :T-486876/S-370558

  			prefixPrefLong = !String.isEmpty(con.Prof_Suffix__c)|| (con.No_Prefix__c)? '':
													!String.isEmpty(con.Salutation) ? con.Salutation : 
													getContactPrefix(con);
  			conName =	prefixPrefLong;
  			conName += !String.isEmpty(firstName )? ' '+firstName : '';
  			conName += !String.isEmpty(con.rC_Bios__Middle_Name__c) ?
										!String.isEmpty(middleName) ? ' '+middleName :
										' '+con.rC_Bios__Middle_Name__c.left(1).toUpperCase() +'.':'';						
  			
  			conName += !String.isEmpty(lastName ) ? ' '+lastName : '';
  			conName += !String.isEmpty(suffix ) ? ''+suffix : '';
  			conName += !String.isEmpty(proSuffix ) ? ''+proSuffix : ''; 
  			
 				return conName;
  			
  		}  // End of T-486876/S-370558
  		
  	return conName;

	}


	// This Method will update child salutation records's 
	// salutation line with parent object's name
	public List<rC_Bios__Salutation__c> updateChildSaluatationline1(List<Sobject> sobjList){
		String objName = sobjList[0].getSObjectType().getDescribe().getName();
		Map<Id, Account> accountChildSalMap;
		Map<Id, Contact> contactChildSalMap;
		
		List<rC_Bios__Salutation__c> salutationListToUpdate = new List<rC_Bios__Salutation__c>();
		String salLine;
		Set<Id> conIdSet = new Set<Id>();
		
		Map<String, SObject> sObjMap = new Map<String, SObject>();
		for(SObject sobjt : sobjList){
		   sObjMap.put(''+sobjt.get('Id'), sobjt); 
		}
		
		if(objName == 'Account'){

			accountChildSalMap = new Map<Id, Account>([SELECT Name, 
			                                            (SELECT Id,
														rC_Bios__Salutation_Line_1__c,
														Truncated__c,
														rC_Bios__Salutation_Type__c 
														FROM rC_Bios__Salutations__r
														WHERE 
														Override__c = false 
														)
														FROM Account 
														WHERE Id in :sobjList 
														]);

		} else if(objName == 'Contact'){

				contactChildSalMap = new Map<Id, Contact>([SELECT Name,No_Prefix__c,
													 (SELECT Id,
														rC_Bios__Salutation_Line_1__c,
														Truncated__c,
														rC_Bios__Salutation_Type__c 
														FROM rC_Bios__Salutations__r
														WHERE 
														Override__c = false 
														)
														FROM Contact 
														WHERE Id in : sobjList
														]);

														

				//Map Contains contact with child salutations
				// With type = Registration/Birth Name											
				salMap = new Map<Id,Contact>([SELECT id,No_Prefix__c,
																							(SELECT Id,
																								rC_Bios__Salutation_Type__c,
																								rC_Bios__First_Name__c,
																								rC_Bios__Last_Name__c 
																								FROM rC_Bios__Salutations__r 
																								WHERE rC_Bios__Salutation_Type__c
																								= 'Registration/Birth Name' LIMIT 1)
																			FROM Contact WHERE id in : sobjList]);
	
				// Map Contains contact with child preferences 
				// where type = Constituent Type and IsPrimary = true	
				prefMap = new Map<Id,Contact>([SELECT id,No_Prefix__c,
																							(SELECT Id
																							FROM rC_Bios__Preferences__r 
																							WHERE rC_Bios__Category__c = 'Constituent Type'
																					 		AND 
																					 		rC_Bios__Subcategory__c in : subCategoryList	
																					 		AND
																					 		rC_Bios__Primary__c = true 
																					 		LIMIT 1)
																			FROM Contact WHERE id in : sobjList]);			

				// This map store relationship of contact with another contact
				// where another contact is deceased patner of contact
				relationShipMap = new Map<Id,Contact>([Select id,
																											(Select id,
																															rC_Bios__Category__c,
																														 	rC_Bios__Contact_1__c, 
																														 	rC_Bios__Contact_2__c, 
																														 	rC_Bios__Role_2__c, 
																														 	rC_Bios__Stopping_Year__c
																										 	 From rC_Bios__Relationships_Contact_1__r 
																										 	 where 
																										 	 rC_Bios__Role_2__c = 'Deceased Partner'
																										 	 OR
																										 	 rC_Bios__Role_1__c = 'Deceased Partner' 
																										 	 order by  rC_Bios__Stopping_Year__c
																									 	 	 DESC LIMIT 1 ) 
																							From Contact c
																						 	where id in : sobjList]);

			
				if(relationShipMap.Size() > 0){
					System.debug('inside relationship map'+relationShipMap.values().size());
					System.debug('inside relationship map'+relationShipMap.values());
					for(Contact conPartner : relationShipMap.values() ){
						if(conPartner.rC_Bios__Relationships_Contact_1__r.size() > 0){
							conIdSet.add(relationShipMap.get(conPartner.id).rC_Bios__Relationships_Contact_1__r[0].rC_Bios__Contact_2__c);
						}
					}	

					deceasedPartnerMap = new Map<Id,contact>([select id ,
																													FirstName,
																													LastName
																					 				FROM Contact
																						 			WHERE Id In : conIdSet]);
				}
		}

		if( accountChildSalMap != null ){
			for ( Account acc : accountChildSalMap.values()) {
				
				Sobject sobj = sObjMap.get(''+acc.Id);
				
				// Update child salutation's saluattion line with parent contact's name	
				if(acc.rC_Bios__Salutations__r.size() > 0){
					List<rC_Bios__Salutation__c> accountChildSalList = acc.rC_Bios__Salutations__r;
				
				String accName = ''+ sobj.get('Name');
				if(accountChildSalList != null && accountChildSalList.size() > 0) {
					
					
					for (rC_Bios__Salutation__c sal : accountChildSalList){
								if(accName.length() > 60){
									sal.rC_Bios__Salutation_Line_1__c = getAccountName(accName,sal.rC_Bios__Salutation_Type__c);
									if(sal.rC_Bios__Salutation_Type__c == SalutationConstants.ORGANIZATION_PREF_MAIL_NAME){										 
									    sal.Truncated__c = true;
									}
								}else {
									sal.rC_Bios__Salutation_Line_1__c = ''+sobj.get('Name');
									sal.Truncated__c = false;
								}
								salutationListToUpdate.add(sal);
						}
				}	} 
			}
		}
		if( contactChildSalMap != null){
		for(Contact cont : contactChildSalMap.values()){
			Contact con = (Contact)sObjMap.get(''+cont.Id);
			// Update child salutation's salutation line with parent contact's name	
			List<rC_Bios__Salutation__c> contactChildSalList = cont.rC_Bios__Salutations__r;
			if(contactChildSalList!= null && contactChildSalList.size() >0){
				
					for (rC_Bios__Salutation__c sal : contactChildSalList){
							
							if(sal.rC_Bios__Salutation_Type__c == SalutationConstants.PREF_MAIL_NAME
									|| sal.rC_Bios__Salutation_Type__c == SalutationConstants.PUBLICATION_NAME
									|| sal.rC_Bios__Salutation_Type__c == SalutationConstants.PREF_MAIL_NAME_LONG){

									salLine = getContactName(con, sal.rC_Bios__Salutation_Type__c);
									
									if(sal.rC_Bios__Salutation_Type__c == SalutationConstants.PREF_MAIL_NAME 
											&& salLine.length() > 40 ){
												//salLine = salLine.replaceAll( '\\s+', '');	
												sal.rC_Bios__Salutation_Line_1__c = salLine.left(40);
												sal.Truncated__c = true;
											
									} else {
											sal.rC_Bios__Salutation_Line_1__c = salLine;
											sal.Truncated__c = false;
									}

									salutationListToUpdate.add(sal);

							} else if(sal.rC_Bios__Salutation_Type__c == SalutationConstants.FORMAL_NAME){
								sal.rC_Bios__Inside_Salutation__c = getContactName(con,sal.rC_Bios__Salutation_Type__c);
								salutationListToUpdate.add(sal);
							}
					}
				}
				

			}
		}
			contactService.isAutomaticUpdate = true;
			return salutationListToUpdate;

		}

	// This Method will update household salutation records on account
	// when preferrd or secondary contact on acoount updated	
	public void updateHouseHoldChildSalutations(List<Sobject> SobjList) {
		
		Map<Id, Account> contactChildSalMap;
		List<rC_Bios__Salutation__c> householdSalutationToUpdate = new List<rC_Bios__Salutation__c>();
		String salLine1;
		Set<Id> parentAccIdSet = new Set<Id>();

		//Method to populate maps
		populateHouseHoldMaps(SobjList);

		// Get account ids for contacts
		for(Contact cont : (List<Contact>) sobjList){
				parentAccIdSet.add(cont.AccountId);
		}
		Map<String, SObject> sObjMap = new Map<String, SObject>();
		for(SObject sobjt : sobjList){
		   sObjMap.put(''+sobjt.get('Id'), sobjt); 
		}
		// List contains child household salutations on parent account												
		contactChildSalMap  = new Map<Id,Account>([SELECT id,(SELECT Id,
																															rC_Bios__Salutation_Line_1__c,
																															Truncated__c,
																															rC_Bios__Contact__c,
																															rC_Bios__Salutation_Type__c 
																															FROM rC_Bios__Salutations__r
																															WHERE 
																															Override__c =false)
																										FROM Account
																										WHERE id in :parentAccIdSet]);
																			
			
																					
		
		// Update child salutations on account	
		if(contactChildSalMap != null && accMap != null){																
			for(Account acnt : contactChildSalMap.values()){
				Account acc = (Account)sObjMap.get(''+acnt.Id);
				// Update child salutation's salutation line with parent contact's name	
				List<rC_Bios__Salutation__c> childHouseHoldSalutationList = acnt.rC_Bios__Salutations__r;
				
				if(childHouseHoldSalutationList!= null && childHouseHoldSalutationList.size() >0
						&& accMap.get(acnt.id).Contacts.size () > 1){

					
						for (rC_Bios__Salutation__c sal1 : childHouseHoldSalutationList){
							
							if(sal1.rC_Bios__Salutation_Type__c 
																	== SalutationConstants.HOUSEHOLD_STACKED_PREF_MAIL_NAME ){
								
									sal1.rC_Bios__Salutation_Line_1__c = gethouseholdSalutationLine(acnt.id,true);
		  						sal1.rC_Bios__Salutation_Line_2__c = gethouseholdSalutationLine(acnt.id,false);
		  						householdSalutationToUpdate.add(sal1);
			  			
							} else if(sal1.rC_Bios__Salutation_Type__c
																 == SalutationConstants.HOUSEHOLD_STACKED_PREF_MAIL_NAME_LONG ){
									// Added By Aditi B :T-486876/S-370558

									sal1.rC_Bios__Salutation_Line_1__c = gethouseholdSalLine1ForPrefLong(acnt.id,true);
		  						sal1.rC_Bios__Salutation_Line_2__c = gethouseholdSalLine1ForPrefLong(acnt.id,false);
		  						householdSalutationToUpdate.add(sal1);
			  			
							} else if(sal1.rC_Bios__Salutation_Type__c
																			 == SalutationConstants.HOUSEHOLD_PREF_MAIL_NAME
											 || sal1.rC_Bios__Salutation_Type__c 
										 									== SalutationConstants.HOUSEHOLD_PREF_MAIL_NAME_LONG 
										 		){
									
									// Modified By Aditi B :T-486878/S-370555
			  					if(sal1.rC_Bios__Salutation_Type__c
			  														== SalutationConstants.HOUSEHOLD_PREF_MAIL_NAME){
				  					salLine1 = gethouseholdSalutationLine(acnt.id,true);
				  					salLine1 += +' '+'and'+' '+ gethouseholdSalutationLine(acnt.id,false);
			  					} else {
			  						// Added By Aditi B :T-486878/S-370555
			  						//salLine1 = gethouseholdSalLine1ForPrefLong(acnt.id,true);
				  					//salLine1 += +' '+'and'+' '+ gethouseholdSalLine1ForPrefLong(acnt.id,false);
				  					salLine1 = '';	
		  							salLine1 = getHouseholdPrefMailNameLong(acnt.id);
			  					}
									
			  					if(salLine1.length() > 60){
			  							salLine1 = salLine1.left(60);
			  							sal1.rC_Bios__Salutation_Line_1__c = salLine1; 
			  							sal1.Truncated__c = true;
			  					}else {
			  						sal1.rC_Bios__Salutation_Line_1__c = salLine1;
			  						sal1.Truncated__c = False;
			  					}

			  					
			  					householdSalutationToUpdate.add(sal1);
			  				} else if (sal1.rC_Bios__Salutation_Type__c 
	  																			== SalutationConstants.HOUSEHOLD_FORMAL ){
			  							
			  							sal1.rC_Bios__Inside_Salutation__c 
														= getHouseholdInsideFormalSalutation(acnt.id);
											householdSalutationToUpdate.add(sal1);			
										
		  					} else if(sal1.rC_Bios__Salutation_Type__c
		  																 == SalutationConstants.HOUSEHOLD_FIRST_NAME){
			  							
			  							sal1.rC_Bios__Inside_Salutation__c 
  													= getInsideFirstNameSalutation(acnt.id);
  										householdSalutationToUpdate.add(sal1);			

	  						} else if(sal1.rC_Bios__Salutation_Type__c 
	  																	== SalutationConstants.HOUSEHOLD_STANDARD_INFORMAL){
			  								
			  								sal1.rC_Bios__Inside_Salutation__c 
	  												= getInsideStandardInformalSalutation(acnt.id);
  											householdSalutationToUpdate.add(sal1);		
	  						}
	  				}	
					
				}
			}
		} 
	//	householdSalutationToUpdate = removeDuplicateSalutation(householdSalutationToUpdate);		
		if( householdSalutationToUpdate.size() >0 ){
			contactService.isAutomaticUpdate = true;
			Database.SaveResult[] salutationResult = Database.Update(householdSalutationToUpdate, false); 
			
		}
	}	


	// This Method returns prefix value for ocntact
	private String getContactPrefix(Contact con){
		String conPrefix;
		if((String.isEmpty(con.Salutation)|| con.Salutation =='The Honorable') 
				&& !(con.No_Prefix__c)) {
			if(con.rC_Bios__Gender__c == 'Male' ){
					conPrefix = prefixMap.get('Mr.').Abbreviated_Prefix__c;
			} else if(con.rC_Bios__Gender__c == 'Female'){
					conPrefix = prefixMap.get('Ms.').Abbreviated_Prefix__c;

				} else if(con.rC_Bios__Gender__c == 'Other'){
						conPrefix = prefixMap.get('Mx.').Abbreviated_Prefix__c;

					} else {
						conPrefix = prefixMap.get('Mr/s.').Abbreviated_Prefix__c;
					}
		}
		return conPrefix;
	}

}