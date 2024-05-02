import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import findContactByPhone from '@salesforce/apex/ContactController.findContactByPhone';
import getOrderedProductsByContactId from '@salesforce/apex/ContactController.getOrderedProductsByContactId';
import getCaseRecordsByContactId from '@salesforce/apex/CaseController.getCaseRecordsByContactId';
import { NavigationMixin } from 'lightning/navigation';
export default class VocSearchContacts extends NavigationMixin(LightningElement) {


    @track phoneNumber;
    @track contactId; //선택된 고객의 id를 저장할 변수
    @track contactData; // 고객 데이터를 저장할 배열
    @track orderedProducts; //고객이 가진 제품목록을 저장할 배열
    @track caseData; // 고객의 Case 상담내역을 저장할 배열
    @track hasFindContactResult = true;//고객검색결과
    @track isModalOpen = false; //모달창 제어 변수
    contactResultCount = 0;
    columns = [
        { label: '고객명', fieldName: 'Name', type: 'text', class: 'center-align' },
        { label: '고객번호', fieldName: 'Phone', type: 'phone' },
        { label: '고객등급', fieldName: 'Tier', type: 'text' },
        { label: '총구매액', fieldName: 'TotalSum', type: 'currency' },
        { label: '상담횟수', fieldName: 'Case_Count__c', type: 'Number', class: 'center-align' },
        {
            type: 'button',
            typeAttributes: {
                label: '상세',  // 버튼에 표시될 텍스트
                name: 'view_product',   // 이 버튼과 관련된 액션 이름
                title: 'View product',
                variant: 'brand'        // (선택사항) 버튼 스타일
            }
        },
        {//'선택'버튼 => 동적으로 랜더링
            type: 'button',
            typeAttributes: {
                label: { fieldName: 'selectButtonLabel' },
                iconName: { fieldName: 'selectButtonIcon' },
                name: 'view_details',
                title: 'View Details',
                variant: { fieldName: 'selectButtonVariant' },
                class: 'center-align'
            }
        }
    ];




