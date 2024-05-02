import { LightningElement, track, wire } from 'lwc';
import getCaseRecordsByContactId from '@salesforce/apex/CaseController.getCaseRecordsByContactId';
import { refreshApex } from '@salesforce/apex';


export default class vocParentComponent extends LightningElement {
    @track selectedOrderedProductId; // 선택된 주문된 제품 ID
    @track selectedProductId; // 선택된 제품 ID
    @track selectedProductName; // 선택된 제품명
    @track selectedContactId; // 선택된 연락처 ID
    @track selectedContactName; // 선택된 연락처명
    @track selectedAccountName; // 선택된 판매지점명

    //데이터를 새로고침하기 위함. getCaseRecordsByContactId 함수를 @wire를 통해 호출
    @wire(getCaseRecordsByContactId, { contactId: '$selectedContactId' })
    wiredCaseRecords;


    // 제품 선택 이벤트 핸들링
    handleProductSelect(event) {
        console.log('vocParentComponent.js - handleProductSelect : '+ JSON.stringify(event.detail));
        this.selectedOrderedProductId = event.detail.orderedProductId;
        this.selectedProductId = event.detail.productId;
        this.selectedProductName = event.detail.productName;
        this.selectedAccountName = event.detail.accountName;
    }

    // 고객 선택 이벤트 핸들링
    handleContactSelect(event) {
        this.selectedContactId = event.detail.contactId;
        this.selectedContactName = event.detail.contactName;
    }

    //리프래시 핸들러
    handleRefresh() {
        //alert('handleRefresh');
        location.reload();

        return refreshApex(this.wiredCaseRecords);
    }
}