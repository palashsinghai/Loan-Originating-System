public with sharing class OutboundCallout {
    public static String createCase() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:PAN_Validation/services/apexrest/validatepan');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody('{"accName": "palash"}');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            System.debug('Id---> ' + response.getBody());
            return response.getBody();
            /*// Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // Cast the values in the 'animals' key as a list
            List<Object> animals = (List<Object>) results.get('animals');
            System.debug('Received the following animals:');
            for(Object animal: animals) {
                System.debug(animal);
            }*/
        }
        system.debug('status=> '+response.getStatusCode());
        return 'error';
    }

    @future (callout=true)
    public static void requestPanValidation(String Id) {

        Integration_Message__c msg = [Select Id, Reference_Id__c From Integration_Message__c where Id =: Id];
        Loan_Application__c loan = [Select Id, Date_Of_Birth__c, Mobile_Number__c, Identifier_Number__c, Type_Of_Personal_Identifier__c from Loan_Application__c where Id =: msg.Reference_Id__c][0];
        
        searchScreenWrapper.panValidationRequest wrapper = new searchScreenWrapper.panValidationRequest();
        wrapper.loanId = loan.Id;
        wrapper.typeOfIdentifier = loan.Type_Of_Personal_Identifier__c;
        wrapper.mobile = loan.Mobile_Number__c;
        wrapper.dateOfBirth = loan.Date_Of_Birth__c;
        wrapper.identifier = loan.Identifier_Number__c;

        //String requestBody = '{ "data" :  ' + JSON.serialize(wrapper) + '}';
        String requestBody = JSON.serialize(wrapper);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:PAN_Validation/services/apexrest/validatepan');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(requestBody);
        //request.setBody('{"data":"jhgjhg"}');
        HttpResponse response = http.send(request);

        msg.Request__c = requestBody;
        system.debug('response ==> ' + response.getBody());
        if(response.getStatusCode() == 200) {
            msg.Status__c = 'Responded';
            msg.Response__c = response.getBody();
        }
        else{
            msg.Status__c = 'Failed';
            msg.Error_Message__c = response.getStatusCode() + ' '+ response.getBody();
        }

        update msg;
    }
}