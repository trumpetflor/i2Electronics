public with sharing class CaseController {

    // 특정 연락처 ID에 대한 구매 제품 목록을 검색하는 메서드
    @AuraEnabled
    public static List<Ordered_Product__c> getOrderedProductsByContactId(String contactId) {
    
    String queryString = 'SELECT Id, Product__c, Product__r.Name, Price__c, Quantity__c, Order__r.Name, Order__r.Start_Date__c, Order__r.Account_Name__c FROM Ordered_Product__c';

    if (contactId != null && contactId != '') {
        queryString += ' WHERE Order__r.Contact_Name__c = :contactId';// 조건: 연락처 ID를 기반으로 주문된 제품을 검색
    }
    System.debug('queryString :'+queryString);
    return Database.query(queryString);
    }


    @AuraEnabled
public static Id createCaseForVoC(  String orderedProductId, 
                                    String productId, 
                                    String productName, 
                                    String contactName,
                                    String contactId,
                                    String description,
                                    String accountName) {


    /**
     *         createCaseForVoC({
            orderedProductId: this.orderedProductId, // 주문된 제품 ID 전달
            productId: this.productId,
            productName: this.productName,
            contactName: this.contactName,
            contactId: this.contactId,
            description: this.description,
            accountName: this.accountName
        })
     */
    System.debug('orderedProductId : ' + orderedProductId);
    System.debug('description :       ' + description);
    try {
        // 상담 기록에 필요한 정보 가져오기
        Ordered_Product__c orderedProduct = [SELECT Id, 
                                            Product__c, // 연결된 제품 ID
                                            Product__r.Name, // 제품 이름
                                            Product__r.ProductCode, // 제품 코드
                                        // Product__r.Description, // 제품 설명
                                            Product__r.Family, // 제품군
                                            Price__c, // 제품 가격
                                            Quantity__c, // 구매 수량
                                            Order__r.Id, // 관련 주문서 ID
                                            Order__r.OwnerId, // 주문서의 소유자 ID (담당 판매 직원)
                                            Order__r.Name, // 주문서명
                                            Order__r.Total_Amount__c, // 주문 총 금액
                                            Order__r.Discount_Amount__c, // 할인 금액
                                            Order__r.Final_Amount__c, // 최종 결제 금액
                                            Order__r.Start_Date__c, // 주문 날짜
                                            Order__r.Account_Name__c // 주문 처리한 판매 지점 ID
                                            
                                              FROM Ordered_Product__c 
                                              WHERE Id = :orderedProductId LIMIT 1];

        // 상담 기록에 주문 상품 및 주문 정보 추가
        String detailedDescription = '<b>주문 상품명<b>: ' + orderedProduct.Product__r.Name + '<br>' +
                                    '<b>가격<b>: ' + orderedProduct.Price__c + '<br>' +
                                    '<b>수량<b>: ' + orderedProduct.Quantity__c + '<br>' +
                                    '<b>주문 번호<b>: ' + orderedProduct.Order__r.Name + '<br><br>' +
                                    '<b>--------------상담 내용--------------</b>' +
                                    + description;

        System.debug('detailedDescription : ' + detailedDescription);
        // 새 Case 레코드 생성 로직
        Case newVoCRecord = new Case(
            ContactId = contactId,
            AccountId = orderedProduct.Order__r.Account_Name__c,
            Product__c = productName,
            ProductId = orderedProduct.Product__c,
            Ordered_Product__c = orderedProductId,
            order__c = orderedProduct.Order__r.Id,
            Type = 'VoC',
            Subject = 'VoC 상담', 
            Description__c = detailedDescription,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CaseForVoC').getRecordTypeId(),
            Date__c = DateTime.now()
        );
        System.debug('newVoCRecord : ' + newVoCRecord);
        System.debug('detailedDescription : ' + detailedDescription);

        insert newVoCRecord;

        return newVoCRecord.id;//고객의 폰번호 리턴

    } catch (Exception e) {
            // 예외 처리 로직
            System.debug('error - creating a CaseForVoC: ' + e.getMessage());
            throw new AuraHandledException('CaseForVoC를 생성하는 중 문제가 발생했습니다. 관리자에게 문의하세요.');
        }
    }


    
    //고객 id를 전달받아 고객과 관련된 Case 레코드 반환하는 메서드
    @AuraEnabled(cacheable=true)
    public static List<Case> getCaseRecordsByContactId(String contactId) {
        System.debug('getCaseRecordsByContactId - '+contactId);
        return [
            SELECT Id, Product__c, ContactId,  Description__c, Type, Date__c
            FROM Case
            WHERE ContactId = :contactId
            ORDER BY Date__c DESC
            LIMIT 15
            //AND RecordType.Name = 'CaseForVoC'
            //AND Type = 'VoC'
        ];
    }

    //caseId와 이메일내용을 전달받아 email content를 업데이트하는 메서드
    @AuraEnabled
    public static void updateCaseEmailContent(String caseId, String emailContent) {
        try {
            // Case 레코드 조회
            Case caseToUpdate = [SELECT Id, email_content__c FROM Case WHERE Id = :caseId LIMIT 1];
    
            // 이메일 내용 업데이트
            caseToUpdate.email_content__c = emailContent;
    
            // 레코드 업데이트
            update caseToUpdate;
        } catch (Exception e) {//에러처리
            throw new AuraHandledException('이메일내용 저장 작업 중 오류가 발생했습니다. 관리자에게 문의하세요.: ' + e.getMessage());
        }
    }

    //케이스를 closed로 변경하는 메서드
    @AuraEnabled
    public static void closeCase(String caseId) {
        try {
            // Case 레코드 조회
            Case caseToClose = [SELECT Id, Status FROM Case WHERE Id = :caseId LIMIT 1];

            // 상태를 'Closed Won'으로 변경
            caseToClose.Status = 'Closed';

            // 레코드 업데이트
            update caseToClose;
        } catch (Exception e) {
            // 오류 처리
            throw new AuraHandledException('Case 상태 업데이트 중 오류가 발생했습니다. 관리자에게 문의하세요.: ' + e.getMessage());
        }
}
    //type='단순상담' 저장하는 메서드
    @AuraEnabled
    public static Id insertGeneralInquiry(String accountId, String inquiryDetails) {
        try {
            // 상담 내용을 Case 객체로 생성합니다.
            Case newCase = new Case(
                accountId = accountId, //상담 담당 지점
                Description__c = inquiryDetails,//상담 세부내용
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CaseForOnSite').getRecordTypeId(),
                Type='일반상담',
                Status = 'Closed'//입력시 항상 Closed로 저장
            );

            insert newCase;
            System.debug('insertGeneralInquiry - newCase' + newCase);
            return newCase.Id;
        } catch (Exception e) {
            // 예외 처리
            System.debug('insertGeneralInquiry method error ' + e.getMessage());
            throw new AuraHandledException('상담 내용을 저장하는 동안 오류가 발생했습니다. 관리자에게 문의하세요' + e.getMessage());
        }
    }
    
    //type='구매상담' 저장하는 메서드
    @AuraEnabled
    public static Id insertPurchaseInquiry(String accountId, String contactId, String inquiryDetails) {
        try {
            // 상담 내용을 Case 객체로 생성합니다.
            Case newCase = new Case(
                accountId = accountId, //상담 담당 지점
                contactId = contactId, //고객 Id
                Description__c = inquiryDetails,//상담 세부내용
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CaseForOnSite').getRecordTypeId(),
                Type='구매상담',
                Status = 'Closed'//입력시 항상 Closed로 저장
            );

            insert newCase;
            return newCase.Id;
        } catch (Exception e) {
            // 예외 처리
            System.debug('insertPurchaseInquiry method error ' + e.getMessage());
            throw new AuraHandledException('상담 내용을 저장하는 동안 오류가 발생했습니다. 관리자에게 문의하세요 - ' + e.getMessage());
        }



    }

    //새로운 고객 생성하는 메서드
    @AuraEnabled
    public static id insertNewContact(String contactName, String contactPhone, String contactEmail) {
        try {
            // 필수 입력 필드 확인
            if (String.isBlank(contactName) || String.isBlank(contactPhone) || String.isBlank(contactEmail)) {
                throw new AuraHandledException('모든 필수 입력란을 작성해주세요.');
            }
            
            // 구매 문의 생성
            Contact newContact = new Contact(
                LastName = contactName,
                Phone = contactPhone,
                Email =contactEmail,
                Customer_Type__c = '상담고객'
            );
            
              // 연락처 레코드 삽입
              insert newContact;
              return newContact.Id;

        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
    }//end of insertNewContact


    //모든 판매물건을 리턴하는 메서드
    @AuraEnabled(cacheable=true)
    public static List<Product2> getAllProducts() {
        return [SELECT Id, Name, Price__c,ProductCode, Family FROM Product2];
    }


    //모든 판매지점을 리턴하는 메서드
    @AuraEnabled(cacheable=true)
    public static List<Account> getAllAccounts() {
        return [SELECT Id, Name FROM Account];
    }

    //User의 role를 리턴받는 메서드(role = 판매지점명)
    @AuraEnabled(cacheable=true)
    public static String getUserRoleName() {
        Id currentUserId = UserInfo.getUserId();
        String currentUserName= UserInfo.getUserName();
        Id currentUserRoleId = UserInfo.getUserRoleId();

    
        System.debug('current UserInfo id/name/roleId: ' + currentUserId+'/'+currentUserName+'/'+currentUserRoleId);
    
        // UserRole 쿼리에 대한 결과 리스트 사용
        List<UserRole> userRoles = [SELECT Name FROM UserRole WHERE Id IN 
                                    (SELECT UserRoleId FROM User WHERE Id = :currentUserId)];

        // UserRole 존재 여부 확인
        if (!userRoles.isEmpty()) {
            System.debug('userRole : ' + userRoles[0]);
            return userRoles[0].Name;
        } else {
            // UserRole이 없는 경우 null 반환
            return null; 
        }
    }
    
    }