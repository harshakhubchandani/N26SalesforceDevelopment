/***************************************************************************************************************************
* @author   Harsha Khubchandani
* @date     29-03-2019
* @description  - This is a batch class to send feedback emails to N26 customer .
                   We have also implemented Schedulable interfaace so that we can schedule the batch from UI.
****************************************************************************************************************************/

public class N26_SendFeedbackEmailToCustomers implements Database.Batchable<Sobject>,Schedulable {

    public Id customerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
     
    /************************************************************************************************************************
    * @author   Harsha Khubchandani
    * @date     29-03-2019
    * @description  - This is the execute method for Schedulable interface.We have given batch size as 100
    * @param   sc - SchedulableContext     
    ************************************************************************************************************************/
    public void execute(SchedulableContext sc){
        N26_SendFeedbackEmailToCustomers  batch = new N26_SendFeedbackEmailToCustomers ();      
        database.executebatch(batch,100);
    }    
    
    /************************************************************************************************************************
     * @author  Harsha Khubchandani
     * @date    29-03-2019
     * @description  Start method to query the Customer (contact) records.
     * @param   bc - Database.BatchableContext    
     * @return  This method will return the list of customer records for which the survey date has passed and email!=null
    ************************************************************************************************************************/ 
    public Database.QueryLocator start(Database.BatchableContext bc){         
        return Database.getQueryLocator([SELECT Id,firstname,lastname,email,Survey_date__c,Language__c FROM Contact WHERE 
                                        recordtypeId=:customerRecordTypeId AND 
                                        Survey_date__c!=null AND Email!=null AND Survey_date__c < TODAY]);
    }
   
    /**************************************************************************************************************************
     * @author  Harsha Khubchandani
     * @date    29-03-2019
     * @description  Execute method will call the handler class. The Handler class would send emails to all customers whose 
                    survey date is less the System.Now
     * @param   customerList - List of customer records retrieved from the start method    
     * @return  void
    *************************************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Contact> customerList) {
        N26_SendFeedbackEmailToCustomersHandler.sendEmailsToCustomers(customerList);
    }        
    
    /**************************************************************************************************************************
     * @author  Harsha Khubchandani
     * @date    29-03-2019
     * @description  This method will send a notification when the batch has been processed completely         
     * @return  void
    *************************************************************************************************************************/
    public void finish(Database.BatchableContext BC) {
        try{
            String emailAddressOfAdmin= [Select Id,DeveloperName,Value__c FROM N26_GenericValues__mdt WHERE DeveloperName='AdminEmailAddress'].Value__c;
            List<String> listOfToAddress = emailAddressOfAdmin.split(','); 
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems,CreatedBy.Email
                              FROM AsyncApexJob WHERE Id = :BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = listOfToAddress;
            mail.setToAddresses(toAddresses);
            mail.setSubject('Merging Duplicate Contacts ' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures. ');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(Exception ex){
            system.debug('EXCEPTION OCCURRED'+ex);
        }        
    }
 }