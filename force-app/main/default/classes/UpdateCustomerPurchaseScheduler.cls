global with sharing class UpdateCustomerPurchaseScheduler implements Schedulable{
    
    global void execute(SchedulableContext sc){

        UpdateCustomerPurchaseBatch batchJob = new UpdateCustomerPurchaseBatch();

        Database.executeBatch(batchJob);
    }

    // UpdateCustomerPurchaseAmountScheduler scheduler = new UpdateCustomerPurchaseAmountScheduler();
    // String cronExp = '0 0 0 * * ?'; // 매일 자정에 실행
    // System.schedule('UpdateCustomerPurchaseAmountJob', cronExp, scheduler);
    // String[] scheduleTimes = new String[]{
    //     '0 0 * * * ?',
    //     '0 30 * * * ?'
    // };

//     CustomerTierUpdateScheduler scheduler = new CustomerTierUpdateScheduler();

// String[] scheduleTimes = new String[]{
//     '0 0 * * * ?',
//     '0 30 * * * ?'
// };

// for (String cronExpr : scheduleTimes) {
//     String jobName = 'CustomerTierUpdate_' + cronExpr;
//     System.schedule(jobName, cronExpr, scheduler);
// }
}