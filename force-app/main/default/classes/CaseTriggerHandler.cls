public class CaseTriggerHandler {

    //고객의 상담횟수를 업데이트하는 핸들러메서드
    public static void updateContactCaseCount(List<Case> TriggerNew) {
        // 상담 횟수를 업데이트할 Contact의 ID 저장
        Set<Id> contactIds = new Set<Id>(); 

        // 케이스 레코드에서 관련 Contact의 ID 수집
        for (Case c : TriggerNew) {
            if (c.ContactId != null) {
                contactIds.add(c.ContactId);
            }
        }

        //고객정보가 존재할때만 작업
        if(contactIds != null){

            // 해당 Contact 레코드를 조회
            List<Contact> contactsToUpdate = [SELECT Id, Case_Count__c FROM Contact WHERE Id IN :contactIds];

            // 각 Contact의 상담 횟수를 1 증가
            for (Contact con : contactsToUpdate) {
                if (con.Case_Count__c == null || con.Case_Count__c == 0) {
                    con.Case_Count__c = 1;
                } else {
                    con.Case_Count__c += 1;
                }
            }

            // 변경된 Contact 레코드를 업데이트
            update contactsToUpdate;

        }

    }//end of updateContactCaseCount method

    //Case가 삭제될때 Case Count -1하는 메서드
    public static void updateCaseCountAfterDelete(List<Case> deletedCases) {
        Set<Id> contactIds = new Set<Id>();
        
        //일반상담과 VoC일 경우에만 실행되어야함.
        // 삭제된 Case들 중에서 고객명(ContactId)이 있는 경우만 고객 ID를 Set에 추가
        for(Case c : deletedCases) {
            if(c.ContactId != null) {
                contactIds.add(c.ContactId);
            }
        }
        
        // 고객명이 연관된 Case를 찾기 위해, 관련 고객의 현재 Case Count를 가져옴
        List<Contact> contactCase_Count = [SELECT Id, Case_Count__c FROM Contact WHERE Id IN :contactIds];
        
        // 각 고객별로 Case Count를 감소
        for(Contact con : contactCase_Count) {
            // Case Count가 0보다 클 때만 감소시킴
            if(con.Case_Count__c > 0) {
                con.Case_Count__c -= 1;
            }
        }
        
        // 수정된 고객 정보를 업데이트
        update contactCase_Count;
    }


    // Case 객체가 insert 또는 update된 후 처리 로직
    // VoC 타입의 케이스가 'Closed' 상태일 때 관련 이메일 전송
    public static void sendEmailForVoC(List<Case> caseList, Map<Id, Case> oldMap) {
        List<Id> caseIdsForEmail = new List<Id>();

        for (Case caseRecord : caseList) {
            // 케이스가 VoC 타입이고 상태가 'Closed'로 변경된 경우 확인
            boolean isClosedVoC = caseRecord.Type == 'VoC' && 
                                  caseRecord.Status == 'Closed' && 
                                  (oldMap == null || oldMap.get(caseRecord.Id).Status != 'Closed');

            if (isClosedVoC) {
                caseIdsForEmail.add(caseRecord.Id);
            }
        }

        // 'Closed' 상태로 변경된 VoC 케이스가 있으면 이메일 전송
        if (!caseIdsForEmail.isEmpty()) {
            EmailManager.sendVoCEmail(caseIdsForEmail);
        }
    }

    //Type이 단순상담(일반상담 또는 구매상담)일 경우 항상 종료된 상담으로 전환
    public static void changedClosedForInquiry(){

    }
    
}