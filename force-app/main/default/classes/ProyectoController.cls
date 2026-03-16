/**
 * Controlador para manejar la eliminación de registros de Proyecto__c.
 * Este controlador permite eliminar proyectos por su Id, asegurando que se manejen las excepciones adecuadamente y se respeten los permisos del usuario.
 * @author: Joel Murillo
 * Uso: Llama al método deleteProyectoById desde un componente LWC, pasando una lista de Ids de proyectos que deseas eliminar.
 */
public with sharing class ProyectoController {
    /**
    * Elimina los proyectos por su Id, asegurando que se manejen las excepciones adecuadamente y se respeten los permisos del usuario.
    * @param ids Lista de Ids de proyectos a eliminar.
    * @throws AuraHandledException Si ocurre una excepción durante la eliminación, se lanza una AuraHandledException con el mensaje de error.
    */
    @AuraEnabled
    public static void deleteProyectoById(List<Id> ids){
            try {
                if(ids != null && ids.size() > 0){
                List<Proyecto__c> proyectos = [SELECT Id FROM Proyecto__c WHERE Id IN :ids WITH USER_MODE];
                delete as user proyectos;
            }
            } catch (Exception m) {
                throw  new AuraHandledException(m.getMessage());
            }
    }
}