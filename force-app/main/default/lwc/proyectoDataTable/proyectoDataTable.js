import { LightningElement, wire, api } from 'lwc';
import { gql, graphql } from "lightning/graphql";
import deleteProyectoById from '@salesforce/apex/ProyectoController.deleteProyectoById'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Nombre Proyecto', fieldName: 'Name', type: 'text' },
    { label: 'Presupuesto', fieldName: 'Presupuesto', type: 'currency' },
    { label: 'Estado', fieldName: 'Estado', type: 'text' },
    { label: 'Contacto',fieldName:'Contacto',type:'text'}
];

export default class ProyectoDataTable extends LightningElement {
    @api recordId;
    @api
    proyectoRefresh(){
        this._refresh();
    }

    columns = COLUMNS;
    _data;
    _refresh;
    selectorIds=[]
    get showButton() {
        return this.selectorIds && this.selectorIds.length > 0;
    }
    @wire(graphql, {
        query: gql`
            query GetProyectos($accId: ID) {
                uiapi {
                    query {
                        Proyecto__c(where: { Account__c: { eq: $accId }},first:50) {
                            edges {
                                node {
                                    Id
                                    Name { value }
                                    Presupuesto__c { value }
                                    Estado__c { value }
                                    Contact__r {
                                        Name { value }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        `,
        variables: '$graphqlVariables'
    })
    proyectos({data,errors,refresh}){
        this._refresh = refresh;
        if(data){
            this._data = data;
        }
        if(errors){
            console.log(errors);
        }
    };

    get graphqlVariables() {
        return {
            accId: this.recordId || null
        };
    }
    //OBTENGO LOS PROY
    get allProyectos() {
        const dataSalesforce = this._data?.uiapi?.query?.Proyecto__c?.edges;
        const lista = [];
        if (!dataSalesforce) return [];
        for(const item of dataSalesforce){
            const data = {
                Id: item.node.Id,
                Name: item.node.Name?.value,
                Presupuesto: item.node.Presupuesto__c?.value,
                Estado: item.node.Estado__c?.value,
                Contacto: item.node.Contact__r?.Name?.value
            }
            lista.push(data);
        }
        return lista;
    }
    //EVENTO AL SELECCIONAR ROWS EN LA DATA TABLE
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectorIds = selectedRows.map(row => row.Id);
    }
    //ELIMINAR SELECCIONADOS
    async handleDeleteSelection() {
        if (this.selectorIds.length === 0) return;

        try {
            await deleteProyectoById({ ids: this.selectorIds });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Exito',
                message: 'Proyectos eliminados correctamente',
                variant: 'success'
            }));

            this.selectorIds = [];
            if (this._refresh) {
                await this._refresh();
            }
        } catch (error) {
            let mensaje = 'Ocurrio un error inesperado';

            if (error.body && error.body.message) {
                mensaje = error.body.message;

                if (mensaje.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION,')) {
                    const partes = mensaje.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                    mensaje = partes[1].trim();
                    mensaje = mensaje.replace(/: \[\]$/, '');
                }
            }

            this.dispatchEvent(new ShowToastEvent({
                title: 'No se pudo eliminar',
                message: mensaje,
                variant: 'error',
                mode: 'sticky'
            }));
        }
    }
}
