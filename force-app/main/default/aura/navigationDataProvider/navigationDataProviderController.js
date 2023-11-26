({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var stage = myPageRef.state.c__stage;
        var loanId = myPageRef.state.c__loanId;
        component.set("v.stage", stage);
        component.set("v.loanApplicationId", loanId);
    }
})