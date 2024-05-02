import { LightningElement, track } from 'lwc';
import getAllAccounts from '@salesforce/apex/CaseController.getAllAccounts';
import getUserRoleName from '@salesforce/apex/CaseController.getUserRoleName';

export default class AccountSelector extends LightningElement {
    @track selectedAccountId;
    @track accountOptions = [];
    @track userRole;

    // 컴포넌트가 로드될 때 호출됩니다.
    connectedCallback() {
        getUserRoleName()
            .then(roleName => {
                this.userRole = roleName;
                // 사용자 역할을 로드한 후 계정 정보를 로드합니다.
                this.loadAccounts();
            })
            .catch(error => {
                console.error('Error retrieving user role:', error);
            });
    }

    // 계정 정보를 로드하는 메서드입니다.
    loadAccounts() {
        getAllAccounts()
            .then(data => {
                this.processAccounts(data);
            })
            .catch(error => {
                console.error('getAllAccounts Error', error);
            });
    }

    // 로드된 판매점 정보를 처리하고 사용자 역할에 따라 선택 가능한 계정만 배열에 포함시킴
    processAccounts(accounts) {
        // 사용자 역할과 일치하는 계정만 필터링하여 accountOptions에 추가
        this.accountOptions = accounts.reduce((filtered, account) => {
            if (!this.userRole || account.Name === this.userRole) {
                filtered.push({
                    label: account.Name,
                    value: account.Id
                });
            }
            return filtered;
        }, []);

        // 사용자 역할에 기반하여 계정을 자동으로 선택합니다.
        this.autoSelectAccountBasedOnUserRole();
    }


    // 사용자 역할과 일치하는 계정을 자동으로 선택
    autoSelectAccountBasedOnUserRole() {
        // roleName이 없는 경우, 모든 옵션은 사용 가능하며, 자동 선택은 적용되지 않음
        if (this.userRole) {
            const matchingAccount = this.accountOptions.find(account => account.label === this.userRole && !account.disabled);
            if (matchingAccount) {
                this.selectedAccountId = matchingAccount.value;
            }
            // 선택된 계정 ID를 부모 컴포넌트로 전달합니다.
            const selectedEvent = new CustomEvent('accountchange', { detail: this.selectedAccountId });
            this.dispatchEvent(selectedEvent);
        }
        }
        
    

    // 콤보박스에서 계정을 선택할 때 호출
    handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        // 선택된 계정 ID를 부모 컴포넌트로 전달합니다.
        const selectedEvent = new CustomEvent('accountchange', { detail: this.selectedAccountId });
        this.dispatchEvent(selectedEvent);
    }
}