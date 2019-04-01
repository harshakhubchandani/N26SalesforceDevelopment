({
	handleRecordLoading: function(component, event, helper) {
		var eventParams = event.getParams();
		if(eventParams.changeType === "LOADED") {
			if(!$A.util.isUndefinedOrNull(component.get("v.caseDetails.Contact.Product__r"))){                	
				component.set("v.hasProduct",'one');
			}
		}
	}	
})