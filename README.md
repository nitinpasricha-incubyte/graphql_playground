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

## External API Integration

### GitHub User Service

`app/services/github_user_service.rb` fetches a GitHub user's public profile via the GitHub REST API.

```ruby
result = GithubUserService.new('octocat').call
# => { login: "octocat", name: "The Octocat", avatar_url: "...", public_repos: 8 }
```

**Errors:**

| Error | When |
|---|---|
| `GithubUserService::UserNotFoundError` | GitHub returns 404 (username doesn't exist) |

---

## Testing

```bash
rspec                                               # run all tests
rspec spec/grahpql/queries/users_spec.rb            # users query
rspec spec/grahpql/queries/user_spec.rb             # user query
rspec spec/grahpql/mutations/create_user_spec.rb    # createUser mutation
rspec spec/grahpql/mutations/update_user_spec.rb    # updateUser mutation
rspec spec/grahpql/mutations/delete_user_spec.rb    # deleteUser mutation
rspec spec/services/github_user_service_spec.rb     # GitHub user service
```

### VCR

HTTP interactions in the test suite are recorded and replayed using [VCR](https://github.com/vcr/vcr) + WebMock. No real network calls are made after the cassette is recorded.

**Setup** (`spec/support/vcr.rb`):

```ruby
VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!         # enables :vcr tag in RSpec
  config.ignore_localhost = true
  config.default_cassette_options = { record: :new_episodes }
  config.filter_sensitive_data('<API_KEY>') { ENV['MY_API_KEY'] }
end
```

**Record modes:**

| Mode | Behaviour |
|---|---|
| `:once` | Records once, always replays. Errors if cassette missing. |
| `:new_episodes` | Replays existing, records new requests *(default)* |
| `:none` | Never records — fails if no cassette match |
| `:all` | Always re-records, ignores existing cassette |

**Using VCR in a spec:**

```ruby
it 'returns user data', vcr: { cassette_name: 'github/user_found' } do
  result = GithubUserService.new('octocat').call
  expect(result[:login]).to eq('octocat')
end
```

Cassettes are stored under `spec/cassettes/` and committed to the repository so CI runs without hitting real APIs.

---

### Coverage

19 examples, 0 failures — line coverage: **98.88%**

| Suite | Examples |
|---|---|
| `queries/users_spec.rb` | empty list, returns all users, correct fields |
| `queries/user_spec.rb` | returns user, not found error, nil data |
| `mutations/create_user_spec.rb` | creates user, returns user, missing field error, duplicate email error |
| `mutations/update_user_spec.rb` | updates user, no attributes error, duplicate email error, not found error |
| `mutations/delete_user_spec.rb` | deletes user, returns deleted user, not found error |
| `services/github_user_service_spec.rb` | returns user data, raises UserNotFoundError |
