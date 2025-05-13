import axios from 'axios';
import chalk from 'chalk';
import config from '../config.js';

/**
 * Makes an authenticated API request
 * @param {Object} options - Request options
 * @param {string} options.method - HTTP method (GET, POST, etc.)
 * @param {string} options.url - API endpoint URL
 * @param {Object} [options.data] - Request body
 * @param {Object} [options.headers] - Request headers
 * @param {string} [options.token] - JWT token for authentication
 * @returns {Promise<Object>} - Response data
 */
export const apiRequest = async ({
  method = 'GET',
  url,
  data,
  headers = {},
  token,
}) => {
  try {
    const fullUrl = url.startsWith('http') ? url : `${config.api.baseUrl}${url}`;
    
    const requestConfig = {
      method,
      url: fullUrl,
      headers: {
        'Content-Type': 'application/json',
        ...(token && { Authorization: `Bearer ${token}` }),
        ...headers,
      },
      timeout: config.api.timeout,
      validateStatus: () => true, // Don't throw on HTTP error status
    };

    if (data && ['POST', 'PUT', 'PATCH'].includes(method.toUpperCase())) {
      requestConfig.data = data;
    }

    console.debug(`🌐 ${method.toUpperCase()} ${fullUrl}`);
    const response = await axios(requestConfig);

    // Log response summary
    const statusColor = response.status >= 400 ? 'red' : 'green';
    console.debug(
      `↩️  ${chalk[statusColor](response.status)} ${response.statusText}`
    );

    return {
      status: response.status,
      data: response.data,
      headers: response.headers,
    };
  } catch (error) {
    console.error(`❌ Request failed: ${error.message}`);
    throw error;
  }
};

/**
 * Authenticates a user and returns the JWT token
 * @param {string} email - User email
 * @param {string} password - User password
 * @returns {Promise<string>} JWT token
 */
export const authenticateUser = async (email, password) => {
  try {
    const { data } = await apiRequest({
      method: 'POST',
      url: config.endpoints.auth.signin,
      data: { email, password },
    });

    if (!data?.data?.token) {
      throw new Error('Authentication failed: No token received');
    }

    return data.data.token;
  } catch (error) {
    console.error('Authentication error:', error.message);
    throw error;
  }
};

/**
 * Creates a test user and returns the user data and token
 * @returns {Promise<{user: Object, token: string}>}
 */
export const createTestUser = async () => {
  const testUser = {
    ...config.testData.newUser,
    email: `test-${Date.now()}@example.com`,
  };

  // Register new user
  await apiRequest({
    method: 'POST',
    url: config.endpoints.auth.signup,
    data: testUser,
  });

  // Login to get token
  const token = await authenticateUser(testUser.email, testUser.password);

  return { user: testUser, token };
};

/**
 * Formats test results for better console output
 * @param {Object} results - Test results
 * @returns {string} Formatted test results
 */
export const formatTestResults = (results) => {
  const { numPassedTests, numFailedTests, testResults } = results;
  
  const formattedResults = testResults.map(suite => {
    const suiteResults = suite.testResults.map(test => {
      const status = test.status === 'passed' 
        ? chalk.green('✓') 
        : chalk.red('✗');
      return `  ${status} ${test.title}`;
    }).join('\n');
    
    return `${chalk.cyan(suite.name)}\n${suiteResults}`;
  }).join('\n\n');

  return `\n${formattedResults}\n\n` +
    `${chalk.green(`✓ ${numPassedTests} passed`)} | ` +
    `${chalk.red(`✗ ${numFailedTests} failed`)}`;
};
