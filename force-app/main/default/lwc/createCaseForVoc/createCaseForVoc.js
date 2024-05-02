// createCaseForVoc.js
import { LightningElement, api, track } from 'lwc';
import createCaseForVoC from '@salesforce/apex/CaseController.createCaseForVoC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CreateCaseForVoc extends LightningElement {
    //@api 데코레이터: 부모 컴포넌트로부터 데이터를 받기
    //CreateCaseForVoc 컴포넌트의 부모 컴포넌트인 ParentComponent로부터 데이터받음
    @api orderedProductId; // 부모 컴포넌트로부터 받은 주문된 제품 ID
    @api productId; // 외부에서 설정될 제품 ID
    @api productName; // 외부에서 설정될 제품 ID
    @api contactName; // 외부에서 설정될 고객명
    @api contactId; // 외부에서 설정될 고객명
    @api accountName; // 외부에서 설정될 판매지점
    @track description; // VoC 상담 내용
    selectedProduct; // 선택된 제품명


    get myformats() {
        return ['font', 'size', 'bold', 'italic', 'underline', 'strike', 'list', 'indent', 'align', 'link', 'image', 'clean', 'table', 'header'];
    }

            // 오류 메시지를 만드는 함수
            showErrorMessage(title, msg) {
                const event = new ShowToastEvent({
                    title: title,
                    message: msg,
                    variant: 'error', // 메시지 스타일
                    mode: 'dismissable' // 사용자가 닫을 수 있는 모드
                });
                this.dispatchEvent(event);

            }
            // 성공 메시지를 표시하는 함수
            showSuccessMessage(title, msg) {
                const event = new ShowToastEvent({
                    title: title,      // 제목
                    message: msg,  // 메시지 내용
                    variant: 'success', // 메시지 스타일
                    mode: 'dismissable' // 사용자가 닫을 수 있는 모드
                });
                this.dispatchEvent(event);
        }

        
    // VoC상담 내용 가져오는 핸들러
    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    // 저장 버튼 핸들러
    handleSave() {
        if (!this.validateFields()) {
            return; // 검증이 실패하면 저장 중지
        }
        console.log('CreateCaseForVoc.js - this.orderedProductId : '+ this.orderedProductId);
        // apex클래스를 통해 CaseForVoC 레코드 생성 로직
        createCaseForVoC({
            orderedProductId: this.orderedProductId, // 주문된 제품 ID 전달
            productId: this.productId,
            productName: this.productName,
            contactName: this.contactName,
            contactId: this.contactId,
            description: this.description,
            accountName: this.accountName
        })
        .then(result => {

            // 성공
            console.log('CaseForVoC 레코드 생성: ', result);
            this.showSuccessMessage('저장 성공','VoC 내역이 저장되었습니다.');
          
             //저장 후 리프래시하는 이벤트 발생시키기
            this.dispatchEvent(new CustomEvent('refresh', { 
                bubbles: true, 
                detail: { result } // 여기에 result를 포함시킵니다.
            }));

            
        })
        .catch(error => {
            // 에러
            console.error('CaseForVoC 레코드 생성 Error: ', error);
            this.showErrorMessage('저장 실패', 'VoC 내역 저장 중 오류가 발생했습니다. error:'+ error);
        });

    }//end of handleSave

   //필드가 비어있으면 토스트 메시지를 표시하는 메서드
   validateFields() {
    let isValid = true; // 기본적으로 유효하다고 가정
    let missingFields = [];
    let message = '';

    if (!this.orderedProductId) missingFields.push('제품');
    if (!this.contactName) missingFields.push('고객명');
    
    if (missingFields.length > 0) {
        message += `${missingFields.join(', ')}을 선택해주세요. `;
        isValid = false; // 누락된 필드가 있으면 유효하지 않음
    }

    // description 필드 검증 추가
    if (!this.description) {
        message += '상담 내용을 작성해주세요.';
        isValid = false; // description이 비어 있으면 유효하지 않음
    }
    
    // 필드가 누락되었거나, description이 비어있으면 에러 메시지 표시
    if (!isValid) {
        this.showErrorMessage('필수 필드 누락', message);
    }
    
    return isValid; // 모든 검증을 통과했다면 true를 반환
}

}