public with sharing class LoyaltyController {
    @AuraEnabled(cacheable=true)
    public static Loyalty_Program_c__c getLoyaltyProgram(Id contactId) {
        List<Loyalty_Program_c__c> programs = [
            SELECT Points_Balance_c__c 
            FROM Loyalty_Program_c__c 
            WHERE Customer_c__c = :contactId 
            LIMIT 1
        ];

        if (!programs.isEmpty()) {
            return programs[0];
        } else {
            return null;
        }
    }
}