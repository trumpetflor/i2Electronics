public class CustomerSalesInfoManager {

    public static void UpdateCustomerSalesInfo(List<Order__c> orderList) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for (Order__c order : orderList) {
            contactIds.add(order.Contact_Name__c);
            accountIds.add(order.Account_Name__c);
        }

        // 연관된 모든 Account 레코드를 조회
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
        );

        // 연관된 모든 Contact 레코드를 조회
        Map<Id, Contact> contactMap = new Map<Id, Contact>(
            [SELECT Id, Start_Point__c, Customer_Type__c, (SELECT Id FROM Orders__r) FROM Contact WHERE Id IN :contactIds]
        );

        Map<Id, Integer> countOrderMap = new Map<Id, Integer>();

        List<AggregateResult> remainingOrder = [SELECT Contact_Name__c, COUNT(Id) orderCount 
                                                FROM Order__c 
                                                WHERE Contact_Name__c IN :contactMap.keySet() 
                                                GROUP BY Contact_Name__c];

        for(AggregateResult result : remainingOrder){
            Id contactId = (Id)result.get('Contact_Name__c');
            Integer orderCount = (Integer)result.get('orderCount');
            countOrderMap.put(contactId, orderCount);
        }

        List<Contact> contactsToUpdate = new List<Contact>();

        for (Order__c order : orderList) {
            Contact relatedContact = contactMap.get(order.Contact_Name__c);
            Integer relatedOrderCount = countOrderMap.get(order.contact_name__c);
            // 첫 번째 주문인 경우
            if (relatedContact != null && relatedOrderCount == 1) {
                Account relatedAccount = accountMap.get(order.Account_Name__c);
                if (relatedAccount != null) {
                    // Account 정보를 사용하여 Contact 정보를 업데이트
                    relatedContact.Start_Point__c = relatedAccount.Name;
                    relatedContact.Customer_Type__c = '구매고객';
                    contactsToUpdate.add(relatedContact);
                }
            }
        }

        if (!contactsToUpdate.isEmpty()) {
                update contactsToUpdate;            
        }

        // List<Order__c> orders = [select id, account_name__c, contact_name__c, account_name__r.name, contact_name__r.start_point__c, contact_name__r.customer_type__c from order__c];
        
        // CustomerSalesInfoManager.UpdateCustomerSalesInfo(orders);     
    }

    public static void DeleteCustomerSalesInfo(List<Order__c> deletedOrders){

        Set<Id> contactIds = new Set<Id>();

        Map<Id, Integer> countOrderMap = new Map<Id, Integer>();

        List<Contact> contactsToUpdate = new List<Contact>();

        for(Order__c order : deletedOrders){
            if(order.Contact_Name__c != NULL){
                contactIds.add(order.Contact_Name__c);
                countOrderMap.put(order.Contact_Name__c, 0);
            }
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, (SELECT Id FROM Orders__r) FROM Contact WHERE Id IN :contactIds]);

        List<AggregateResult> remainingOrder = [SELECT Contact_Name__c, COUNT(Id) orderCount 
                                                FROM Order__c 
                                                WHERE Contact_Name__c IN :contactMap.keySet() 
                                                GROUP BY Contact_Name__c];

        for(AggregateResult result : remainingOrder){
            Id contactId = (Id)result.get('Contact_Name__c');
            Integer orderCount = (Integer)result.get('orderCount');
            countOrderMap.put(contactId, orderCount);
        }

        // for(Order__c deleteOrder : deletedOrders){
        //     contactIds.add(deleteOrder.Contact_Name__c);
        // }

        // for(Id contactId : contactIds){
        //     Integer remainingOrders = [SELECT COUNT() FROM Order__c WHERE Contact_Name__c = :contactId];

        //     if(remainingOrders == 0){
        //         Contact updateContact = new Contact(Id = contactId);
        //         updateContact.Start_Point__c = '';
        //         updateContact.Customer_Type__c = '상담고객';
        //         contactsToUpdate.add(updateContact);
        //     }
        // }

        for(Order__c order : deletedOrders){
            Contact deleteContact = contactMap.get(order.Contact_Name__c);
            Integer countOrder = countOrderMap.get(order.Contact_Name__c);

            if(countOrder == 0){
                deleteContact.Start_Point__c = '';
                deleteContact.Customer_Type__c = '상담고객';
                contactsToUpdate.add(deleteContact);
            }
        }

        if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }

    }
}