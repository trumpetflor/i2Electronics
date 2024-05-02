global with sharing class UpdateCustomerTierScheduler implements Schedulable{
    
    global void execute(SchedulableContext sc){

        CustomerTierUpdateBatch batchJob = new CustomerTierUpdateBatch();

        Database.executeBatch(batchJob);
    }

    // UpdateCustomerPurchaseAmountScheduler scheduler = new UpdateCustomerPurchaseAmountScheduler();
    // String cronExp = '0 0 0 * * ?'; // 매일 자정에 실행
    // System.schedule('UpdateCustomerPurchaseAmountJob', cronExp, scheduler);
    // String[] scheduleTimes = new String[]{
    //     '0 0 * * * ?',
    //     '0 30 * * * ?'
    // }

//     UpdateCustomerTierScheduler scheduler = new UpdateCustomerTierScheduler();

// String[] scheduleTimes = new String[]{
//     '0 0 * * * ?',
//     '0 30 * * * ?'
// };

// for (String cronExpr : scheduleTimes) {
//     String jobName = 'UpdateCustomerTier_' + cronExpr;
//     System.schedule(jobName, cronExpr, scheduler);
// }

}