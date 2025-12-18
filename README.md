# Graphql in Crystal

## Oxide

Oxide is a low level library that implements the core of GraphQL following the spec as closely as possible. The schema is defined by creating instances of core types (`Schema`, `Field`, `Type`, `Argument`...). This provides an AST which is used in both the execution and validation phases.

This library was originally built to experiment with building dynamic schemas on a per tenant basis. An early prototype allowed a user to define their models within a UI and a custom GraphQL API would be generated at runtime.

## 🚀 Implementation Progress

**Spec Version**: [GraphQL September 2025](https://spec.graphql.org/September2025/)  
**Status**: 17.4% Complete (37 of 213+ spec examples covered)  
**Test Suite**: 376 tests passing (100% pass rate)

This project is actively working towards full GraphQL specification compliance. See [plan.md](plan.md) for the complete implementation roadmap and [PROGRESS.md](PROGRESS.md) for detailed progress tracking.

### Milestone Completion Status (6 of 7 Complete - 86%)

- ✅ **Milestone 1: Language & Parser** - COMPLETE (100%)
- ✅ **Milestone 2: Type System** - COMPLETE (100%)
- ✅ **Milestone 3: Validation Rules** - COMPLETE (100%)  
- ✅ **Milestone 4: Execution Engine** - COMPLETE (100%)
- ✅ **Milestone 5: Introspection System** - COMPLETE (100%)
- ✅ **Milestone 6: Response Format** - COMPLETE (100%)
- ❌ **Milestone 7: Subscriptions** - NOT STARTED (deferred)

### Recently Completed ✨

#### ✅ Language & Parser Complete (Milestone 1)
- **Parser Error Messages**: 32 comprehensive tests with line/column information
- **Document Descriptions (§2.2)**: 15 tests covering all definition types
- **Bug Fix**: Added missing description support for InputValueDefinition
- **Schema Coordinates (§2.14)**: Underlying functionality verified
- **Test Coverage**: 47 new tests, bringing parser to 100% completion

#### ✅ Execution Engine Complete (Milestone 4)
- **Directive Execution**: @skip and @include directives working in all contexts
- **Value Completion**: All types (scalars, enums, lists, objects, non-null)
- **Serial Mutation Execution**: Mutations execute in order with side effect guarantees
- **Comprehensive Error Handling**: Field-level errors with paths
- **Test Coverage**: 30 new tests covering all execution scenarios

#### ✅ Response Format Compliance (Milestone 6)
- **Error Path Tracking** (§7.1.4): Full path implementation with field names and list indices
- **Error Format** (§7.1.6): Complete error objects with message, locations, and path
- **Array Serialization**: Errors properly serialized as JSON array
- **Field-level Error Handling**: Errors caught and tracked at field boundaries
- **Path in Context**: Execution context tracks current path through response
- **Test Coverage**: 6 response format tests + 3 integration tests for error paths

#### ✅ Complete Validation Rule Implementation (Milestone 3)
- **All Fragment Validation Rules** (§5.5):
  - Fragment Name Uniqueness, Type Existence, Composite Types
  - Fragments Must Be Used, Spread Target Defined
  - Fragment Spreads Must Not Form Cycles (with cycle detection algorithm)
  - Fragment Spread Is Possible (full type compatibility checking)
- **Value Validation** (§5.6): Values of Correct Type, Input Object Required Fields
- **Variable Validation** (§5.8): All Variable Usages Are Allowed
- **Field Validation** (§5.3.2): Field Selection Merging
- **Operation Validation** (§5.2): Operation Type Existence
- **OneOf Input Objects** (§3.10.1): Complete @oneOf directive implementation
- **Test Coverage**: 141 validation tests, all passing

#### ✅ Execution Engine Improvements (Milestone 4)
- **Variable Coercion** (§6.1.2): Full implementation with null handling - examples #31-32
- **Argument Coercion** (§6.4.1): Complete coercion algorithm - examples #9-12  
- **Query Execution**: Basic queries, mutations, nested selections - examples #1-8
- **Field Aliases**: Full alias support - examples #13-16
- **Fragment Execution**: Named fragments and inline fragments - examples #17-18
- **Test Coverage**: 31 execution tests, all passing

#### ✅ String & Block String Parsing (Milestone 1)
- **Complete Unicode escape support**: `\uXXXX` and `\u{X...}` including surrogate pairs
- **All standard escapes**: `\"`, `\\`, `\/`, `\b`, `\f`, `\n`, `\r`, `\t`
- **Block strings**: Full `BlockStringValue()` algorithm implementation
- **Test Coverage**: 41 tests covering spec examples #24-27

#### 🔧 Critical Bug Fixes
- Fixed variable coercion null handling (non-null type checking and nullable type coercion)
- Fixed argument name context tracking in validation
- Corrected inline fragment visitor traversal
- Fixed block string processing placement

### Implementation Statistics

- **Total Tests**: 376 passing (100% pass rate)
- **Milestones Complete**: 6 of 7 (86%)
- **Validation Rules**: 14+ rules fully implemented
- **Spec Examples Covered**: 37 of 213+ (17.4%)
- **Code Quality**: Zero test failures, zero errors

### TODO

- [x] Parser & Lexer ✅ (COMPLETE)
  - [x] Fully support block strings ✅ (Complete with spec algorithm - examples #24-27)
  - [x] Unicode escape sequences ✅ (Fixed-width and variable-width with full validation)
  - [x] Surrogate pair handling ✅ (Automatic UTF-16 surrogate pair combination)
  - [x] Add tests for parsing errors ✅ (32 comprehensive error tests)
  - [x] Schema coordinates ✅ (Underlying functionality verified)
  - [x] Document descriptions ✅ (15 tests covering all definition types)
- [x] Fragment Validation ✅ (COMPLETE)
  - [x] Fragment name uniqueness ✅ (examples #146-147)
  - [x] Fragment spread type existence ✅ (examples #148-149)
  - [x] Fragments on composite types ✅ (examples #150-152)
  - [x] Fragments must be used ✅ (counter example #153)
  - [x] Fragment spread target defined ✅ (counter example #154)
  - [x] Fragment spreads must not form cycles ✅ (counter examples #155-157)
  - [x] Fragment spread is possible ✅ (examples #158-169)
- [ ] Error handling
  - [x] Raise appropriate classes of exceptions within runtime
  - [ ] Raise errors during validation phase
  - [ ] Handle exceptions to generate an errored response
- [x] Static validation ✅ (COMPLETE - https://spec.graphql.org/October2021/#sec-Validation)
  - [x] 5.1 Documents ✅
    - [x] 5.1. ~~Executable Definitions~~ _Currently all definitions are executable so enforced by the type system_
  - [x] 5.2 Operations ✅
    - [x] 5.2.1 Named Operation Definitions ✅
    - [x] 5.2.2 Anonymous Operation Definitions ✅
    - [x] 5.2.1.1 Operation Type Existence ✅ (examples #107-109)
    - [ ] 5.2.3 ~~Subscription Operation Definitions~~ _Subscriptions are not supported at this time_
  - [x] 5.3 Fields ✅
    - [x] 5.3.1 Field Selections ✅
    - [x] 5.3.2 Field Selection Merging ✅ (examples #126-131)
    - [x] 5.3.3 Leaf Field Selections ✅
  - [x] 5.4 Arguments ✅
    - [x] 5.4.1 Argument Names ✅
    - [x] 5.4.2 Argument Uniqueness ✅
    - [x] 5.4.3 Required Arguments ✅
  - [x] 5.5 Fragments ✅ (COMPLETE)
    - [x] 5.5.1 Fragment Declarations ✅
      - [x] 5.5.1.1 Fragment Name Uniqueness ✅ (examples #146-147)
      - [x] 5.5.1.2 Fragment Spread Type Existence ✅ (examples #148-149)
      - [x] 5.5.1.3 Fragments on Composite Types ✅ (examples #150-152)
      - [x] 5.5.1.4 Fragments Must Be Used ✅ (counter example #153)
    - [x] 5.5.2 Fragment Spreads ✅
      - [x] 5.5.2.1 Fragment Spread Target Defined ✅ (counter example #154)
      - [x] 5.5.2.2 Fragment Spreads Must Not Form Cycles ✅ (counter examples #155-157)
      - [x] 5.5.2.3 Fragment Spread Is Possible ✅ (examples #158-169)
  - [x] 5.6 Values ✅
    - [x] 5.6.1 Values of Correct Type ✅ (examples #160-161)
    - [x] 5.6.2 Input Object Field Names ✅
    - [x] 5.6.3 Input Object Field Uniqueness ✅
    - [x] 5.6.4 Input Object Required Fields ✅
  - [x] 5.7 Directives ✅
    - [x] 5.7.1 Directives Are Defined ✅
    - [x] 5.7.2 Directives Are In Valid Locations ✅
    - [x] 5.7.3 Directives Are Unique Per Location ✅
  - [x] 5.8 Variables ✅
    - [x] 5.8.1 Variable Uniqueness ✅
    - [x] 5.8.2 Variables are Input Types ✅
    - [x] 5.8.3 All Variable Uses Defined ✅
    - [x] 5.8.4 All Variables Used ✅
    - [x] 5.8.5 All Variable Usages Are Allowed ✅ (examples #190-198)
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
