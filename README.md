# Lost and Found Application

A RESTful API for managing lost and found items, built with Spring Boot and PostgreSQL.

## Author
- Name: KASOGA Justesse
- Registration Number: 11471/2024

## Features

- User authentication with JWT
- Create, read, update, and delete lost items
- Create, read, update, and delete found items
- Search functionality for lost and found items
- Admin features for managing users and items
- System reports and statistics

## Tech Stack

- Java 21
- Spring Boot 3.4.5
- Spring Security with JWT Authentication
- Spring Data JPA
- PostgreSQL
- Maven

## Project Structure

The project follows a custom structure:

```
src/
├── config/            # Configuration classes (Security, JWT)
├── controllers/       # REST controllers
│   └── v1/            # API v1 controllers
├── entities/          # JPA entities
├── exceptions/        # Custom exceptions and error handlers
├── payloads/          # Request/Response DTOs
│   ├── request/
│   └── response/
├── repositories/      # JPA repositories
├── services/          # Business logic services
└── utils/             # Utility classes
resources/             # Application properties and static resources
```

## Getting Started

### Prerequisites

- Java 21
- Maven
- PostgreSQL database

### Database Setup

1. Create a PostgreSQL database named `lost_n_found`
2. Update the `application.properties` with your database credentials if needed:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/lost_n_found
spring.datasource.username=postgres
spring.datasource.password=postgres
```

### Building and Running

1. Clone the repository
2. Navigate to the project directory
3. Build the project:
   ```
   mvn clean package
   ```
4. Run the application:
   ```
   java -jar target/lost_n_found-0.0.1-SNAPSHOT.jar
   ```

## API Documentation

The API is organized around REST principles. All endpoints are versioned with `/api/v1/` prefix.

### Authentication

#### Register a new user
```
POST /api/v1/auth/signup
```

Request body:
```json
{
  "email": "user@example.com",
  "password": "password",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "1234567890",
  "address": "123 Street, City"
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
  "password": "password"
}
```

Response includes JWT token:
```json
{
  "status": 200,
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    ...
  }
}
```

### Lost Items

#### Create a lost item
```
POST /api/v1/lost-items
```

#### Get a lost item
```
GET /api/v1/lost-items/{id}
```

#### Update a lost item
```
PATCH /api/v1/lost-items/{id}
```

#### Delete a lost item
```
DELETE /api/v1/lost-items/{id}
```

### Found Items

Similar endpoints are available for found items:
```
POST /api/v1/found-items
GET /api/v1/found-items/{id}
PATCH /api/v1/found-items/{id}
DELETE /api/v1/found-items/{id}
```

### Search

```
GET /api/v1/search?type=lost&keyword=phone&location=campus&start_date=2025-01-01&end_date=2025-05-01
```

### Admin Endpoints

#### User Management
```
PATCH /api/v1/admin/users/{id}
```

#### Item Approval/Rejection
```
PATCH /api/v1/admin/items/{id}
```

#### System Reports
```
GET /api/v1/admin/reports
```

## Security

- All endpoints except `/api/v1/auth/*` require authentication
- Admin endpoints require ADMIN role
- Passwords are encrypted using BCrypt
- JWT tokens expire after 24 hours

## License

This project is open-source and available under the MIT License.
