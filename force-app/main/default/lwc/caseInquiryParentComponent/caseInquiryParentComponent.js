import { LightningElement, track } from 'lwc';

export default class CaseInquiryParentComponent extends LightningElement {
    @track inquiryType;

    get isGeneralInquiry() {
        return this.inquiryType === '일반상담';
    }

    get isPurchaseInquiry() {
        return this.inquiryType === '구매상담';
    }

    handleInquiryTypeChange(event) {
        this.inquiryType = event.target.value;
    }

    handleSave(event) {
        //추후에 작성
    }
}