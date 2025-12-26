/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest
private class TriggerProyectoHandlerTest {
   @TestSetup
static void makeData() {
    User admin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(admin) {
        Profile p = [SELECT Id FROM Profile WHERE Name IN ('System Administrator') LIMIT 1];
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
        User u2 = new  User(
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
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Bypass_Validation_Rules' LIMIT 1];
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
    @IsTest
    static void updateDescripcionAlto(){

        //PRUEBO QUE SE ACTUALICE LA DESCRIPCION DEL CONTACTO CUANDO SE ACTUALIZA UN PROYECTO CON PRESUPUESTO ALTO
        Account acct = [SELECT Id FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        User u = [SELECT Id FROM User WHERE Alias = 'test' WITH USER_MODE LIMIT 1];
        Proyecto__c proyecto = new Proyecto__c(Name = 'ProyectoTest',Account__c = acct.Id ,Contact__c = cont.Id);
        insert as user proyecto;
        proyecto.Presupuesto__c = 550000;
        System.runAs(u){
            Test.startTest();
            update proyecto;
            Test.stopTest();
        }
        Contact updatedContact = [SELECT Id,Descripcion__c FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        Assert.areEqual('Este contacto está asociado con un proyecto con presupuesto alto.', updatedContact.Descripcion__c);
    }
        @IsTest
    static void insertDescripcionDeContactoExitoso(){
        //PRUEBO QUE SE ACTUALICE LA DESCRIPCION DEL CONTACTO CUANDO SE INSERTA UN PROYECTO CON PRESUPUESTO ALTO
        Account acct = [SELECT Id FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        Proyecto__c proyecto = new Proyecto__c(Name = 'ProyectoTest',Account__c = acct.Id ,Contact__c = cont.Id,Presupuesto__c = 60000);
        User u = [SELECT Id FROM User WHERE Alias = 'test' WITH USER_MODE LIMIT 1];

         System.runAs(u){
            Test.startTest();
            insert as user proyecto;
            Test.stopTest();
        }

        Contact updatedContact = [SELECT Id,Descripcion__c FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        Assert.areEqual('Este contacto está asociado con un proyecto con presupuesto alto.', updatedContact.Descripcion__c);
    }
    @IsTest
    static void updateDescripcionDeContactoFallido(){
        //PRUEBO QUE NO SE ACTUALICE LA DESCRIPCION DEL CONTACTO CUANDO SE ACTUALIZA UN PROYECTO CON PRESUPUESTO BAJO
        Account acct = [SELECT Id FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        Proyecto__c proyecto = new Proyecto__c(Name = 'ProyectoTest',Account__c = acct.Id ,Contact__c = cont.Id,Presupuesto__c = 5000);
        User u = [SELECT Id FROM User WHERE Alias = 'test' WITH USER_MODE LIMIT 1];

       System.runAs(u){
            Test.startTest();
            insert as user proyecto;
            Test.stopTest();
        }

        Contact updatedContact = [SELECT Id,Descripcion__c FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
        Assert.areNotEqual('Este contacto está asociado con un proyecto con presupuesto alto.', updatedContact.Descripcion__c);
    }
    @IsTest
    static void deleteProyectoBorradoExitoso(){
        //PRUEBO ELIMINAR PROYECTOS DE FORMA EXITOSA
        Account acct = [SELECT Id, Presupuesto_promedio__c FROM Account WHERE Name = 'AccountTest' LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' LIMIT 1];
        User u = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];

            List<Proyecto__c> proyectos = new List<Proyecto__c>{
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

        Proyecto__c pro = new Proyecto__c(
            Name = 'Proyecto',
            Account__c = acct.Id,
            Contact__C = cont.Id,
            Estado__c = 'Planeado',
            Fecha_de_inicio__c = Date.today().addYears(-1)
        );

        System.runAs(u){
            insert proyectos;
             Account acctBeforeDelete = [SELECT Id, Presupuesto_promedio__c FROM Account WHERE Id = :acct.Id WITH USER_MODE LIMIT 1];
            Assert.isTrue(acctBeforeDelete.Presupuesto_promedio__c != null, 'Debió establecerse un promedio antes del borrado');
             insert pro;

            Test.startTest();
            delete pro;
            Test.stopTest();
        }

        List<Proyecto__c> listaResultado = [SELECT Id FROM Proyecto__c WHERE Id = :pro.Id];
        Assert.areEqual(0, listaResultado.size(), 'El registro no debería existir , por ende fue eliminado correctamente');

        Account acctAfterDelete = [SELECT Id, Presupuesto_promedio__c FROM Account WHERE Id = :acct.Id WITH USER_MODE LIMIT 1];
        Assert.areEqual(10000, acctAfterDelete.Presupuesto_promedio__c, 'El promedio de la cuenta debe recalcularse tras afterDelete');
    }
    @IsTest
    static void deleteProyectoBorradoFallido(){
        //PRUEBO ELIMINAR PROYECTOS DE FORMA FALLIDA
        Account acct = [SELECT Id FROM Account WHERE Name = 'AccountTest' LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE Alias = 'test2' LIMIT 1];
            Proyecto__c pro = new Proyecto__c(
            Name = 'Proyecto',
            Account__c = acct.Id,
            Contact__C = cont.Id,
            Estado__c = 'Planeado',
            Fecha_de_inicio__c = Date.today()
            );
            insert pro;
            System.runAs(u2){
                Test.startTest();
                try {
                    delete pro;
                }
                catch (DmlException m) {
                    Assert.isTrue(m.getMessage().contains('No se puede eliminar el record ya que no cumple las condiciones '));
                }
                Test.stopTest();
            }
    }
    @IsTest
     static void deleteProyectoFechaInicioNullTest(){
        //PRUEBO ELIMINAR PROYECTOS NULOS
        Account acct = [SELECT Id FROM Account WHERE Name = 'AccountTest' LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' LIMIT 1];
        User u = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];
            Proyecto__c pro = new Proyecto__c(
            Name = 'Proyecto',
            Account__c = acct.Id,
            Contact__C = cont.Id,
            Estado__c = 'Planeado'
            );

            System.runAs(u){
            insert as user pro;
            Test.startTest();
            try {
                delete as user pro;
            }
            catch (DmlException m) {
            Assert.isTrue(m.getMessage().contains('No se puede eliminar el record ya que no cumple las condiciones '));
            }
            Test.stopTest();
        }
    }
    @IsTest
    static void actualizarPromedioDeAccount(){
            // PRUEBO ACTUALIZAR EL PROMEDIO DE LA CUENTA
            Account acct = [SELECT Id FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
            Contact cont = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
            User u = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];
            List<Proyecto__c> proyectos = new List<Proyecto__c>{
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
                insert as user  proyectos;
                Test.stopTest();
            }
            Account updatedAccount = [SELECT Id,Presupuesto_promedio__c FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
            Assert.areEqual(17500, updatedAccount.Presupuesto_promedio__c);
    }
    @IsTest
    static void verificarCantidadActivosErrorTest(){
            //PRUEBO VERIFICAR LA CANTIDAD DE PROYECTOS ACTIVOS , ERROR
            Account acct = [SELECT Id FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
            Contact cont = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' WITH USER_MODE LIMIT 1];
            User u = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];
            acct.Maximo_de_proyectos_activos__c = 1;
            update as user acct;
            List<Proyecto__c> proyectos = new List<Proyecto__c>{
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
                insert as user proyectos;
                Test.stopTest();
            } catch (DmlException m) {
                Assert.isTrue(m.getMessage().contains('No se puede crear el proyecto, la cuenta supera el limite de proyectos activos'));
            }
        }
    }
    @IsTest
    static void verificarCantidadActivosExitosoTest(){
            //PRUEBO VERIFICAR LA CANTIDAD DE PROYECTOS ACTIVOS , EXITOSO
            Account acct = [SELECT Id FROM Account WHERE Name = 'AccountTest' WITH USER_MODE LIMIT 1];
            Contact cont = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' WITH USER_mODE LIMIT 1];
            User u = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];
            acct.Maximo_de_proyectos_activos__c = 1;
            update as user acct;
            List<Proyecto__c> proyectos = new List<Proyecto__c>{
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
            insert as user proyectos;
            Test.stopTest();
            List<Proyecto__c> resultado = [SELECT Id FROM Proyecto__c];
            Assert.isTrue(resultado.size() == 2);
        }
    }
}