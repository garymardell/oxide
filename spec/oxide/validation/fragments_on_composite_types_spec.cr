require "../../spec_helper"

describe Oxide::Validation::FragmentsOnCompositeTypes do
  describe "example #150" do
    it "accepts fragments on object types" do
      query_string = <<-QUERY
        fragment fragOnObject on Dog {
          name
        }

        {
          dog {
            ...fragOnObject
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentsOnCompositeTypes.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end

    it "accepts fragments on interface types" do
      query_string = <<-QUERY
        fragment fragOnInterface on Pet {
          name
        }

        {
          dog {
            ...fragOnInterface
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentsOnCompositeTypes.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end

    it "accepts fragments on union types" do
      query_string = <<-QUERY
        fragment fragOnUnion on CatOrDog {
          ... on Dog {
            name
          }
        }

        {
          dog {
            ...fragOnUnion
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentsOnCompositeTypes.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end
  end

  describe "counter example #151" do
    it "rejects fragments on scalar types" do
      query_string = <<-QUERY
        fragment fragOnScalar on Int {
          something
        }

        {
          dog {
            ...fragOnScalar
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentsOnCompositeTypes.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should be >= 1
      runtime.errors.first.message.should match(/Int.*scalar|scalar.*Int|composite/i)
    end

    it "rejects inline fragments on scalar types" do
      query_string = <<-QUERY
        {
          dog {
            ... on Boolean {
              somethingElse
            }
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentsOnCompositeTypes.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should be >= 1
      runtime.errors.first.message.should match(/Boolean.*scalar|scalar.*Boolean|composite/i)
    end
  end

  it "accepts inline fragments on object types" do
    query_string = <<-QUERY
      {
        dog {
          ... on Dog {
            name
            barkVolume
          }
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentsOnCompositeTypes.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "accepts inline fragments on interface types" do
    query_string = <<-QUERY
      {
        dog {
          ... on Pet {
            name
          }
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentsOnCompositeTypes.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "accepts inline fragments on union types" do
    query_string = <<-QUERY
      {
        dog {
          ... on CatOrDog {
            ... on Dog {
              name
            }
          }
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentsOnCompositeTypes.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "rejects fragments on enum types" do
    query_string = <<-QUERY
      fragment fragOnEnum on DogCommand {
        something
      }

      {
        dog {
          ...fragOnEnum
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentsOnCompositeTypes.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should be >= 1
    runtime.errors.first.message.should match(/DogCommand.*enum|enum.*DogCommand|composite/i)
  end

  it "accepts inline fragments without type condition" do
    query_string = <<-QUERY
      {
        dog {
          ... {
            name
            barkVolume
          }
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentsOnCompositeTypes.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end
end