public with sharing class StorePurchaseManager {
    
    public static void UpdateStorePurchaseAmountForCustomer(List<Order__c> orders) {
        // 최근 90일 동안 구매한 금액을 관리하기 위한 맵 생성
        Set<Id> contactIds = new Set<Id>();
        Set<Id> notOrderContactIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();

        // Id userRoleId = UserInfo.getUserRoleId();
        // String roleName = [SELECT Name FROM UserRole WHERE Id = :userRoleId].Name;
        // System.debug(roleName);

        for(Contact contact : [SELECT Id, Name FROM Contact WHERE Total_Sum__c = 0]){
            notOrderContactIds.add(contact.Id);
            //System.debug(contact.Name);
            //System.debug(contact.Id);
        }

        Map<Id, Map<String, Decimal>> storePurchaseMap = new Map<Id, Map<String, Decimal>>();

        for(Order__c order : orders){
            contactIds.add(order.Contact_Name__c);
            storePurchaseMap.put(order.Contact_Name__c, new Map<String, Decimal>{
                '강원 지점' => 0,
                '경기 지점' => 0,
                '광주 지점' => 0,
                '대구 지점' => 0,
                '대전 지점' => 0,
                '부산 지점' => 0,
                '서울 지점' => 0,
                '세종 지점' => 0,
                '울산 지점' => 0,
                '인천 지점' => 0,
                '제주 지점' => 0
            });
        }

        //Map<Id, Decimal> purchaseMap = new Map<Id, Decimal>();

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, (SELECT Id FROM Orders1__r) FROM Contact WHERE Id =: contactIds]);

        for(Contact contact : contactMap.values()){
            for(Order__c order : contact.Orders1__r){
                orderIds.add(order.Id);
            }
        }

        Map<Id, Order__c> orderMap = new Map<Id, Order__c>([SELECT Id, 
                                                            Contact_Name__c, 
                                                            Start_Date__c, 
                                                            (SELECT id, Name, Price__c, Quantity__c  FROM Ordered_Products__r),
                                                            Account_Name__r.Name, 
                                                            Discount_Percent__c
                                                            FROM Order__c
                                                            WHERE Id =: orderIds]);
        // 현재 날짜
        Date currentDate = Date.today();
        
        // 최근 90일 이전의 날짜 계산
        Date startDate = currentDate.addDays(-90);

        for(Contact contact : contactMap.values()){
            System.debug('고객ID '+contact.Name);
            for(Order__c order : orderMap.values()){
                //System.debug('OrderId '+order.Id);
                if(contact.Id == order.Contact_Name__c){
                    if(order.Start_Date__c >= startDate && order.Start_Date__c <= currentDate){
                        Map<String, Decimal> storeMap = storePurchaseMap.get(order.Contact_Name__c);

                        for(Ordered_Product__c item : order.Ordered_Products__r) {
                            Decimal purchaseAmount = 0;
                            // 제품의 이름이 노트북일 경우 가격 * 개수를 계산
                            purchaseAmount = storeMap.get(order.Contact_Name__c);
                            if(purchaseAmount == null) {
                                purchaseAmount = 0;
                            }

                            if(order.Discount_Percent__c != 0 && order.Discount_Percent__c != null){
                                System.debug('Discount Percent '+order.Discount_Percent__c);
                                purchaseAmount += item.Price__c * item.Quantity__c*(1-order.Discount_Percent__c*0.01);
                            }else{
                                purchaseAmount += item.Price__c * item.Quantity__c;
                            }
                            //purchaseAmount += item.Price__c * item.Quantity__c;
                            System.debug('지점 총 합계'+purchaseAmount);
                            //purchaseMap.put(contact.Id, purchaseAmount);
                            storeMap.put(order.Account_Name__r.Name, storeMap.get(order.Account_Name__r.Name)+purchaseAmount);
                            storePurchaseMap.put(order.Contact_Name__c , storeMap);

                            System.debug(storePurchaseMap.get(order.Contact_Name__c));
                            System.debug(storeMap.get(order.Account_Name__r.Name));
                    
                        }
                    }
                }
            }
        }
        
        // 최근 90일 동안의 구매 금액을 고객 레코드에 업데이트
        List<Contact> customerToUpdate = new List<Contact>();
        
        for(Id contactId : contactIds){
            Map<String, Decimal> updateMap = storePurchaseMap.get(contactId);
            Contact customer = new Contact(Id = contactId, GangwonSum__c = 0, GyeonggiSum__c = 0, DaejeonSum__c = 0, IncheonSum__c = 0, UlsanSum__c = 0, DaeguSum__c = 0,
                                            GwangjuSum__c = 0, BusanSum__c = 0, SejongSum__c = 0, SeoulSum__c = 0, JejuSum__c = 0);
            

            if(updateMap.containsKey('강원 지점')){
                customer.GangwonSum__c = updateMap.get('강원 지점');
                //customerToUpdate.add(customer);
            }
            if(updateMap.containsKey('경기 지점')){
                customer.GyeonggiSum__c = updateMap.get('경기 지점');
                //customerToUpdate.add(customer);
            }
            if(updateMap.containsKey('광주 지점')){
                customer.GwangjuSum__c = updateMap.get('광주 지점');
                //customerToUpdate.add(customer);
            }
            if(updateMap.containsKey('대구 지점')){
                customer.DaeguSum__c = updateMap.get('대구 지점');
                //customerToUpdate.add(customer);
            }
            if(updateMap.containsKey('대전 지점')){
                customer.DaejeonSum__c = updateMap.get('대전 지점');
                //customerToUpdate.add(customer);
            }
            if(updateMap.containsKey('부산 지점')){
                customer.BusanSum__c = updateMap.get('부산 지점');
                //customerToUpdate.add(customer);
            }
            if(updateMap.containsKey('서울 지점')){
                customer.SeoulSum__c = updateMap.get('서울 지점');
                //customerToUpdate.add(customer);
            }
            if(updateMap.containsKey('세종 지점')){
                customer.SejongSum__c = updateMap.get('세종 지점');
                //customerToUpdate.add(customer);
            }
            if(updateMap.containsKey('울산 지점')){
                customer.UlsanSum__c = updateMap.get('울산 지점');
                //customerToUpdate.add(customer);
            }
            if(updateMap.containsKey('인천 지점')){
                customer.IncheonSum__c = updateMap.get('인천 지점');
                //customerToUpdate.add(customer);
            }
            if(updateMap.containsKey('제주 지점')){
                customer.JejuSum__c = updateMap.get('제주 지점');
                //customerToUpdate.add(customer);
            }

            customerToUpdate.add(customer);
            
        }

        for(Id con : notOrderContactIds){
            Contact customer = new Contact(Id = con, GangwonSum__c = 0, GyeonggiSum__c = 0, DaejeonSum__c = 0, IncheonSum__c = 0, UlsanSum__c = 0, DaeguSum__c = 0,
                                            GwangjuSum__c = 0, BusanSum__c = 0, SejongSum__c = 0, SeoulSum__c = 0, JejuSum__c = 0);
            customerToUpdate.add(customer);
        }

        for(Contact con : customerToUpdate){
            System.debug('Store '+con);
        }

        update customerToUpdate;
    }

    // List<Order__c> orders = [SELECT Id, Contact_Name__c, Start_Date__c,Discount_Percent__c, (select id, Name, Price__c, Quantity__c  from Ordered_Products__r)
    //                         FROM Order__c
    //                        WHERE Start_Date__c >= LAST_N_DAYS:90];
        
        
    // StorePurchaseManager.UpdateStorePurchaseAmountForCustomer(orders);

}