/*
** @author : (c) 2015 Appirio, Inc.[Rahul Khanchandani]
** @date : 26/02/2015
** @description : Creating Chatter Post through Quick Action for Request Research Rating,Volunteer Interest
*/
public class ChatterPostQuickAction {
    private String postText = ': Based on this contact, I would like to request a new research rating on this prospect.';
   	private String chatterVolunteerpostText = ' This prospect ';
   	public String postToDisplay {get; private set;}
   	public String chatterVolunteerpostToDisplay {get; private set;}
   	public String recordId= ApexPages.currentPage().getParameters().get('ID');
    
    public ChatterPostQuickAction(ApexPages.StandardController cntrl){
    	postToDisplay = '@[Proposal Review Team]' + postText;
    	chatterVolunteerpostToDisplay = '@[Volunteer Interest] ';
    	getContactReportInfo();
    }
    public void requestResearchRating() {
           List<CollaborationGroup> collGroup= [SELECT Id From CollaborationGroup where Name = 'Proposal Review Team' limit 1];
       			if(collGroup.size() > 0){
       					createPost(recordId,collGroup[0].ID,postText);		
       			}
    }
		public void chatterVolunteerInterest() {
				List<CollaborationGroup> collGroup= [SELECT Id From CollaborationGroup where Name = 'Volunteer Interest' limit 1];
       			if(collGroup.size() > 0){
       					createPost(recordId,collGroup[0].ID,chatterVolunteerpostText);		
       			}
    }
		
		public void intrestedInPlannedGiving() {
  		  Chatter_QuickAction_Admins__c chatterQuickAction = [Select Interest_In_PG_Chatter_User__c from Chatter_QuickAction_Admins__c];
     	  User usr = [Select Name from User where UserName =: chatterQuickAction.Interest_In_PG_Chatter_User__c];
     	  if(usr.Name != null){
     	  	createPost(recordId,usr.Id,postText);	
     	  }
 		}
 		
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
     
     private void getContactReportInfo(){
	     	String accountName;
	    	String contactName;
	    	String conaccNameText = '';
	      Contact_Report__c conReport = [Select Account__r.Name,Contact__r.Name from Contact_Report__c where ID =: recordId ];
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
	     	chatterVolunteerpostText += conaccNameText +' is interested in volunteering.';	
	      chatterVolunteerpostToDisplay += chatterVolunteerpostText;
     }
}