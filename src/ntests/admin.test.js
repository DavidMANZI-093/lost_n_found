import { describe, it, expect, beforeAll, afterAll } from '@jest/globals';
import { apiRequest, authenticateUser, createTestUser } from './utils/testUtils.js';
import config from './config.js';

describe('👑 Admin Tests', () => {
  let adminToken;
  let regularUserToken;
  let regularUserId;
  let testLostItemId;
  let testFoundItemId;

  beforeAll(async () => {
    // Login as admin
    adminToken = await authenticateUser(
      config.auth.admin.email,
      config.auth.admin.password
    );

    // Create a regular test user
    const regularUser = await createTestUser();
    regularUserToken = regularUser.token;
    regularUserId = regularUser.user.id; // This would need to be set from the API response
  });

  describe('User Management', () => {
    it('should allow admin to get all users', async () => {
      const response = await apiRequest({
        method: 'GET',
        url: config.endpoints.admin.users,
        token: adminToken,
      });

      expect(response.status).toBe(200);
      expect(Array.isArray(response.data.data)).toBe(true);
    });

    it('should allow admin to ban/unban a user', async () => {
      // First, ban the user
      const banResponse = await apiRequest({
        method: 'PATCH',
        url: `${config.endpoints.admin.users}/${regularUserId}`,
        token: adminToken,
        data: { isBanned: true },
      });

      expect(banResponse.status).toBe(200);
      expect(banResponse.data.data.isBanned).toBe(true);

      // Then unban the user
      const unbanResponse = await apiRequest({
        method: 'PATCH',
        url: `${config.endpoints.admin.users}/${regularUserId}`,
        token: adminToken,
        data: { isBanned: false },
      });

      expect(unbanResponse.status).toBe(200);
      expect(unbanResponse.data.data.isBanned).toBe(false);
    });

    it('should prevent regular users from accessing admin endpoints', async () => {
      const response = await apiRequest({
        method: 'GET',
        url: config.endpoints.admin.users,
        token: regularUserToken,
      });

      expect(response.status).toBe(403);
    });
  });

  describe('Item Moderation', () => {
    beforeAll(async () => {
      // Create test items for moderation
      const lostItemResponse = await apiRequest({
        method: 'POST',
        url: config.endpoints.lostItems,
        token: regularUserToken,
        data: {
          title: 'Test Lost Item',
          description: 'This is a test lost item',
          category: 'Electronics',
          location: 'Test Location',
          lostDate: new Date().toISOString(),
        },
      });

      const foundItemResponse = await apiRequest({
        method: 'POST',
        url: config.endpoints.foundItems,
        token: regularUserToken,
        data: {
          title: 'Test Found Item',
          description: 'This is a test found item',
          category: 'Accessories',
          location: 'Test Location',
          foundDate: new Date().toISOString(),
          storageLocation: 'Test Storage',
        },
      });

      testLostItemId = lostItemResponse?.data?.data?.id;
      testFoundItemId = foundItemResponse?.data?.data?.id;
    });

    it('should allow admin to approve a lost item', async () => {
      const response = await apiRequest({
        method: 'PATCH',
        url: `${config.endpoints.admin.items}/${testLostItemId}`,
        token: adminToken,
        data: {
          status: 'APPROVED',
          type: 'LOST',
        },
      });

      expect(response.status).toBe(200);
      expect(response.data.data.status).toBe('APPROVED');
    });

    it('should allow admin to reject a found item', async () => {
      const response = await apiRequest({
        method: 'PATCH',
        url: `${config.endpoints.admin.items}/${testFoundItemId}`,
        token: adminToken,
        data: {
          status: 'REJECTED',
          type: 'FOUND',
          rejectionReason: 'Insufficient information',
        },
      });

      expect(response.status).toBe(200);
      expect(response.data.data.status).toBe('REJECTED');
    });
  });

  describe('Reports', () => {
    it('should allow admin to get system reports', async () => {
      const response = await apiRequest({
        method: 'GET',
        url: config.endpoints.admin.reports,
        token: adminToken,
      });

      expect(response.status).toBe(200);
      expect(response.data.data).toHaveProperty('userStats');
      expect(response.data.data).toHaveProperty('itemStats');
      expect(response.data.data).toHaveProperty('recentActivity');
    });
  });
});
