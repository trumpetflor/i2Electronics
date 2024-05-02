import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertGeneralInquiry from '@salesforce/apex/CaseController.insertGeneralInquiry';
import { NavigationMixin } from 'lightning/navigation';
export default class CaseGeneralInquiry extends NavigationMixin(LightningElement) {
    caseType = '일반상담'; // Case 타입 설정
    @track accountSelected = false;
    @track productSelected = false;
    @track inquiryDetailsEntered = false;
    @track inquiryDetails = ''; // // 사용자가 입력한 상담 내용을 저장하는 변수
    @track selectedAccountId; // 선택된 판매지점 ID, AccountSelector 컴포넌트로부터 발생된 accountchange 이벤트를 받기 위한 이벤트 리스너에서 쓸 변수


    // 각 단계의 완료 상태에 따른 클래스
    get step1Class() {
        return `slds-progress-ring slds-progress-ring_large ${this.accountSelected ? 'slds-is-complete' : ''}`;
    }

    get step2Class() {
        return `slds-progress-ring slds-progress-ring_large ${this.productSelected ? 'slds-is-complete' : ''}`;
    }

    get step3Class() {
        return `slds-progress-ring slds-progress-ring_large ${this.inquiryDetails ? 'slds-is-complete' : ''}`;
    }




    // 제품 선택 변경 이벤트 핸들러
    handleProductSelect(event) {
        this.productSelected = event.detail ? true : false;
    }

    // 판매지점 선택 변경 이벤트 핸들러
    handleAccountChange(event) {
        this.accountSelected = true;
        this.selectedAccountId = event.detail; // 이벤트의 detail로부터 받은 판매지점 ID를 저장

    }


    // 상담내용 변경 이벤트 핸들러
    handleInquiryChange(event) {
        this.inquiryDetails = event.detail.value; // 입력된 상담 내용 저장
    }

    // 상담 기록 저장 버튼 핸들러
    saveInquiry() {
        // 상담 내용이 비어있는지 확인
        if (!this.inquiryDetails.trim().length) {
            // 상담 내용이 없으면 오류 메시지 표시
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '상담 내용을 입력해주세요.',
                    message: '상담 내용이 비어있습니다. 상담 진행사항을 작성해주세요.',
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        } else {// 상담 내용이 있으면 저장

            insertGeneralInquiry({
                accountId: this.selectedAccountId, // 부모컴포넌트를 통해 받은 판매지점 ID 
                inquiryDetails: this.inquiryDetails //상담 세부내용  
            })
                .then((result) => {

                    console.log('저장 ! result:', result);

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '성공',
                                message: '상담 내용이 저장되었습니다.',
                                variant: 'success'
                            })
                        );

                        // navigate 함수를 호출하여 레코드 페이지로 리디렉션
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result,
                                actionName: 'view'
                            }

                        });

                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: '저장 실패',
                            message: '오류가 발생했습니다: ' + error,
                            variant: 'error'
                        })
                    );
                    // 오류 처리 로직
                });
        }
    }//end of saveInquiry()
}