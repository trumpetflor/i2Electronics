trigger OrderCaseDeleteTrigger on Order__c (before delete) {

    OrderCaseDeleteManager.deleteRelatedCases(Trigger.old);

}