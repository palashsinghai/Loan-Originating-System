public with sharing class searchScreenWrapper {

        @AuraEnabled
        public String mobile{get; set;}
        @AuraEnabled
        public Date dateOfBirth{get; set;}
        @AuraEnabled
        public String typeOfIdentifier{get; set;}
        @AuraEnabled
        public String typeOfValidDocument{get; set;}
        @AuraEnabled
        public String identifier{get; set;}

        public class panStatus {
                @AuraEnabled
                public String status{get; set;}
                @AuraEnabled
                public String loanId{get; set;}
                @AuraEnabled
                public String identifier{get; set;}
        }
        
        public class panValidationRequest {
                @AuraEnabled
                public String typeOfIdentifier{get; set;}
                @AuraEnabled
                public String loanId{get; set;}
                @AuraEnabled
                public String identifier{get; set;}
                @AuraEnabled
                public String mobile{get; set;}
                @AuraEnabled
                public Date dateOfBirth{get; set;}
        }
        public class panValidationResponse{
                @AuraEnabled
                public String typeOfIdentifier{get; set;}
                @AuraEnabled
                public String loanId{get; set;}
                @AuraEnabled
                public String identifier{get; set;}
                @AuraEnabled
                public String panValid{get; set;}

        }
}