trigger PreventDuplicatePhoneTrigger on Contact (before insert, before update) {
    PreventDuplicatePhoneManager.handleContacts(Trigger.new);
    ContactManager.AssignHeadOfficeAccount(Trigger.new);
}