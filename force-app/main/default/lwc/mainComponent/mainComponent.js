// MainComponent.js
import { LightningElement } from 'lwc';

export default class MainComponent extends LightningElement {
    idSeleccionado;
    handleAccountSelection(event) {
        this.idSeleccionado = event.detail;
    }
    handleCreation() {
        const proyDt = this.template.querySelector('c-proyecto-data-table');
        proyDt.proyectoRefresh();
    }

    get Record() {
        return this.idSeleccionado;
    }
}
