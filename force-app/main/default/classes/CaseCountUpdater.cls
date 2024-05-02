public class CaseCountUpdater {
    public static void updateCaseCounts(List<Contact> contacts) {
        // 연락처 ID를 기준으로 Case 개수를 매핑하기 위한 맵 생성
        Map<Id, Integer> contactCaseCountMap = new Map<Id, Integer>();

        // 연락처 ID 리스트 생성
        List<Id> contactIds = new List<Id>();
        for(Contact contact : contacts) {
            contactIds.add(contact.Id);
        }

        // 연락처별 Case 개수 집계
        List<AggregateResult> results = [
            SELECT ContactId, COUNT(Id)
            FROM Case
            WHERE ContactId IN :contactIds
            GROUP BY ContactId
        ];

        // 집계 결과를 맵에 저장
        for(AggregateResult ar : results) {
            contactCaseCountMap.put((Id)ar.get('ContactId'), (Integer)ar.get('expr0'));
        }

        // 각 연락처에 대해 Case 개수 업데이트
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact contact : contacts) {
            Integer caseCount = contactCaseCountMap.get(contact.Id);
            if(caseCount == null) {
                caseCount = 0; // Case가 없는 경우 0으로 설정
            }
            if(contact.Case_Count__c != caseCount) { // 현재 값과 다른 경우에만 업데이트
                contact.Case_Count__c = caseCount;
                contactsToUpdate.add(contact);
            }
        }

        // 변경된 연락처 업데이트
        if(!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}