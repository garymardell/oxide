require "../../spec_helper"

describe Graphql::Validation::OperationNameUniqueness do
  it "checks for operation name uniqueness" do
    query_string = <<-QUERY
      query getName {
        dog {
          name
        }
      }

      query getName {
        dog {
          owner {
            name
          }
        }
      }
    QUERY

    schema = Graphql::Schema.new(
      query: Graphql::Type::Object.new(
        typename: "Query",
        resolver: NullResolver.new
      )
    )

    rule = Graphql::Validation::OperationNameUniqueness.new(schema)

    query = Graphql::Query.new(query_string)
    query.accept(rule)

    rule.errors.size.should eq(1)
    rule.errors.should eq([Graphql::Validation::Error.new("multiple operations found with the name getName")])
  end
end