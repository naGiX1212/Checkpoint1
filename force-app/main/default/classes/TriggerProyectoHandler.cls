/**
 * Handler de trigger para el objeto Proyecto__c,
 * @author Joel Murillo
 */
public with sharing class TriggerProyectoHandler {
    /**
     * Actualiza la descripción de los contactos asociados a proyectos con presupuesto mayor a 50.000,
     * y recalcula el promedio de las cuentas vinculadas a los proyectos recibidos.
     *
     * @param projects Lista de proyectos a procesar.
     */
    public static void updateContactDescriptionForHighBudget(List<Proyecto__c> projects){
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        for(Proyecto__c project : projects){
            if(project.Contact__c != null && project.Presupuesto__c > 50000){
                contactMap.put(project.Contact__c,new Contact(Id = project.Contact__c , Descripcion__c ='Este contacto está asociado con un proyecto con presupuesto alto.'));
            }
        }
        if(contactMap.size() > 0 ){
            update as user contactMap.values();
        }
        Set<Id> accountIds = getAccountIdsFromProjects(projects);
        updateAccountBudgetAverage(accountIds);
    }
    /**
     * Valida que la cantidad de proyectos en progreso asociados a una cuenta no supere el limite establecido en el campo Maximo_de_proyectos_activos__c de la cuenta.
     * @param newProjects Lista de proyectos a validar.
     */
    public static void validateActiveProjectsLimit(List<Proyecto__c> newProjects) {
        Set<Id> accountInProgressIds = new Set<Id>();
        List<Proyecto__c> projectsInProgress = new List<Proyecto__c>();
        for(Proyecto__c projectItem : newProjects){
            if(projectItem.Estado__c == 'En Progreso'){
                accountInProgressIds.add(projectItem.Account__c);
                projectsInProgress.add(projectItem);
            }
        }
        if(accountInProgressIds.size() == 0){
            return;
        }
        Map<Id,Account> accountsInProgress = new Map<Id,Account>([SELECT Id, Maximo_de_proyectos_activos__c, (SELECT Id FROM Proyectos__r WHERE Estado_Resumen__c LIKE 'Proyecto Activo')
                                    FROM Account
                                    WHERE Id IN :accountInProgressIds WITH USER_MODE]);
        Map<Id,Integer> accountActiveCount = new Map<Id,Integer>();
        for(Account accountItem : accountsInProgress.values()){
            accountActiveCount.put(accountItem.Id,accountItem.Proyectos__r.size());
        }
        for(Proyecto__c projectItem : projectsInProgress){
            Integer maxActive = (Integer) accountsInProgress.get(projectItem.Account__c).Maximo_de_proyectos_activos__c;
            if(maxActive != null && accountActiveCount.get(projectItem.Account__c) >= maxActive){
                projectItem.addError('No se puede crear el proyecto, la cuenta supera el limite de proyectos activos');
            }
            else {
                accountActiveCount.put(projectItem.Account__c,accountActiveCount.get(projectItem.Account__c) + 1);
            }
        }
    }
    /**
     * Valida que los proyectos que se van a eliminar cumplan con las condiciones
     * que esten en estado 'Planeado' y el anio de antiguedad del proyecto sea mayor a 1 anio
     * @param projectsToDelete Lista de proyectos antes de la eliminación
     */
    public static void deleteIfOldAndPlanned(List<Proyecto__c> projectsToDelete) {
        for(Proyecto__c projectItem : projectsToDelete) {
            Boolean isOldAndPlanned = projectItem.Estado__c == 'Planeado' && projectItem.Fecha_de_inicio__c != null && projectItem.Fecha_de_inicio__c <= Date.today().addYears(-1);
            if(!isOldAndPlanned) {
                projectItem.addError('No se puede eliminar el record ya que no cumple las condiciones (Planeado y antiguo)');
            }
        }
    }
    /**
     * Actualiza el promedio de la cuenta después de eliminar un proyecto
     * @param projects Lista de proyectos eliminados
     */
    public static void updateAccountBudgetAverageAfterDelete(List<Proyecto__c> projects){
        Set<Id> accountIds = getAccountIdsFromProjects(projects);
        updateAccountBudgetAverage(accountIds);
    }
    /**
     * Actualiza el promedio de la cuenta asociada al proyecto
     * @param accountIds Conjunto de IDs de cuentas a actualizar
     */
    private static void updateAccountBudgetAverage(Set<Id> accountIds) {
        List<Account> accountsToUpdate = new List<Account>();
        List<AggregateResult> averages = [SELECT Account__c, AVG(Presupuesto__c) promedio
                                           FROM Proyecto__c
                                           WHERE Account__c
                                           IN :accountIds
                                           AND Estado__c='En Progreso'
                                           WITH USER_MODE
                                           GROUP BY Account__c
                                           ];
        Set<Id> accountsWithActiveProjects = new Set<Id>();
        for(AggregateResult average : averages){
            Id accountId = (Id)average.get('Account__c');
            accountsWithActiveProjects.add(accountId);
            accountsToUpdate.add(
                new Account(
                    Id = accountId,
                    Presupuesto_promedio__c = (Decimal)average.get('promedio')
                )
            );
        }
        for(Id accountId : accountIds){
            if(!accountsWithActiveProjects.contains(accountId)){
                accountsToUpdate.add(new Account(Id = accountId, Presupuesto_promedio__c = null));
            }
        }
        if(!accountsToUpdate.isEmpty()){
            update as user accountsToUpdate;
        }
    }
    /**
     * Obtiene las ids de las cuentas asociadas a una lista de proyectos
     * @param projects Lista de proyectos a procesar
     * @return Conjunto de IDs de cuentas asociadas a los proyectos
     */
    private static Set<Id> getAccountIdsFromProjects(List<Proyecto__c> projects){
        Set<Id> accountIds = new Set<Id>();
        for(Proyecto__c project : projects){
            accountIds.add(project.Account__c);
        }
        return accountIds;
    }
}
