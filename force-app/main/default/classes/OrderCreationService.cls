@RestResource(urlMapping='/OrderReceiver/*')
global with sharing class OrderCreationService {

    @HttpPost
    global static String createOrder(String contactEmail, String menuItem, Integer quantity, Decimal totalAmount) {
        
        try {
            // DO NOT search for a Contact. Instead, store the email in a new field.
            Order_c__c newOrder = new Order_c__c(
                Customer_Email__c = contactEmail, // Store email in the new text field
                Menu_Item_c__c = menuItem,
                Quantity_c__c = quantity,
                Total_Amount_c__c = totalAmount,
                Status_c__c = 'Complete' 
            );

            insert newOrder;

            return 'Success: Order received with Id ' + newOrder.Id;

        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}