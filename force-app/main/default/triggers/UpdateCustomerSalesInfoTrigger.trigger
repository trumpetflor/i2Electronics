trigger UpdateCustomerSalesInfoTrigger on Order__c (after insert, after delete, after update) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            CustomerSalesInfoManager.UpdateCustomerSalesInfo(Trigger.new);
            //StorePurchaseManager.UpdateStorePurchaseAmountForCustomer(Trigger.new);
        }

        if(Trigger.isDelete){
            CustomerSalesInfoManager.DeleteCustomerSalesInfo(Trigger.old);
            //StorePurchaseManager.UpdateStorePurchaseAmountForCustomer(Trigger.old);
        }

        if(Trigger.isUpdate){
            //StorePurchaseManager.UpdateStorePurchaseAmountForCustomer(Trigger.new);
        }
    }

}