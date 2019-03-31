/*****************************************************************************************************************************
* @author   Harsha Khubchandani
* @date     30-03-2019
* @description  - This class will be the controller class to lightning component "N26_CustomerProductInformation " and will 
                  fetch the production information of the customer
******************************************************************************************************************************/
public without sharing class N26_CustomerProductInformation{
 
    /*************************************************************************************************************************
    * @author   Harsha Khubchandani
    * @date     30-03-2019
    * @description  - This method will fetch the customer details using the recordId
    * @param scope : Record Id (objectID)
    **************************************************************************************************************************/
    @AuraEnabled
    public static Case fetchCustomerProductInformation(Id caseRecordId){
        Case caseDetails = [SELECT Id,ContactId,Contact.Name,Contact.Home_Country__c,Contact.Product__r.Country_Code__c,
                            Contact.Product__r.Product__c,Contact.Product__r.Type__c,Contact.Product__r.Value__c
                            FROM Case WHERE Id=:caseRecordId]; 
        return caseDetails ;
    }  
    
}