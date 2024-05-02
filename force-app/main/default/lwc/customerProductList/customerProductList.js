import { LightningElement, wire, api } from 'lwc';
import getCustomerProducts from '@salesforce/apex/CustomerProductController.getCustomerProducts';

const columns = [
    { label: '제품 이름', fieldName: 'name' , hideDefaultActions: "true"},
    { label: '수량', fieldName: 'quantity', type: 'number', hideDefaultActions: "true" }
];

export default class CustomerProductList extends LightningElement {
    @api recordId;
    
    laptopProducts;
    otherProducts;
    columns = columns;
    rowOffset = 0;

    @wire(getCustomerProducts, { customerId: '$recordId' })
    wiredCustomerProducts({ error, data }) {
        if (data) {
            this.laptopProducts = data.filter(product => product.family === '노트북');
            this.otherProducts = data.filter(product => product.family === '주변기기');
            console.log(this.laptopProducts);
            console.log(this.otherProducts);
        } else if (error) {
            console.error('Error fetching customer products', JSON.stringify(error));
        }
    }
}