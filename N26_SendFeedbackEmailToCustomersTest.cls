@isTest(seeAllData= false)

/************************************************************************************************************
 * @author   Harsha Khubchandani 
 * @date     29-03-2019
 * @description  - This class will be the test class for N26_SendFeedbackEmailToCustomers Batch class
*************************************************************************************************************/
public class N26_SendFeedbackEmailToCustomersTest{
    
    /************************************************************************************************************
     * @author   Harsha Khubchandani 
     * @date     29-03-2019
     * @description  - Setup method to create customer records 
    *************************************************************************************************************/
    @testSetup 
    static void setup() 
    {
        Id customerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        List<Contact> listOfRecords = new List<Contact>();
        for(Integer i=0;i<10;i++){
            if (math.mod(i, 2) == 0){
                listOfRecords.add(new Contact(firstname='Test'+i,Lastname='Contact'+i,
                                        Email='TestContact'+i+'@test.com',
                                        RecordtypeId=customerRecordTypeId,
                                        Survey_date__c=System.TODAY()-i,Language__c ='EN'));
            }else{
                listOfRecords.add(new Contact(firstname='Test'+i,Lastname='Contact'+i,
                                        Email='TestContact'+i+'@test.com',
                                        RecordtypeId=customerRecordTypeId,
                                        Survey_date__c=System.TODAY()-i,Language__c ='DE'));
            }       
        }
        insert listOfRecords;
    }    
    /************************************************************************************************************
     * @author   Harsha Khubchandani 
     * @date     29-03-2019
     * @description  - Method to test Batch class
    *************************************************************************************************************/
    static testmethod void testSendEmailsToCustomers() {                      
        Test.startTest();                       
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();        
        String jobId = System.schedule('Schedule Batch For Sending Emails to Customers', CRON_EXP,new N26_SendFeedbackEmailToCustomers ());         
        Test.stopTest();
        List<Contact> listOfTotalcontacts =[SELECT id from Contact WHERE Survey_date__c=null];      
    }
}