@RestResource(urlMapping='/api/v1/external/updatecontractrequest/*')
global with sharing class ContractManager {
    
    public class Response {
        public boolean isSuccess;
        public String message;
        public string ContractRec;
        public Response(boolean isSuccess,String message, string conrtRec) {
            this.isSuccess = isSuccess;
            this.message = message;
            this.ContractRec = conrtRec;
        }
    }
    
    
    
    @HttpPatch
    global static void   updateContractFields() {
    
        RestRequest request = RestContext.request;
        list<Contract_api__c> thisConrt = new list<Contract_api__c>();
        string ContractingEntityId;
        String conReqId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        
            
        try {
           RestResponse res = RestContext.response;
           list<Response>  lstResponse = new  list <Response>();
           for( Contract_api__c c : [SELECT Id,contact__r.account.Contracting_Entity_Id__c FROM Contract_api__c WHERE Contract_Request_Queue_Id__c = :conReqId]){
                thisConrt.add(c);
            }
            API_Mapper__mdt[] mappers=  [select FieldName__c,MappedFieldAPI__c  from API_Mapper__mdt];
            system.debug('mappers'+mappers);
            
            Map<string,string> mapFields=new Map<string,string>();
            Map<string,string> mapFields2=new Map<string,string>();
            if(mappers!=null && mappers.size()>0)
            {
               for(API_Mapper__mdt mapObject:mappers)
               {
                   mapFields.put(mapObject.FieldName__c,mapObject.MappedFieldAPI__c);
                   mapFields2.put(mapObject.MappedFieldAPI__c,mapObject.FieldName__c);
                }
            }
            system.debug('mapFields--'+mapFields);
            // Deserialize the JSON string into name-value pairs
            Map<String, Object> params = (Map<String, object>)JSON.deserializeUntyped(request.requestbody.tostring());
            system.debug('param'+params);
            
            Map<String, object> newParams = new  Map<String, object>();
            for(String fieldName : params.keySet()) {
                        String val = mapFields.get(fieldName);
                        system.debug('val='+val);
                        if(string.isNotBlank(val))
                        {
                            newParams.put(val,params.get(fieldName));
                        }
                        else{
                            lstResponse.add(new Response(false,fieldName +' is not a valid property', null)); 
                        }
            }
            system.debug('newParams--'+newParams);
           
            // Iterate through each parameter field and value
            for(String fieldName : newParams.keySet()) {
                system.debug('fieldName--'+fieldName);
                if(thisConrt.size() > 0){
                    if(fieldName == 'ContractingEntityId'){
                        system.debug('ContractingEntityId');
                         if(thisConrt[0].contact__c != null){
                             if(thisConrt[0].contact__r.account != null){
                               if(newParams.get(fieldName) instanceof Integer){
                                  account a = [select id,Contracting_Entity_Id__c from account where id = : thisConrt[0].contact__r.accountid limit 1];
                                  a.Contracting_Entity_Id__c = (Integer)newParams.get(fieldName);
                                  update a;
                               }
                               else {
                                  lstResponse.add(new Response(false,'ContractingEntityId value must be Integer', null));  
                               }
                                
                             }
                         }
                    }
                    
                    else{
                     if(fieldName == 'Entity_Queue_Status_ID__c' || fieldName == 'Queue_Status_Type_ID__c' || fieldName == 'contractRequestQueueStatusTypeId__c' ){
                      if(newParams.get(fieldName) instanceof integer){
                          thisConrt[0].put(fieldName, newParams.get(fieldName));
                      }
                      else{
                           lstResponse.add(new Response(false,mapFields2.get(fieldName) +' value must be Integer', null));  
                      }
                     }
                     if(fieldName == 'Entity_Queue_Status__c' || fieldName == 'Queue_Status_Type__c' || fieldName == 'contractRequestQueueStatusTypeName__c' ){
                      if(newParams.get(fieldName) instanceof string){
                          thisConrt[0].put(fieldName, newParams.get(fieldName));
                      }
                      else {
                          lstResponse.add(new Response(false,mapFields2.get(fieldName) +' value must be String', null));  
                      }
                     }
                      
                    }
                    //thisConrt[0].put('contact__r.account.Contracting_Entity_Id__c','sangee');
                    system.debug('thisConrt[0]--'+thisConrt[0]);
                    
                }else {
                  lstResponse.add(new Response(false,'No Contract present for Contract request Id', null));  
                }
            }
         
            
           if(thisConrt.size() > 0){
                Database.SaveResult sr = Database.update(thisConrt[0], false); 
                
                String errorMsg = '';
                if (sr.isSuccess()) {
                    res.statusCode = 200;
                    lstResponse.add(new Response(true,'Successfully Updated',thisConrt[0].Id));
                } else {
                for (Database.Error err: sr.getErrors()) {
                    errorMsg = err.getStatusCode() + ': ' + err.getMessage();
                    system.debug('DML error-'+errorMsg);
                }
                    res.statusCode = 400;
                    lstResponse.add(new Response(false,'Error during Update', null));
                }
            }   
     
           if(lstResponse.size() > 0){
             res.responseBody = Blob.valueOf(JSON.serialize(lstResponse[0]));
           }

        } 
        catch(System.QueryException e){
            RestResponse res = RestContext.response;
            res.statusCode = 500;
            system.debug(e.getTypeName() + e.getMessage());
            res.responseBody = Blob.valueOf(JSON.serialize(new Response(false,'Requested Record not found', null)));
        }
        catch (Exception e) {
            RestResponse res = RestContext.response;
            res.statusCode = 500;
            system.debug(e.getTypeName() + e.getMessage());
            res.responseBody = Blob.valueOf(JSON.serialize(new Response(false,e.getMessage(), null)));
    }

    
    }    
}