public with sharing class qdeScreenWrapper {
    
    @AuraEnabled
    public String loanId{get; set;}
    @AuraEnabled
    public String loanAmount{get; set;}
    @AuraEnabled
    public String name{get; set;}
    @AuraEnabled
    public Date dateOfBirth{get; set;}
    @AuraEnabled
    public String email{get; set;}
    @AuraEnabled
    public String mobile{get; set;}
    @AuraEnabled
    public String employmentType{get; set;}
    @AuraEnabled
    public String gender{get; set;}
    @AuraEnabled
    public String address{get; set;}

    public qdeScreenWrapper(Loan_Application__c loan){

        this.loanId = loan.Id;
        this.loanAmount = loan.Requested_Loan_Amount__c;
        this.name = loan.Applicant__r.Full_Name__c;
        this.dateOfBirth = loan.Applicant__r.Date_Of_Birth__c;
        this.email = loan.Applicant__r.Email__c;
        this.mobile = loan.Applicant__r.Mobile_Number__c;
        this.employmentType = loan.Applicant__r.Employment_Type__c;
        this.gender = loan.Applicant__r.Gender__c;
        this.address = loan.Applicant__r.Address__c;
    }
    
}