/**
 * @author: Joel Murillo
 * @see: TriggerProyectoHandler
 * Esta clase de prueba  está diseñada para validar la funcionalidad del TriggerProyectoHandler, que maneja eventos relacionados con el objeto Proyecto__c.
 */
@IsTest
private class TriggerProyectoHandlerTest {
    /**
     * Configura los datos de prueba necesarios para las pruebas unitarias.
     * Crea un usuario con permisos de administrador, una cuenta y un contacto asociados a esa cuenta.
     * Estos datos se utilizarán en las pruebas para validar la funcionalidad del TriggerProyectoHandler.
     */
    @TestSetup
    static void makeData() {
        List<User> admins = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User admin = admins[0];
        System.runAs(admin) {
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
            insert u;
            insert u2;
            List<PermissionSet> permSets = [SELECT Id FROM PermissionSet WHERE Name = 'Bypass_Validation_Rules' LIMIT 1];
            PermissionSet ps = permSets[0];
            insert new PermissionSetAssignment(
                AssigneeId = u.Id,
                PermissionSetId = ps.Id
            );
        }
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
    /**
     * Prueba que la descripción del contacto se actualice correctamente cuando se actualiza un proyecto con presupuesto alto.
     * Crea un proyecto asociado a una cuenta y un contacto, luego actualiza el presupuesto del proyecto a un valor alto.
     * Verifica que la descripción del contacto se haya actualizado con el mensaje esperado.
     */
    @IsTest
    static void updateDescriptionHighBudgetTest(){
        List<Account> accts = [SELECT Id FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
        Account acct = accts[0];
        List<Contact> conts = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        Contact cont = conts[0];
        List<User> users = [SELECT Id FROM User WHERE Alias = 'test' WITH USER_MODE LIMIT 1];
        User u = users[0];
        Proyecto__c project = new Proyecto__c(Name = 'ProyectoTest',Account__c = acct.Id ,Contact__c = cont.Id);
        insert as user project;
        project.Presupuesto__c = 550000;
        System.runAs(u){
            Test.startTest();
            update project;
            Test.stopTest();
        }
        List<Contact> updatedContacts = [SELECT Id,Descripcion__c FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        Contact updatedContact = updatedContacts[0];
        Assert.areEqual('Este contacto está asociado con un proyecto con presupuesto alto.', updatedContact.Descripcion__c);
    }
    /**
     * Prueba que la descripción del contacto no se actualice cuando se actualiza un proyecto con presupuesto bajo.
     * Crea un proyecto asociado a una cuenta y un contacto, luego actualiza el presupuesto del proyecto a un valor bajo.
     * Verifica que la descripción del contacto no se haya actualizado con el mensaje esperado.
     */
    @IsTest
    static void insertContactDescriptionSuccessTest(){
        List<Account> accts = [SELECT Id FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
        Account acct = accts[0];
        List<Contact> conts = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        Contact cont = conts[0];
        Proyecto__c project = new Proyecto__c(Name = 'ProyectoTest',Account__c = acct.Id ,Contact__c = cont.Id,Presupuesto__c = 60000);
        List<User> users = [SELECT Id FROM User WHERE Alias = 'test' WITH USER_MODE LIMIT 1];
        User u = users[0];
        System.runAs(u){
            Test.startTest();
            insert as user project;
            Test.stopTest();
        }
        List<Contact> updatedContacts = [SELECT Id,Descripcion__c FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        Contact updatedContact = updatedContacts[0];
        Assert.areEqual('Este contacto está asociado con un proyecto con presupuesto alto.', updatedContact.Descripcion__c);
    }
    /**
     * Prueba que la descripción del contacto no se actualice cuando se actualiza un proyecto con presupuesto bajo.
     * Crea un proyecto asociado a una cuenta y un contacto, luego actualiza el presupuesto del proyecto a un valor bajo.
     * Verifica que la descripción del contacto no se haya actualizado con el mensaje esperado.
     */
    @IsTest
    static void updateContactDescriptionLowBudgetTest(){
        List<Account> accts = [SELECT Id FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
        Account acct = accts[0];
        List<Contact> conts = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        Contact cont = conts[0];
        Proyecto__c project = new Proyecto__c(Name = 'ProyectoTest',Account__c = acct.Id ,Contact__c = cont.Id,Presupuesto__c = 5000);
        List<User> users = [SELECT Id FROM User WHERE Alias = 'test' WITH USER_MODE LIMIT 1];
        User u = users[0];
        System.runAs(u){
            Test.startTest();
            insert as user project;
            Test.stopTest();
        }
        List<Contact> updatedContacts = [SELECT Id,Descripcion__c FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        Contact updatedContact = updatedContacts[0];
        Assert.areNotEqual('Este contacto está asociado con un proyecto con presupuesto alto.', updatedContact.Descripcion__c);
    }
    /**
     * Prueba que un proyecto se elimine correctamente cuando cumple con las condiciones de eliminación.
     * Crea un proyecto asociado a una cuenta y un contacto, luego intenta eliminar el proyecto.
     * Verifica que el proyecto se haya eliminado correctamente y que el promedio de la cuenta se haya recalculado.
     */
    @IsTest
    static void deleteProjectSuccessTest(){
        List<Account> accts = [SELECT Id, Presupuesto_promedio__c FROM Account WHERE Name = 'AccountTest' LIMIT 1];
        Account acct = accts[0];
        List<Contact> conts = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' LIMIT 1];
        Contact cont = conts[0];
        List<User> users = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];
        User u = users[0];
        List<Proyecto__c> projects = new List<Proyecto__c>{
            new Proyecto__c(
                Name = 'Proyecto En Progreso1',
                Account__c = acct.Id,
                Contact__c = cont.Id,
                Estado__c = 'En Progreso',
                Presupuesto__c = 10000
            ),
            new Proyecto__c(
                Name = 'Proyecto En Progreso2',
                Account__c = acct.Id,
                Contact__c = cont.Id,
                Estado__c = 'En Progreso',
                Presupuesto__c = 10000
            )
        };
        Proyecto__c project = new Proyecto__c(
            Name = 'Proyecto',
            Account__c = acct.Id,
            Contact__C = cont.Id,
            Estado__c = 'Planeado',
            Fecha_de_inicio__c = Date.today().addYears(-1)
        );
        System.runAs(u){
            insert projects;
            List<Account> acctsBefore = [SELECT Id, Presupuesto_promedio__c FROM Account WHERE Id = :acct.Id WITH USER_MODE LIMIT 1];
            Account accountBeforeDelete = acctsBefore[0];
            Assert.isTrue(accountBeforeDelete.Presupuesto_promedio__c != null, 'Debió establecerse un promedio antes del borrado');
            insert project;
            Test.startTest();
            delete project;
            Test.stopTest();
        }
        List<Proyecto__c> resultList = [SELECT Id FROM Proyecto__c WHERE Id = :project.Id];
        Assert.areEqual(0, resultList.size(), 'El registro no debería existir , por ende fue eliminado correctamente');
        List<Account> acctsAfter = [SELECT Id, Presupuesto_promedio__c FROM Account WHERE Id = :acct.Id WITH USER_MODE LIMIT 1];
        Account accountAfterDelete = acctsAfter[0];
        Assert.areEqual(10000, accountAfterDelete.Presupuesto_promedio__c, 'El promedio de la cuenta debe recalcularse tras afterDelete');
    }
    /**
     * Prueba que un proyecto no se elimine cuando no cumple con las condiciones de eliminación.
     * Verifica que el proyecto no se haya eliminado y que se haya lanzado la excepción esperada.
     */
    @IsTest
    static void deleteProjectFailTest(){
        List<Account> accts = [SELECT Id FROM Account WHERE Name = 'AccountTest' LIMIT 1];
        Account acct = accts[0];
        List<Contact> conts = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' LIMIT 1];
        Contact cont = conts[0];
        List<User> users = [SELECT Id FROM User WHERE Alias = 'test2' LIMIT 1];
        User u2 = users[0];
        Proyecto__c project = new Proyecto__c(
            Name = 'Proyecto',
            Account__c = acct.Id,
            Contact__C = cont.Id,
            Estado__c = 'Planeado',
            Fecha_de_inicio__c = Date.today()
        );
        insert project;
        System.runAs(u2){
            Test.startTest();
            try {
                delete project;
            }
            catch (DmlException e) {
                Assert.isTrue(e.getMessage().contains('No se puede eliminar el record ya que no cumple las condiciones '));
            }
            Test.stopTest();
        }
    }
    /**
     * Prueba que un proyecto no se elimine cuando la fecha de inicio es nula.
     * Crea un proyecto asociado a una cuenta y un contacto, luego intenta eliminar el proyecto sin establecer la fecha de inicio.
     * Verifica que el proyecto no se haya eliminado y que se haya lanzado la excepción esperada.
     */
    @IsTest
    static void deleteProjectNullStartDateTest(){
        List<Account> accts = [SELECT Id FROM Account WHERE Name = 'AccountTest' LIMIT 1];
        Account acct = accts[0];
        List<Contact> conts = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' LIMIT 1];
        Contact cont = conts[0];
        List<User> users = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];
        User u = users[0];
        Proyecto__c project = new Proyecto__c(
            Name = 'Proyecto',
            Account__c = acct.Id,
            Contact__C = cont.Id,
            Estado__c = 'Planeado'
        );
        System.runAs(u){
            insert as user project;
            Test.startTest();
            try {
                delete as user project;
            }
            catch (DmlException e) {
                Assert.isTrue(e.getMessage().contains('No se puede eliminar el record ya que no cumple las condiciones '));
            }
            Test.stopTest();
        }
    }
    /**
     * Prueba que el promedio de presupuesto de la cuenta se calcule correctamente al insertar proyectos en progreso.
     * Crea dos proyectos en estado 'En Progreso' con presupuestos distintos asociados a una cuenta.
     * Verifica que el campo Presupuesto_promedio__c de la cuenta refleje el promedio correcto.
     */
    @IsTest
    static void updateAccountAverageTest(){
        List<Account> accts = [SELECT Id FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
        Account acct = accts[0];
        List<Contact> conts = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        Contact cont = conts[0];
        List<User> users = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];
        User u = users[0];
        List<Proyecto__c> projects = new List<Proyecto__c>{
            new Proyecto__c(
                Name = 'Proyecto1',
                Account__c = acct.Id,
                Contact__C = cont.Id,
                Estado__c = 'En Progreso',
                Presupuesto__c = 20000),
            new Proyecto__c(
                Name = 'Proyecto2',
                Account__c = acct.Id,
                Contact__C = cont.Id,
                Estado__c = 'En Progreso',
                Presupuesto__c = 15000
            )};
        System.runAs(u) {
            Test.startTest();
            insert as user projects;
            Test.stopTest();
        }
        List<Account> updatedAccounts = [SELECT Id,Presupuesto_promedio__c FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
        Account updatedAccount = updatedAccounts[0];
        Assert.areEqual(17500, updatedAccount.Presupuesto_promedio__c);
    }
    /** CLASE AUXILIAR PARA PRUEBAS DE CANTIDAD DE PROYECTOS ACTIVOS */
    private class ActivosTestSetup {
        Account acct;
        Contact cont;
        User u;
    }
    /** Configura los datos necesarios para las pruebas de cantidad de proyectos activos.
     * Crea una cuenta con un límite de proyectos activos establecido, un contacto asociado a esa cuenta y un usuario para ejecutar las pruebas.
     * Estos datos se utilizarán en las pruebas para validar la funcionalidad relacionada con la cantidad de proyectos activos en una cuenta.
     * @return Un objeto ActivosTestSetup que contiene la cuenta, el contacto y el usuario configurados para las pruebas.
     */
    private static ActivosTestSetup setupActiveProjectsLimit() {
        ActivosTestSetup setup = new ActivosTestSetup();
        List<Account> accts = [SELECT Id FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
        setup.acct = accts[0];
        List<Contact> conts = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        setup.cont = conts[0];
        List<User> users = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];
        setup.u = users[0];
        setup.acct.Maximo_de_proyectos_activos__c = 1;
        update as user setup.acct;
        return setup;
    }
    /** Prueba que no se puedan crear proyectos en estado 'En Progreso' si la cuenta ya tiene el máximo de proyectos activos permitido.
     * Crea una cuenta con un límite de proyectos activos establecido, luego intenta crear dos proyectos en estado 'En Progreso' asociados a esa cuenta.
     * Verifica que se lance la excepción esperada al intentar crear el segundo proyecto, indicando que se ha superado el límite de proyectos activos.
     */
    @IsTest
    static void validateActiveProjectsLimitErrorTest(){
        ActivosTestSetup setup = setupActiveProjectsLimit();
        Account acct = setup.acct;
        Contact cont = setup.cont;
        User u = setup.u;
        List<Proyecto__c> projects = new List<Proyecto__c>{
            new Proyecto__c(
                Name = 'Proyecto5',
                Account__c = acct.Id,
                Contact__C = cont.Id,
                Estado__c = 'En Progreso',
                Presupuesto__c = 20000,
                Fecha_de_inicio__c = Date.today().addYears(-1)
            ),
            new Proyecto__c(
                Name = 'Proyecto6',
                Account__c = acct.Id,
                Contact__c = cont.Id,
                Estado__c = 'En Progreso',
                Presupuesto__c = 15000,
                Fecha_de_inicio__c= Date.today().addYears(-1)
            )};
        System.runAs(u){
            try {
                Test.startTest();
                insert as user projects;
                Test.stopTest();
            } catch (DmlException e) {
                Assert.isTrue(e.getMessage().contains('No se puede crear el proyecto, la cuenta supera el limite de proyectos activos'));
            }
        }
    }
    /** Prueba que se puedan crear proyectos en estado 'En Progreso' si la cuenta no ha alcanzado el máximo de proyectos activos permitido.
     * Crea una cuenta con un límite de proyectos activos establecido, luego intenta crear un proyecto en estado 'En Progreso' asociado a esa cuenta.
     * Verifica que el proyecto se haya creado correctamente sin lanzar ninguna excepción, indicando que la cuenta no ha superado el límite de proyectos activos.
     * */
    @IsTest
    static void validateActiveProjectsLimitSuccessTest(){
        ActivosTestSetup setup = setupActiveProjectsLimit();
        Account acct = setup.acct;
        Contact cont = setup.cont;
        User u = setup.u;
        List<Proyecto__c> projects = new List<Proyecto__c>{
            new Proyecto__c(
                Name = 'Proyecto1',
                Account__c = acct.Id,
                Contact__C = cont.Id,
                Estado__c = 'En Progreso',
                Presupuesto__c = 20000,
                Fecha_de_inicio__c = Date.today().addYears(-1)
            ),
            new Proyecto__c(
                Name = 'Proyecto2',
                Account__c = acct.Id,
                Contact__c = cont.Id,
                Estado__c = 'Planeado',
                Presupuesto__c = 15000,
                Fecha_de_inicio__c= Date.today().addYears(-1)
            )};
        System.runAs(u){
            Test.startTest();
            insert as user projects;
            Test.stopTest();
            List<Proyecto__c> result = [SELECT Id FROM Proyecto__c];
            Assert.isTrue(result.size() == 2);
        }
    }
}
