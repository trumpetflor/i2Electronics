import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertNewContact from '@salesforce/apex/CaseController.insertNewContact';

export default class NewCustomerForm extends LightningElement {
    @track customerName = '';
    @track customerPhone = '';
    @track customerEmail = '';
    @api contactId;
    @api contactName;

    handleNameChange(event) {
        this.customerName = event.target.value;
    }

    handlePhoneChange(event) {
        this.customerPhone = event.target.value;
        console.log('handlePhoneChange():'+this.customerPhone);
    }

    handleEmailChange(event) {
        this.customerEmail = event.target.value;
    }

    //저장버튼 - 신규 고객 생성하는 메서드
    saveNewCustomer() {
        // 필수 입력 필드 확인
        if (!this.customerName || !this.customerPhone || !this.customerEmail) {
            this.showToast('오류', '모든 필드는 필수입니다.', 'error');
            return;
        }

        // Apex 메서드 호출
        insertNewContact({  contactName: this.customerName, 
                            contactPhone: this.customerPhone, 
                            contactEmail: this.customerEmail})
            .then(id => {//contact id리턴받음
                this.showToast('성공', '고객이 성공적으로 생성되었습니다.', 'success');
                this.contactId = id;
                this.contactName = this.customerName;
                
                //리턴된 ID와 이름을 CasePurchaseInquiry 컴포넌트로 전달
                const event = new CustomEvent('contactcreated', {
                    detail: {
                        contactId: this.contactId,
                        contactName: this.contactName,
                        contactPhone: this.customerPhone
                    }
                });
                this.dispatchEvent(event);


                
            })
            .catch(error => {//에러처리

                if (error.body && error.body.message) {

                    let fullMessage = error.body.message;
                    // "FIELD_CUSTOM_VALIDATION_EXCEPTION,"를 기준으로 메시지를 분리
                    let parts = fullMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                    if (parts.length > 1) {
                        // 분리된 두 번째 부분(즉, 원하는 오류 메시지)을 가져옴
                        let customValidationMessage = parts[1].trim();
                        this.showToast('벨리데이션 오류', customValidationMessage, 'error');
                    } else {
                        // "FIELD_CUSTOM_VALIDATION_EXCEPTION,"를 포함하지 않는 경우 기본 오류 메시지 표시
                        this.showToast('오류', '처리 중 오류가 발생했습니다.'+error.body.message, 'error');
                    }
                } else {
                    // 오류 메시지가 없는 경우
                    this.showToast('오류', '알 수 없는 오류가 발생했습니다.', 'error');
                }
            });
            
    }

    // 토스트 메시지 표시 메서드
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}