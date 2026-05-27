import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOpenOpportunitiesByHotScore from '@salesforce/apex/OpportunityUtility.getOpenOpportunitiesByHotScore';

const COLUMNS = [
    {
        label: 'Opportunity Name',
        fieldName: 'opportunityUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        },
        sortable: true
    },
    {
        label: 'Account Name',
        fieldName: 'accountUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'AccountName' },
            target: '_blank'
        },
        sortable: true
    },
    {
        label: 'Stage',
        fieldName: 'StageName',
        type: 'text',
        sortable: true
    },
    {
        label: 'Close Date',
        fieldName: 'CloseDate',
        type: 'date',
        sortable: true
    },
    /*{
        label: 'Amount',
        fieldName: 'Amount',
        type: 'currency',
        sortable: true
    },*/
    {
        label: 'Hot Score',
        fieldName: 'Investor_Hot_Score__c',
        type: 'number',
        sortable: true,
        cellAttributes: {
            class: { fieldName: 'hotScoreClass' }
        }
    },
    /*{
        label: 'Probability',
        fieldName: 'Probability',
        type: 'percent',
        typeAttributes: {
            step: '0.01',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        },
        sortable: true
    },
    {
        label: 'Owner',
        fieldName: 'OwnerName',
        type: 'text',
        sortable: true
    }*/
];

export default class InvestorHotScore extends NavigationMixin(LightningElement) {
    @api height; // Configurable height for utility bar
    columns = COLUMNS;
    opportunities = [];
    error;
    sortBy;
    sortDirection;

    @wire(getOpenOpportunitiesByHotScore)
    wiredOpportunities({ error, data }) {
        if (data) {
            // Transform data to include URLs and styling
            this.opportunities = data.map(opp => {
                return {
                    ...opp,
                    AccountName: opp.Account?.Name || '',
                    OwnerName: opp.Owner?.Name || '',
                    opportunityUrl: `/lightning/r/Opportunity/${opp.Id}/view`,
                    accountUrl: `/lightning/r/Account/${opp.AccountId}/view`,
                    hotScoreClass: this.getHotScoreClass(opp.Investor_Hot_Score__c)
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.opportunities = [];
        }
    }

    getHotScoreClass(score) {
        if (score >= 80) {
            return 'slds-text-color_success slds-text-title_bold';
        } else if (score >= 50) {
            return 'slds-text-color_default';
        } else if (score > 0) {
            return 'slds-text-color_weak';
        }
        return '';
    }

    handleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldName, direction) {
        // Create a copy of the data to sort
        let parseData = JSON.parse(JSON.stringify(this.opportunities));
        
        // Map URL fields back to their base field names for sorting
        let keyValue = (a) => {
            if (fieldName === 'opportunityUrl') {
                return a['Name'];
            } else if (fieldName === 'accountUrl') {
                return a['AccountName'];
            } else {
                return a[fieldName];
            }
        };

        // Check if the field is a string
        let isReverse = direction === 'asc' ? 1 : -1;

        // Sort the data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });

        this.opportunities = parseData;
    }

    get hasOpportunities() {
        return this.opportunities && this.opportunities.length > 0;
    }

    get recordCount() {
        return this.opportunities ? this.opportunities.length : 0;
    }
}