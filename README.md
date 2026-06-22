# GraphQL Playground

A Rails 8.1 API-only application demonstrating GraphQL CRUD operations for a `User` resource.

## Stack

| Layer | Technology |
|---|---|
| Language | Ruby 4.0.5 |
| Framework | Rails 8.1.3 (API-only) |
| GraphQL | graphql-ruby 2.6.x |
| Database | SQLite3 |
| Server | Puma + Thruster |
| Testing | RSpec |

## Getting Started

```bash
bundle install
rails db:migrate
rails s         # starts server on http://localhost:3000
```

## Project Structure

```
app/graphql/
├── graphql_playground_schema.rb
├── types/
│   ├── user_type.rb          # id, fullName, email
│   ├── query_type.rb         # users, user(id)
│   ├── mutation_type.rb      # createUser, updateUser, deleteUser
│   └── base_*.rb             # base classes (object, field, argument, etc.)
├── mutations/
│   ├── create_user.rb
│   ├── update_user.rb
│   └── delete_user.rb
└── resolvers/
    └── base_resolver.rb
```

## GraphQL API

- **Endpoint:** `POST /graphql`
- **Interactive IDE (dev):** `GET /graphiql`

---

## User Resource

The `User` model has `first_name`, `last_name`, and `email` fields. The GraphQL type exposes:

| Field | Type | Notes |
|---|---|---|
| `id` | `ID!` | Record ID |
| `fullName` | `String!` | `first_name + last_name` joined |
| `email` | `String!` | |

---

## Queries

### List all users

```graphql
query {
  users {
    id
    fullName
    email
  }
}
```

### Fetch a single user

```graphql
query {
  user(id: "1") {
    id
    fullName
    email
  }
}
```

---

## Mutations

### Create a user

All three arguments are required. Raises an error if validations fail (e.g. duplicate email).

```graphql
mutation {
  createUser(input: {
    firstName: "Jane"
    lastName: "Doe"
    email: "jane@example.com"
  }) {
    user {
      id
      fullName
      email
    }
  }
}
```

### Update a user

Only `id` is required. Pass any combination of `firstName`, `lastName`, `email` to update. Raises an error if no attributes are provided or if the user is not found.

```graphql
mutation {
  updateUser(input: {
    id: "1"
    firstName: "Janet"
    email: "janet@example.com"
  }) {
    user {
      id
      fullName
      email
    }
  }
}
```

### Delete a user

Destroys the record and returns the deleted user. Raises an error if the ID does not exist.

```graphql
mutation {
  deleteUser(input: {
    id: "1"
  }) {
    user {
      id
      fullName
    }
  }
}
```

---

## Error Handling

All mutations return a `GraphQL::ExecutionError` in the `errors` key on failure. Example:

```json
{
  "errors": [
    { "message": "Email has already been taken" }
  ]
}
```

---

## Testing

```bash
rspec
```
