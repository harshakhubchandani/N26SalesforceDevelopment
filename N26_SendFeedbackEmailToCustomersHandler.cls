/*******************************************************************************************************************************************
* @author   Harsha Khubchandani
* @date     29-03-2019
* @description  - This class will be the handler class to batch "N26_SendFeedbackEmailToCustomers" and it will send emails to the customers 
********************************************************************************************************************************************/
public without sharing class N26_SendFeedbackEmailToCustomersHandler{
 
    /***************************************************************************************************************************************
    * @author   Harsha Khubchandani
    * @date     29-03-2019
    * @description  - This method will send the emails to the customers.Currently we have only two languages but we have made the email body
                    configurable based on the language.
                    --> N26_EmailConfiguration__mdt Custom metadata type will store the email body against the Language code (ISO 639-1)
    * param scope : List of Contacts
    ****************************************************************************************************************************************/
    public static void sendEmailsToCustomers(List<Contact> scope){
        List<Messaging.SingleEmailMessage> listOfEmail = new List<Messaging.SingleEmailMessage>();         
        Map<String,String> mapOfMetadata = new Map<String,String>();
        List<Contact> listOfContactsToBeUpdated = new List<Contact> ();
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        
        /************************ Creating a map of contacts *******************************************************************************/
        Map<Id,Contact> mapOfContacts = new Map<Id,Contact>(scope);
        
        List<N26_EmailConfiguration__mdt> listOfMetdataNames = [SELECT Id,MasterLabel,N26_EmailBody__c FROM N26_EmailConfiguration__mdt];
        
        /*********************** Creating a map of Languages and its corresponding email body **********************************************/
        if(! listOfMetdataNames.isEmpty()){
            for(N26_EmailConfiguration__mdt customMtadta :listOfMetdataNames ){
                mapOfMetadata.put(customMtadta.MasterLabel,customMtadta.N26_EmailBody__c);
            }
        }
        
        if(!scope.isEmpty()){
            for(Contact con : scope){
                Messaging.SingleEmailMessage feedbackEmail= new Messaging.SingleEmailMessage();
                feedbackEmail.toAddresses = new String[]{con.Email}; 
                feedbackEmail.setTargetObjectId(con.Id);
                feedbackEmail.subject = 'Please tell us about your experience';
                if(con.Language__c !=null && mapOfMetadata.containsKey(con.Language__c)){
                    String emailBody = 'Hey '+ con.Firstname +',<br> '+mapOfMetadata.get(con.Language__c)+con.Id;
                    feedbackEmail.setHtmlBody(emailBody ); 
                }
                listOfEmail.add(feedbackEmail);                
            }       
        }
        
        /**************************** Allowing partial email send by setting the "AllorNone" option to false*******************************/
        if(!listOfEmail.isEmpty()){
            results = Messaging.sendEmail(listOfEmail,false);
        } 
        
        /***********************************************************************************************************************************
        @description : Checking if there are any errors while sending the emails..If there are, remove the record from the mapOfContacts.
                        This has been done to get the list of contacts for which the email was sent successfully.
        ***********************************************************************************************************************************/
        if(!results.isEmpty()){
            for(Messaging.SendEmailResult msgresult : results){                
                if(!msgresult.Issuccess() && mapOfContacts.containsKey(msgresult.getErrors()[0].getTargetObjectId())){
                    mapOfContacts.remove(msgresult.getErrors()[0].getTargetObjectId());
                }             
            }
        }    
        
        /***********************************************************************************************************************************
        @description : The list of records for which the email was sent successfully are updated (Survey date is set to null).
        ***********************************************************************************************************************************/
        if(!mapOfContacts.isEmpty()){
            for(Contact contactToBeUpdated : mapOfContacts.values()){
                contactToBeUpdated.Survey_date__c=null;
            }           
            update mapOfContacts.values();
        }        
    }        
}
