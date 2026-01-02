trigger TriggerProyecto on Proyecto__c (before insert,after insert , after update,before delete,after delete) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            TriggerProyectoHandler.updateDescripcion(Trigger.new);
        }
        when AFTER_UPDATE {
            TriggerProyectoHandler.updateDescripcion(Trigger.new);
        }
        when BEFORE_INSERT{
            TriggerProyectoHandler.validateProyectoLimite(Trigger.new);
        }
        when BEFORE_DELETE {
            TriggerProyectoHandler.deleteAntiguedadYEstadoPlaneado(Trigger.old);
        }
        when AFTER_DELETE {
            TriggerProyectoHandler.updatePromedioAfterDelete(Trigger.old);
        }
    }
}