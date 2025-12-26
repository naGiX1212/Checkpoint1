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
private class ProyectoControllerTest {

    @TestSetup
    static void makeData(){
         User admin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(admin){
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
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Bypass_Validation_Rules' LIMIT 1];
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
    @IsTest
    static void deleteProyectoByIdTestExito() {
            //PRUEBO ELIMINAR PROYECTOS , EXITOSO
            Account acct = [SELECT Id FROM Account WHERE Name = 'AccountTest' LIMIT 1];
            Contact cont = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' LIMIT 1];
            User u = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];
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
     @IsTest
    static void deleteProyectoByIdTestFallido() {
            //PRUEBO ELIMINAR PROYECTOS , FALLIDO
            Account acct = [SELECT Id FROM Account WHERE Name = 'AccountTest' LIMIT 1];
            Contact cont = [SELECT Id FROM Contact WHERE LastName = 'ContactTest' LIMIT 1];
            User u = [SELECT Id FROM User WHERE Alias = 'test' LIMIT 1];
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
