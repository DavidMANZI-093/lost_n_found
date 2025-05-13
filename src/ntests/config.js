// Test environment configuration
export const config = {
  api: {
    baseUrl: process.env.API_BASE_URL || 'http://localhost:8080',
    timeout: 10000, // 10 seconds
  },
  auth: {
    admin: {
      email: process.env.ADMIN_EMAIL || 'admin@lostfound.com',
      password: process.env.ADMIN_PASSWORD || 'AdminPass123!',
    },
    user: {
      email: process.env.TEST_USER_EMAIL || 'testuser@example.com',
      password: process.env.TEST_USER_PASSWORD || 'password123',
    },
  },
  testData: {
    newUser: {
      email: `test-${Date.now()}@example.com`,
      password: 'TestPass123!',
      firstName: 'Test',
      lastName: 'User',
      phoneNumber: '1234567890',
      address: '123 Test St, Test City',
    },
  },
  endpoints: {
    auth: {
      signup: '/api/v1/auth/signup',
      signin: '/api/v1/auth/signin',
    },
    admin: {
      users: '/api/v1/admin/users',
      items: '/api/v1/admin/items',
      reports: '/api/v1/admin/reports',
    },
    lostItems: '/api/v1/lost-items',
    foundItems: '/api/v1/found-items',
  },
};

export default config;
