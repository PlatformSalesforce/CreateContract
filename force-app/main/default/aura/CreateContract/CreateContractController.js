({
    handleClick : function(cmp, evt, hlp) {
     var changeValue = evt.getParam("value");
     console.log('radio Option--'+cmp.get('v.value')); 
        if(cmp.get('v.value') == 'option1') {
            if(cmp.get('v.selectedValue')== 'None'){
                   var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Required',
                            message: "Please select contact.",
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
        			toastEvent.fire();
            }
            hlp.apex(cmp,'postMethod',{recordId : cmp.get('v.selectedValue') })
            .then(function(result){	
                console.log('Call 1 : ' , result );
                let msg = cmp.get('v.msg');
                let response =  JSON.parse(result);
                cmp.set("v.variable1", true );
                cmp.set("v.msg", response.model.contractRequestQueueId );
                console.log('result.contractRequestQueueId response--'+typeof response +'#-'+response.model.contractRequestQueueId);
                return hlp.apex(cmp,'getMethod',{reqNum : response.model.contractRequestQueueId});
            })
            .then(function(result){
                console.log('Call 2.. : ' ,JSON.parse(result) );
                 let response =  JSON.parse(result);
                return hlp.apex(cmp,'updateContact',{ contactId : cmp.get('v.selectedValue'), conReqQ : cmp.get("v.msg"), wp:response.model,notes: cmp.get('v.notes')});
                
            })
            .then(function (result){
                console.log('Call 3.. : ' ,JSON.parse(result) );
                var close = true;
                return hlp.apex(cmp,'forceCloseQA',{});
             	  
             })
            
        }
    },
  	handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        cmp.set("v.value",changeValue);
    },
    handleExit : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire()
	},
    myAction : function(component, event, helper) {
        var ConList = component.get("c.getRelatedList");
        ConList.setParams({
            recordId: component.get("v.recordId")
        });
        ConList.setCallback(this, function(data) {
            var retVal = data.getReturnValue();
            var opts = retVal.map(opt => ({ value: opt.Id, label: opt.Name }));
			component.set("v.ContactList", opts);
        });
        $A.enqueueAction(ConList);
 	}
})