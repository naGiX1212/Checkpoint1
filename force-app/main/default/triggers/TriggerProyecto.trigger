trigger TriggerProyecto on Proyecto__c (before insert,after insert , after update,before delete,after delete) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            TriggerProyectoHandler.updateContactDescriptionForHighBudget(Trigger.new);
        }
        when AFTER_UPDATE {
            TriggerProyectoHandler.updateContactDescriptionForHighBudget(Trigger.new);
        }
        when BEFORE_INSERT{
            TriggerProyectoHandler.validateActiveProjectsLimit(Trigger.new);
        }
        when BEFORE_DELETE {
            TriggerProyectoHandler.deleteIfOldAndPlanned(Trigger.old);
        }
        when AFTER_DELETE {
            TriggerProyectoHandler.updateAccountAverageAfterDelete(Trigger.old);
        }
    }
}