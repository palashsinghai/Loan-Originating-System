trigger IntegrationMessageTrigger on Integration_Message__c (before insert, after insert, before update, after update) {

    if(trigger.isAfter){
        if(trigger.isInsert){
            for(Integration_Message__c msg: trigger.new){
                if(msg.Status__c == 'New' && msg.SVCName__c == 'JOCATA_NSDL_PAN'){
                    OutboundCallout.requestPanValidation(msg.Id);
                }
            }
        }
    }
    if(trigger.isBefore){
        if(trigger.isUpdate){
            
            Map<Id, Loan_Application__c> loanvsId = new Map<Id, Loan_Application__c>();
            List<Loan_Application__c> loans = new List<Loan_Application__c>();

            for(Loan_Application__c loan: [Select Id, Pan_Validation__c, Identifier_Number__c from Loan_Application__c]){
                loanvsId.put(loan.Id, loan);
            }

            for(Integration_Message__c msg: trigger.new){
                if(msg.Status__c == 'Responded' && msg.SVCName__c == 'JOCATA_NSDL_PAN'){
                    searchScreenWrapper.panValidationResponse wrapper = (searchScreenWrapper.panValidationResponse)JSON.Deserialize(msg.Response__c, searchScreenWrapper.panValidationResponse.class);
                    Loan_Application__c loan = loanvsId.get(msg.Reference_Id__c);
                    if(wrapper.panValid == 'pass'){
                        loan.Pan_Validation__c = 'success';
                    }
                    else{
                        loan.Pan_Validation__c = 'failed';
                    }
                    
                    loan.Identifier_Number__c = wrapper.identifier;
                    loans.add(loan);
                }
            }
            update loans;
        }
    }    
}