/*


*/
Public Class CreateContractAPI{
    public Id conrtId {get;set;}
    public string conrtUpdate{get;set;}
    public CreateContractAPI(ApexPages.StandardController controller) {
        conrtId = controller.getId();
        getMethodUpdate(conrtId);
    }


    
    Public static string firstName;
    Public static string lastName = '';
    Public static string MailingAddress = '';
    Public static string MailingCity = '';
    Public static string MailingState = '';
    Public static string MailingCountry = '';
    Public static string MailingPostalCode = '';
    Public static string MobilePhone = '';
      
    
    @AuraEnabled public wrapValue w;
    //Method to create contract in the external system
    @AuraEnabled
    Public static String postMethod(string recordId){
        system.debug('recordId--'+recordId);
        contact con;
        try{
         con = [select Id,firstname,lastname,email,account.name,accountid,
        account.BillingCity,account.BillingCountry,account.BillingPostalCode,
        account.BillingState,account.BillingStreet,account.website,
        MailingAddress,MailingStreet,MailingCity,MailingState,MailingCountry,
        MailingPostalCode,Phone from contact where id = :recordId limit 1];
        }
        catch(Exception ex)
         {
             throw new AuraHandledException(ex.getMessage());
         }
        
        string firstName = con.firstName != null ? con.firstName : '';
        string lastName = con.lastName != null ? con.lastName: '';
        string MailingAddress = con.MailingStreet != null ? con.MailingStreet: '';
        string MailingCity = con.MailingCity != null ? con.MailingCity: '';
        string MailingState = con.MailingState != null ?con.MailingState : '';
        string MailingCountry = con.MailingCountry != null ?con.MailingCountry : '';
        string MailingPostalCode = con.MailingPostalCode != null ? con.MailingPostalCode: '';
        string BillingAddress = con.accountid != null && con.account.BillingStreet != null ? con.account.BillingStreet : '';
        string BillingCity = con.accountid != null && con.account.BillingCity != null ? con.account.BillingCity : '';
        string BillingState = con.accountid != null && con.account.BillingState != null ?  con.account.BillingState : '';
        string BillingCountry = con.accountid != null && con.account.BillingCountry != null ?  con.account.BillingCountry : '';
        string BillingPostalCode = con.accountid != null && con.account.BillingPostalCode != null ? con.account.BillingPostalCode : '';
        string website = con.accountid != null && con.account.website != null ? con.account.website : '';
        string MobilePhone = con.Phone != null ? con.Phone : '' ;
        string contractName = con.account.name != null ? con.account.name + ' - New Contract' : 'New Contract';
        string businessName = con.account.name != null ? con.account.name  : '';
        string externalId = con.accountid != null ? 'SF - ' + con.accountid  : '';
        string email = con.email != null ? con.email : UserInfo.getUserEmail();
        String jsonBody;
        string contractRequestQueueId = '';
        string accessKey = System.Label.API_KEY;
        
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        jsonGen.writeStringField('accessKey', accessKey);
        jsonGen.writeNumberField('contractRequestTypeId', 1);
        jsonGen.writeStringField('emailOrExternalIdOrName', '');
        jsonGen.writeStringField('newContractTitle', contractName);
        jsonGen.writeStringField('newDoingBusinessAsName', businessName);
        jsonGen.writeStringField('newExternalId', externalId);
        jsonGen.writeStringField('newName', businessName);
        jsonGen.writeStringField('newFirstName', firstName);
        jsonGen.writeStringField('newLastName', lastName);
        jsonGen.writeStringField('newMiddleName', '');
        jsonGen.writeBooleanField('newIsBusinessAddressSameAsMailingAddress', true);
        jsonGen.writeStringField('newMailingAddress1', MailingAddress);
        jsonGen.writeStringField('newMailingAddress2', '');
        jsonGen.writeStringField('newMailingCity', MailingCity);
        jsonGen.writeStringField('newMailingState', MailingState);
        jsonGen.writeStringField('newMailingCountry', MailingCountry);
        jsonGen.writeStringField('newMailingZipCode', MailingPostalCode);
        jsonGen.writeStringField('newMailingPhone', MobilePhone);
        jsonGen.writeStringField('newMailingFax', '');
        jsonGen.writeStringField('newBusinessAddress1', BillingAddress);
        jsonGen.writeStringField('newBusinessAddress2', '');
        jsonGen.writeStringField('newBusinessCity', BillingCity);
        jsonGen.writeStringField('newBusinessState', BillingState);
        jsonGen.writeStringField('newBusinessCountry', BillingCountry);
        jsonGen.writeStringField('newBusinessZipCode', BillingPostalCode);
        jsonGen.writeStringField('newBusinessPhone', '');
        jsonGen.writeStringField('newBusinessFax', '');
        jsonGen.writeStringField('newEmail', email);
        jsonGen.writeStringField('newWebsite', website);
        jsonGen.writeStringField('newNotes', '');
        jsonGen.writeStringField('newNpi', '');
        jsonGen.writeStringField('newTaxId', '');
        jsonGen.writeEndObject();
        jsonBody = jsonGen.getAsString();
        jsonGen.close();
                
        System.debug('************JSON BODY************' + jsonBody);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(System.Label.API_URL +'api/v1/external/createcontractrequest');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(jsonBody);
        system.debug('test post body '+request.getBody());
        HttpResponse response = http.send(request);
        system.debug('@@@RESPONSE 1 @@'+response.getBody());
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        system.debug('result-'+results);
        return response.getBody();
    }
    
    @AuraEnabled
    Public static string getMethod(string reqNum){
       System.debug('req#'+reqNum);
       String reqID = reqNum;
       String endPoint = System.Label.API_URL+'api/v1/external/getcontractrequest?AccessKey='+System.Label.API_KEY+'&ContractRequestId='+reqID;
       Http h2 = new Http();
       HttpRequest req1 = new HttpRequest();
       req1.setHeader('accept','text/plain');
       req1.setMethod('GET');
       req1.setEndpoint(endPoint);
       HttpResponse res1 = h2.send(req1);
       system.debug('@@@RESPONSE 2 @@'+res1.getBody());
       return res1.getBody();
    }
    
    Public void getMethodUpdate(string conrtId){
       list<Contract_api__c> conrtList = [select id,Contact__c,Contract_Request_Queue_Id__c from Contract_api__c where id = :conrtId  limit 1];
       conrtUpdate = CreateContractAPI.getMethod(conrtList[0].Contract_Request_Queue_Id__c); 
    }
    
    public PageReference updatingContract(){
       string local = conrtUpdate;
       JSON2Apex ex = (JSON2Apex)JSON.deserialize(local, JSON2Apex.class);

       list<Contract_api__c> conrtList2 = [select id,Contact__c,Contract_Request_Queue_Id__c from Contract_api__c where id = :conrtId  limit 1]; 
       conrtList2[0].Entity_Queue_Status__c = ex.model.contractingEntityQueueStatusTypeName;
       conrtList2[0].Queue_Status_Type__c = ex.model.contractQueueStatusTypeName;
       conrtList2[0].contractRequestQueueStatusTypeName__c = ex.model.contractRequestQueueStatusTypeName;
       conrtList2[0].Queue_Status_Type_ID__c = ex.model.contractQueueStatusTypeId;
       conrtList2[0].Entity_Queue_Status_ID__c = ex.model.contractingEntityQueueStatusTypeId;
       conrtList2[0].contractRequestQueueStatusTypeId__c = ex.model.contractRequestQueueStatusTypeId;
       update conrtList2[0];
       PageReference pg = new PageReference('/'+conrtList2[0].Id);
        pg.setRedirect(true);
        return pg; 
       //return null;
    }

    
    @AuraEnabled
    public static void  sendContact(string recordId){
       system.debug('recordId--'+recordId);
       
       contact con = [select Id,firstname,lastname,MailingAddress,MailingCity,MailingState,MailingCountry,MailingPostalCode,MobilePhone from contact where id = :recordId limit 1];
       CreateContractAPI.firstName = con.firstname;
       CreateContractAPI.lastname = con.lastname;
       //CreateContractAPI.MailingAddress = con.MailingAddress;
       CreateContractAPI.MailingCity = con.MailingCity;
       CreateContractAPI.MailingState = con.MailingState;
       CreateContractAPI.MailingCountry = con.MailingCountry;
       CreateContractAPI.MailingPostalCode = con.MailingPostalCode;
       CreateContractAPI.MobilePhone = con.MobilePhone;
       system.debug('CreateContractAPI.firstName =='+CreateContractAPI.firstName );
        
        //return w;
    }
    
    @AuraEnabled
    public static void  updateContact(string contactId,string conReqQ, wrapValue wp,string notes){
       system.debug('contactId--'+contactId+'conReqQ--'+conReqQ+ 'wp--'+wp);
       contact con = [select Id,Accountid from contact where id = :contactId limit 1];
       Contract_api__c conrt = new Contract_api__c(Contact__c = con.id,Accounts__c = con.Accountid,Contract_Request_Queue_Id__c = conReqQ , 
                               Entity_Queue_Status__c = wp.contractingEntityQueueStatusTypeName,  
                               Queue_Status_Type__c = wp.contractQueueStatusTypeName,notes__c  = notes,
                               contractRequestQueueStatusTypeName__c = wp.contractRequestQueueStatusTypeName);
       insert conrt;
    
    }
    
    @AuraEnabled
    public static list<Contact> getRelatedList(Id recordId)
    {    system.debug('id'+recordId);
        List<Contact> Conlist = [Select id, name,firstname,lastname from Contact where AccountId=: recordId ];
        return Conlist;
    }
    @AuraEnabled
    public static boolean  forceCloseQA(){
       wrapValue w = new wrapValue();
       w.closeQA = true;
       return true;
    
    }
    
    public class wrapValue{
        @AuraEnabled public boolean closeQA{get;set;}
        @AuraEnabled public boolean isSuccess{get;set;}
        @AuraEnabled public string contractQueueStatusTypeName{get;set;}
        @AuraEnabled public string contractingEntityQueueStatusTypeName{get;set;}
        @AuraEnabled public string contractRequestQueueStatusTypeName{get;set;}
    }
    
    
    
    
}