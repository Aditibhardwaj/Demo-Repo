<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Approver_Team</fullName>
        <description>Notify Approver Team</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approvals/Approval_Strategy_Approval_requested_TEAM</template>
    </alerts>
    <alerts>
        <fullName>Notify_Proposal_Owner_that_Proposal_was_approved</fullName>
        <description>Notify Proposal Owner that Proposal was approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approvals/Approval_Strategy_Approved_TEAM</template>
    </alerts>
    <alerts>
        <fullName>Notify_Proposal_Owner_that_Proposal_was_rejected</fullName>
        <description>Notify Proposal Owner that Proposal was rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approvals/Approval_Strategy_Approval_requested_TEAM</template>
    </alerts>
    <fieldUpdates>
        <fullName>Revert_Stage_to_Prospecting</fullName>
        <description>Revert Stage to Prospecting to allow owner to continue working and remove the proposal from the Pending Approval list.</description>
        <field>StageName</field>
        <literalValue>Prospecting</literalValue>
        <name>Revert Stage to Prospecting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Proposal_Status_to_Needs_Analysis</fullName>
        <description>Update proposal status to NEEDS ANALYSIS when Rejected ; proposal requires more work</description>
        <field>StageName</field>
        <literalValue>Needs Analysis</literalValue>
        <name>Update Proposal Status to Needs Analysis</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Proposal_to_Pending</fullName>
        <description>Update proposal status to PENDING when approved; proposal can continue</description>
        <field>StageName</field>
        <literalValue>Pending</literalValue>
        <name>Update Proposal to Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_to_Qualification</fullName>
        <description>Update Stage to Qualification to indicate Pending Approval</description>
        <field>StageName</field>
        <literalValue>Qualification</literalValue>
        <name>Update Stage to Qualification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>rC_Giving__Opportunity_SetUncollectibleTrue</fullName>
        <field>rC_Giving__Is_Uncollectible__c</field>
        <literalValue>1</literalValue>
        <name>Opportunity_SetUncollectibleTrue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Populate Account name on new proposal</fullName>
        <active>false</active>
        <formula>NOT(ISBLANK(rC_Giving__Primary_Contact__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Giving Name</fullName>
        <active>false</active>
        <formula>OR(ISCHANGED(Strategy__c),ISCHANGED(Group__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
