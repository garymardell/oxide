require "../../spec_helper"

describe Oxide::Validation::ExecutableDefinitions do
  it "example - accepts executable definitions (operations and fragments)" do
    query_string = <<-QUERY
      query getDogName {
        dog {
          name
        }
      }

      fragment dogFragment on Dog {
        name
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ExecutableDefinitions.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end

  it "counter example #106 - rejects type system definitions in executable documents" do
    query_string = <<-QUERY
      query getDogName {
        dog {
          name
        }
      }

      type Cat {
        name: String
        color: String
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ExecutableDefinitions.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should be >= 1
    runtime.errors.first.message.should match(/definition is not executable/)
  end

  it "rejects schema definition" do
    query_string = <<-QUERY
      schema {
        query: Query
      }

      query test {
        dog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ExecutableDefinitions.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("The \"schema\" definition is not executable."))
  end

  it "rejects scalar type definition" do
    query_string = <<-QUERY
      scalar DateTime

      query test {
        dog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ExecutableDefinitions.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("The \"DateTime\" definition is not executable."))
  end

  it "rejects object type definition" do
    query_string = <<-QUERY
      type Cat {
        name: String
      }

      query test {
        dog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ExecutableDefinitions.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("The \"Cat\" definition is not executable."))
  end

  it "rejects interface type definition" do
    query_string = <<-QUERY
      interface Animal {
        name: String
      }

      query test {
        dog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ExecutableDefinitions.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("The \"Animal\" definition is not executable."))
  end

  it "rejects union type definition" do
    query_string = <<-QUERY
      union SearchResult = Dog | Cat

      query test {
        dog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ExecutableDefinitions.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("The \"SearchResult\" definition is not executable."))
  end

  it "rejects enum type definition" do
    query_string = <<-QUERY
      enum Color {
        RED
        GREEN
        BLUE
      }

      query test {
        dog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ExecutableDefinitions.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("The \"Color\" definition is not executable."))
  end

  it "rejects input object type definition" do
    query_string = <<-QUERY
      input SearchInput {
        name: String
      }

      query test {
        dog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ExecutableDefinitions.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("The \"SearchInput\" definition is not executable."))
  end

  it "rejects directive definition" do
    query_string = <<-QUERY
      directive @custom on FIELD

      query test {
        dog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::ExecutableDefinitions.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.should contain(Oxide::ValidationError.new("The \"custom\" definition is not executable."))
  end
end
