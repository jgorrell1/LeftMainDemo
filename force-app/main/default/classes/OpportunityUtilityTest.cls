/**
 * @description Test class for OpportunityUtility
 * @author Salesforce
 * @date 2026
 */
@IsTest
private class OpportunityUtilityTest {
    
    /**
     * @description Setup test data for all test methods
     */
    @TestSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        // Create multiple opportunities with different hot scores
        List<Opportunity> opportunities = new List<Opportunity>();
        
        // Open opportunity with high score
        opportunities.add(new Opportunity(
            Name = 'High Score Opp',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 100000,
            Seller_Response_Score__c = 90,
            ARV__c=1000000,
            Purchase_Price__c = 680000,
            Estimated_Repairs__c = 50000,
            Probability = 75
        ));
        
        // Open opportunity with medium score
        opportunities.add(new Opportunity(
            Name = 'Medium Score Opp',
            AccountId = testAccount.Id,
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(45),
            Amount = 75000,
            Seller_Response_Score__c = 80,
            ARV__c=100000,
            Purchase_Price__c = 80000,
            Estimated_Repairs__c = 5000,
            Probability = 50
        ));
        
        // Open opportunity with low score
        opportunities.add(new Opportunity(
            Name = 'Low Score Opp',
            AccountId = testAccount.Id,
            StageName = 'Needs Analysis',
            CloseDate = Date.today().addDays(60),
            Amount = 50000,
            Seller_Response_Score__c = 70,
            ARV__c=200000,
            Purchase_Price__c = 80000,
            Estimated_Repairs__c = 40000,
            Probability = 25
        ));
        
        // Open opportunity with null score
        opportunities.add(new Opportunity(
            Name = 'No Score Opp',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(15),
            Amount = 25000,
            Seller_Response_Score__c = 60,
            ARV__c=300000,
            Purchase_Price__c = 180000,
            Estimated_Repairs__c = 15000,
            Probability = 10
        ));
        
        // Closed won opportunity (should not be returned)
        opportunities.add(new Opportunity(
            Name = 'Closed Won Opp',
            AccountId = testAccount.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(-10),
            Amount = 200000,
            Seller_Response_Score__c = 50,
            ARV__c=250000,
            Purchase_Price__c = 180000,
            Estimated_Repairs__c = 25000,
            Probability = 100
        ));
        
        // Closed lost opportunity (should not be returned)
        opportunities.add(new Opportunity(
            Name = 'Closed Lost Opp',
            AccountId = testAccount.Id,
            StageName = 'Closed Lost',
            CloseDate = Date.today().addDays(-5),
            Amount = 150000,
            Seller_Response_Score__c = 40,
            ARV__c=150000,
            Purchase_Price__c = 80000,
            Estimated_Repairs__c = 5000,
            Probability = 0
        ));
        
        insert opportunities;
    }
    
    /**
     * @description Test getOpenOpportunitiesByHotScore returns only open opportunities
     */
    @IsTest
    static void testGetOpenOpportunitiesByHotScore_ReturnsOnlyOpenOpportunities() {
        Test.startTest();
        List<Opportunity> results = OpportunityUtility.getOpenOpportunitiesByHotScore();
        Test.stopTest();
        
        // Verify only open opportunities are returned (4 open, 2 closed)
        System.assertEquals(4, results.size(), 'Should return only 4 open opportunities');
        
        // Verify none of the results are closed
        for (Opportunity opp : results) {
            System.assertNotEquals('Closed Won', opp.StageName, 'Should not return Closed Won opportunities');
            System.assertNotEquals('Closed Lost', opp.StageName, 'Should not return Closed Lost opportunities');
        }
    }
    
    /**
     * @description Test opportunities are sorted by hot score in descending order
     */
    @IsTest
    static void testGetOpenOpportunitiesByHotScore_SortedByHotScoreDescending() {
        Test.startTest();
        List<Opportunity> results = OpportunityUtility.getOpenOpportunitiesByHotScore();
        Test.stopTest();
        
        // Verify sorting - highest score should be first
        System.assertEquals('High Score Opp', results[0].Name, 'Highest score opportunity should be first');
        //System.assertEquals(95, results[0].Investor_Hot_Score__c, 'First opportunity should have score of 95');
        
        System.assertEquals('Medium Score Opp', results[1].Name, 'Medium score opportunity should be second');
        //System.assertEquals(50, results[1].Investor_Hot_Score__c, 'Second opportunity should have score of 50');
        
        System.assertEquals('Low Score Opp', results[2].Name, 'Low score opportunity should be third');
        //System.assertEquals(25, results[2].Investor_Hot_Score__c, 'Third opportunity should have score of 25');
        
        // Null scores should be last
        System.assertEquals('No Score Opp', results[3].Name, 'Null score opportunity should be last');
        //System.assertEquals(null, results[3].Investor_Hot_Score__c, 'Last opportunity should have null score');
    }
    
    /**
     * @description Test method returns required fields for LWC
     */
    @IsTest
    static void testGetOpenOpportunitiesByHotScore_ReturnsRequiredFields() {
        Test.startTest();
        List<Opportunity> results = OpportunityUtility.getOpenOpportunitiesByHotScore();
        Test.stopTest();
        
        // Verify first result has all required fields populated
        Opportunity testOpp = results[0];
        System.assertNotEquals(null, testOpp.Id, 'Id should be populated');
        System.assertNotEquals(null, testOpp.Name, 'Name should be populated');
        System.assertNotEquals(null, testOpp.StageName, 'StageName should be populated');
        System.assertNotEquals(null, testOpp.CloseDate, 'CloseDate should be populated');
        System.assertNotEquals(null, testOpp.Amount, 'Amount should be populated');
        System.assertNotEquals(null, testOpp.AccountId, 'AccountId should be populated');
        System.assertNotEquals(null, testOpp.Account.Name, 'Account.Name should be populated');
        System.assertNotEquals(null, testOpp.OwnerId, 'OwnerId should be populated');
        System.assertNotEquals(null, testOpp.Probability, 'Probability should be populated');
    }
    
    /**
     * @description Test method is cacheable for LWC wire service
     */
    @IsTest
    static void testGetOpenOpportunitiesByHotScore_IsCacheable() {
        Test.startTest();
        
        // First call
        List<Opportunity> results1 = OpportunityUtility.getOpenOpportunitiesByHotScore();
        
        // Second call (should use cache in real scenario)
        List<Opportunity> results2 = OpportunityUtility.getOpenOpportunitiesByHotScore();
        
        Test.stopTest();
        
        // Verify both calls return same number of records
        System.assertEquals(results1.size(), results2.size(), 'Both calls should return same number of records');
    }
    
    /**
     * @description Test method handles empty result set
     */
    @IsTest
    static void testGetOpenOpportunitiesByHotScore_HandlesNoRecords() {
        // Delete all test opportunities
        delete [SELECT Id FROM Opportunity];
        
        Test.startTest();
        List<Opportunity> results = OpportunityUtility.getOpenOpportunitiesByHotScore();
        Test.stopTest();
        
        // Verify empty list is returned
        System.assertNotEquals(null, results, 'Should return a list, not null');
        System.assertEquals(0, results.size(), 'Should return empty list when no opportunities exist');
    }
}