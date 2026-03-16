import { api, LightningElement,wire } from 'lwc';
import { gql, graphql } from "lightning/graphql";

export default class AccountInfo extends LightningElement {
    @api searchId;
    @wire(graphql, {
        query: gql`
            query GetAccount($accId: ID) {
                uiapi {
                    query {
                        Account(where: { Id: { eq: $accId } }) {
                            edges {
                                node {
                                    Id
                                    Name { value }
                                    Presupuesto_Total__c { value }
                                    Proyectos__r {
                                        edges {
                                            node {
                                                Id
                                                Name { value }
                                                Numero_de_Recursos__c { value }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        `,
        variables: '$recordIdVariable'
    })
    account;

    get recordIdVariable() {
        return {
            accId: this.searchId || null
        };
    }

    get totalRecursos() {
        const proyectos = this.account.data?.uiapi?.query?.Account?.edges?.[0]?.node?.Proyectos__r?.edges;
        let total = 0;
        if(proyectos){
            for(const item of proyectos){
                total += item.node.Numero_de_Recursos__c?.value || 0;
            }
        }
        return total;
    }
}
