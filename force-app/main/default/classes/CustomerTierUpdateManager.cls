public with sharing class CustomerTierUpdateManager {
    
    public static void UpdateCustomerTier(List<Contact> contactsToUpdate){

        List<Custom_Tier__mdt> tiers = [SELECT Grade__c, Minimum_Spending__c FROM Custom_Tier__mdt ORDER BY Grade__c ASC];

        Map<String, Decimal> gradeToMinSpendingMap = new Map<String, Decimal>();

        for(Custom_Tier__mdt tier : tiers){
            gradeToMinSpendingMap.put(tier.Grade__c, tier.Minimum_Spending__c);
            System.debug(tier.Grade__c +'='+tier.Minimum_Spending__c );
        }

        for(Contact contact : contactsToUpdate){
            System.debug(contact.Name);
            Decimal totalSpending = contact.Total_Sum__c != null ? contact.Total_Sum__c : 0;
            System.debug(totalSpending);
            String tier = detetminCustomerTier(totalSpending, gradeToMinSpendingMap);
            contact.Tier__c = tier;
            System.debug(tier);
        }

        update contactsToUpdate;

    }

    private static String detetminCustomerTier(Decimal totalSpending, Map<String, Decimal> gradeToMinSpendingMap){
        for(String grade : gradeToMinSpendingMap.keySet()){
            Decimal minSpending = gradeToMinSpendingMap.get(grade);
            if(totalSpending >= minSpending){
                return grade;
            }
        }

        return 'D등급';
    }

    /*List<Contact> contact = [Select Id, Name, Total_Sum__c from contact];

    CustomerTierUpdateManager.UpdateCustomerTier(contact);*/
}