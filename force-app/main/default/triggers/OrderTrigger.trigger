trigger OrderTrigger on Order_c__c (after insert, after update) {
    OrderTriggerHandler.updateLoyaltyPoints(Trigger.new);
}