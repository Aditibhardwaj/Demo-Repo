/**
* (c) 2016 Appirio, Inc
* Description : An apex class used creating Chatter Post through Quick Action For Request Research Rating(T-476842).
* Created By : Rahul Khanchandani
* Created Date : February 26th 2016
--------------------------------------------------------------------------------------------
* Updated by : Rahul Khanchandani
* Updated on : Feb 29, 2016
* Update : Added Code for Intrested In Planned Giving Quick Action (T-476843)
------------------------------------------------------------------------------------------------
* Updated by : Rahul Khanchandani
* Updated on : March 3, 2016
* Update : Added Code for Volunteer Intrest (T-476841)
------------------------------------------------------------------------------------------------
*/

public class ChatterPostQuickActionController {
	  //Request Research Rating Variables
		public String requestResearchpostText = ': Based on this contact, I would like to request a new research rating on this prospect.';
   	public String requestResearchpostToDisplay {get; private set;}
   	
   	//Intrested In Planned Giving Variables
   	public String plannedGivingpostText = ' : Based on this contact, the prospect ';
    public static String  plannedGivingpostToDisplay {get; private set;}
   	public  Chatter_QuickAction_Admins__c chatterQuickAction;
    private User usr ;
    
    //Volunteer Intrest Variables
  	public String chatterVolunteerpostText = ' This prospect ';
   	public String chatterVolunteerpostToDisplay {get; private set;}
   	
   	public String recordId= ApexPages.currentPage().getParameters().get('ID');
   	
    public ChatterPostQuickActionController(ApexPages.StandardController cntrl){
    	chatterQuickAction = Chatter_QuickAction_Admins__c.getOrgDefaults();
    	if(chatterQuickAction.Request_Research_Rating_Chatter_Group__c != null){
    		requestResearchpostToDisplay = '@['+chatterQuickAction.Request_Research_Rating_Chatter_Group__c+']' + requestResearchpostText;
    	}
    	getContactReportInfoVolunteerInterest();
    	getContactReportInfoForPlannedGiving();
    }
    
    //Action To Post Request Research Rating Chatter Post in 'Proposal Review Team' Chatter Group Through Quick Action
    public void requestResearchRating() {
    	      
            List<CollaborationGroup> collGroup= [SELECT Id FROM CollaborationGroup WHERE Name =: chatterQuickAction.Request_Research_Rating_Chatter_Group__c LIMIT 1];
       			if(collGroup.size() > 0){
       					createPost(recordId,collGroup[0].ID,requestResearchpostText);		
       			}
    }
    
    //Action To Post Volunteer Intrest Chatter Post in 'Volunteer Interest' Chatter Group Through Quick Action
    public void chatterVolunteerInterest() {
				List<CollaborationGroup> collGroup= [SELECT Id FROM CollaborationGroup WHERE Name =: chatterQuickAction.Volunteer_Intrest_Chatter_Group__c LIMIT 1];
       			if(collGroup.size() > 0){
       					createPost(recordId,collGroup[0].ID,chatterVolunteerpostText);		
       			}
    }

    //Action To Post Planned Giving Variables Chatter Post for 'User' Through Quick Action
		public void intrestedInPlannedGiving() {
          if(usr.Id != null){
            createPost(recordId,usr.Id,plannedGivingpostText);   
          }
    }
    //Creating Chatter Posting 
    private void createPost(Id recordId, Id userorGrouToMentionId, String postText) { 
    
       ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
       messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    
       // add the mention
       ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
       mentionSegment.id = userorGrouToMentionId;
       messageInput.messageSegments.add(mentionSegment);
    
       // add some text before the mention
       ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
       textSegment.text = postText;
       messageInput.messageSegments.add(textSegment);
    
       ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
       input.body = messageInput;
    	 
      	 // post it
	       ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, recordId, input, null);	
    }  
     //Getting Contact Report Info for Volunteer Interest
     private void getContactReportInfoVolunteerInterest(){
    		if(chatterQuickAction.Volunteer_Intrest_Chatter_Group__c != null){
    			chatterVolunteerpostToDisplay = '@['+chatterQuickAction.Volunteer_Intrest_Chatter_Group__c+'] ';
       		String conaccNameTextResult = getContactReportInfo();
	    		chatterVolunteerpostText += conaccNameTextResult +' is interested in volunteering.';	
	      	chatterVolunteerpostToDisplay += chatterVolunteerpostText;	
    		}
     		
     }
    
     //Getting Contact Report Info for Intrested In Planned Giving
     private void getContactReportInfoForPlannedGiving(){
	      String conaccNameTextResult = getContactReportInfo();
	       plannedGivingpostText += conaccNameTextResult +' is interested in Planned Giving.';	
	       if(chatterQuickAction.Interest_In_PG_Chatter_User__c != null){
		       		usr = [SELECT Name FROM User WHERE UserName =:chatterQuickAction.Interest_In_PG_Chatter_User__c];
		       		plannedGivingpostToDisplay = '@['+usr.Name +']'+ plannedGivingpostText;
	    		}
     }
   
  	//A method that returns Account and Contact Name from ContactReport.
	  private String getContactReportInfo(){
	     	String accountName;
	    	String contactName;
	    	String conaccNameText = '';
	       Contact_Report__c conReport = [SELECT Account__c, Contact__c, Account__r.Name,Contact__r.Name FROM Contact_Report__c WHERE ID =: recordId ];
	       system.debug([SELECT Subject__c, Account__c, Contact__c, Account__r.Name,Contact__r.Name FROM Contact_Report__c WHERE ID =: recordId ]);
	       boolean flag = false;
	       if(conReport.Account__r != null){
	       	 	accountName= conReport.Account__r.Name;
	       	 	conaccNameText = accountName;
	       	 	flag = true;
	       }else{
	       		accountName = '';
	       		conaccNameText = accountName;
	       }
	       if(conReport.Contact__r != null){
		       	if(flag){
		       		conaccNameText = conaccNameText +', ';
		       	}
		       	contactName=conReport.Contact__r.Name;
	       		conaccNameText += contactName;
	       	}else{
	       		 contactName= '';
	       		 conaccNameText += contactName;
	      	}
	      	return conaccNameText;
     }
}