public class CustomerPurchaseManager {
    
    public static void UpdatePurchaseAmountForCustomer(List<Order__c> orders) {
        // 최근 90일 동안 구매한 금액을 관리하기 위한 맵 생성
        Set<Id> contactIds = new Set<Id>();
        
        for(Contact contact : [SELECT Id, Name FROM Contact]){
            contactIds.add(contact.Id);
            //System.debug(contact.Name);
            //System.debug(contact.Id);
        }
        
        Map<Id, Decimal> laptopPurchaseMap = new Map<Id, Decimal>();
        Map<Id, Decimal> otherPurchaseMap = new Map<Id, Decimal>();

        // 현재 날짜
        Date currentDate = Date.today();
        
        // 최근 90일 이전의 날짜 계산
        Date startDate = currentDate.addDays(-90);
        
        // 최근 90일 동안의 구매 금액 계산
        for(Order__c order : orders) {
            // 주문이 최근 90일에 이루어졌는지 확인
            System.debug(order.Id);
            if(order.Start_Date__c >= startDate && order.Start_Date__c <= currentDate) {
                // 주문에 대한 주문 제품 검색
                System.debug(order.Ordered_Products__r);
                for(Ordered_Product__c item : order.Ordered_Products__r) {
                    // 제품의 가격을 합산
                    Decimal purchaseAmount = 0;
                    // 제품의 이름이 노트북일 경우 가격 * 개수를 계산
                    if(item.Name == '노트북') {
                        System.debug(order.Discount_Percent__c);
                        purchaseAmount = laptopPurchaseMap.get(order.Contact_Name__c);
                        if(purchaseAmount == null) {
                            purchaseAmount = 0;
                        }
                        if(order.Discount_Percent__c != 0 && order.Discount_Percent__c != null){
                            System.debug(order.Discount_Percent__c);
                            purchaseAmount += item.Price__c * item.Quantity__c*(1-order.Discount_Percent__c*0.01);
                        }else{
                            purchaseAmount += item.Price__c * item.Quantity__c;
                        }
                        //purchaseAmount += item.Price__c * item.Quantity__c;
                        System.debug('노트북'+purchaseAmount);
                        laptopPurchaseMap.put(order.Contact_Name__c, purchaseAmount);
                    }
                    // 제품의 이름이 노트북이 아닐 경우 가격 * 개수를 계산
                    else {
                        purchaseAmount = otherPurchaseMap.get(order.Contact_Name__c);
                        if(purchaseAmount == null) {
                            purchaseAmount = 0;
                        }
                        if(order.Discount_Percent__c != 0 && order.Discount_Percent__c != null){
                            System.debug(order.Discount_Percent__c);
                            purchaseAmount += item.Price__c * item.Quantity__c*(1-order.Discount_Percent__c*0.01);
                        }else{
                            purchaseAmount += item.Price__c * item.Quantity__c;
                        }
                        //purchaseAmount += item.Price__c * item.Quantity__c  ;
                        System.debug('주변기기'+purchaseAmount);
                        otherPurchaseMap.put(order.Contact_Name__c, purchaseAmount);
                    }
                }
            }
        }
        
        // 최근 90일 동안의 구매 금액을 고객 레코드에 업데이트
        List<Contact> customerToUpdate = new List<Contact>();
        
        for(Id contactId : contactIds){
            if(laptopPurchaseMap.containsKey(contactId) && otherPurchaseMap.containsKey(contactId)){
                Contact customer = new Contact(Id = contactId, 
                                                Total_Sale_Laptop__c = laptopPurchaseMap.get(contactId), 
                                                Total_Sale_Others__c = otherPurchaseMap.get(contactId),
                                                Total_Sum__c = laptopPurchaseMap.get(contactId)+otherPurchaseMap.get(contactId));
                customerToUpdate.add(customer);
                //System.debug('update id: '+customer.Id);
            }
            else if(laptopPurchaseMap.containsKey(contactId)){
                Contact customer = new Contact(Id = contactId, 
                                                Total_Sale_Laptop__c = laptopPurchaseMap.get(contactId),
                                                Total_Sale_Others__c = 0,
                                                Total_Sum__c = laptopPurchaseMap.get(contactId));
            	customerToUpdate.add(customer);
                //System.debug('update id: '+customer.Id);
            }
            else if(otherPurchaseMap.containsKey(contactId)){
                Contact customer = new Contact(Id = contactId, 
                                                Total_Sale_Others__c = otherPurchaseMap.get(contactId),
                                                Total_Sale_Laptop__c = 0,
                                                Total_Sum__c = otherPurchaseMap.get(contactId));
            	customerToUpdate.add(customer);
                //System.debug('update id: '+customer.Id);
            }else{
                Contact customer = new Contact(Id = contactId, 
                                                Total_Sale_Laptop__c = 0,
                                                Total_Sale_Others__c = 0,
                                                Total_Sum__c = 0);
            	customerToUpdate.add(customer);
                //System.debug('update id: '+customer.Id);
            }
        }
        /*for(Id contactId : laptopPurchaseMap.keySet()) {
            Contact customer = new Contact(Id = contactId, Total_Sale_Laptop__c = laptopPurchaseMap.get(contactId));
            customerToUpdate.add(customer);
        }
        for(Id contactId : otherPurchaseMap.keySet()) {
            if(laptopPurchaseMap.containsKey(contactId)){
                contact.Total_Sale_Others__c = otherPurchaseMap.get(contactId);
            }
            for(Contact contact : customerToUpdate){
                if(contact.id == contactId){
                    contact.Total_Sale_Others__c = otherPurchaseMap.get(contactId);
                }else{
                    Contact customer = new Contact(Id = contactId, Total_Sale_Others__c = otherPurchaseMap.get(contactId));
            		customerToUpdate.add(customer);
                }
            }
        }*/
        // for(Contact con : customerToUpdate){
        //     System.debug('con '+con);

        // }

        update customerToUpdate;
    }

    // List<Order__c> orders = [SELECT Id, Contact_Name__c, Start_Date__c,Discount__c, (select id, Name, Price__c, Quantity__c  from Ordered_Products__r)
    //                            FROM Order__c
    //                           WHERE Start_Date__c >= LAST_N_DAYS:90];
        
        
    // CustomerPurchaseManager.updatePurchaseAmountForCustomer(orders);
}