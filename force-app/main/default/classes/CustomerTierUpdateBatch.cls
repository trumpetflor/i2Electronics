global with sharing class CustomerTierUpdateBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // 배치에서 업데이트해야 할 연락처를 검색합니다.
        return Database.getQueryLocator([SELECT Id, Name, Total_Sum__c FROM Contact]);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        //List<Contact> contactsToUpdate = (List<Contact>)scope;
        
        // CustomerTierUpdateManager의 UpdateCustomerTier 메서드 호출
        CustomerTierUpdateManager.UpdateCustomerTier(scope);
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch job completed successfully.');
    }

}