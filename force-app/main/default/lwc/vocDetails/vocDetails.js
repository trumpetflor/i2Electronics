import { LightningElement, api } from 'lwc';

export default class VocDetails extends LightningElement {
    @api contactName;
    @api productId;
    @api productName;
    @api description;
    @api recordId;
}