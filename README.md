# README

# Books API (Ruby on Rails)

A simple RESTful API for managing books and authors, built with **Ruby on Rails 8.1.1** and **Ruby 3.4.7**.  
Includes token-based authentication using JWTs. RSpec is used for testing.

---

## Tech Stack

- **Ruby**: 3.4.7  
- **Rails**: 8.1.1 (API mode)  
- **Database**: PostgreSQL  
- **Authentication**: JSON Web Tokens (JWT)

## Endpoints

| Method   | Endpoint               | Description                      | Auth Required |
| -------- | ---------------------- | -------------------------------- | ------------- |
| `POST`   | `/api/v1/users`        | Create a new user account        | ❌             |
| `POST`   | `/api/v1/authenticate` | Authenticate a user and get JWT  | ❌             |
| `GET`    | `/api/v1/books`        | List all books (with pagination) | ❌             |
| `GET`    | `/api/v1/books/:id`    | Get a single book                | ❌             |
| `POST`   | `/api/v1/books`        | Create a new book and author     | ✅             |
| `PATCH`  | `/api/v1/books/:id`    | Update a book and its author     | ✅             |
| `DELETE` | `/api/v1/books/:id`    | Delete a book                    | ✅             |


## Example Curl Requests
- curl -X POST "http://localhost:3000/api/v1/users" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "username": "BookSeller99",
      "password": "Password1"
    }
  }'
- curl -X POST "http://localhost:3000/api/v1/authenticate" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "BookSeller99",
    "password": "Password1"
  }'
- curl -X GET "http://localhost:3000/api/v1/books?limit=10&offset=0"
- curl -X GET "http://localhost:3000/api/v1/books/2"
- curl -X POST "http://localhost:3000/api/v1/books" \
  -H "Content-Type: application/json" \
  -H "Authorization: Token YOUR_JWT_TOKEN" \
  -d '{
    "book": { "title": "1984" },
    "author": { "first_name": "George", "last_name": "Orwell", "age": 46 }
  }'
- curl -X PATCH "http://localhost:3000/api/v1/books/2" \
  -H "Content-Type: application/json" \
  -H "Authorization: Token YOUR JWT" \
  -d '{
    "book": { "title": "Animal Farm" },
    "author": { "first_name": "George", "last_name": "Orwell", "age": 47 }
  }'
- curl -X DELETE "http://localhost:3000/api/v1/books/2" \
  -H "Authorization: Token YOUR JWT"

## Testing
- This API uses RSpec for automated testing. All tests are located in the spec/ directory.
- Tests are automatically run on GitHub Actions via the workflow defined in .github/workflows/ci.yml
