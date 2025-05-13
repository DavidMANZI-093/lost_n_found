import { describe, it, expect, beforeAll, afterAll } from '@jest/globals';
import { apiRequest, authenticateUser, createTestUser } from './utils/testUtils.js';
import config from './config.js';

describe('📦 Items Management Tests', () => {
  let regularUserToken;
  let adminToken;
  let testItemId;
  let testUserId;

  beforeAll(async () => {
    // Login as admin
    adminToken = await authenticateUser(
      config.auth.admin.email,
      config.auth.admin.password
    );

    // Create a regular test user
    const regularUser = await createTestUser();
    regularUserToken = regularUser.token;
    testUserId = regularUser.user.id; // This would be set from the API response
  });

  describe('Lost Items', () => {
    it('should allow authenticated users to create a lost item', async () => {
      const itemData = {
        title: 'Lost MacBook Pro',
        description: '16-inch MacBook Pro, Space Gray, last seen in the Computer Science building',
        category: 'Electronics',
        location: 'Computer Science Building, Room 302',
        lostDate: new Date().toISOString(),
      };

      const response = await apiRequest({
        method: 'POST',
        url: config.endpoints.lostItems,
        token: regularUserToken,
        data: itemData,
      });

      expect(response.status).toBe(201);
      expect(response.data.data).toMatchObject({
        title: itemData.title,
        description: itemData.description,
        status: 'PENDING', // Default status
      });

      // Save the item ID for later tests
      testItemId = response.data.data.id;
    });

    it('should allow users to view their own lost items', async () => {
      const response = await apiRequest({
        method: 'GET',
        url: config.endpoints.lostItems,
        token: regularUserToken,
      });

      expect(response.status).toBe(200);
      expect(Array.isArray(response.data.data)).toBe(true);
      expect(response.data.data.length).toBeGreaterThan(0);
    });

    it('should allow users to update their own lost items', async () => {
      const updateData = {
        description: 'Updated description - 16-inch MacBook Pro, Space Gray, with stickers on the back',
      };

      const response = await apiRequest({
        method: 'PATCH',
        url: `${config.endpoints.lostItems}/${testItemId}`,
        token: regularUserToken,
        data: updateData,
      });

      expect(response.status).toBe(200);
      expect(response.data.data.description).toBe(updateData.description);
    });
  });

  describe('Found Items', () => {
    let foundItemId;

    it('should allow users to report found items', async () => {
      const itemData = {
        title: 'Found iPhone',
        description: 'iPhone 13 Pro, Pacific Blue, found in the library',
        category: 'Electronics',
        location: 'Main Library, 2nd floor',
        foundDate: new Date().toISOString(),
        storageLocation: 'Campus Security Office',
      };

      const response = await apiRequest({
        method: 'POST',
        url: config.endpoints.foundItems,
        token: regularUserToken,
        data: itemData,
      });

      expect(response.status).toBe(201);
      expect(response.data.data).toMatchObject({
        title: itemData.title,
        status: 'PENDING',
      });

      foundItemId = response.data.data.id;
    });

    it('should allow users to search for found items', async () => {
      const response = await apiRequest({
        method: 'GET',
        url: `${config.endpoints.foundItems}?search=iPhone`,
        token: regularUserToken,
      });

      expect(response.status).toBe(200);
      expect(Array.isArray(response.data.data)).toBe(true);
      expect(response.data.data.length).toBeGreaterThan(0);
    });
  });

  describe('Item Moderation', () => {
    it('should allow admin to approve a pending item', async () => {
      // First, create a pending item
      const itemData = {
        title: 'Test Pending Item',
        description: 'This is a test pending item',
        category: 'Other',
        location: 'Test Location',
        lostDate: new Date().toISOString(),
      };

      const createResponse = await apiRequest({
        method: 'POST',
        url: config.endpoints.lostItems,
        token: regularUserToken,
        data: itemData,
      });

      const pendingItemId = createResponse.data.data.id;

      // Then approve it as admin
      const response = await apiRequest({
        method: 'PATCH',
        url: `${config.endpoints.admin.items}/${pendingItemId}`,
        token: adminToken,
        data: {
          status: 'APPROVED',
          type: 'LOST',
        },
      });

      expect(response.status).toBe(200);
      expect(response.data.data.status).toBe('APPROVED');
    });
  });
});
