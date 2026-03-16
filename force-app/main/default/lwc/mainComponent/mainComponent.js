// MainComponent.js
import { LightningElement } from 'lwc';

export default class MainComponent extends LightningElement {
    selectedAccountId;
    handleAccountSelection(event) {
        this.selectedAccountId = event.detail;
    }
    handleCreation() {
        const projectDataTable = this.template.querySelector('c-proyecto-data-table');
        if (projectDataTable) {
            projectDataTable.refreshProjects();
        }
    }

    get Record() {
        return this.selectedAccountId;
    }
}
