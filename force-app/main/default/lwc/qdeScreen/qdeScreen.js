import { LightningElement, track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import cancel from '@salesforce/apex/qdeScreen_cc.cancel';
import save from '@salesforce/apex/qdeScreen_cc.save';
import loadData from '@salesforce/apex/qdeScreen_cc.loadData';
import next from '@salesforce/apex/qdeScreen_cc.next';

export default class QdeScreen extends NavigationMixin(LightningElement) {

    @track wrapper = {};
    @api loanId;
    disable = false;

    renderedCallback(){
        loadData({loanId: this.loanId})
        .then(result=>{
            let data = JSON.parse(result)
            this.wrapper = data;
        })
        .then(()=>{
            let elements = this.template.querySelectorAll("lightning-input")
            let elements2 = this.template.querySelectorAll("lightning-combobox")

            elements.forEach((ele)=>{
                ele.value = this.wrapper[ele.name]
            })
            elements2.forEach((ele)=>{
                ele.value = this.wrapper[ele.name]
            })
        })
        .catch(error=>{
            console.log('connected call back error')
            console.log(error)
        })
        
    }
    
    genericOnChange(event){
        this.wrapper[event.target.name] = event.target.value;
    }

    get employmentTypeOptions(){
        return [
            {
                label: 'None', value: ''
            },
            {
                label: 'Self Employed', value: 'Self Employed'
            },
            {
                label: 'Salaried', value: 'Salaried'
            },
            {
                label: 'House Wife', value: 'House Wife'
            },
            {
                label: 'Pensioner', value: 'Pensioner'
            }
        ]
    }

    get genderOptions(){
        return [
            {
                label: 'None', value: ''
            },
            {
                label: 'Male', value: 'Male'
            },
            {
                label: 'Female', value: 'Female'
            },
            {
                label: 'Others', value: 'Others'
            }
        ]
    }

    validate(){
        return true;
    }

    handleCancel(){
        cancel({loanId: this.loanId})
        .then((result)=>{
            this.disable = true;
            this.showToast('Success', 'Loan Application Cancelled Successfully', 'success', 'dismissed');
        })
        .catch(error=>{
            console.log('cancel error')
            console.log(error);
            this.showToast('Error', 'Error Occured', 'error', 'dismissed')
        })
    }

    handleSave(){
        if(this.validate()){
            this.wrapper['loanId'] = this.loanId
            this.wrapper['address'] = this.wrapper['house'] + ' ' + this.wrapper['road'] + ' ' + this.wrapper['addressLine'] + ' ' + this.wrapper['landmark']
            let wrapperData = JSON.stringify(this.wrapper)
            save({data: wrapperData})
            .then(result=>{
                this.showToast('Success', 'Details Saved Successfully', 'success', 'dismissed');
            })
            .catch(error=>{
                console.log('save error')
                console.log(error);
                this.showToast('Error', 'Error Occured', 'error', 'dismissed')
            })
        }
        else{
            this.showToast('Error', 'Please Fill Mandatory Fields!', 'error', 'dismissed');
        }
    }

    handleNext(){
        if(this.validate()){
            this.wrapper['loanId'] = this.loanId
            this.wrapper['address'] = this.wrapper['house'] + ' ' + this.wrapper['road'] + ' ' + this.wrapper['addressLine'] + ' ' + this.wrapper['landmark']
            let wrapperData = JSON.stringify(this.wrapper)
            next({data: wrapperData})
            .then(result=>{
                this.loanId = result
                this.showToast('Success', 'Details Saved Successfully', 'success', 'dismissed');
                this[NavigationMixin.Navigate]({
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__navigationDataProvider'
                    },
                    state: {
                        c__stage: 'DDE',
                        c__loanId: this.loanId
                    }
                })
            })
            .catch(error=>{
                console.log('save error')
                console.log(error);
                this.showToast('Error', 'Error Occured', 'error', 'dismissed')
            })
        }
        else{
            this.showToast('Error', 'Please Fill Mandatory Fields!', 'error', 'dismissed');
        }
    }

    showToast(title, message, variant, mode){
        const toast = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(toast);
    }
}