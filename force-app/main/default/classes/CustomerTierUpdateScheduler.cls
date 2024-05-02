global with sharing class CustomerTierUpdateScheduler implements Schedulable{
    
    global void execute(SchedulableContext sc){

        List<Contact> contact = [Select Id, Name, Total_Sum__c from contact];

        CustomerTierUpdateManager.UpdateCustomerTier(contact);

    }

    // CustomerTierUpdateScheduler scheduler = new CustomerTierUpdateScheduler();

    // // 매월 1일 00:00에 실행되도록 스케줄을 설정합니다.
    // String cronExp = '0 0 0 1 * ?'; // 매월 1일 실행
    // String cronExp = '0 0 0 * * ?'; // 매일 자정에 실행
    // System.schedule('CustomerTierUpdateJob', cronExp, scheduler);

//         CustomerTierUpdateScheduler scheduler = new CustomerTierUpdateScheduler();

// String[] scheduleTimes = new String[]{
//     '0 0 * * * ?',
//     '0 30 * * * ?'
// };

// for (String cronExpr : scheduleTimes) {
//     String jobName = 'CustomerTierUpdate_' + cronExpr;
//     System.schedule(jobName, cronExpr, scheduler);
// }

}