require "../../spec_helper"

describe Graphene::Validation::FieldSelections do
  it "gives an error if field is not defined on object" do
    query_string = <<-QUERY
      fragment fieldNotDefined on Dog {
        meowVolume
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::FieldSelections.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Validation::Error.new("field meowVolume not defined on Dog"))
  end

  it "gives an error if fragment field is not defined on interface" do
    query_string = <<-QUERY
      fragment definedOnImplementorsButNotInterface on Pet {
        nickname
      }
    QUERY

    query = Graphene::Query.new(query_string)

    pipeline = Graphene::Validation::Pipeline.new(
      ValidationsSchema,
      query,
      [Graphene::Validation::FieldSelections.new.as(Graphene::Validation::Rule)]
    )

    pipeline.execute

    pipeline.errors.size.should eq(1)
    pipeline.errors.should contain(Graphene::Validation::Error.new("field nickname not defined on Pet"))
  end
end