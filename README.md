# Graphql in Crystal

## TODO

- [ ] Error handling
  - [ ] Runtime / Response errors
  - [ ] Validation errors
- [ ] Static validation
- [ ] Input objects
  - [ ] Runtime support
  - [ ] Validations
  - [ ] Schema Builder
- [ ] Custom directives
  - [ ] Runtime support
  - [ ] Validations
  - [ ] Schema Builder
- [x] Complete language visitor
- [ ] Refactor parser
  - [x] LibGraphqlParser to use specific types
  - [ ] Reduce duplication with macros
  - [ ] Merge Parser and SchemaParser
- [ ] Test framework for generating schemas, mocking resolvers and validating results
- [ ] Separate coerce input from output

## Missing features

- Query Analyser
- Complexity and depth
- Timeout
- Multiplexing
- Lookahead
- Tracing hooks
- Visibility
- Pagination
- Subscriptions

### Pro features

- Streaming @defer
- Persisted queries
- Cursor pagination
