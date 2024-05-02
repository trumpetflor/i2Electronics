global class UpdatePurchaseAmountSchedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        // 매일 실행되는 작업 수행
        List<Order__c> orders = [SELECT Id, Contact_Name__c, Start_Date__c, (select id from Ordered_Products__r)
                               FROM Order__c
                              WHERE Start_Date__c >= LAST_N_DAYS:90];
        
        CustomerPurchaseManager.updatePurchaseAmountForCustomer(orders);
    }

    /*UpdatePurchaseAmountSchedule schedule = new UpdatePurchaseAmountSchedule();
    String jobId = System.schedule('Update Purchase Amount', '0 0 0 * * ?', schedule);*/
}