public with sharing class PreventDuplicatePhoneManager {
    
    public static void handleContacts(List<Contact> newContacts) {
        Set<String> phoneNumbers = new Set<String>();
        Map<String, Contact> phoneToContactMap = new Map<String, Contact>();

        // 새로운 Contact의 Phone을 수집한다.
        for(Contact newContact : newContacts){
            if(newContact.Phone != null){
                phoneNumbers.add(newContact.Phone);
                phoneToContactMap.put(newContact.Phone, newContact);
            }
        }

        // 이미 존재하는 Phone인지 확인한다.
        for(Contact existingContact : [SELECT Phone FROM Contact WHERE Phone IN :phoneNumbers]){
            // 새로운 Contact의 Phone이 존재하는 경우 오류 메시지를 발생시킨다.
            Contact newContact = phoneToContactMap.get(existingContact.Phone);

            if(newContact != null){
                if(newContact.Id != existingContact.Id){
                    newContact.Phone.addError('이 전화번호는 이미 다른 연락처에 사용 중입니다.');
                    newContact.addError('이 전화번호는 이미 다른 연락처에 사용 중입니다.');
                }
            }
        }
    }

}