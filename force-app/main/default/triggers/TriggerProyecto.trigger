trigger TriggerProyecto on Proyecto__c (before insert,after insert , after update,before delete,after delete) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            TriggerProyectoHandler.afterInsertOrUpdate(Trigger.new);
        }
        when AFTER_UPDATE {
            TriggerProyectoHandler.afterInsertOrUpdate(Trigger.new);
        }
        when BEFORE_INSERT{
            TriggerProyectoHandler.validarLimiteProyectos(Trigger.new);
        }
        when BEFORE_DELETE {
            TriggerProyectoHandler.beforeDelete(Trigger.old);
        }
        when AFTER_DELETE {
            TriggerProyectoHandler.afterDelete(Trigger.old);
        }
    }
}