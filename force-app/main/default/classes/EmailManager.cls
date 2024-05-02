public class EmailManager {
    //사용할 이메일 템플릿 @하원
   private static final String EMAIL_TEMPLATE_NAME = 'VoC_Consultations_Email_Template';
   //private static final String EMAIL_TEMPLATE_NAME = 'VoC_Consultations_Email_Template_for_Lightning_1710007761588';

    private static EmailTemplate getEmailTemplate() {
        return [SELECT Id FROM EmailTemplate WHERE DeveloperName = :EMAIL_TEMPLATE_NAME LIMIT 1];
    }

    //VoC관련 이메일 보내는 메서드
    @future
    public static void sendVoCEmail(List<Id> caseIds) {
        EmailTemplate template = getEmailTemplate();//사용할 이메일 템플릿
        List<Messaging.SingleEmailMessage> emails = createEmails(caseIds, template);

        //이메일 전송
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            System.debug('이메일 보내기 성공: '+ emails);
        }else{
            System.debug('이메일 보내기 실패: '+ emails);
        }
    }


    private static List<Messaging.SingleEmailMessage> createEmails(List<Id> caseIds, EmailTemplate template) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Id caseId : caseIds) {
            emails.add(createSingleEmail(caseId, template.Id));
        }

        return emails;
    }

private static Messaging.SingleEmailMessage createSingleEmail(Id caseId, Id templateId) {
    Case caseRecord = [SELECT ContactId FROM Case WHERE Id = :caseId LIMIT 1];
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setTemplateId(templateId);
    mail.setTargetObjectId(caseRecord.ContactId); // Case의 ContactId를 targetObjectId로 설정 =>Case와 연관된 연락처로 이메일을 보낼 수 있음
    mail.setWhatId(caseId); // Case ID를 whatId로 설정
    System.debug('mail targetObjectId,WhatId'+ mail);

    return mail;
}

}