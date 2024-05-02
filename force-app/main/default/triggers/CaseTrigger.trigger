trigger CaseTrigger on Case (after insert, after update, after delete) {

    // 'Closed Won' 상태로 업데이트된 case에 대한 이메일 전송
    if (Trigger.isAfter && Trigger.isUpdate) {
        CaseTriggerHandler.sendEmailForVoC(Trigger.new, Trigger.oldMap);
    }


    if(Trigger.isAfter) {

         // 새 Case 레코드가 생성될 때 상담 횟수 업데이트
        if(Trigger.isInsert){
            CaseTriggerHandler.updateContactCaseCount(Trigger.new);
        }

        if(Trigger.isDelete) {
            // 삭제된 Case를 핸들러에 전달
            CaseTriggerHandler.updateCaseCountAfterDelete(Trigger.old);
        }
    }
}