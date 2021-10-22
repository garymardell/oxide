require "../../spec_helper"

describe Graphene::Validation::OperationNameUniqueness do
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

    schema = Graphene::Schema.new(
      query: Graphene::Type::Object.new(
        name: "Query"
      )
    )

    rule = Graphene::Validation::OperationNameUniqueness.new(schema)

    query = Graphene::Query.new(query_string)
    query.accept(rule)

    rule.errors.size.should eq(1)
    rule.errors.should eq([Graphene::Validation::Error.new("multiple operations found with the name getName")])
  end
end