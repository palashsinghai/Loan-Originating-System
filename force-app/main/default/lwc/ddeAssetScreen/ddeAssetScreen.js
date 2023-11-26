import { LightningElement, api } from 'lwc';

export default class DdeAssetScreen extends LightningElement {
    @api
    loanId
    wrapper = {}

    genericOnChange(event){
        this.wrapper[event.target.name] = event.target.value
    }

    onClearClick(){
        
    }
}