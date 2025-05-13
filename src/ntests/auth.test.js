import { describe, it, expect, beforeAll, afterAll } from '@jest/globals';
import { apiRequest, authenticateUser, createTestUser } from './utils/testUtils.js';
import config from './config.js';

describe('🔐 Authentication Tests', () => {
  let testUser;
  let testUserToken;

  beforeAll(async () => {
    // Create a test user before running the tests
    const result = await createTestUser();
    testUser = result.user;
    testUserToken = result.token;
  });

  describe('POST /api/v1/auth/signup', () => {
    it('should register a new user', async () => {
      const newUser = {
        email: `test-${Date.now()}@example.com`,
        password: 'TestPass123!',
        firstName: 'Test',
        lastName: 'User',
        phoneNumber: '1234567890',
        address: '123 Test St',
      };

      const response = await apiRequest({
        method: 'POST',
        url: config.endpoints.auth.signup,
        data: newUser,
      });

      expect(response.status).toBe(201);
      expect(response.data).toHaveProperty('data');
      expect(response.data.data).toHaveProperty('email', newUser.email);
      expect(response.data.data).not.toHaveProperty('password');
    });

    it('should fail with 400 for invalid user data', async () => {
      const invalidUser = {
        email: 'invalid-email',
        password: 'short',
      };

      const response = await apiRequest({
        method: 'POST',
        url: config.endpoints.auth.signup,
        data: invalidUser,
      });

      expect(response.status).toBe(400);
      expect(response.data).toHaveProperty('error');
    });
  });

  describe('POST /api/v1/auth/signin', () => {
    it('should authenticate with valid credentials', async () => {
      const response = await apiRequest({
        method: 'POST',
        url: config.endpoints.auth.signin,
        data: {
          email: testUser.email,
          password: testUser.password,
        },
      });

      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('data');
      expect(response.data.data).toHaveProperty('token');
      expect(typeof response.data.data.token).toBe('string');
    });

    it('should fail with 401 for invalid credentials', async () => {
      const response = await apiRequest({
        method: 'POST',
        url: config.endpoints.auth.signin,
        data: {
          email: testUser.email,
          password: 'wrong-password',
        },
      });

      expect(response.status).toBe(401);
      expect(response.data).toHaveProperty('error');
    });
  });

  describe('Protected Routes', () => {
    it('should allow access with valid token', async () => {
      const response = await apiRequest({
        method: 'GET',
        url: config.endpoints.lostItems,
        token: testUserToken,
      });

      expect([200, 204]).toContain(response.status);
    });

    it('should deny access without token', async () => {
      const response = await apiRequest({
        method: 'GET',
        url: config.endpoints.lostItems,
      });

      expect(response.status).toBe(401);
      expect(response.data).toHaveProperty('error');
    });

    it('should deny access with invalid token', async () => {
      const response = await apiRequest({
        method: 'GET',
        url: config.endpoints.lostItems,
        headers: {
          Authorization: 'Bearer invalid.token.here',
        },
      });

      expect(response.status).toBe(401);
      expect(response.data).toHaveProperty('error');
    });
  });
});
