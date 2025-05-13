# Lost and Found Application

A RESTful API for managing lost and found items, built with Spring Boot and PostgreSQL.

## Author
- Name: KASOGA Justesse
- Registration Number: 11471/2017

## Features

- User authentication with JWT
- Create, read, update, and delete lost items
- Create, read, update, and delete found items
- Search functionality for lost and found items
- Admin features for managing users and items
- System reports and statistics

## Table of Contents

- [Tech Stack](#tech-stack)
- [Custom Project Structure](#custom-project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Database Setup](#database-setup)
  - [Building and Running](#building-and-running)
- [API Documentation](#api-documentation)
  - [Authentication](#authentication)
  - [Lost Items](#lost-items)
  - [Found Items](#found-items)
  - [Search](#search)
  - [Admin Features](#admin-features)
- [Security](#security)
- [License](#license)

## Tech Stack

- Java 21
- Spring Boot 3.4.5
- Spring Security with JWT Authentication
- Spring Data JPA
- PostgreSQL
- Maven

## Custom Project Structure

This project uses a non-conventional but more intuitive directory structure that places all source code directly within the `src` directory, rather than the standard Maven structure with `src/main/java` and nested packages.

```
Project Root/
├── resources/                # Application properties and static resources
│   └── application.properties # Main configuration file
├── src/
│   ├── config/               # Configuration classes (Security, JWT)
│   ├── controllers/          # REST controllers
│   │   ├── HomeController.java # Base API controller
│   │   └── v1/              # API v1 versioned controllers
│   │       ├── AuthController.java
│   │       ├── LostItemController.java
│   │       ├── FoundItemController.java
│   │       ├── SearchController.java
│   │       ├── ItemController.java
│   │       └── AdminController.java
│   ├── entities/             # JPA entities
│   │   ├── User.java
│   │   ├── LostItem.java
│   │   └── FoundItem.java
│   ├── exceptions/           # Custom exceptions and error handlers
│   │   ├── ResourceNotFoundException.java
│   │   └── GlobalExceptionHandler.java
│   ├── payloads/             # Request/Response DTOs
│   │   ├── request/
│   │   │   ├── LoginRequest.java
│   │   │   ├── SignupRequest.java
│   │   │   ├── LostItemRequest.java
│   │   │   └── FoundItemRequest.java
│   │   └── response/
│   │       └── ApiResponse.java
│   ├── repositories/         # JPA repositories
│   │   ├── UserRepository.java
│   │   ├── LostItemRepository.java
│   │   └── FoundItemRepository.java
│   ├── services/             # Business logic services
│   │   ├── AuthService.java
│   │   ├── LostItemService.java
│   │   ├── FoundItemService.java
│   │   └── AdminService.java
│   ├── utils/                # Utility classes
│   │   ├── JwtUtils.java
│   │   ├── UserDetailsImpl.java
│   │   └── UserDetailsServiceImpl.java
│   └── main.java             # Application entry point
├── pom.xml                   # Maven configuration
└── README.md                 # Project documentation
```

### Key Customizations

1. **No Package Hierarchy**: Instead of having Java packages under `src/main/java`, all code is directly under `src` directory with clear subdirectories

2. **Resources Folder**: Placed at the root level instead of `src/main/resources`

3. **Tests Directory**: Located in `src/tests` rather than the standard `src/test/java`

4. **Main Application Class**: Named `main.java` rather than a traditional class name, containing a non-public `Main` class to avoid filename restrictions

5. **Maven Configuration**: Custom configuration in `pom.xml` to support this structure:

```xml
<build>
    <sourceDirectory>${project.basedir}/src</sourceDirectory>
    <testSourceDirectory>${project.basedir}/src/tests</testSourceDirectory>
    <resources>
        <resource>
            <directory>${project.basedir}/resources</directory>
        </resource>
    </resources>
    <!-- Other build configuration -->
</build>
```

## Getting Started

### Prerequisites

- Java 21
- Maven
- PostgreSQL database

### Database Setup

1. Create a PostgreSQL database named `lost_n_found`:

```sql
CREATE DATABASE lost_n_found;
```

2. Update the `resources/application.properties` with your database credentials:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/lost_n_found
spring.datasource.username=postgres
spring.datasource.password=your_password
```

3. The application will automatically create all necessary tables on startup using Hibernate's schema generation.

### Building and Running

1. Clone the repository
2. Navigate to the project directory
3. Build the project:
   ```shell
   mvn clean package
   ```
4. Run the application:
   ```shell
   java -jar target/lost_n_found-0.0.1-SNAPSHOT.jar
   ```

## API Documentation

The API is organized around REST principles. All endpoints are versioned with `/api/v1/` prefix and follow a consistent response format.

### Standard Response Format

**Success Response:**
```json
{
  "status": 200, // HTTP status code
  "message": "Operation successful", // Human-readable message
  "data": { ... } // Response data (object or array)
}
```

**Error Response:**
```json
{
  "status": 400, // HTTP status code
  "error": "Validation failed" // Error message
}
```

### Authentication

#### Register a new user
```
POST /api/v1/auth/signup
```

Request body:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "1234567890",
  "address": "123 Street, City"
}
```

Response:
```json
{
  "status": 201,
  "message": "User registered successfully",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "1234567890",
    "address": "123 Street, City",
    "isAdmin": false,
    "isBanned": false,
    "createdAt": "2025-05-12T12:00:00",
    "updatedAt": "2025-05-12T12:00:00"
  }
}
```

#### Login
```
POST /api/v1/auth/signin
```

Request body:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "status": 200,
  "message": "Authentication successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      // Other user properties
    }
  }
}
```

### Lost Items

#### Create a lost item
```
POST /api/v1/lost-items
```

Headers:
```
Authorization: Bearer {jwt_token}
```

Request body:
```json
{
  "title": "Lost Smartphone",
  "description": "iPhone 14 Pro, Space Gray, lost at the library",
  "category": "Electronics",
  "location": "University Library",
  "imageUrl": "https://example.com/iphone.jpg",
  "lostDate": "2025-05-10T15:30:00"
}
```

Response:
```json
{
  "status": 201,
  "message": "Lost item created successfully",
  "data": {
    "id": 1,
    "userId": 1,
    "title": "Lost Smartphone",
    "description": "iPhone 14 Pro, Space Gray, lost at the library",
    "category": "Electronics",
    "location": "University Library",
    "imageUrl": "https://example.com/iphone.jpg",
    "lostDate": "2025-05-10T15:30:00",
    "status": "pending",
    "createdAt": "2025-05-12T12:00:00",
    "updatedAt": "2025-05-12T12:00:00"
  }
}
```

#### Get a lost item
```
GET /api/v1/lost-items/{id}
```

Headers:
```
Authorization: Bearer {jwt_token}
```

Response: Same as the create response.

#### Update a lost item
```
PATCH /api/v1/lost-items/{id}
```

Headers:
```
Authorization: Bearer {jwt_token}
```

Request body (partial update):
```json
{
  "description": "Updated description with more details"
}
```

Response: Updated lost item object.

#### Delete a lost item
```
DELETE /api/v1/lost-items/{id}
```

Headers:
```
Authorization: Bearer {jwt_token}
```

Response:
```json
{
  "status": 200,
  "message": "Lost item deleted successfully",
  "data": {
    "message": "Lost item deleted successfully"
  }
}
```

### Found Items

Found items have similar endpoints to lost items, with the addition of a `storageLocation` field:

#### Create a found item
```
POST /api/v1/found-items
```

Request body:
```json
{
  "title": "Found Laptop",
  "description": "Dell XPS 13, found at the cafeteria",
  "category": "Electronics",
  "location": "University Cafeteria",
  "imageUrl": "https://example.com/laptop.jpg",
  "foundDate": "2025-05-11T14:20:00",
  "storageLocation": "Lost and Found Office"
}
```

Other endpoints follow the same pattern as lost items:
```
GET /api/v1/found-items/{id}
PATCH /api/v1/found-items/{id}
DELETE /api/v1/found-items/{id}
```

### Search

Search for lost or found items based on various criteria:

```
GET /api/v1/search
```

Query parameters:
- `type`: Required, either "lost" or "found"
- `keyword`: Optional, search in title and description
- `location`: Optional, filter by location
- `start_date`: Optional, filter by date range start (ISO format)
- `end_date`: Optional, filter by date range end (ISO format)

Example:
```
GET /api/v1/search?type=lost&keyword=phone&location=library&start_date=2025-05-01&end_date=2025-05-12
```

### Admin Features

#### User Management

Ban or unban a user:
```
PATCH /api/v1/admin/users/{id}
```

Headers:
```
Authorization: Bearer {admin_jwt_token}
```

Request body:
```json
{
  "is_banned": true
}
```

#### Item Approval/Rejection

Approve or reject a lost or found item:
```
PATCH /api/v1/admin/items/{id}
```

Headers:
```
Authorization: Bearer {admin_jwt_token}
```

Request body:
```json
{
  "status": "approved", // or "rejected"
  "type": "lost" // or "found"
}
```

#### System Reports

Get system statistics:
```
GET /api/v1/admin/reports
```

Response:
```json
{
  "status": 200,
  "message": "System reports retrieved successfully",
  "data": {
    "total_users": 10,
    "active_users": 9,
    "banned_users": 1,
    "total_lost_items": 15,
    "claimed_lost_items": 5,
    "total_found_items": 12,
    "claimed_found_items": 4
  }
}
```

## Security

- All endpoints except `/api/v1/auth/*` require authentication via JWT token
- Admin endpoints require the ADMIN role
- Passwords are encrypted using BCrypt before storing in the database
- JWT tokens expire after 24 hours
- Token contains user ID and role information for authorization
- CORS is configured to restrict access to the API

## License

This project is open-source and available under the MIT License.
