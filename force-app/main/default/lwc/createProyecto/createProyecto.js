import { LightningElement} from 'lwc';
import PROYECTO_OBJECT from '@salesforce/schema/Proyecto__c';
import FIELD_NAME from '@salesforce/schema/Proyecto__c.Name';
import FIELD_ACCOUNT from '@salesforce/schema/Proyecto__c.Account__c';
import FIELD_CONTACT from '@salesforce/schema/Proyecto__c.Contact__c';
import FIELD_DESCRIPCION from '@salesforce/schema/Proyecto__c.Descripcion__c';
import FIELD_ESTADO from '@salesforce/schema/Proyecto__c.Estado__c';
import FIELD_FECHA_INICIO from '@salesforce/schema/Proyecto__c.Fecha_de_inicio__c';
import FIELD_NUMERO_DE_RECURSOS from '@salesforce/schema/Proyecto__c.Numero_de_Recursos__c';
import FIELD_PRESUPUESTO from '@salesforce/schema/Proyecto__c.Presupuesto__c';
export default class CreateProyecto extends LightningElement {
    objectApiName = PROYECTO_OBJECT;
    fields = [
        FIELD_NAME,FIELD_ACCOUNT,FIELD_CONTACT,
        FIELD_DESCRIPCION, FIELD_ESTADO, FIELD_FECHA_INICIO,
        FIELD_NUMERO_DE_RECURSOS, FIELD_PRESUPUESTO
    ];
    recordId = undefined;
    formInstances = [{ key: 0 }];

    successHandler(event) {
        this.recordId = event.detail.id;
        this.dispatchEvent(new CustomEvent('creation'));
    }

    handleClick() {
        this.recordId = undefined;
        this.formInstances = [{ key: this.formInstances[0].key + 1 }];
    }
}
