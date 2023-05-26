require "../../spec_helper"

describe Graphene::Validation::FieldSelections do
  describe "objects" do
    it "gives an error if an selection does not exist" do
      query_string = <<-QUERY
        {
          dog(name: "George") {
            meowVolume
          }
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
      pipeline.errors.should contain(Graphene::Error.new("Field \"meowVolume\" does not exist on \"Dog\""))
    end

    it "gives an error when field does not exist when aliased to a field that does exist" do
      query_string = <<-QUERY
        {
          dog(name: "George") {
            barkVolume: kawVolume
          }
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
      pipeline.errors.should contain(Graphene::Error.new("Field \"kawVolume\" does not exist on \"Dog\""))
    end
  end

  describe "interfaces" do
    it "gives an error if an selection does not exist" do
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
      pipeline.errors.should contain(Graphene::Error.new("Field \"nickname\" does not exist on \"Pet\""))
    end
  end

  describe "unions" do
    it "fields may not be selected directly from union" do
      query_string = <<-QUERY
        fragment directFieldSelectionOnUnion on CatOrDog {
          name
          barkVolume
        }
      QUERY

      query = Graphene::Query.new(query_string)

      pipeline = Graphene::Validation::Pipeline.new(
        ValidationsSchema,
        query,
        [Graphene::Validation::FieldSelections.new.as(Graphene::Validation::Rule)]
      )

      pipeline.execute

      pipeline.errors.size.should eq(2)
      pipeline.errors.should contain(Graphene::Error.new("Field \"name\" can not be selected on union type \"CatOrDog\""))
    end

    it "__typename field can be selected" do
      query_string = <<-QUERY
        fragment directFieldSelectionOnUnion on CatOrDog {
          __typename

          ... on Pet {
            name
          }
          ... on Dog {
            barkVolume
          }
        }
      QUERY

      query = Graphene::Query.new(query_string)

      pipeline = Graphene::Validation::Pipeline.new(
        ValidationsSchema,
        query,
        [Graphene::Validation::FieldSelections.new.as(Graphene::Validation::Rule)]
      )

      pipeline.execute

      pipeline.errors.size.should eq(0)
    end
  end
end