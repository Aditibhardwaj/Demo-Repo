public without sharing class ApproveRejectStatergies {
  //Constants
  public static final String SORT_ORDER_DESC {get; set;}
  public static final String SORT_ORDER_ASC {get; set;}

  public static final Integer PAGE_SIZE {get; private set;}
  public static final List<Custom_Inline_Edit_Support_Configuration__c> inlineEditConfigurations {get; private set;}

  private static final Set<String> SEARCHABLE_FIELD_TYPES;
  private static final String OBJECT_NAME;
  private static final Schema.DescribeSObjectResult objDescribe;

  private static final Map<String, Schema.SObjectField> fieldMap;
  private static final Map<String, Custom_Inline_Edit_Support_Configuration__c> inlineEditConfigMap;

  static{
    SORT_ORDER_DESC = 'desc';
    SORT_ORDER_ASC = 'asc';
    PAGE_SIZE = 25;
    OBJECT_NAME = 'Strategy__c';
    SEARCHABLE_FIELD_TYPES = new Set<String>{'EMAIL', 'MULTIPICKLIST', 'PHONE', 'PICKLIST', 'STRING', 'URL', 'ENCRYPTEDSTRING'};

    objDescribe = Strategy__c.getSObjectType().getDescribe();
    fieldMap = objDescribe.fields.getMap();

    inlineEditConfigurations = [SELECT Name, Field_Label__c, Order__c, Field_API_Name__c, Object_Name_API__c, SearchableFields__c
                                   FROM Custom_Inline_Edit_Support_Configuration__c
                                  WHERE Field_API_Name__c != null
                                    AND Object_Name_API__c = :OBJECT_NAME
                               ORDER BY Order__c ASC];

    inlineEditConfigMap = new Map<String, Custom_Inline_Edit_Support_Configuration__c>();
    for(Custom_Inline_Edit_Support_Configuration__c psConfig : inlineEditConfigurations) {
      inlineEditConfigMap.put(psConfig.Field_API_Name__c.tolowercase(), psConfig);
    }
  }

  public String searchString {get; set;}
  public String selectedOption {get; set;}
  public String sortOrder {get; set;}

  public String sortField {
    get {
      return previousSortField;
    }
    set {
      if(previousSortField == value)
        sortOrder = (SORT_ORDER_ASC.equalsIgnoreCase(sortOrder)) ? SORT_ORDER_DESC : SORT_ORDER_ASC; //End if(previousSortField == value)
      else
        sortOrder = SORT_ORDER_ASC;
      previousSortField = value;
    }
  }

  public Integer noOfRecords {get; set;}
  public Integer selectedIndex {get; set;}
  public string commentForApprover{get;set;}
  public user usr{get;set;}
  public Id selectedRecordId {get; set;}

  public Strategy__c strategy {get; set;}

  public List<SelectOption> radioOptions {get; set;}

  public List<StrategyWrapper> listStrategy {get; set;}

  private String previousSortField;
  private ApexPages.StandardSetController setCon;

  public ApproveRejectStatergies() {
    radioOptions = new List<SelectOption>();
    sortOrder = SORT_ORDER_ASC;
    previousSortField = 'Name';
    strategy = new Strategy__c();
    listStrategy = new List<StrategyWrapper>();
    refresh();
  }

     /**
     *  @Description : this method perform filter and populate summary
     *
     */
   private void performFilter() {
     listStrategy.clear();



     Set<Id> objectTargetIds = new Set<Id>();

     for(ProcessInstance pF : [SELECT id , Status , TargetObjectId
                                 FROM ProcessInstance
                                WHERE  status = 'Pending' OR status = 'Started']){
        objectTargetIds.add(pF.TargetObjectId);
	   }




     if(setCon == null && objectTargetIds.size() > 0) {
       String query = 'SELECT Id';

       for(Custom_Inline_Edit_Support_Configuration__c progSummary : inlineEditConfigurations) {
         if(!query.contains(progSummary.Field_API_Name__c)) {
           query += ', ' + progSummary.Field_API_Name__c;
         }
       }

       String fromClause = ' FROM Strategy__c';
       String whereClause = '';

       String completeQuery = query + fromClause;
       try {
        String whereSubClause = ' WHERE Id IN :objectTargetIds ';
        if(String.isNotBlank(searchString)) {
          whereSubClause += ' AND (';
          for(String fieldAPIName : fieldMap.keySet()) {
            if(SEARCHABLE_FIELD_TYPES.contains(String.ValueOf(fieldMap.get(fieldAPIName).getDescribe().getType()))) {
        		  whereSubClause += fieldAPIName + ' like  \'%' + String.escapeSingleQuotes(searchString) + '%\' OR ';
            }
            else if(inlineEditConfigMap.containsKey(fieldAPIName) && inlineEditConfigMap.get(fieldAPIName).SearchableFields__c != null) {
	            whereSubClause += inlineEditConfigMap.get(fieldAPIName).SearchableFields__c + ' like  \'%' + String.escapeSingleQuotes(searchString) + '%\' OR ';
	          }
          }
          whereSubClause  = whereSubClause.subString(0, whereSubClause.lastIndexOf('OR')) + ') ';

        }
        whereClause = whereSubClause;
        String orderClause = ' ORDER BY ' + sortField + ' ' + sortOrder;
        String limitClause = ' LIMIT ' + Limits.getLimitQueryRows();
        String nullClause = ' NULLS ' + (SORT_ORDER_ASC.equalsIgnoreCase(sortOrder) ? 'LAST' : 'FIRST');

        completeQuery = query + fromClause + whereClause + orderClause + nullClause + limitClause;
        List<Strategy__c> mktPrograms = Database.query(completeQuery);
        setCon = new ApexPages.StandardSetController(mktPrograms);
        setCon.setPageSize(PAGE_SIZE);
        noOfRecords = setCon.getResultSize();
        listStrategy = getAccounts(setCon);
      }
      catch(Exception e) {
        ApexPages.addMessages(e);
      }
    }
  }

  private List<StrategyWrapper> getAccounts(ApexPages.StandardSetController setCon) {
    List<StrategyWrapper> accList = new List<StrategyWrapper>();
    for(Strategy__c acc : (List<Strategy__c>)setCon.getRecords())
      accList.add(new StrategyWrapper(acc));
    return accList;
  }

  public pageReference refresh() {
    setCon = null;
    commentForApprover = '';
    strategy.OwnerId = null;
    performFilter();
    setCon.setPageNumber(1);
    return null;
  }

  public pageReference refreshPage() {
    setCon = null;
    searchString = '';
    commentForApprover = '';
    strategy.OwnerId = null;
    performFilter();
    setCon.setPageNumber(1);
    return null;
  }

  public Boolean hasNext {
    get {
      return setCon.getHasNext();
    }
    set;
  }

  public Boolean hasPrevious {
    get {
      return setCon.getHasPrevious();
    }
    set;
  }

  public Integer pageNumber {
    get {
      return setCon.getPageNumber();
    }
    set;
  }

  public void first() {
    setCon.first();
    listStrategy = getAccounts(setCon);
  }

  public void last() {
    setCon.last();
    listStrategy = getAccounts(setCon);
  }

  public void previous() {
    setCon.previous();
    listStrategy = getAccounts(setCon);
  }

  public void next() {
    setCon.next();
    listStrategy = getAccounts(setCon);
  }

  /*public PageReference deleteProgram() {
    try {
        if(selectedRecordId != null) {
            delete new Account(Id = selectedRecordId);
            refresh();
        }
    }
    catch(Exception excep) {
        ApexPages.addMessages(excep);
      }
    return null;
  }*/

  public PageReference setInlineEditing() {
    radioOptions.clear();
    if(selectedIndex != null && selectedIndex >= 0 && selectedIndex < listStrategy.size()) {
      Integer selectedCount = 0;
      for(StrategyWrapper mProgWrapper : listStrategy) {
        selectedCount += mProgWrapper.isSelected ? 1 : 0;
      }
      if(selectedCount > 1) {
        selectedOption = 'single';
        radioOptions.add(new SelectOption('single', 'The record clicked'));
        radioOptions.add(new SelectOption('massEdit', 'All '+selectedCount+' selected records'));
      }
    }
    return null;
  }

  public PageReference setOwnerField() {
    selectedOption = 'massEdit';
    return null;
  }

  public PageReference approveStrategies() {
  	approveRejectRecords(true);
  	return null;
  }

  public PageReference rejectStrategies() {
    approveRejectRecords(false);
    return null;
  }

  private void approveRejectRecords(Boolean isApprove) {
    try {
    	  Set<Id> targetObjectIds = new Set<Id>();
        if(selectedOption != null && selectedOption.equalsIgnoreCase('single')) {
          targetObjectIds.add(listStrategy.get(selectedIndex).strategy.Id);
        }
        else {
            for(StrategyWrapper accountObj : listStrategy) {
              if(accountObj.isSelected) {
                targetObjectIds.add(accountObj.strategy.Id);
              }
            }
        }

        List<Approval.ProcessWorkitemRequest> processWorkItemList = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem  : [SELECT p.Id
                                                   FROM ProcessInstanceWorkitem p
                                                  WHERE p.ProcessInstance.TargetObjectId IN :targetObjectIds]) {
          Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
	        req2.setComments(commentForApprover);
	        req2.setAction(isApprove ? 'Approve' : 'Reject');
	        req2.setNextApproverIds(new Id[] {strategy.ownerid});
          req2.setWorkitemId(workItem.Id);
          processWorkItemList.add(req2);
        }
        selectedOption = 'single';

        // Submit the request for approval
        List<Approval.ProcessResult> resultList =  Approval.process(processWorkItemList, false);
        refresh();
    }
    catch(Exception excep) {
        ApexPages.addMessages(excep);
    }
  }

  public class StrategyWrapper {
    public Boolean isSelected {get; set;}
    public Strategy__c strategy {get; set;}
    public StrategyWrapper(Strategy__c strategy) {
        this.isSelected = false;
        this.strategy = strategy;
    }
  }
}