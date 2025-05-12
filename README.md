# Lost and Found API

A RESTful API for managing lost and found items, built with Spring Boot and PostgreSQL.

## Project Overview

This project implements a complete API for a lost and found system, allowing users to register, report lost/found items, search for items, and administrators to manage the system.

## Custom Directory Structure

This project uses a custom directory structure rather than the conventional Maven structure for better organization:

```text
lost_n_found/
├── resources/                    # Application resources
│   └── application.properties    # Configuration properties
├── src/                          # Source code
│   ├── controllers/              # API controllers
│   │   ├── HomeController.java
│   │   └── v1/                   # API version 1 controllers
│   │       ├── AdminController.java
│   │       ├── AuthController.java
│   │       ├── FoundItemController.java
│   │       ├── LostItemController.java
│   │       └── SearchController.java
│   ├── entities/                 # Database entities
│   ├── exceptions/               # Custom exceptions
│   ├── main.java                 # Application entry point
│   ├── payloads/                 # Request/response objects
│   │   ├── request/
│   │   └── response/
│   ├── repositories/             # Data repositories
│   ├── services/                 # Business logic services
│   ├── tests/                    # Test scripts
│   │   ├── admin_tests.ps1       # Admin functionality tests
│   │   ├── api_tests.ps1         # Basic API endpoint tests
│   │   ├── db_cleanup.ps1        # Database cleanup script
│   │   ├── dummy_profiles.json   # Test user profiles and data
│   │   ├── output/               # Test output files
│   │   ├── run_all_tests.ps1     # Test runner script
│   │   └── user_journey_tests.ps1 # User flow tests
│   └── utils/                    # Utility classes
└── pom.xml                       # Maven dependencies
```

## Prerequisites

- Java 17 or higher
- Maven 3.6 or higher
- PostgreSQL database
- PowerShell (for running test scripts)

## Setup Instructions

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourrepository/lost_n_found.git
   cd lost_n_found
   ```

2. **Configure the database**

   Create a PostgreSQL database named `lost_n_found` and update the connection details in `resources/application.properties` if needed.

   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/lost_n_found
   spring.datasource.username=postgres
   spring.datasource.password=post093
   ```

3. **Build the application**

   ```bash
   mvn clean install
   ```

4. **Run the application**

   ```bash
   mvn spring-boot:run
   ```

   The API will be available at `http://localhost:8080`

## Running Tests

We provide PowerShell scripts to thoroughly test the API. For convenience, we've included both a batch file and PowerShell scripts:

### Option 1: Using the batch file (simplest)

Simply double-click the `run_tests.bat` file or run it from the command line:

```bash
.\run_tests.bat
```

This will bypass PowerShell execution policy restrictions and run all tests.

### Option 2: Using PowerShell directly

If you prefer running via PowerShell directly:

1. Open PowerShell as administrator
2. Set the execution policy to allow running scripts (if needed):

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
   ```

3. Run the test runner script:

   ```powershell
   .\src\tests\run_all_tests.ps1
   ```

### Test Suite Components

Our test suite includes:

1. **API Basic Tests** - Tests all API endpoints and basic functionality
2. **User Journey Tests** - Simulates a complete user flow from registration to item claiming
3. **Admin Functionality Tests** - Tests administrative features like approving/rejecting items and managing users

Test results are stored in the `src/tests/output` directory.

## API Endpoints

### Authentication

- `POST /api/v1/auth/signup` - Register a new user
- `POST /api/v1/auth/signin` - Log in an existing user

### Lost Items

- `GET /api/v1/lost-items` - Get all lost items
- `GET /api/v1/lost-items/{id}` - Get a specific lost item
- `POST /api/v1/lost-items` - Report a lost item
- `PATCH /api/v1/lost-items/{id}` - Update a lost item
- `DELETE /api/v1/lost-items/{id}` - Delete a lost item

### Found Items

- `GET /api/v1/found-items` - Get all found items
- `GET /api/v1/found-items/{id}` - Get a specific found item
- `POST /api/v1/found-items` - Report a found item
- `PATCH /api/v1/found-items/{id}` - Update a found item
- `DELETE /api/v1/found-items/{id}` - Delete a found item

### Search

- `GET /api/v1/search?type={type}&keyword={keyword}` - Search for items

### Admin Operations

- `GET /api/v1/admin/users` - Get all users (admin only)
- `PATCH /api/v1/admin/users/{id}` - Update user status (admin only)
- `PATCH /api/v1/admin/items/{id}` - Approve/reject items (admin only)
- `GET /api/v1/admin/reports` - Get system reports (admin only)

## Author

David MANZI

## License

This project is licensed under the MIT License - see the LICENSE file for details.
