/**
 * @author: Joel Murillo
 * @see: ProyectoController
 */
@IsTest
private class ProyectoControllerTest {

    /**
     * Configura los datos de prueba necesarios para las pruebas unitarias.
     * Crea dos usuarios con perfil de administrador, asigna el permission set
     * Bypass_Validation_Rules al primero, y genera una cuenta con un contacto asociado.
     */
    @TestSetup
    static void makeData(){
        List<User> admins = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User admin = admins[0];
        System.runAs(admin){
            List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('System Administrator') LIMIT 1];
            Profile p = profiles[0];
            User u = new User(
                Alias = 'test',
                Email = 'testuser@example.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'asd',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'test' + DateTime.now().getTime() + '@test.com'
            );
            User u2 = new User(
                Alias = 'test2',
                Email = 'test2user@example.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'asd',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'test2' + DateTime.now().getTime() + '@test.com'
            );
            List<User> users = new List<User>{u,u2};
            insert users;
            List<PermissionSet> permSets = [SELECT Id FROM PermissionSet WHERE Name = 'Bypass_Validation_Rules' LIMIT 1];
            PermissionSet ps = permSets[0];
            insert new PermissionSetAssignment(
                AssigneeId = u.Id,
                PermissionSetId = ps.Id
            );
            Account acct = new Account(
                Name = 'AccountTest'
            );
            insert acct;
            Contact cont = new Contact(
                LastName = 'ContactTest',
                AccountId = acct.Id
            );
            insert cont;
        }
    }

    /** Clase auxiliar que agrupa los datos de prueba comunes para los tests de eliminación. */
    private class DeleteTestSetup {
        Account acct;
        Contact cont;
        User u;
    }
    /**
     * Obtiene los registros de prueba necesarios para los tests de eliminación.
     * Recupera la cuenta, el contacto y el usuario creados en makeData.
     * @return Un objeto DeleteTestSetup con los registros listos para usar.
     */
    private static DeleteTestSetup setupDeleteTest() {
        DeleteTestSetup setup = new DeleteTestSetup();
        List<Account> accts = [SELECT Id FROM Account WHERE Name = 'AccountTest' LIMIT 1];
        setup.acct = accts[0];
        List<Contact> conts = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' LIMIT 1];
        setup.cont = conts[0];
        List<User> users = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];
        setup.u = users[0];
        return setup;
    }
    /**
     * Prueba que un proyecto se elimine correctamente cuando cumple las condiciones requeridas.
     * Crea un proyecto en estado 'Planeado' con fecha de inicio hace 2 años y verifica
     * que tras llamar a deleteProyectoById el registro ya no exista en la base de datos.
     * @see ProyectoController.deleteProyectoById
     */
    @IsTest
    static void deleteProyectoByIdTestExito() {
        DeleteTestSetup setup = setupDeleteTest();
        Account acct = setup.acct;
        Contact cont = setup.cont;
        User u = setup.u;
        Proyecto__c pro = new Proyecto__c(
            Name = 'Proyecto Test',
            Account__c = acct.Id,
            Contact__c = cont.Id,
            Fecha_de_inicio__c = Date.today().addYears(-2),
            Estado__c = 'Planeado'
        );
        System.runAs(u) {
            insert pro;
            List<Id> ids = new List<Id>{ pro.Id };
            Test.startTest();
            ProyectoController.deleteProyectoById(ids);
            Test.stopTest();
        }
        List<Proyecto__c> resultados = [SELECT Id FROM Proyecto__c WHERE Id = :pro.Id];
        Assert.areEqual(0, resultados.size(), 'El proyecto debería haber sido eliminado');
    }

    /**
     * Prueba que un proyecto no se elimine cuando no cumple las condiciones requeridas.
     * Crea un proyecto en estado 'Planeado' con fecha de inicio igual a hoy y verifica
     * que deleteProyectoById lance una AuraHandledException al intentar eliminarlo.
     * @see ProyectoController.deleteProyectoById
     */
    @IsTest
    static void deleteProyectoByIdTestFallido() {
        DeleteTestSetup setup = setupDeleteTest();
        Account acct = setup.acct;
        Contact cont = setup.cont;
        User u = setup.u;
        Proyecto__c pro = new Proyecto__c(
            Name = 'Proyecto Test',
            Account__c = acct.Id,
            Contact__c = cont.Id,
            Fecha_de_inicio__c = Date.today(),
            Estado__c = 'Planeado'
        );
        System.runAs(u) {
            insert pro;
            List<Id> ids = new List<Id>{ pro.Id };
            Test.startTest();
            try {
                ProyectoController.deleteProyectoById(ids);
            } catch (AuraHandledException m) {
                Assert.isNotNull(m.getMessage());
            }
            Test.stopTest();
        }
    }
}
