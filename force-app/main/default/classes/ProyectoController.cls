public with sharing class ProyectoController {
    @AuraEnabled
    public static void deleteProyectoById(List<Id> ids){
            try {
                if(ids != null && ids.size() > 0){
                delete [SELECT Id FROM Proyecto__c WHERE Id IN :ids WITH USER_MODE];
            }

            } catch (Exception m) {
                throw  new AuraHandledException(m.getMessage());
            }
    }
}