import { LightningElement, wire, track } from 'lwc';
import getAllProducts from '@salesforce/apex/CaseController.getAllProducts';

export default class ProductListView extends LightningElement {
    /**  return [SELECT Id, Name, Price__c,Family FROM Product2]; */
    @track columns = [
        { label: '제품군', fieldName: 'Family' },
        { label: '제품명', fieldName: 'Name' },
        { label: '제품 코드', fieldName: 'ProductCode'},
        { label: '가격', fieldName: 'Price__c' , type: 'currency'}
    ];

    @track products;

    @wire(getAllProducts)
    wiredProducts({ error, data }) {
        if (data) {
            this.products = data;
            this.dispatchEvent(new CustomEvent('productsloaded', { detail: this.products }));
        } else if (error) {
            // 오류 처리
            console.error('wiredProducts 에러', error);
        }
    }

        //랜더링할 레포트 아이디값
        reportId = "00OIS000000Kdws2AC";

    
        handleRowSelection(event) {
            const selectedRows = event.detail.selectedRows;
            
            // 선택된 행에서 필요한 정보 추출
            let selectedProducts = selectedRows.map(row => {
                return { name: row.Name, code: row.ProductCode }; // 'Name'과 'ProductCode'는 데이터의 필드명에 따라 달라질 수 있음
            });

            // 선택된 제품 정보 이벤트로 발송
            this.dispatchEvent(new CustomEvent('productselection', { detail: { products: selectedProducts } }));//이중배열로 안넘어가게 처리함
        }

        

}