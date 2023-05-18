require "../spec_helper"

describe Graphene do
  it "gets object __typename" do
    query_string = <<-QUERY
      query {
        charges {
          id
          __typename
        }
      }
    QUERY

    runtime = Graphene::Execution::Runtime.new(
      DummySchema,
      Graphene::Query.new(query_string),
      initial_value: Query.new
    )

    result = runtime.execute["data"]

    result.should eq({ "charges" => [{ "id" => "1", "__typename" => "Charge" }, { "id" => "2", "__typename" => "Charge" }, { "id" => "3", "__typename" => "Charge" }] })
  end

  it "gets types from schema" do
    query_string = <<-QUERY
      {
        __schema {
          types {
            name
            kind
          }
        }
      }
    QUERY

    runtime = Graphene::Execution::Runtime.new(
      DummySchema,
      Graphene::Query.new(query_string)
    )

    result = runtime.execute["data"]

    pp result
  end

  it "supports full introspection" do
    query_string = <<-QUERY
      query IntrospectionQuery {
        __schema {
          queryType { name }
          mutationType { name }
          subscriptionType { name }
          types {
            ...FullType
          }
          directives {
            name
            description
            locations
            args {
              ...InputValue
            }
          }
        }
      }
      fragment FullType on __Type {
        kind
        name
        description
        fields(includeDeprecated: true) {
          name
          description
          args {
            ...InputValue
          }
          type {
            ...TypeRef
          }
          isDeprecated
          deprecationReason
        }
        inputFields {
          ...InputValue
        }
        interfaces {
          ...TypeRef
        }
        enumValues(includeDeprecated: true) {
          name
          description
          isDeprecated
          deprecationReason
        }
        possibleTypes {
          ...TypeRef
        }
      }
      fragment InputValue on __InputValue {
        name
        description
        type { ...TypeRef }
        defaultValue
      }
      fragment TypeRef on __Type {
        kind
        name
        ofType {
          kind
          name
          ofType {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
                ofType {
                  kind
                  name
                  ofType {
                    kind
                    name
                    ofType {
                      kind
                      name
                    }
                  }
                }
              }
            }
          }
        }
      }
    QUERY

    runtime = Graphene::Execution::Runtime.new(
      DummySchema,
      Graphene::Query.new(query_string)
    )

    result = runtime.execute["data"]

    pp result
  end
end