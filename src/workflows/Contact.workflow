<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Stamp_Deceased_Status_Change_to_NOW</fullName>
        <description>S-378313</description>
        <field>Deceased_Status_Change__c</field>
        <formula>NOW()</formula>
        <name>Stamp Deceased Status Change to NOW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contact - Stamp Deceased Status Change</fullName>
        <actions>
            <name>Stamp_Deceased_Status_Change_to_NOW</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>S-378313 - Stamp Deceased Status Change field with the last time the Deceased? flag was modified.</description>
        <formula>ISCHANGED(rC_Bios__Deceased__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
