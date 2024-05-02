global with sharing class UpdateCustomerPurchaseBatch implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        Date startDate = Date.today().addDays(-90);
        Date endDate = Date.today();
        return Database.getQueryLocator([
            SELECT Id, Contact_Name__c, Start_Date__c, (SELECT id, Name, Price__c, Quantity__c  FROM Ordered_Products__r), Discount_Percent__c
            FROM Order__c
            WHERE Start_Date__c >= :startDate AND Start_Date__c <= :endDate
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Order__c> scope){

        CustomerPurchaseManager.UpdatePurchaseAmountForCustomer(scope);
        StorePurchaseManager.UpdateStorePurchaseAmountForCustomer(scope);

    }

    global void finish(Database.BatchableContext bc){

        System.debug('Batch job completed successfully.');

    }

    // Database.executeBatch(new CustomerPurchaseBatch());
}