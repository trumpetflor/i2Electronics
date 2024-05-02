public with sharing class RefundController {
    @AuraEnabled
    public static Id createRefund(Id orderId, String refundReason) {
        try {
        // 주문 정보 조회
        Order__c orderToRefund = [SELECT Id, Name, Final_Amount__c, Account_Name__c, Contact_Name__c, Contact_Name__r.Id, List_Product__c FROM Order__c WHERE Id = :orderId LIMIT 1];
        
        // 환불 레코드 생성 및 필요한 정보 할당
        Order_Refund__c newRefund = new Order_Refund__c(
            Amount__c = orderToRefund.Final_Amount__c, 
            Refund_Date__c = Date.today(),
            Reason__c = refundReason,
            Account_Name__c = orderToRefund.Account_Name__c,
            Order_Name__c = orderToRefund.Name,
            Refund_Product_List__c = orderToRefund.List_Product__c,
            Contact_Name__c = orderToRefund.Contact_Name__c 
        );
        
        insert newRefund;
        // 환불 레코드 생성되면 해당 주문 삭제
        delete orderToRefund;
        return orderToRefund.Contact_Name__r.Id;
        } catch(Exception e){
            throw new AuraHandledException('Error: ' + e.getMessage()); // 오류 발생 시 예외 던지기
        }
    }
}