import { LightningElement, track } from 'lwc';
import insertPurchaseInquiry from '@salesforce/apex/CaseController.insertPurchaseInquiry';
import insertNewContact from '@salesforce/apex/CaseController.insertNewContact';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CasePurchaseInquiry extends NavigationMixin(LightningElement) {
    @track selectedAccountId;
    @track inquiryDetails;
    caseType = '구매상담'; // Case 타입 설정

    // 모달 제어 및 고객 정보 표시 관련 변수
    @track isExistingCustomer = false;
    @track isNewCustomer = false;
    @track selectedContactId; // 고객 선택 컴포넌트로부터 받은 고객 ID
    @track selectedContactName; // 고객 선택 컴포넌트로부터 받은 고객명
    @track selectedContactPhone;// 고객 선택 컴포넌트로부터 받은 고객번호
    @track showCustomerInfo = false; // 고객정보 표시 제어 변수
    @track selectedProducts = [];// 선택된 제품의 이름과 코드를 포함하는 객체의 배열

    // 판매지점 변경 핸들러
    handleAccountChange(event) {
        this.selectedAccountId = event.detail;
    }

    // 상담내용 변경 핸들러
    handleInquiryChange(event) {
        this.inquiryDetails = event.target.value;
    }


    handleCustomerInfoChange(event) {
        this.customerInfo = event.detail;
    }


    //선택된 제품이 생길떄마다 발생하는 이벤트를 캐치하는 핸들러
    //<c-product-list-view onproductselection={handleProductSelection}></c-product-list-view>
    handleProductSelection(event) {
        this.selectedProducts = []; //선택될때마다 배열 초기화
        this.selectedProducts = event.detail.products;

        // 선택된 제품들을 문자열로 변환
        const selectedProductsText = this.selectedProducts
            .map(product => `${product.name} (${product.code})`)
            .join('<br>'); // 엔터로 구분

        // 상담 내용 필드에 제품 정보 추가
        this.inquiryDetails = ` <b>---관심있어하는 제품---</b><br> ${selectedProductsText}`;
    }
    
        

        



    // 고객유형 변경 핸들러
    handleCustomerTypeChange(event) {
        const selectedValue = event.target.value;
        this.isNewCustomer = selectedValue === 'newCustomer';
        this.isExistingCustomer = selectedValue === 'existingCustomer';

        // 고객 정보 표시를 초기화
        this.showCustomerInfo = false;

        if (selectedValue == 'existingCustomer') {
            this.openModal();
        }
    }

    //c-voc-search-contacts컴포넌트를 여는 모달 관련 함수들
    openModal() {
        //신규고객 slot닫기
        this.isNewCustomer = false;

        this.isExistingCustomer = true; // 모달 열기
    }

    closeModal() {
        this.isExistingCustomer = false; // 모달 닫기
    }


    // c-voc-search-contacts 컴포넌트로부터 발생한 고객 선택 이벤트 핸들러
    handleContactSelect(event) {
        this.selectedContactId = event.detail.contactId;
        this.selectedContactName = event.detail.contactName;
        this.selectedContactPhone = event.detail.contactPhone;

        //신규고객 slot닫기
        this.isNewCustomer = false;
        //고객 정보 표시
        this.showCustomerInfo = true;
    }


    // c-new-customer-form 컴포넌트에서 고객 생성 이벤트(contactcreated)가 발생하면 handleContactCreated 메서드를 호출
    handleContactCreated(event) {
        this.selectedContactId = event.detail.contactId;
        this.selectedContactName = event.detail.contactName;
        this.selectedContactPhone = event.detail.contactPhone;
        //신규고객 slot닫기
        this.isNewCustomer = false;
        // 고객 정보 표시
        this.showCustomerInfo = true;
    }
    // 상담 기록 저장 버튼 핸들러
    saveInquiry() {
        console.log('this.selectedAccountId:', this.selectedAccountId);
        // selectedContactId가 없거나 showCustomerInfo가 false인 경우 실행을 중단
        if (!this.selectedContactId || !this.showCustomerInfo) {
            this.showToast('오류', '고객 정보가 필요합니다. 고객을 선택하거나 신규 고객 정보를 입력해주세요.', 'error');
            return; // 함수 실행 중단
        }

        // 판매지점이 선택되었는지 확인
        if (!this.selectedAccountId) {
            this.showToast('오류', '판매지점을 선택해주세요.', 'error');
            return; // 함수 실행 중단
        }

        // 상담내용이 입력되었는지 확인
        if (!this.inquiryDetails || this.inquiryDetails.trim() === '') {
            this.showToast('오류', '상담내용을 입력해주세요.', 'error');
            return; // 함수 실행 중단
        }


        // 상담 내용이 있으면 저장
        console.log('저장 ! this.selectedContactId / this.showCustomerInfo:', this.selectedContactId , this.showCustomerInfo, this.selectedAccountId);
        // apex클래스를 호출해서 상담내용저장
        insertPurchaseInquiry({
            accountId: this.selectedAccountId, // 부모컴포넌트를 통해 받은 판매지점 ID 
            contactId: this.selectedContactId,//고객 아이디
            inquiryDetails: this.inquiryDetails //상담 세부내용  
        })
            .then((result) => {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '성공',
                        message: '상담 내용이 저장되었습니다.',
                        variant: 'success'
                    })
                );
                console.log('insertPurchaseInquiry -result: '+ result);
                // navigate 함수를 호출하여 고객 레코드 페이지로 리디렉션
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.selectedContactId,
                        actionName: 'view'
                    }
                });

            })
            .catch((error) => {

                showToast('저장 실패', '오류가 발생했습니다: ' + error.body, error);

                // 오류 처리 로직
            });

    }//end of saveInquiry()

    // 오류 메시지를 표시하는 함수
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant, // 오류 메시지 스타일
            mode: 'dismissable' // 사용자가 닫을 수 있는 모드
        });
        this.dispatchEvent(event);
    }
}