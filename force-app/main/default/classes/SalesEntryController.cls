public with sharing class SalesEntryController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getProductFamilies() {
    List<Map<String, String>> options = new List<Map<String, String>>();
    // GROUP BY 구문을 사용하여 제품군 조회
    for (AggregateResult ar : [SELECT Family FROM Product2 WHERE Family != null GROUP BY Family]) {
        // AggregateResult 객체에서 Family 값을 추출
        String family = (String)ar.get('Family');
        options.add(new Map<String, String>{'label' => family, 'value' => family});
    }
    return options;
}


@AuraEnabled(cacheable=true)
public static List<Map<String, String>> getProductsByFamily(String familyName) {
    List<Map<String, String>> options = new List<Map<String, String>>();
    for (Product2 product : [SELECT Id, Name, Price__c FROM Product2 WHERE Family = :familyName]) {
        // 가격을 한국 원화 형식으로 포맷팅
        String formattedPrice = formatCurrency(product.Price__c);
        String label = product.Name + ' (' + formattedPrice + ')';
        options.add(new Map<String, String>{'label' => label, 'value' => product.Id});
    }
    return options;
}
 
 
    @AuraEnabled
    public static Id createOrder(String contactId, List<String> productIds, List<Integer> quantities, Decimal discountPercent) {

        // 현재 로그인한 사용자의 Role 정보를 쿼리
        UserRole userRole = [SELECT Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId()];

        // 해당 Role 이름과 일치하는 Account 레코드 조회
        Account matchingAccount = [SELECT Id FROM Account WHERE Name = :userRole.Name LIMIT 1];

        // 입력된 할인율이 최대 할인율을 초과하는 경우 최대 할인율로 제한
        // discountPercent = Math.min(discountPercent, 20);
        if(discountPercent < 0){
            discountPercent = 0;
        } else if(discountPercent > 20){
            discountPercent = 20;
        }

        // Contact 객체에서 주문을 생성하는 데 필요한 연락처 정보를 쿼리
        Contact contactInfo = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
        // 주문의 총 금액을 계산하기 위한 변수를 초기화
        Decimal totalAmount = 0;
        List<String> productDetails = new List<String>();
        
        // 제품 ID와 수량을 반복하여 각 제품의 가격과 수량을 기반으로 총 금액을 계산
        for(Integer i = 0; i < productIds.size(); i++) {
            Id productId = productIds[i];
            Integer quantity = quantities[i];
            
            // Product2 객체에서 제품 정보를
            Product2 product = [SELECT Id, Name, Price__c, Family FROM Product2 WHERE Id = :productId LIMIT 1];
            
            // 통화 형식으로 가격 포맷팅
            String formattedPrice = formatCurrency(product.Price__c);

            String detail = product.Name + ' (' + formattedPrice + ') - 수량: ' + quantities[i];
            productDetails.add(detail);
            
            // 총 금액 계산
            totalAmount += product.Price__c * quantity;
        }        
        
        Decimal discountAmount = totalAmount * (discountPercent / 100);
        Decimal finalAmount = totalAmount - discountAmount;

        String productListString = String.join(productDetails, '\n ');
        
        // 새로운 주문 객체를 생성하고 필드 값을 설정
        List<Order__c> newOrders = new List<Order__c>();
        Order__c order = new Order__c(
            Contact_Name__c = contactId,
            Account_Name__c = matchingAccount.Id,
            Start_Date__c = Date.today(),
            List_Product__c = productListString,
            Total_Amount__c = totalAmount,
            Discount_Amount__c = discountAmount, 
            Discount_Percent__c = discountPercent, 
            Final_Amount__c = finalAmount 
        );
        newOrders.add(order);
        
        insert newOrders;

        // 주문이 성공적으로 저장된 후 Ordered_Product__c 레코드를 생성
        List<Ordered_Product__c> orderedProducts = new List<Ordered_Product__c>();
        for(Integer i = 0; i < productIds.size(); i++) {
            Product2 product = [SELECT Id, Name, Price__c, Family FROM Product2 WHERE Id = :productIds[i]];
            Ordered_Product__c orderedProduct = new Ordered_Product__c(
                Order__c = order.Id, // 방금 생성된 주문의 ID 할당
                Product__c = productIds[i],
                Quantity__c = quantities[i],
                Price__c = product.Price__c,
                Name = product.Family // 제품군 정보를 Name 필드에 설정
            );
            orderedProducts.add(orderedProduct);
        }
        
        insert orderedProducts; // Ordered_Product__c 레코드 데이터베이스에 저장

        // 주문이 성공적으로 저장된 후 Sold_Product__c 레코드를 생성
    List<Sold_Product__c> soldProducts = new List<Sold_Product__c>();
    for(Integer i = 0; i < productIds.size(); i++) {
        Product2 product = [SELECT Id, Name, ProductCode, Family, Price__c FROM Product2 WHERE Id = :productIds[i]];
        Integer quantity = quantities[i];
        for(Integer j = 0; j < quantity; j++) {
            // 각 제품에 대한 시리얼 번호를 생성합니다.
            String serialNumber = generateSerialNumber();
            Sold_Product__c soldProduct = new Sold_Product__c(
                Serial_Number__c = serialNumber, // 시리얼 번호 생성
                Order__c = order.Id, // 방금 생성된 주문의 ID 할당
                Product_Code__c = product.ProductCode, // 제품 코드 할당
                Product_Name__c = product.Name,
                Family__c = product.Family,
                Price__c = product.Price__c
            );
            soldProducts.add(soldProduct);
        }
    }
    insert soldProducts;

    return newOrders[0].Id;

    }

    // 통화 형식 포맷팅 메서드
    private static String formatCurrency(Decimal amount) {
        return '₩' + amount.setScale(0).format();
    }

    public static String generateSerialNumber() {
        Long timestamp = Datetime.now().getTime();
        Double randomNumber = Math.abs(Math.random() * 1000000);
        String serialNumber = 'I2' + timestamp + '_' + randomNumber.intValue();
        return serialNumber;
    }
    
    
       
}