import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CASE_Description__c_FIELD from '@salesforce/schema/Case.Description__c';
import updateCaseEmailContent from '@salesforce/apex/CaseController.updateCaseEmailContent';
import closeCase from '@salesforce/apex/CaseController.closeCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class VoCClosedModal extends LightningElement {

    @api recordId; // 현재 Case의 record ID
    @track isModalOpen = false;
    emailContent = '';
    addText ='// 고객에게 보낼 이메일을 작성하세요';
    caseRecord;
    @track richTextValue = '';


    @wire(getRecord, { recordId: '$recordId', fields: [CASE_Description__c_FIELD] })
    caseRecord;

    get description() {
        return this.caseRecord.data ? getFieldValue(this.caseRecord.data, CASE_Description__c_FIELD) : '';
    }
    get myformats() {
        return ['font', 'size', 'bold', 'italic', 'underline', 'strike', 'list', 'indent', 'align', 'link', 'image', 'clean', 'table', 'header'];
    }
    openModal() {
        this.isModalOpen = true;
        this.emailContent = this.description;
        console.log('emailContent: '+ this.emailContent);
        
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleContentChange(event) {
        this.emailContent = event.target.value;
    }

    showError(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            })
        );
    }

    showSuccess(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: message,
                variant: 'success',
                mode: 'dismissable'
            })
        );
    }
    


        sendEmail() {
            // Apex메서드를 통해서 email_content field 업데이트
            updateCaseEmailContent({ caseId: this.recordId, emailContent: this.emailContent })
                .then(() => {
                    console.log('updateCaseEmailContent successful');
                    
                    //Apex메서드를 통해서  status = closed 로 변경
                    return closeCase({ caseId: this.recordId });
                })
                .then(() => {
                    //이메일 전송은 trigger를 통해서 처리됨.
                    this.showSuccess('이메일이 성공적으로 전송되었습니다');
                })
                .catch(error => {
                    this.showError(error);
                    console.log('Error in process:', error);
                })
                .finally(() => {
                    this.closeModal();
                    location.reload();
                });
            }






}