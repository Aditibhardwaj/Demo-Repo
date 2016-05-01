<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>rC_Event__Email_Confirmation_Added_To_Waitlist</fullName>
        <description>Email Confirmation: Added To Waitlist</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>rC_Event__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>rC_Event__Events_Email_Templates/rC_Event__Email_Confirmation_Added_To_Waitlist</template>
    </alerts>
    <alerts>
        <fullName>rC_Event__Email_Confirmation_Registration_Canceled</fullName>
        <description>Email Confirmation: Registration Canceled</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>rC_Event__Events_Email_Templates/rC_Event__Email_Confirmation_Registration_Canceled</template>
    </alerts>
    <alerts>
        <fullName>rC_Event__Email_Confirmation_Registration_Confirmed</fullName>
        <description>Email Confirmation: Registration Confirmed</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>rC_Event__Events_Email_Templates/rC_Event__Email_Confirmation_Registration_Confirmed</template>
    </alerts>
    <alerts>
        <fullName>rC_Event__Email_Confirmation_Registration_Confirmed_For_Session</fullName>
        <description>Email Confirmation: Registration Confirmed For Session</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>rC_Event__Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>rC_Event__Events_Email_Templates/rC_Event__Email_Confirmation_Registration_Confirmed_For_Session</template>
    </alerts>
    <alerts>
        <fullName>rC_Event__Email_Confirmation_Waitlist_Upgraded_To_Registration</fullName>
        <description>Email Confirmation: Waitlist Upgraded To Registration</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>rC_Event__Events_Email_Templates/rC_Event__Email_Confirmation_Waitlist_Upgraded_To_Registration</template>
    </alerts>
    <fieldUpdates>
        <fullName>rC_Giving__Send_To_Email_Campaign_Active</fullName>
        <field>rC_Giving__Send_To_Email_Campaign__c</field>
        <literalValue>1</literalValue>
        <name>Send To Email Campaign Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>true</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>rC_Giving__Send_To_Email_Campaign_Inactive</fullName>
        <field>rC_Giving__Send_To_Email_Campaign__c</field>
        <literalValue>0</literalValue>
        <name>Send To Email Campaign Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>true</protected>
    </fieldUpdates>
    <rules>
        <fullName>rC_Event__Email Confirmation%3A Added To Waitlist</fullName>
        <actions>
            <name>rC_Event__Email_Confirmation_Added_To_Waitlist</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow rule sends the confirmation mail to Campaign Member, for being waitlisted.</description>
        <formula>AND(  $Setup.rC_Event__Email_Setting__c.rC_Event__Enable_Added_To_Waitlist_Workflow__c ,  ISPICKVAL( rC_Event__Registered_Status__c , &apos;Waitlisted&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>rC_Event__Email Confirmation%3A Registration Canceled</fullName>
        <actions>
            <name>rC_Event__Email_Confirmation_Registration_Canceled</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow rule will trigger when Campaign Member cancels registration for an Event.</description>
        <formula>AND (  $Setup.rC_Event__Email_Setting__c.rC_Event__Enable_Registration_Canceled_Workflow__c  , ISPICKVAL(rC_Event__Registered_Status__c , &apos;Canceled&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>rC_Event__Email Confirmation%3A Registration Confirmed</fullName>
        <actions>
            <name>rC_Event__Email_Confirmation_Registration_Confirmed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow rule will trigger when Campaign Member register himself/herself for an Event.</description>
        <formula>AND( Campaign.RecordType.DeveloperName = &quot;Event&quot;, ISPICKVAL( rC_Event__Registered_Status__c , &apos;Registered&apos;),  $Setup.rC_Event__Email_Setting__c.rC_Event__Enable_Registration_Confirmed_Workflow__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>rC_Event__Email Confirmation%3A Registration Confirmed For Session</fullName>
        <actions>
            <name>rC_Event__Email_Confirmation_Registration_Confirmed_For_Session</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow rule will trigger when Campaign Member register himself/herself for an Event Session.</description>
        <formula>AND( Campaign.RecordType.DeveloperName  = &quot;Event_Session&quot;, ISPICKVAL( rC_Event__Registered_Status__c , &apos;Registered&apos;),  $Setup.rC_Event__Email_Setting__c.rC_Event__Enable_Registration_Confirmed_Session__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>rC_Event__Email Confirmation%3A Waitlist Upgraded To Registration</fullName>
        <actions>
            <name>rC_Event__Email_Confirmation_Waitlist_Upgraded_To_Registration</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This workflow rule will trigger when Campaign Member&apos;s waitlist is upgraded to a registration for an Event.</description>
        <formula>AND( ISPICKVAL( PRIORVALUE( rC_Event__Registered_Status__c ),  &apos;Waitlisted&apos;), ISPICKVAL( rC_Event__Registered_Status__c , &apos;Registered&apos;),  $Setup.rC_Event__Email_Setting__c.rC_Event__Enable_Waitlist_Upgraded_Workflow__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>rC_Giving__Send To Email Campaign Active</fullName>
        <actions>
            <name>rC_Giving__Send_To_Email_Campaign_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.rC_Giving__Send_To_Email_Campaign__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>rC_Giving__Send To Email Campaign Inactive</fullName>
        <actions>
            <name>rC_Giving__Send_To_Email_Campaign_Inactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.rC_Giving__Send_To_Email_Campaign__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
