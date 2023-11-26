import { LightningElement,track,wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import  saveDetails from '@salesforce/apex/searchScreen_cc.saveDetails';
import  validatePAN from '@salesforce/apex/searchScreen_cc.validatePAN';
import  checkPanStatus from '@salesforce/apex/searchScreen_cc.checkPanStatus';

export default class SearchScreen extends NavigationMixin(LightningElement) {
    
    counter = 10;
    loanId = '';
    loanAppId = '';
    isForm60Selected = false;
    isPanSelected = false;
    showIdentifier = true;
    searchClicked = false;
    isPANSuccessful = false;
    fields = ['mobile', 'dateOfBirth', 'typeOfIdentifier', 'typeOfValidDocument']
    @track wrapper = {}
    
    genericOnChange(event){
        this.wrapper[event.target.name] = event.target.value
    }
    get identifierOptions(){
        return [
            {
                label: 'None', value: ''
            },
            {
                label: 'PAN', value: 'PAN'
            },
            {
                label: 'FORM 60', value: 'FORM 60'
            }
        ];
     }

    get documentOptions(){
        return [
            {
                label: 'None', value: ''
            },
            {
                label: 'Aadhaar', value: 'aadhaar'
            },
            {
                label: 'Voter ID', value: 'voterId'
            },
            {
                label: 'Driving License', value: 'drivingLicense'
            }
        ];
     }
    
    get showProceed(){
        return (this.searchClicked && this.showIdentifier && this.counter <= 0) || this.isPANSuccessful;
    }

    handleIdentifierChange(event){
        this.genericOnChange(event)

        let value = event.target.value;
        
        if(value === 'FORM 60'){
            this.isForm60Selected = true;
            this.isPanSelected = false;
            this.showIdentifier = false;
        }
        else if(value === 'PAN'){
            this.isPanSelected = true;
            this.isForm60Selected = false;
            this.showIdentifier = true;
        }
        else if(value === 'drivingLicense'){
            this.showIdentifier = true;
        }
    }

    handleSearchClick(){
        if(this.validate()){
            this.searchClicked = true;
            const timer = setInterval(() => {
                if(this.counter <= 0){
                    clearInterval(timer)
                    let toastMsg = new ShowToastEvent({
                        title: 'Success',
                        message: 'Please click on proceed',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                    this.dispatchEvent(toastMsg)
                }
                else{
                    this.counter--;
                }
            }, 1000)
        }
        else{
            let toastMsg = new ShowToastEvent({
                title: 'Error',
                message: 'Please fill all the mandatory fields',
                variant: 'error',
                mode: 'dismissable'
            })
            this.dispatchEvent(toastMsg)
        }
        
    }
    
    handleValidatePAN(){

        if(this.wrapper.identifier === null || this.wrapper.identifier === undefined || this.wrapper.identifier === ''){
            let toastMsg = new ShowToastEvent({
                title: 'Error',
                message: 'Please fill all the mandatory fields',
                variant: 'error',
                mode: 'dismissable'
            })
            this.dispatchEvent(toastMsg)
        }
        else{
            validatePAN({data: JSON.stringify(this.wrapper)})
            .then(result=>{
                let data = JSON.parse(result);
                if(data.status === 'Success'){
                    this.loanId = data.loanId
                    let toastMsg = new ShowToastEvent({
                        title: 'Success',
                        message: 'PAN Validation started. Please wait',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                    this.dispatchEvent(toastMsg)
                    let panCounter = 3;
                    const panPoll = setInterval(() => {
                        panCounter --
                        if(panCounter <= 0 || this.isPANSuccessful){
                            clearInterval(panPoll)
                        }
                        this.panStatus()
                    }, 10000);
                }
                else{
                    let toastMsg = new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Occured. Data not saved',
                        variant: 'error',
                        mode: 'dismissable'
                    })
                    this.dispatchEvent(toastMsg)
                    console.log(error);
                }
            })
            .catch(error=>{
                let toastMsg = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error Occured',
                    variant: 'error',
                    mode: 'dismissable'
                })
                this.dispatchEvent(toastMsg)
                console.log(error);
            })
        }       

    }

    handleProceed(){

            saveDetails({data: JSON.stringify(this.wrapper)})
            .then(result =>{
                this.loanAppId = result
                let toastMsg = new ShowToastEvent({
                    title: 'Success',
                    message: 'Data saved successfully',
                    variant: 'success',
                    mode: 'dismissable'
                })
                this.dispatchEvent(toastMsg)
                
                this[NavigationMixin.Navigate]({
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__navigationDataProvider'
                    },
                    state: {
                        c__stage: 'QDE',
                        c__loanId: this.loanAppId
                    }
                })

            })
            .catch(error=>{
                alert('error')
                console.log(error)
            })
        
        
    }

    validate(){
        for(let ele of this.fields){
            console.log(ele + ' ' + this.wrapper[ele])
            if(this.wrapper[ele] === null || this.wrapper[ele] === '' || this.wrapper[ele] === undefined){
                return false
            }
        }

        if(this.isForm60Selected === true && this.wrapper['typeOfValidDocument'] === undefined){
            return false
        }

        return true
    }

    panStatus(){
        checkPanStatus({loanId : this.loanId})
        .then(resolve => {
            let data = resolve
            if(data != null || data != ''){
                data = JSON.parse(data)
                if(data.status === 'success'){
                    this.isPANSuccessful = true
                    this.isPanSelected = false
                    let toastMsg = new ShowToastEvent({
                        title: 'Success',
                        message: 'PAN Validation Successfull. Please proceed....',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                    this.dispatchEvent(toastMsg)
                }
                else{
                    let toastMsg = new ShowToastEvent({
                        title: 'Error',
                        message: 'PAN Validation Failed. Please retry...',
                        variant: 'error',
                        mode: 'dismissable'
                    })
                    this.dispatchEvent(toastMsg)
                }
            }
            else{
                let toastMsg = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error Occured...null data',
                    variant: 'error',
                    mode: 'dismissable'
                })
                this.dispatchEvent(toastMsg)
            }
        
        })
        .catch(resole=>{
            alert('error')
            console.log(error)
        })
    }

}