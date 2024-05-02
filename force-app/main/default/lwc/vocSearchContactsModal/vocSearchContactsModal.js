import { LightningElement, api } from 'lwc';

export default class VocSearchContactsModal extends LightningElement {
    //CasePurchaseInquiry.html에 바인딩할 변수
    @api isModalOpen = false; //@api로 노출 - 부모 컴포넌트인 CasePurchaseInquiry가 직접 제어

    //모달닫기버튼
    closeModal() {
        this.isModalOpen = false;
    }
}