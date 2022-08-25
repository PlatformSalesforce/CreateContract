({
    apex : function( cmp, apexAction, params ) {
    var p = new Promise( $A.getCallback( function( resolve , reject ) { 
        var action  = cmp.get("c."+apexAction+"");
        action.setParams( params );
        action.setCallback( this , function(callbackResult) {
            if(callbackResult.getState()=='SUCCESS') {
                resolve( callbackResult.getReturnValue() );
                var returnObj = JSON.parse(callbackResult.getReturnValue());
                var closeQA = callbackResult.getReturnValue();
                
                if(returnObj.isSuccess == true){
                     resolve( returnObj.model);
                    
                    if(returnObj.model.contractRequestQueueId){
                     console.log('1');
                     var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Info',
                            message: 'Contract is successfylly created with request Id: '+returnObj.model.contractRequestQueueId ,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'dismissible'
                        });
        			toastEvent.fire();
                    
                    }
          		}
                else if(returnObj.isSuccess == false){
                    var errorList = '';
                    if (returnObj.errorHolder.errorItemList[0].value != ''){
                        errorList = returnObj.errorHolder.errorItemList[0].value;
                    }
                        
                   var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Contract is not created ',
                            message: returnObj.errorHolder.friendlyMessage+ ' due to '+errorList,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
        			toastEvent.fire();
                    //var dismissActionPanel = $A.get("e.force:closeQuickAction");
        			//dismissActionPanel.fire();
                }
                else if(closeQA == true){
                    console.log('tester');
					 var dismissActionPanel = $A.get("e.force:closeQuickAction");
        			 dismissActionPanel.fire();  
                     $A.get('e.force:refreshView').fire();
                }
             }
            if(callbackResult.getState()=='ERROR') {
                console.log('ERROR', callbackResult.getError() ); 
                reject( callbackResult.getError() );
            }
        });
        $A.enqueueAction( action );
        
    }));    
	  
    return p;
    
}
})