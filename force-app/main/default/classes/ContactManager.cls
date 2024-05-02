public with sharing class ContactManager {
    
    public static void AssignHeadOfficeAccount(List<Contact> contacts){
        //Map<Id, Account> mainOfficeAccounts = new Map<Id, Account>();
        List<Account> HeadOfficeAccounts = [SELECT Id, Name FROM Account WHERE Name = '본사'];

        // for(Account acc : [SELECT Id, Name FROM Account WHERE Name = '본사']) {
        //     mainOfficeAccounts.put(acc.Id, acc);
        // }

        for(Contact con : contacts) {
            if(HeadOfficeAccounts.size() > 0 && con.AccountId == null) {
                con.AccountId = HeadOfficeAccounts[0].Id;
            }
        }
    }
}