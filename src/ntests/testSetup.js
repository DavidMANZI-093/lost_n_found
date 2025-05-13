import chalk from 'chalk';
import figlet from 'figlet';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import { jest } from '@jest/globals';

// Global test configuration
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Custom console reporter
const originalConsoleLog = console.log;
const originalConsoleError = console.error;

const log = (message, type = 'info') => {
  const timestamp = new Date().toISOString();
  const colors = {
    info: chalk.blue,
    success: chalk.green,
    warning: chalk.yellow,
    error: chalk.red,
    debug: chalk.magenta
  };
  
  const logMessage = `[${timestamp}] ${colors[type](type.toUpperCase())} ${message}`;
  originalConsoleLog(logMessage);
};

// Override console methods
console.log = (...args) => log(args.join(' '), 'info');
console.info = (...args) => log(args.join(' '), 'info');
console.warn = (...args) => log(args.join(' '), 'warning');
console.error = (...args) => log(args.join(' '), 'error');
console.debug = (...args) => log(args.join(' '), 'debug');
console.success = (...args) => log(args.join(' '), 'success');

// Global test environment setup
beforeAll(() => {
  // Display test suite header
  console.log(chalk.cyanBright(figlet.textSync('Lost & Found', { horizontalLayout: 'full' })));
  console.log(chalk.cyanBright('='.repeat(80)));
  console.log(chalk.cyanBright(`Starting Test Suite: ${new Date().toISOString()}`));
  console.log(chalk.cyanBright('='.repeat(80)));
});

// Global test teardown
afterAll(() => {
  // Restore original console methods
  console.log = originalConsoleLog;
  console.error = originalConsoleError;
});

// Custom Jest matchers
expect.extend({
  toBeWithinRange(received, floor, ceiling) {
    const pass = received >= floor && received <= ceiling;
    return {
      message: () => `expected ${received} ${pass ? 'not ' : ''}to be within range ${floor} - ${ceiling}`,
      pass,
    };
  },
});

// Global test timeout (10 seconds)
jest.setTimeout(10000);
