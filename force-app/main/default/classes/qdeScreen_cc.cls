public with sharing class qdeScreen_cc {

    @AuraEnabled
    public static string loadData(String loanId){
        try {
            Loan_Application__c loan = [Select ID, Requested_Loan_Amount__c, Applicant__r.Full_Name__c, Applicant__r.Mobile_Number__c, Applicant__r.Email__c, Applicant__r.Gender__c, Applicant__r.Employment_Type__c, Applicant__r.Date_Of_Birth__c, Applicant__r.Address__c from Loan_Application__c where Id =: loanId];
            
            return JSON.serialize(new qdeScreenWrapper(loan));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void cancel(String loanId){
        try {
            Loan_Application__c loan = [Select ID, Stage__c, Sub_stage__c from Loan_Application__c where Id =: loanId limit 1];
            loan.Stage__c = 'Cancel';
            loan.Sub_stage__c = 'Sales Cancel';
            update loan;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled
    public static void save(String data){
        try {
            
            qdeScreenWrapper wrapper = (qdeScreenWrapper)JSON.deserialize(data, qdeScreenWrapper.class);
            Loan_Application__c loan = [Select Id, Requested_Loan_Amount__c from Loan_Application__c where Id =: wrapper.loanId limit 1];
            loan.Requested_Loan_Amount__c = wrapper.loanAmount;

            Applicant__c app = new Applicant__c();
            app.Full_Name__c = wrapper.name;
            app.Mobile_Number__c = wrapper.mobile;
            app.Email__c = wrapper.email;
            app.Gender__C = wrapper.gender;
            app.Employment_Type__c = wrapper.employmentType;
            app.Date_Of_Birth__c = wrapper.dateOfBirth;
            app.Address__c = wrapper.address;
            app.Loan_Application__c = loan.Id;
            insert app;

            loan.Applicant__c = app.Id;
            update loan;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String next(String data){
        try {
            qdeScreenWrapper wrapper = (qdeScreenWrapper)JSON.deserialize(data, qdeScreenWrapper.class);
            Loan_Application__c loan = [Select Id, Requested_Loan_Amount__c from Loan_Application__c where Id =: wrapper.loanId limit 1];
            loan.Requested_Loan_Amount__c = wrapper.loanAmount;

            Applicant__c app = new Applicant__c();
            app.Full_Name__c = wrapper.name;
            app.Mobile_Number__c = wrapper.mobile;
            app.Email__c = wrapper.email;
            app.Gender__C = wrapper.gender;
            app.Employment_Type__c = wrapper.employmentType;
            app.Date_Of_Birth__c = wrapper.dateOfBirth;
            app.Address__c = wrapper.address;
            app.Loan_Application__c = loan.Id;
            insert app;

            loan.Applicant__c = app.Id;
            loan.Stage__c = 'DDE';
            loan.Sub_Stage__c = 'DDE Pending';
            update loan;

            return loan.Id;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}