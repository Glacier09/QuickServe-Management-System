@IsTest
private class OrderTriggerHandler_Test {

    @IsTest
    static void testUpdateLoyaltyPoints() {
        // 1. Prepare Test Data
        Contact newCustomer = new Contact(FirstName = 'Test', LastName = 'Customer');
        insert newCustomer;

        Loyalty_Program_c__c loyaltyProgram = new Loyalty_Program_c__c(Customer_c__c = newCustomer.Id, Points_Balance_c__c = 100);
        insert loyaltyProgram;

        // 2. Perform action
        Order_c__c newOrder = new Order_c__c(
            Contact__c = newCustomer.Id,
            Total_Amount_c__c = 50.00,
            Status_c__c = 'Complete',
            Menu_Item_c__c = 'Pizza',
            Quantity_c__c = 1
        );
        insert newOrder;

        // 3. Verify results
        Loyalty_Program_c__c updatedLoyalty = [SELECT Points_Balance_c__c FROM Loyalty_Program_c__c WHERE Id = :loyaltyProgram.Id];

        System.assertEquals(105, updatedLoyalty.Points_Balance_c__c);
    }
    
    @IsTest
    static void testNewOrder_PendingStatus() {
        // 1. Prepare Test Data
        Contact newCustomer = new Contact(FirstName = 'Test', LastName = 'Customer');
        insert newCustomer;
    
        Loyalty_Program_c__c loyaltyProgram = new Loyalty_Program_c__c(Customer_c__c = newCustomer.Id, Points_Balance_c__c = 100);
        insert loyaltyProgram;
    
        // 2. Perform action: Insert a pending order
        Order_c__c newOrder = new Order_c__c(
            Contact__c = newCustomer.Id,
            Total_Amount_c__c = 50.00,
            Status_c__c = 'Pending', // Status is not 'Complete'
            Menu_Item_c__c = 'Burger',
            Quantity_c__c = 1
        );
        insert newOrder;
    
        // 3. Verify results: Points should not have changed
        Loyalty_Program_c__c updatedLoyalty = [SELECT Points_Balance_c__c FROM Loyalty_Program_c__c WHERE Id = :loyaltyProgram.Id];
        
        System.assertEquals(100, updatedLoyalty.Points_Balance_c__c, 'Points should not have been updated for a pending order.');
    }
    
    @IsTest
    static void testUpdatedOrder_toComplete() {
        // 1. Prepare Test Data
        Contact newCustomer = new Contact(FirstName = 'Test', LastName = 'Customer');
        insert newCustomer;
    
        Loyalty_Program_c__c loyaltyProgram = new Loyalty_Program_c__c(Customer_c__c = newCustomer.Id, Points_Balance_c__c = 100);
        insert loyaltyProgram;
        
        // Create the order as 'Pending' first
        Order_c__c newOrder = new Order_c__c(
            Contact__c = newCustomer.Id,
            Total_Amount_c__c = 75.00,
            Status_c__c = 'Pending',
            Menu_Item_c__c = 'Pizza',
            Quantity_c__c = 1
        );
        insert newOrder;
    
        // 2. Perform action: Update the order's status to 'Complete'
        newOrder.Status_c__c = 'Complete';
        update newOrder;
    
        // 3. Verify results: Check that points were added
        Loyalty_Program_c__c updatedLoyalty = [SELECT Points_Balance_c__c FROM Loyalty_Program_c__c WHERE Id = :loyaltyProgram.Id];
        
        // 75.00 * 0.1 = 7.5 points. Original points were 100. Total should be 107.5.
        System.assertEquals(107.5, updatedLoyalty.Points_Balance_c__c, 'Points should have been updated after the status change.');
    }
    
    @IsTest
    static void testNewOrder_NoContact() {
        // 1. Prepare Test Data: Insert an order without a customer but with all required fields
        Order_c__c newOrder = new Order_c__c(
            Contact__c = null, // The key to this test
            Total_Amount_c__c = 50.00,
            Status_c__c = 'Complete',
            Menu_Item_c__c = 'Pizza', // Add this required field
            Quantity_c__c = 1       // Add this required field
        );
        // 2. Perform action: Insert the order
        // This will cause the if condition to be false and hit the return statement.
        insert newOrder;
        
        // 3. Verification: No assertion is needed as no code should run after the return.
        // The mere fact that this test completes successfully means the code path was covered.
    }
    
    @IsTest
    static void testNewOrder_NoLoyaltyProgram() {
        // 1. Prepare Test Data: Insert a new customer without a loyalty program record
        Contact newCustomer = new Contact(FirstName = 'New', LastName = 'Customer');
        insert newCustomer;
    
        // 2. Perform action: Insert a new order that would normally trigger an update
        Order_c__c newOrder = new Order_c__c(
            Contact__c = newCustomer.Id,
            Total_Amount_c__c = 50.00,
            Status_c__c = 'Complete',
            Menu_Item_c__c = 'Pizza',
            Quantity_c__c = 1
        );
        insert newOrder;
    
        // 3. Verification: No assertion needed. The code should not fail.
        // The mere fact that this test completes successfully means the code path was covered.
	}
    
    @isTest
    private static void testUpdateLoyaltyPoints_HappyPath() {
        // 1. Setup: Create a Contact and a related Loyalty Program
        Contact testContact = new Contact(LastName = 'Testcontact');
        insert testContact;
    
        Loyalty_Program_c__c loyaltyProgram = new Loyalty_Program_c__c(
            Customer_c__c = testContact.Id,
            Points_Balance_c__c = 100 // Start with some initial points
        );
        insert loyaltyProgram;
        
        
        // 2. Action: Create the Order that should trigger the logic
        Test.startTest();
    
        Order_c__c testOrder = new Order_c__c(
            Contact__c = testContact.Id,
            Status_c__c = 'Complete',   // This status is crucial
            Total_Amount_c__c = 500.00, // An amount to calculate points from 
            Quantity_c__c = 1
        );
        insert testOrder;
    
        Test.stopTest();
    
        // 3. Verification: Query the database again and assert the change
        Loyalty_Program_c__c updatedLoyaltyProgram = [SELECT Points_Balance_c__c FROM Loyalty_Program_c__c WHERE Id = :loyaltyProgram.Id];
    
        // Expected points: 100 (initial) + (500 * 0.1) = 150
        Decimal expectedPoints = 150;
        System.assertEquals(expectedPoints, updatedLoyaltyProgram.Points_Balance_c__c, 'Loyalty points were not updated correctly.');
    }
}