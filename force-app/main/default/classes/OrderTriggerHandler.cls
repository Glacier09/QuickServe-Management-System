public with sharing class OrderTriggerHandler {
    public static void updateLoyaltyPoints(List<Order_c__c> newOrders) {
        Set<Id> contactIds = new Set<Id>();
        for (Order_c__c o : newOrders) {
            if (o.Status_c__c == 'Complete' && o.Contact__c != null) {
                contactIds.add(o.Contact__c);
            }
        }

        if (contactIds.isEmpty()) {
            return;
        }

        // Create a map where the KEY is the Contact ID (Customer__c)
        Map<Id, Loyalty_Program_c__c> loyaltyMap = new Map<Id, Loyalty_Program_c__c>();
        for (Loyalty_Program_c__c lp : [
            SELECT Id, Customer_c__c, Points_Balance_c__c 
            FROM Loyalty_Program_c__c 
            WHERE Customer_c__c IN :contactIds
        ]) {
            loyaltyMap.put(lp.Customer_c__c, lp);
        }

        List<Loyalty_Program_c__c> programsToUpdate = new list<Loyalty_Program_c__c>();
        for (Order_c__c order : newOrders) {
            // This check will now work correctly
            if (order.Status_c__c == 'Complete' && loyaltyMap.containsKey(order.Contact__c)) {
                Loyalty_Program_c__c loyalty = loyaltyMap.get(order.Contact__c);
                loyalty.Points_Balance_c__c += order.Total_Amount_c__c * 0.1;
                programsToUpdate.add(loyalty);
            }
        }

        if (!programsToUpdate.isEmpty()) {
            update programsToUpdate;
        }
    }
}