import { LightningElement, api, wire } from 'lwc';
import getLoyaltyProgram from '@salesforce/apex/LoyaltyController.getLoyaltyProgram';

export default class LoyaltyPointsDisplay extends LightningElement {
    @api recordId; // Automatically gets the Contact's ID from the record page

    // Use the @wire adapter to call the Apex method
    @wire(getLoyaltyProgram, { contactId: '$recordId' })
    loyaltyProgram;
}