public with sharing class ContactController {

    //전화번호로 고객 리스트 검색하는 메서드 @하원
    @AuraEnabled(cacheable=true)
    public static List<Contact> findContactByPhone(String phone) {

        String searchPhone = '%' + phone + '%';
        
        List<Contact> contacts = [SELECT Id,name,phone,Tier__c,Total_Sum__c ,Case_Count__c
                            FROM Contact 
                            WHERE Phone LIKE :searchPhone];
                            System.debug('contacts : '+ contacts);
        return (contacts != null) ? contacts : null;

    }


    //고객 id를 사용해서 해당 고객의 주문된 제품 목록을 검색하는 메서드 @하원
    @AuraEnabled(cacheable=true)
    public static List<Ordered_Product__c> getOrderedProductsByContactId(Id contactId) {

        return [SELECT  Id, 
                    Product__c,  
                    Product__r.Name,  
                    Product__r.Price__c,  
                    Quantity__c, //수량
                    Order__r.Total_Amount__c ,
                    Order__r.start_Date__c, //주문일자
                    Order__r.Account_Name__c //판매지점 id
                    
                FROM Ordered_Product__c
                WHERE Order__r.Contact_Name__c = :contactId];
    
}
}