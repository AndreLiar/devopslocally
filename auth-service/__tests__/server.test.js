// Basic server unit tests
describe('Server', () => {
  let app;

  beforeEach(() => {
    // Clear any require cache to get fresh app instance
    delete require.cache[require.resolve('../server.js')];
    app = require('../server.js');
  });

  describe('Health Check Endpoint', () => {
    it('should return 200 OK for health check', async () => {
      const res = await global.testUtils.createApiClient(app)
        .get('/health')
        .expect(200);

      expect(res.body).toHaveProperty('status');
      expect(res.body.status).toBe('ok');
    });

    it('should include timestamp in health response', async () => {
      const res = await global.testUtils.createApiClient(app)
        .get('/health')
        .expect(200);

      expect(res.body).toHaveProperty('timestamp');
    });

    it('should include version in health response', async () => {
      const res = await global.testUtils.createApiClient(app)
        .get('/health')
        .expect(200);

      expect(res.body).toHaveProperty('version');
    });
  });

  describe('Root Endpoint', () => {
    it('should return welcome message on root path', async () => {
      const res = await global.testUtils.createApiClient(app)
        .get('/')
        .expect(200);

      expect(res.body).toHaveProperty('message');
    });
  });

  describe('Error Handling', () => {
    it('should return 404 for unknown routes', async () => {
      await global.testUtils.createApiClient(app)
        .get('/unknown-route')
        .expect(404);
    });

    it('should handle JSON parsing errors', async () => {
      const res = await global.testUtils.createApiClient(app)
        .post('/api/test')
        .send('invalid json')
        .expect(400);

      expect(res.body).toHaveProperty('error');
    });
  });

  describe('Middleware', () => {
    it('should include security headers', async () => {
      const res = await global.testUtils.createApiClient(app)
        .get('/')
        .expect(200);

      expect(res.headers['x-content-type-options']).toBe('nosniff');
      expect(res.headers['x-frame-options']).toBe('DENY');
    });

    it('should accept JSON content type', async () => {
      const res = await global.testUtils.createApiClient(app)
        .post('/api/test')
        .set('Content-Type', 'application/json')
        .send({ data: 'test' })
        .expect(404); // Route doesn't exist but should accept the content-type

      expect(res.status).not.toBe(415); // Not Unsupported Media Type
    });
  });

  describe('Performance', () => {
    it('should respond within acceptable time (< 100ms)', async () => {
      const start = Date.now();
      await global.testUtils.createApiClient(app)
        .get('/health')
        .expect(200);
      const duration = Date.now() - start;

      expect(duration).toBeLessThan(100);
    });
  });
});
