@isTest(seeAllData= false)

/************************************************************************************************************
 * @author   Harsha Khubchandani 
 * @date     30-03-2019
 * @description  - This class will be the test class for N26_CustomerProductInformation class
*************************************************************************************************************/
public class N26_CustomerProductInformationTest{
    
    /*************************************************************************************************************************
    * @author   Harsha Khubchandani
    * @date     30-03-2019
    * @description  - This method will test the fetchCustomerProductInformation method
     **************************************************************************************************************************/
     
    @isTest static void  testFetchCaseDetailsMethod(){
     
         /********************* Inserting Product Record ***********************************************************/
         N26_ProductInformation__c productRec = new N26_ProductInformation__c(Product__c='Standard',Type__c='Cost per Calendar Month',
                                                 Value__c='36',Country_Code__c='DE');
         insert productRec;
         
         /********************* Inserting Contact Record ***********************************************************/
         Contact contactRec = new Contact(FirstName='Test',Lastname='Customer Contact',Product__c=productRec.Id,Home_Country__c='DE');
         insert contactRec ;
         
         /********************* Inserting Case Record **************************************************************/
         Case caseRec = new Case(Subject='Testing Lightning Apex Controller',Contact=contactRec);
         insert caseRec;
         
         /********************* Testing the method *****************************************************************/
         Test.startTest();
              Case testCaseRecord = N26_CustomerProductInformation.fetchCustomerProductInformation(caseRec.Id);   
         Test.stopTest();      
     
     }
}