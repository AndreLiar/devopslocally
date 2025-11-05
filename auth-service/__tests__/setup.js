// Unit test setup and utilities
const request = require('supertest');

// Mock environment variables for testing
process.env.NODE_ENV = 'test';
process.env.PORT = 3001;
process.env.LOG_LEVEL = 'error';

// Global test utilities
global.testUtils = {
  // Create a test API client
  createApiClient: (app) => request(app),
  
  // Generate test token (mock JWT)
  generateToken: (payload = {}) => {
    return Buffer.from(JSON.stringify({ ...payload, iat: Date.now() })).toString('base64');
  },
  
  // Wait utility for async tests
  wait: (ms) => new Promise(resolve => setTimeout(resolve, ms)),
  
  // Mock logger
  mockLogger: {
    info: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
    debug: jest.fn(),
  },
};

// Suppress console output during tests unless explicitly needed
const originalLog = console.log;
const originalError = console.error;
const originalWarn = console.warn;

console.log = jest.fn((...args) => {
  if (process.env.DEBUG) originalLog(...args);
});
console.error = jest.fn((...args) => {
  if (process.env.DEBUG) originalError(...args);
});
console.warn = jest.fn((...args) => {
  if (process.env.DEBUG) originalWarn(...args);
});

// Cleanup after all tests
afterAll(() => {
  console.log = originalLog;
  console.error = originalError;
  console.warn = originalWarn;
});
