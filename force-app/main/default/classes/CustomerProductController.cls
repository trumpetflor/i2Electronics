public with sharing class CustomerProductController {

    public class ProductWrapper {
        @AuraEnabled
        public String name;

        @AuraEnabled
        public String family;

        @AuraEnabled
        public Decimal quantity;

        public ProductWrapper(String name, String family, Decimal quantity){
            this.name = name;
            this.family = family;
            this.quantity = quantity;
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<ProductWrapper> getCustomerProducts(Id customerId){

        List<ProductWrapper> products = new List<ProductWrapper>();

        // 고객이 보유한 모든 주문을 가져옵니다.
        List<Order__c> orders = [SELECT Id FROM Order__c WHERE Contact_Name__c = :customerId];
        
        // 고객이 보유한 모든 주문에 대한 Ordered_Product__c 레코드를 가져옵니다.
        List<Ordered_Product__c> orderedProducts = [SELECT Product__r.Name, Product__r.Family, Quantity__c, Order__c
                                                    FROM Ordered_Product__c 
                                                    WHERE Order__r.Contact_Name__c = :customerId];
        
        // Ordered_Product__c 레코드를 반복하여 제품 Name, Family 및 Quantity을 계산합니다.
        Map<String, Map<String, Decimal>> productMap = new Map<String, Map<String, Decimal>>();

        for (Ordered_Product__c orderedProduct : orderedProducts) {
            String productName = orderedProduct.Product__r.Name;
            String productFamily = orderedProduct.Product__r.Family;
            Decimal quantity = orderedProduct.Quantity__c;
            
            // ProductMap에 제품 Name과 Family를 키로 사용하여 Quantity을 누적합니다.
            if (!productMap.containsKey(productName)) {
                productMap.put(productName, new Map<String, Decimal>());
            }
            if (!productMap.get(productName).containsKey(productFamily)) {
                productMap.get(productName).put(productFamily, 0);
            }
            productMap.get(productName).put(productFamily, productMap.get(productName).get(productFamily) + quantity);
        }
        
        // ProductMap의 결과를 ProductWrapper 목록으로 변환합니다.
        for (String productName : productMap.keySet()) {
            Map<String, Decimal> familyMap = productMap.get(productName);
            for (String productFamily : familyMap.keySet()) {
                Decimal quantity = familyMap.get(productFamily);
                products.add(new ProductWrapper(productName, productFamily, quantity));
            }
        }
        
        return products;
    }

}