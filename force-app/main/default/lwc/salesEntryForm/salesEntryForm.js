import { LightningElement, wire, api } from 'lwc';
import getProductFamilies from '@salesforce/apex/SalesEntryController.getProductFamilies';
import getProductsByFamily from '@salesforce/apex/SalesEntryController.getProductsByFamily';
import createOrder from '@salesforce/apex/SalesEntryController.createOrder';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import getUserProfileName from '@salesforce/apex/ProfileChecker.getUserProfileName';

const FIELDS = ['Contact.Id'];

export default class SalesEntryForm extends NavigationMixin(LightningElement) {
    @api recordId; // 현재 페이지의 레코드 ID를 받기 위한 public property
    _contactId; // 내부적으로 사용할 연락처 ID를 저장하기 위한 private property
    selectedProductId; // 사용자가 선택한 제품 ID
    quantity = 1; // 선택한 제품의 수량, 기본값은 1
    discountPercent = 0; // 할인율, 기본값은 0
    productOptions = []; // 드롭다운에 보여줄 제품 목록
    cartItems = []; // 추가된 제품 목록
    productFamilyOptions = []; // 제품군 선택을 위한 옵션
    selectedProductFamily; // 선택된 제품군
    isSalesProfile = false;


    // contactId의 getter와 setter
    // 외부에서 contactId 값을 변경할 때 자동으로 호출되어 내부 _contactId 값을 업데이트
    @api
    get contactId() {
        return this._contactId;
    }
    set contactId(value) {
        this._contactId = value;
    }

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

    @wire(getProductFamilies)
    wiredProductFamilies({ error, data }) {
        if (data) {
            this.productFamilyOptions = data; // 직접적으로 맵핑 필요 없이 할당
        } else if (error) {
            console.error('Error fetching product families:', error);
        }
    }

    // 현재 페이지의 Contact 레코드를 가져오는 wire 서비스
    // 레코드 ID를 사용하여 연락처 정보를 검색하고, 해당 정보를 contactId property에 저장
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredContact({ error, data }) {
        if (data) {
            this.contactId = getFieldValue(data, 'Contact.Id');
        } else if (error) {
            console.error('Error retrieving contact record', error);
        }
    }

    handleProductFamilyChange(event) {
        this.selectedProductFamily = event.detail.value;
        getProductsByFamily({ familyName: this.selectedProductFamily })
            .then(data => {
                this.productOptions = data; // 직접적으로 맵핑 필요 없이 할당
            })
            .catch(error => {
                console.error('Error fetching products by family:', error);
            });
    }
    

    

    // 제품 선택 드롭다운의 변경을 처리하는 핸들러
    handleProductChange(event) {
        this.selectedProductId = event.detail.value;
    }

    // 수량 입력 필드의 변경을 처리하는 핸들러
    handleQuantityChange(event) {
        this.quantity = parseInt(event.target.value, 10);
    }

    // 할인율 입력 필드의 변경을 처리하는 핸들러
    handleDiscountPercentChange(event) {
        this.discountPercent = parseFloat(event.target.value);
    }

    handleDeleteItem(event) {
        const index = event.currentTarget.dataset.id; // 삭제 버튼의 data-id 속성을 통해 인덱스를 얻음
        this.cartItems.splice(index, 1); // 해당 인덱스의 항목을 배열에서 제거
        this.cartItems = [...this.cartItems]; // 변경 사항을 반영하기 위해 배열을 다시 할당
    }

    // "제품 추가" 버튼 클릭 시 호출되는 메서드
    // 선택한 제품과 수량을 cartItems 배열에 추가
    addToCart() {
        const selectedProduct = this.productOptions.find(product => product.value === this.selectedProductId);
        if (selectedProduct) {
            // 카트에서 현재 선택된 제품 찾기
            const existingItemIndex = this.cartItems.findIndex(item => item.productId === this.selectedProductId);
    
            if (existingItemIndex !== -1) {
                // 제품이 이미 카트에 있으면, 수량을 업데이트
                this.cartItems[existingItemIndex].quantity += this.quantity;
                // UI를 업데이트하기 위해 배열을 새로 할당
                this.cartItems = [...this.cartItems];
            } else {
                // 제품이 카트에 없으면, 새 항목으로 추가
                this.cartItems.push({
                    productId: this.selectedProductId,
                    productName: selectedProduct.label,
                    quantity: this.quantity
                });
            }
        } else {
            // 제품 선택이 유효하지 않은 경우 경고
            alert('제품을 선택하세요.');
        }
        
        // 제품을 추가한 후 선택한 제품과 수량을 기본값으로 초기화
        this.selectedProductId = null;
        this.quantity = 1;
    }

    // "주문 생성" 버튼 클릭 시 호출되는 메서드
    // cartItems 배열에 담긴 제품 정보와 할인율을 사용하여 주문을 생성
    createOrder() {
        if (this.cartItems.length > 0) {
            createOrder({
                contactId: this.contactId,
                productIds: this.cartItems.map(item => item.productId),
                quantities: this.cartItems.map(item => item.quantity),
                discountPercent: this.discountPercent
            })
            .then(orderId => {
                // 할인율 체크 로직을 유지합니다.
                if (this.discountPercent > 20) {
                    alert('입력한 할인율이 최대 할인율을 초과하여 20%로 적용됩니다.');                    
                } else if(this.discountPercent < 0){
                    alert('입력한 할인율이 0% 미만으로 0%로 적용됩니다.');
                }
                // 성공 메시지 표시
                // alert('주문이 성공적으로 생성되었습니다.');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '주문 생성 완료',
                        message: '주문이 성공적으로 생성되었습니다.',
                        variant: 'success'
                    })
                );
                // 리디렉트 로직
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: orderId,
                        actionName: 'view'
                    },
                });
                // 주문 생성 후 추가된 제품 목록과 할인율 초기화
                this.cartItems = [];
                this.discountPercent = 0;                
            })
            .catch(error => {
                alert('주문 생성에 실패했습니다. 오류: ' + (error.body ? error.body.message : 'Unknown Error'));
            });
        } else {
            alert('제품을 추가하고 수량을 올바르게 입력해주세요.');
        }
    }
    
}