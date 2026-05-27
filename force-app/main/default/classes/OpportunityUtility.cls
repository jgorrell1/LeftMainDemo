/**
 * @description Utility class for Opportunity object operations
 * @author Salesforce
 * @date 2026
 */
public with sharing class OpportunityUtility {
    
    /**
     * @description Retrieves all open opportunities sorted by Investor Hot Score in descending order
     * @return List<Opportunity> List of open opportunities sorted by hot score
     */
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpenOpportunitiesByHotScore() {
        try {
            return [
                SELECT Id, 
                       Name, 
                       StageName, 
                       CloseDate, 
                       Amount,
                       AccountId,
                       Account.Name,
                       OwnerId,
                       Owner.Name,
                       Investor_Hot_Score__c,
                       Probability
                FROM Opportunity
                WHERE IsClosed = false
                ORDER BY Investor_Hot_Score__c DESC NULLS LAST, 
                         CloseDate ASC
                LIMIT 50000
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving opportunities: ' + e.getMessage());
        }
    }
}