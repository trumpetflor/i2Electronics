import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createRefund from '@salesforce/apex/RefundController.createRefund';
import getUserProfileName from '@salesforce/apex/ProfileChecker.getUserProfileName';

export default class RefundOrder extends NavigationMixin(LightningElement) {
    @api recordId;
    isModalOpen = false;
    refundReason = '';
    isSalesProfile = false;

    @wire(getUserProfileName)
    wiredProfileName({ error, data }) {
        console.log("data : " + data);
        if (data) {
            this.isSalesProfile = (data === '판매점');
        } else if (error) {
            // 에러 처리
            this.isSalesProfile = false;
        }
    }

    showModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleReasonChange(event) {
        this.refundReason = event.target.value;
    }

    processRefund() {
        createRefund({ orderId: this.recordId, refundReason: this.refundReason })
            .then(contactId => {
                // 환불 처리 후 리디렉트
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: contactId, // 고객(Contact) 레코드의 ID
                        actionName: 'view'
                    },
                });

                this.closeModal(); // 모달 창 닫기
                
                // 성공 메시지 표시
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '환불 완료',
                        message: '해당 주문의 환불 처리가 정상적으로 되었습니다.',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                // 오류 메시지 표시
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '환불 처리 중 문제가 발생하였습니다.',
                        message: error.body ? error.body.message : error,
                        variant: 'error',
                    }),
                );
            });
    }
}