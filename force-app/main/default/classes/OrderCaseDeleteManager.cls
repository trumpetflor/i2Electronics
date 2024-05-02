public with sharing class OrderCaseDeleteManager {
    
    public static void deleteRelatedCases(List<Order__c> deletedOrders) {

        Set<Id> orderIds = new Set<Id>();

        for (Order__c deletedOrder : deletedOrders) {
            orderIds.add(deletedOrder.Id);
            System.debug(deletedOrder.Id);
        }
        
        List<Case> casesToDelete = [SELECT Id FROM Case WHERE order__c IN :orderIds];

        delete casesToDelete;
    }
}