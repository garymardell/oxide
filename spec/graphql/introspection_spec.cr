require "../spec_helper"

describe Graphql do
  it "gets object __typename" do
    query = <<-QUERY
      query {
        charges {
          id
          __typename
        }
      }
    QUERY

    parser = Graphql::Language::Parser.new
    
    runtime = Graphql::Execution::Runtime.new(
      DummySchema,
      parser.parse(query)
    )

    result = runtime.execute

    result.should eq({ "charges" => [{ "id" => 1, "__typename" => "Charge" }, { "id" => 2, "__typename" => "Charge" }] })
  end
  
  it "executes introspection query" do
    query = <<-QUERY
    query IntrospectionQuery {
      __schema {
        queryType {
          name
        }
        mutationType {
          name
        }
        subscriptionType {
          name
        }
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
      type {
        ...TypeRef
      }
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

    parser = Graphql::Language::Parser.new
    
    runtime = Graphql::Execution::Runtime.new(
      DummySchema,
      parser.parse(query)
    )

    puts runtime.execute
  end
end