    // 오류 메시지를 표시하는 함수
    showErrorMessage(title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error', // 오류 메시지 스타일
            mode: 'dismissable' // 사용자가 닫을 수 있는 모드
        });
        this.dispatchEvent(event);
    }
    /**SELECT  Id, 
            Product__c,  
            Product__r.Name,  
            Product__r.Price__c,  
            Quantity__c, //수량
            Order__r.Total_Amount__c ,
            Order__r.start_Date__c //주문일자
        FROM Ordered_Product__c
*/


    connectedCallback() {
        console.log('connectedCallback()');
        this.phoneNumber = '';
        // 페이지 로딩 시 자동으로 모든 연락처 검색
        this.handleSearch();
    }


    //전화번호 입력 필드 onChange 핸들러
    handlePhoneChange(event) {
        this.phoneNumber = event.target.value;
        console.log(this.phoneNumber);
    }

    //검색버튼 클릭시에 실행되는 핸들러
    handleSearch() {

        console.log('handleSearch()');
        findContactByPhone({ phone: this.phoneNumber })
            .then(result => {

                if (result && result.length > 0) {
                    // 전화번호에 해당하는 고객 정보를 contactData 배열에 저장
                    this.contactData = result.map(contact => ({
                        Id: contact.Id,
                        Name: contact.Name,
                        Phone: contact.Phone,
                        Tier: contact.Tier__c,
                        TotalSum: contact.Total_Sum__c,
                        Case_Count__c: contact.Case_Count__c,
                        selectButtonLabel: '선택', //버튼 기본 설정 초기화
                        selectButtonVariant: 'brand'//버튼 기본 설정 초기화

                    }));
                    this.contactResultCount = result.length;

                    // 기존에 선택된 고객 정보와 관련된 제품정보와 상담내역 데이터 초기화
                    this.orderedProducts = null;
                    this.caseData = null;
                    this.hasFindContactResult = true; //프론트에서 '고객이 존재하지 않습니다'를 표시하기 위함.
                } else {// 검색 결과가 없는 경우, 모든 데이터 초기화
                    this.contactData = null;
                    this.orderedProducts = null;
                    this.caseData = null;

                    this.hasFindContactResult = false; //프론트에서 '고객이 존재하지 않습니다'를 표시하기 위함.
                }
            })
            .catch(error => {
                console.error('오류:', error);
                this.contactData = null;
                this.orderedProducts = null;
                this.caseData = null;

                this.showErrorMessage('검색 실패', '고객 검색 중 오류가 발생했습니다. error:' + error);
            });
    }





    @track selectedRowId = null; // '선택'된 행의 ID를 추적하기 위한 변수

    // 고객 선택시 이벤트 핸들러
    handleContactSelect(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        // 선택된 행의 ID를 업데이트
        this.selectedRowId = row.Id;

        // contactData 배열을 반복하면서 현재 선택된 행과 비교
        this.contactData = this.contactData.map(contact => {
            if (contact.Id === this.selectedRowId) {
                return { ...contact, selectButtonLabel: '선택', selectButtonIcon: null, selectButtonVariant: 'success' };
            } else {
                return { ...contact, selectButtonLabel: '선택', selectButtonIcon: null, selectButtonVariant: 'brand' };
            }
        });

        switch (action.name) {
            // 'View Details' 버튼 클릭 시
            case 'view_details':
                console.log('Selected Contact - ID: ' + row.Id + ', Name: ' + row.Name);
                this.contactId = row.Id; // 선택된 고객의 ID 저장

                //이벤트 디스패치 - 선택된 고객명과 고객이름과 폰번호를 voc상담기록 컴포넌트에 보내기 위함 
                this.dispatchEvent(new CustomEvent('contactselect', {
                    detail: { contactId: row.Id, contactName: row.Name, contactPhone: row.Phone },
                    bubbles: true
                }));
                //초기화
                this.dispatchEvent(new CustomEvent('productselect', {
                    detail: "",
                    bubbles: true
                }));

                // Apex 메서드를 호출하여 선택된 고객의 주문된 제품 목록을 조회
                getOrderedProductsByContactId({ contactId: this.contactId })
                    .then(orderedProductsResult => {


                        if (orderedProductsResult && orderedProductsResult.length > 0) {
                            // 조회된 주문된 제품 정보를 orderedProducts 배열에 저장
                            this.orderedProducts = orderedProductsResult.map(prod => ({
                                orderedProductId: prod.Id,
                                ProductId: prod.Product__r.Id,
                                ProductName: prod.Product__r.Name,
                                ProductPrice: prod.Product__r.Price__c,
                                Quantity: prod.Quantity__c,
                                TotalAmount: prod.Order__r.Total_Amount__c,
                                OrderDate: prod.Order__r.Start_Date__c,
                                accountName: prod.Order__r.Account_Name__c

                            }));
                            console.log('orderedProductsResult: ' + JSON.stringify(orderedProductsResult));
                        }

                        if (JSON.stringify(orderedProductsResult) == '[]' || orderedProductsResult.length == 0) {
                            this.orderedProducts = false; //프론트에서 '보유제품이 없습니다'를 표시하기 위함.
                        }
                    })//end of then
                    .catch(error => {
                        console.error('handleContactSelect - getOrderedProductsByContactId Error:', error);
                        this.showErrorMessage('조회 실패', '고객의 제품목록을 가져오는 중 오류가 발생했습니다. error:' + error);
                    });

                //  Apex 메서드를 호출하여 선택된 고객의 Case 상담내역을 조회
                getCaseRecordsByContactId({ contactId: this.contactId })
                    .then(data => {
                        // 조회된 Case 상담내역을 caseData 배열에 저장
                        this.caseData = data.map(record => {
                            let formattedDate = this.formatDate(record.Date__c); // 상담날짜 변환 로직
                            return {
                                ...record,
                                formattedDate: formattedDate, // 변환된 날짜를 새 필드에 저장
                                headerClass: this.getHeaderClass(record.Type) // 여기서 headerClass를 계산하여 추가
                            };
                        });

                        if (JSON.stringify(data) == '[]') {
                            this.caseData = false; //프론트에서 '상담내역이 없습니다'를 표시하기 위함.
                        }
                    })
                    .catch(error => {
                        console.error('Case Records Error - getCaseRecordsByContactId:', error);
                        this.showErrorMessage('조회 실패', '고객의 VoC내역을 가져오는 중 오류가 발생했습니다. error:' + error);

                    });
                break;
            case 'view_product':

                // navigate 함수를 호출하여 레코드 페이지로 리디렉션
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'view'
                    }
                });
                break;


        }



    }//end of handleContactSelect

    //제품 클릭 이벤트 핸들러
    handleProductSelect(event) {
        const dataset = event.currentTarget.dataset;
        const orderedProductId = dataset.id; // Ordered_Product__c 레코드의 ID
        const productId = dataset.productid; // Product__c 레코드의 ID
        const productName = dataset.name; // 제품 이름
        const accountName = dataset.accountname; // 판매 지점 이름

        //  console.log('handleProductSelect - '+ 'this.orderedProducts: '+JSON.stringify(this.orderedProducts)+ 'AccountName:'+accountname);
        console.log('dataset:', JSON.stringify(event.currentTarget.dataset));
        // 이벤트를 통해 제품 정보 전달
        this.dispatchEvent(new CustomEvent('productselect', {
            detail: { orderedProductId, productId, productName, accountName },
            bubbles: true
        }));


    }//end of handleProductSelect


    //케이스 상세내역 더보기 핸들러
    handleViewMoreDetails(event) {
        // 이벤트에서 Case 레코드 ID 추출
        const caseId = event.currentTarget.dataset.id;

        // Case 레코드 페이지로 리다이렉트
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                actionName: 'view'
            }
        });
    }



    //모달창 제어 함수들
    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    //상담내역탭 스타일 관련 코드
    // Type에 따른 css 클래스를 반환하는 메서드
    getHeaderClass(type) {
        switch (type) {
            case '구매상담':
                return 'purchase-consultation';
            case 'VoC':
                return 'voc-consultation';
            default:
                return 'default-header';
        }
    }


    // 날짜 및 시간을 "YYYY-MM-DD HH:mm:ss" 형식으로 변환하는 함수
    formatDate(dateString) {
        const date = new Date(dateString);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작하므로 1을 더해줌
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        //const seconds = String(date.getSeconds()).padStart(2, '0');
        return `${year}-${month}-${day} ${hours}:${minutes}`;
    }

}