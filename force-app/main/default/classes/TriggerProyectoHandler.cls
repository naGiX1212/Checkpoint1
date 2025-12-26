public with sharing class TriggerProyectoHandler {
    //Actualiza la descripcion en el caso de que el contacto tenga un presupuesto mayor a 50000
    public static void afterInsertOrUpdate(List<Proyecto__c> proyectos){
        Map<Id,Contact> cont = new Map<Id,Contact>();
        for(Proyecto__c pro : proyectos){
            if(pro.Presupuesto__c > 50000){
                cont.put(pro.Contact__c,new Contact(Id = pro.Contact__c , Descripcion__c ='Este contacto está asociado con un proyecto con presupuesto alto.'));
            }
        }
        if(cont.size() > 0 ){
            update as user cont.values();
        }
        Set<Id> accountIds = getAccountsIds(proyectos);
        updateAccountPromedio(accountIds);
    }
    //Se encargar de verificar que la cantidad de proyectos activos no supere el limite de proyectos activos de la cuenta
    //Se toman en cuenta solo los 'En progreso'
    public static void validarLimiteProyectos(List<Proyecto__c> nuevosProyectos) {
        Set<Id> idsAccountProgreso = new Set<Id>();
        List<Proyecto__c> proyectosProgreso = new List<Proyecto__c>();
        for(Proyecto__c proyItem : nuevosProyectos){
            if(proyItem.Estado__c == 'En Progreso'){
                idsAccountProgreso.add(proyItem.Account__c);
                proyectosProgreso.add(proyItem);
            }
        }
        if(idsAccountProgreso.size() == 0){
            return;
        }
        Map<Id,Account> accountsProgreso = new Map<Id,Account>([SELECT Id, Maximo_de_proyectos_activos__c, (SELECT Id FROM Proyectos__r WHERE Estado_Resumen__c LIKE 'Proyecto Activo')
                                    FROM Account
                                    WHERE Id IN :idsAccountProgreso WITH USER_MODE]);
        Map<Id,Integer> accountsCantActivos = new Map<Id,Integer>();
        for(Account accountItem : accountsProgreso.values()){
            accountsCantActivos.put(accountItem.Id,accountItem.Proyectos__r.size());
        }
        for(Proyecto__c proyItem : proyectosProgreso){
            if(accountsCantActivos.get(proyItem.Account__c) >= accountsProgreso.get(proyItem.Account__c).Maximo_de_proyectos_activos__c){
                proyItem.addError('No se puede crear el proyecto, la cuenta supera el limite de proyectos activos');
            }
            else {
                accountsCantActivos.put(proyItem.Account__c,accountsCantActivos.get(proyItem.Account__c) + 1);
            }
        }
    }
    //Funcion del beforeDelete, que se encargar de validar que los proyectos que se van a eliminar cumplan con las condiciones
    //que esten en estado 'Planeado' y el anio de antiguedad del proyecto sea mayor a 1 anio
    public static void beforeDelete(List<Proyecto__c> before) {
        for(Proyecto__c proItem : before) {
            Boolean esAntiguoYPlaneado = proItem.Estado__c == 'Planeado' && proItem.Fecha_de_inicio__c != null && proItem.Fecha_de_inicio__c.year() <= Date.today().addYears(-1).year();
            if(!esAntiguoYPlaneado) {
                proItem.addError('No se puede eliminar el record ya que no cumple las condiciones (Planeado y antiguo)');
            }
        }
    }
    //se supone que los unicos que puedo eliminar son los que cumplen antiguo y planeado , pero estos no cuentan para el preomedio , por ende al eliminar un proyecto el promedio no cambia
    public static void afterDelete(List<Proyecto__c> ls){
        Set<Id> accountIds = getAccountsIds(ls);
        updateAccountPromedio(accountIds);
    }
    //Acutaliza el promedio de la cuenta asoaciada al proyecto
    public static void updateAccountPromedio(Set<Id> accountIds) {
        List<Account> accounts = new List<Account>();
        List<AggregateResult> promedios = [SELECT Account__c, AVG(Presupuesto__c) promedio
                                           FROM Proyecto__c
                                           WHERE Account__c
                                           IN :accountIds
                                           AND Estado__c='En Progreso'
                                           WITH USER_MODE
                                           GROUP BY Account__c
                                           ];
        for(AggregateResult promedio : promedios){
            accounts.add(
                new Account(
                    Id = (Id)promedio.get('Account__c'),
                    Presupuesto_promedio__c = (Decimal)promedio.get('promedio')
                )
            );
        }
        if(accounts.size() > 0){
            update as user accounts;
        }
    }
    //Obtiene las ids de los proyectos;
    public static Set<Id> getAccountsIds(List<Proyecto__c> ls){
        Set<Id> accountIds = new Set<Id>();
        for(Proyecto__c pro : ls){
            accountIds.add(pro.Account__c);
        }
        return accountIds;
    }
}