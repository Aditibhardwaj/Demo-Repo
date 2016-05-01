<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Approver_of_Exec_Approval_Pending</fullName>
        <description>Notify Approver of Exec Approval Pending</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approvals/Approval_Strategy_Pending_Approval_EXEC</template>
    </alerts>
    <alerts>
        <fullName>Solicitation_Strategy_Approved</fullName>
        <description>Solicitation Strategy Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approvals/Approval_Strategy_Approved_TEAM</template>
    </alerts>
    <alerts>
        <fullName>Solicitation_Strategy_Declined</fullName>
        <ccEmails>dweiss@appirio.com</ccEmails>
        <description>Solicitation Strategy Declined</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approvals/Approval_Strategy_Declined_TEAM</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Status_to_Pending_Executive_Approval</fullName>
        <description>T-465417 update the status when the team has approved and the Strategy qualifies for exec approval.</description>
        <field>Status__c</field>
        <literalValue>Pending Executive Approval</literalValue>
        <name>Set Status to Pending Executive Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Strategy_Update_Status_Approved</fullName>
        <description>T-465417</description>
        <field>Status__c</field>
        <literalValue>Team Approved</literalValue>
        <name>Strategy: Update Status=Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Strategy_Update_Status_Declined</fullName>
        <description>T-465417</description>
        <field>Status__c</field>
        <literalValue>Not Approved</literalValue>
        <name>Strategy: Update Status=Declined</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Strategy_Update_Status_Pending</fullName>
        <description>T-465417 update the record status when the approval status changes</description>
        <field>Status__c</field>
        <literalValue>Pending Team Approval</literalValue>
        <name>Strategy: Update Status=Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Strategy_Update_Status_Recalled</fullName>
        <description>T-470420</description>
        <field>Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Strategy: Update Status=Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Reset Status for Exec Approval</fullName>
        <actions>
            <name>Notify_Approver_of_Exec_Approval_Pending</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Status_to_Pending_Executive_Approval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>T-465417 update the strategy status when the team has approved and now requires executive approal</description>
        <formula>AND(
RecordType.DeveloperName=&apos;Solicitation&apos;,
ISPICKVAL(Proposed_Ask_Range__c,&quot;&gt;10,000,000&quot;),
ISPICKVAL(Status__c,&quot;Approved&quot;)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
