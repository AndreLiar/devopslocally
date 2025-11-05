// Integration tests - test across multiple components
describe('Integration Tests', () => {
  let app;
  let apiClient;

  beforeAll(() => {
    delete require.cache[require.resolve('../server.js')];
    app = require('../server.js');
    apiClient = global.testUtils.createApiClient(app);
  });

  describe('API Workflow', () => {
    it('should complete a health check workflow', async () => {
      const healthRes = await apiClient
        .get('/health')
        .expect(200);

      expect(healthRes.body.status).toBe('ok');
      
      // Follow-up request should also work
      const secondRes = await apiClient
        .get('/health')
        .expect(200);

      expect(secondRes.body.status).toBe('ok');
    });
  });

  describe('Multiple Request Patterns', () => {
    it('should handle sequential requests without issues', async () => {
      const requests = Array(5).fill().map(() => 
        apiClient.get('/health').expect(200)
      );

      const results = await Promise.all(requests);
      
      results.forEach(res => {
        expect(res.body.status).toBe('ok');
      });
    });

    it('should handle concurrent requests', async () => {
      const concurrentRequests = Array(10).fill().map(() =>
        apiClient.get('/health')
      );

      const results = await Promise.all(concurrentRequests);
      
      results.forEach(res => {
        expect(res.status).toBe(200);
        expect(res.body.status).toBe('ok');
      });
    });
  });

  describe('Response Consistency', () => {
    it('should return consistent response structure', async () => {
      const requests = Array(3).fill().map(() =>
        apiClient.get('/health')
      );

      const [res1, res2, res3] = await Promise.all(requests);

      // All should have same keys
      const keys1 = Object.keys(res1.body).sort();
      const keys2 = Object.keys(res2.body).sort();
      const keys3 = Object.keys(res3.body).sort();

      expect(keys1).toEqual(keys2);
      expect(keys2).toEqual(keys3);
    });
  });

  describe('Error Recovery', () => {
    it('should recover after a bad request', async () => {
      // Send invalid request
      await apiClient
        .get('/invalid-route')
        .expect(404);

      // Should still work normally after
      const res = await apiClient
        .get('/health')
        .expect(200);

      expect(res.body.status).toBe('ok');
    });
  });

  describe('Data Validation', () => {
    it('should validate response data types', async () => {
      const res = await apiClient
        .get('/health')
        .expect(200);

      expect(typeof res.body.status).toBe('string');
      expect(typeof res.body.timestamp).toBe('number');
      expect(res.body.timestamp).toBeGreaterThan(0);
    });
  });
});
