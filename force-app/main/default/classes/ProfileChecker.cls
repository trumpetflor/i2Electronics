public with sharing class ProfileChecker {
    @AuraEnabled(cacheable=true)
    public static String getUserProfileName() {
        List<User> currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        System.debug(currentUser[0].Profile.Name);
        return currentUser[0].Profile.Name;
    }
}