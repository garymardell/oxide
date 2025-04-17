# Graphql in Crystal

## Oxide

Oxide is a low level library that implements the core of GraphQL following the spec as closely as possible. The schema is defined by creating instances of core types (`Schema`, `Field`, `Type`, `Argument`...). This provides an AST which is used in both the execution and validation phases.

This library was originally built to experiment with building dynamic schemas on a per tenant basis. An early prototype allowed a user to define their models within a UI and a custom GraphQL API would be generated at runtime.

### TODO

- [ ] Parser & Lexer
  - [ ] Fully support block strings
  - [ ] Add tests for parsing errors
- [ ] Error handling
  - [x] Raise appropriate classes of exceptions within runtime
  - [ ] Raise errors during validation phase
  - [ ] Handle exceptions to generate an errored response
- Static validation (https://spec.graphql.org/October2021/#sec-Validation)
  - [x] 5.1 Documents
    - [ ] 5.1. ~~Executable Definitions~~ _Currently all definitions are executable so enforced by the type system_
  - [x] 5.2 Operations
    - [x] 5.2.1 Named Operation Definitions
    - [x] 5.2.2 Anonymous Operation Definitions
    - [ ] 5.2.3 ~~Subscription Operation Definitions~~ _Subscriptions are not supported at this time_
  - [ ] 5.3 Fields
    - [x] 5.3.1 Field Selections
    - [ ] 5.3.2 Field Selection Merging
    - [x] 5.3.3 Leaf Field Selections
  - [x] 5.4 Arguments
    - [x] 5.4.1 Argument Names
    - [x] 5.4.2 Argument Uniqueness
    - [ ] 5.4.3 Required arguments
  - [ ] 5.5 Fragments
    - [ ] 5.5.1 Fragment Declarations
      - [ ] 5.5.1.1 Fragment Name Uniqueness
      - [ ] 5.5.1.2 Fragment Spread Type Existence
      - [ ] 5.5.1.3 Fragments on Composite Types
      - [ ] 5.5.1.4 Fragments Must Be Used
    - [ ] 5.5.2 Fragment Spreads
      - [ ] 5.5.2.1 Fragment Spread Target Defined
      - [ ] 5.5.2.2 Fragment Spreads Must Not Form Cycles
      - [ ] 5.5.2.3 Fragment Spread is Possible
  - [ ] 5.6 Values
    - [ ] 5.6.1 Values of Correct Type
    - [x] 5.6.2 Input Object Field Names
    - [x] 5.6.3 Input Object Field Uniqueness
    - [ ] 5.6.4 Input Object Required Fields
  - [x] 5.7 Directives
    - [x] 5.7.1 Directives Are Defined
    - [x] 5.7.2 Directives Are In Valid Locations
    - [x] 5.7.3 Directives Are Unique Per Location
  - [ ] 5.8 Variables
    - [x] 5.8.1 Variable Uniqueness
    - [x] 5.8.2 Variables are Input Types
    - [x] 5.8.3 All Variable Uses Defined
    - [x] 5.8.4 All Variables Used
    - [ ] 5.8.5 All Variable Usages are Allowed
- [ ] Custom directives
  - [x] SCHEMA
  - [x] SCALAR
  - [x] OBJECT
  - [x] FIELD_DEFINITION
  - [x] ARGUMENT_DEFINITION
  - [x] INTERFACE
  - [x] UNION
  - [x] ENUM
  - [x] ENUM_VALUE
  - [x] INPUT_OBJECT
  - [x] INPUT_FIELD_DEFINITION
- [ ] Test framework
  - [ ] Validating responses
  - [ ] Generating schema + resolvers
- [ ] Validate scalar coercion and serialization is compliant

### Features

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
- [x] Input Object
- [x] List
- [x] Non-Null
- [x] Directive
  - [x] @skip
  - [x] @include
  - [x] @deprecated
  - [x] @specifiedBy

#### Execution

- [x] Queries
- [x] Mutations
- [ ] Subscriptions
- [x] Lazy execution

### Schema

#### Late Bound Type

Oxide introduces a custom type called `LateBoundType` that allows you to refer to another type in the schema by name. This was introduced to allow recursively/cyclic defined types. As types are defined as objects we cannot use itself during it's own definition. The runtime will automatically look up late bound types from the schema during execution and therefore need to either be already directly referenced or provided when instantiating the schema with the `orphan_types` parameter.

*Example*

This example is taken from the introspection schema. The `_Type` object contains a list of all `possibleTypes` which is a list of `_Type` objects.

```crystal
  TypeType = Oxide::Types::ObjectType.new(
    name: "__Type",
    fields: {
      ...
      "possibleTypes" => Oxide::Field.new(
        type: Oxide::Types::ListType.new(
          of_type: Oxide::Types::NonNullType.new(
            of_type: Oxide::Types::LateBoundType.new("__Type")
          )
        )
      ),
      ...
    }
  )
```

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

Oxide comes with a built in `Loader` abstract class that can be extended to provide simple batch loading. It automatically generates the `Lazy` objects and provides a callback that will fulfill each `Lazy` with it's value. A `perform` method must be implemented that receives an array of identifiers and for each identifier `fulfill` must be called.

##### Example

```crystal
class PaymentMethodLoader < Oxide::Loader(Int32, PaymentMethod)
  def perform(load_keys)
    payment_methods = PaymentMethod.where(charge_id: load_keys).to_a

    load_keys.each do |key|
      payment_method = payment_methods.find { |pm| pm.charge_id == key }

      fulfill(key, payment_method)
    end
  end
end
```
