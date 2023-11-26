public with sharing class searchScreen_cc {

    @AuraEnabled
    public static String saveDetails(String data){
        try{
            searchScreenWrapper wrapper = (searchScreenWrapper)JSON.deserialize(data, searchScreenWrapper.class);
            if(wrapper!=null){
                Loan_Application__c loan = new Loan_Application__c();
                loan.Mobile_Number__c = wrapper.mobile;
                loan.Type_Of_Personal_Identifier__c = wrapper.typeOfIdentifier;
                loan.Identifier_Number__c = wrapper.identifier;
                loan.Date_Of_Birth__c = wrapper.dateOfBirth;
                loan.Stage__c = 'QDE';
                loan.Sub_stage__c = 'QDE Pending';
                insert loan;

                return loan.Id;
            }
            return '';
        }
        catch(Exception e){
            System.debug('Error===>' + e);
            String errorMsg = e.getMessage();
            throw new AuraHandledException(errorMsg);
        }
        
    }

    @AuraEnabled
    public static string validatePAN(String data){
        try{
            searchScreenWrapper wrapper = (searchScreenWrapper)JSON.deserialize(data, searchScreenWrapper.class);
            if(wrapper!=null){

                Loan_Application__c loan = new Loan_Application__c();
                loan.Mobile_Number__c = wrapper.mobile;
                loan.Type_Of_Personal_Identifier__c = wrapper.typeOfIdentifier;
                loan.Identifier_Number__c = wrapper.identifier;
                loan.Date_Of_Birth__c = wrapper.dateOfBirth;
    
                insert loan;
                
                Integration_Message__c msg = new Integration_Message__c();
                msg.Status__c = 'New';
                msg.SVCName__c = 'JOCATA_NSDL_PAN';
                msg.Reference_Id__c = String.valueOf(loan.Id);
                
                insert msg;
                
                searchScreenWrapper.panStatus result = new searchScreenWrapper.panStatus();
                result.loanId = loan.Id;
                result.status = 'Success';

                return JSON.serialize(result);

            }
            return null;
        }
        catch(Exception e){
            System.debug('Error===>' + e);
            String errorMsg = e.getMessage();
            return errorMsg;
        }
    }

    @AuraEnabled
    public static string checkPanStatus(String loanId){
        try {
            
            Loan_Application__c loan = [Select Id, Identifier_Number__c, Pan_Validation__c From Loan_Application__c where Id =: loanId][0];
            if(loan != null){
                searchScreenWrapper.panStatus result = new searchScreenWrapper.panStatus();
                result.loanId = loan.Id;
                result.status = loan.Pan_Validation__c;
                result.identifier = loan.Identifier_Number__c;
                return JSON.serialize(result);
            }

            return '';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}