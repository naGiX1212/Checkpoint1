import { LightningElement } from 'lwc';

export default class AccountSearch extends LightningElement {
    searchId = ''; 

    handleAccountSelection(event) {
        this.searchId = event.detail.recordId; 

        this.dispatchEvent(new CustomEvent('selection', {
            detail: this.searchId 
        }));
}
}