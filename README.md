# Graphql in Crystal

## Graphene

Graphene is a low level library that implements the core of GraphQL following the spec as closely as possible. The schema is defined by creating instances of core types (`Schema`, `Field`, `Type`, `Argument`...). This provides an AST which is used in both the execution and validation phases.

This library was originally built to experiment with building dynamic schemas on a per tenant basis. An early prototype allowed a user to define their models within a UI and a custom GraphQL API would be generated at runtime.

### Features

#### Queries

- [x] Libgraphqlpaser based parser

#### Built-in Types

- [x] Scalars
  - [x] Int
  - [x] Float
  - [x] String
  - [x] Boolean
  - [x] ID
- [x] Object
- [x] Interface
- [x] Union
- [x] Enum
- [ ] Input Object
- [x] List
- [x] Non-Null
- [x] Directive
  - [x] @skip
  - [x] @include
  - [x] @deprecated
  - [ ] @specifiedBy

#### Execution

- [x] Queries
- [ ] Mutations
- [ ] Subscriptions
- [x] Lazy execution



### Runtime

A goal when building the `Runtime` was to follow the GraphQL Spec on Execution (https://spec.graphql.org/October2021/#sec-Executing-Requests) as closely as possible. Variable names and methods are mostly taken from the spec (albeit converted to snake_case).

It is likely as more features are introduced the implementation may diverge from the spec slightly.

#### Lazy and Loader

A `Lazy` object defers completion of a value until required. It is a synchronous future implementation. Each `Lazy` has a callback that is responsible for resolving it's value. This can be used to batch up operations when fetching multiple children of a list. Take the following query which fetches a list of charges and for each charge returns an associated payment method:

```graphql
{
  charges {
    id
    amount
    paymentMethod {
      id
      name
    }
  }
}
```

By default GraphQL will execute depth first. For each charge it will resolve its payment method and all the child nodes (`id`, `name`) before moving to the next charge. If we are fetching this information from a database this would typically introduce an N+1 query. For each charge we would perform a separate query for it's payment method.

Instead we can store the identifier of the charge into a list and return a `Lazy` future object that tells the runtime we will eventually provide the payment method but for now to pause the depth first implementation and instead move on to the next charge. When we have iterated through all charges the runtime knows that we still need to complete the payment method field. The runtime asks the `Lazy` object for it's value which will trigger it's callback. Now we have all the charge identifiers in a list we can fetch them all at once in a single query and provide each `Lazy` object with it's value.

Graphene comes with a built in `Loader` abstract class that can be extended to provide simple batch loading. It automatically generates the `Lazy` objects and provides a callback that will fulfill each `Lazy` with it's value. A `perform` method must be implemented that receives an array of identifiers and for each identifier `fulfill` must be called.

##### Example

```crystal
class PaymentMethodLoader < Graphene::Loader(Int32, PaymentMethod)
  def perform(load_keys)
    payment_methods = PaymentMethod.where(charge_id: load_keys).to_a

    load_keys.each do |key|
      payment_method = payment_methods.find { |pm| pm.charge_id == key }

      fulfill(key, payment_method)
    end
  end
end
```


### TODO

- [ ] Error handling
  - [ ] Raise appropriate classes of exceptions within runtime
  - [ ] Raise errors during validation phase
  - [ ] Handle exceptions to generate an errored response
- Static validation (https://spec.graphql.org/October2021/#sec-Validation)
  - [ ] Documents
    - [ ] Executable Definitions
  - [ ] Operations
    - [ ] Named Operation Definitions
    - [ ] Anonymous Operation Definitions
    - [ ] Subscription Operation Definitions
  - [ ] Fields
    - [ ] Field Selections
    - [ ] Field Selection Merging
    - [ ] Leaf Field Selections
  - [ ] Arguments
    - [ ] Argument Names
    - [ ] Argument Uniqueness
  - [ ] Fragments
    - [ ] Fragment Declarations
    - [ ] Fragment Spreads
  - [ ] Values
    - [ ] Values of Correct Type
    - [ ] Input Object Field Names
    - [ ] Input Object Field Uniqeness
    - [ ] Input Object Required Fields
  - [ ] Directives
    - [ ] Directives Are Defined
    - [ ] Directives Are In Valid Locations
    - [ ] Directives Are Unique Per Location
  - [ ] Variables
    - [ ] Variable Uniqueness
    - [ ] Variables are Input Types
    - [ ] All Variable Uses Defined
    - [ ] All Variables Used
    - [ ] All Variable Usages are Allowed
- [ ] Mutation support
  - [ ] Input objects
- [ ] Custom directives
- [ ] Test framework
  - [ ] Validating responses
  - [ ] Generating schema + resolvers
- [ ] Validate scalar coercion and serialization is compliant

## Oxide

### TODO

- [ ] Design DSL for generating schemas and resolvers
- [ ] Support field visibility

## Potential features

- Query Analyser
- Complexity and depth
- Timeouts
- Multiplexing
- Lookahead
- Tracing hooks
- Visibility
- Pagination
- Subscriptions
- Streaming @defer
- Persisted queries
