global class OrderEmailServiceHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String emailBody = email.plainTextBody;

        // --- Logic to parse the email body ---
        String contactEmail;
        String menuItem;
        Integer quantity;
        Decimal totalAmount;

        try {
            // Simple parsing logic: assumes "key:value" on each line
            for (String line : emailBody.split('\n')) {
                if (line.startsWith('contactEmail:')) {
                    contactEmail = line.substringAfter(':').trim();
                } else if (line.startsWith('menuItem:')) {
                    menuItem = line.substringAfter(':').trim();
                } else if (line.startsWith('quantity:')) {
                    quantity = Integer.valueOf(line.substringAfter(':').trim());
                } else if (line.startsWith('totalAmount:')) {
                    totalAmount = Decimal.valueOf(line.substringAfter(':').trim());
                }
            }

            // Find the Contact
            List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :contactEmail LIMIT 1];
            if (contacts.isEmpty()) {
                System.debug('OrderEmailServiceHandler Error: Contact not found.');
                return result; // Stop processing
            }

            // Create the Order
            Order_c__c newOrder = new Order_c__c(
                Contact__c = contacts[0].Id,
                Menu_Item_c__c = menuItem,
                Quantity_c__c = quantity,
                Total_Amount_c__c = totalAmount,
                Status_c__c = 'Complete'
            );
            insert newOrder;
            System.debug('Order created with Id: ' + newOrder.Id);

            result.success = true;

        } catch (Exception e) {
            System.debug('OrderEmailServiceHandler Error: ' + e.getMessage());
            result.success = false;
        }

        return result;
    }
}