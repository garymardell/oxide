require "../../spec_helper"

describe Oxide::Validation::OperationTypeExistence do
  it "allows query operations" do
    query_string = <<-QUERY
      query getDog {
        dog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::OperationTypeExistence.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "allows mutation operations when schema has mutation type" do
    # ValidationsSchema has a mutation type defined
    schema_with_mutation = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "dog" => Oxide::Field.new(
            type: DogType,
            resolve: ->(object : Query, resolution : Oxide::Resolution) { nil }
          )
        }
      ),
      mutation: Oxide::Types::ObjectType.new(
        name: "Mutation",
        fields: {
          "createDog" => Oxide::Field.new(
            type: DogType,
            resolve: ->(object : Query, resolution : Oxide::Resolution) { nil }
          )
        }
      )
    )

    query_string = <<-QUERY
      mutation createDog {
        createDog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      schema_with_mutation,
      query,
      [Oxide::Validation::OperationTypeExistence.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "rejects mutation operations when schema has no mutation type" do
    schema_without_mutation = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "dog" => Oxide::Field.new(
            type: DogType,
            resolve: ->(object : Query, resolution : Oxide::Resolution) { nil }
          )
        }
      )
    )

    query_string = <<-QUERY
      mutation createDog {
        createDog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      schema_without_mutation,
      query,
      [Oxide::Validation::OperationTypeExistence.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.should match(/mutation/i)
  end

  it "rejects subscription operations" do
    query_string = <<-QUERY
      subscription watchDog {
        dog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::OperationTypeExistence.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.should match(/subscription/i)
  end
end
