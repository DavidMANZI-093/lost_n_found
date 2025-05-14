# Lost & Found API Testing Framework

A comprehensive testing framework for the Spring Boot Lost & Found RESTful API.

## Features

- Modular and well-organized test structure
- Progress indicators and colorful terminal output
- JSON configuration and test data
- Time metrics and performance analysis
- Detailed test result reporting
- User-friendly setup and execution

## Project Structure

```
├── config.json         # Configuration settings
├── test_data.json      # Test data for API endpoints
├── main.py             # Main test runner
├── setup.py            # Project setup utility
├── api_client.py       # API interaction client
├── db_manager.py       # Database connection manager
├── test_reporter.py    # Test reporting and metrics
├── requirements.txt    # Project dependencies
├── data/               # Data directory (created by setup)
├── reports/            # Test reports directory (created by setup)
└── tests/              # Additional test modules (created by setup)
```

## Requirements

Python 3.7 or higher is required. All dependencies are listed in `requirements.txt`.

## Setup

1. Install dependencies:

```bash
pip install -r requirements.txt
```

2. Ensure your Spring Boot API is running at http://localhost:8080 (or update the URL in config.json)

3. Configure your PostgreSQL database settings in config.json

4. Run the setup utility:

```bash
python setup.py --setup
```

This will create the project directory structure and verify your database and API connections.

## Running Tests

To run the full test suite:

```bash
python main.py
```

## Test Stages

The testing framework runs through the following stages:

1. **Authentication** - User registration and login
2. **Lost Items** - CRUD operations for lost items
3. **Found Items** - CRUD operations for found items
4. **Admin Operations** - Admin-specific functionality
5. **Search & Statistics** - Search and statistical operations

Each stage is clearly indicated during test execution, with progress indicators and timing information.

## Metrics and Reporting

After test completion, the framework provides:

- Success/failure status for each test
- Response time metrics for all API endpoints
- Overall test summary by stage
- Success rate and total execution time

## Customization

You can customize the test data and configuration by editing:

- `config.json` - API and database settings
- `test_data.json` - Test data for API requests

## Author

Created by [Your Name]