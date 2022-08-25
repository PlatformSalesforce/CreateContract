public class JSON2Apex {

    public Model model;
    public Boolean isSuccess;

    public class Model {
        public List<Files> files;
        public String contractingEntityQueueStatusTypeName;
        public String contractQueueStatusTypeName;
        public String contractRequestQueueStatusTypeName;
        public String tenantName;
        public String tenantEntityName;
        public String contractRequestTypeName;
        public String createdBy;
        public String modifiedBy;
        public Integer contractRequestQueueId;
        public Integer contractingEntityTypeId;
        public Integer contractingEntityQueueStatusTypeId;
        public Integer contractTypeId;
        public String newContractTitle;
        public Integer contractQueueStatusTypeId;
        public Integer contractRequestQueueStatusTypeId;
        public Integer tenantId;
        public Integer tenantEntityId;
        public String newDoingBusinessAsName;
        public String newExternalId;
        public String newName;
        public String newFirstName;
        public String newLastName;
        public String newMiddleName;
        public Boolean newIsBusinessAddressSameAsMailingAddress;
        public String newMailingAddress2;
        public String newMailingCity;
        public String newMailingState;
        public String newMailingCountry;
        public String newMailingZipCode;
        public String newMailingPhone;
        public String newMailingFax;
        public String newBusinessAddress1;
        public String newBusinessAddress2;
        public String newBusinessCity;
        public String newBusinessState;
        public String newBusinessCountry;
        public String newBusinessZipCode;
        public String newBusinessPhone;
        public String newBusinessFax;
        public String newEmail;
        public String newWebsite;
        public String newNotes;
        public String newNpi;
        public String newTaxId;
        public Integer contractRequestTypeId;
        public Boolean isDeleted;
        public String createdDate;
        public String modifiedDate;
    }

    public class Files {
    }

    
    public static JSON2Apex parse(String json) {
        return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
    }
}