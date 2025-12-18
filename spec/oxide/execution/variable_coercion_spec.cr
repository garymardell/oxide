require "../../spec_helper"

# Tests for Variable Coercion algorithm (§6.1.2)
# Examples #31-32 from GraphQL spec
describe "Variable Coercion" do
  describe "example #31 and #32: query with variable definition" do
    it "coerces variable values correctly" do
      user_type = Oxide::Types::ObjectType.new(
        name: "User",
        fields: {
          "id" => Oxide::Field.new(
            type: Oxide::Types::IntType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["id"] }
          ),
          "name" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["name"] }
          ),
          "profilePic" => Oxide::Field.new(
            arguments: {
              "size" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
            },
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Hash(String, JSON::Any), resolution : Oxide::Resolution) {
              size = resolution.arguments["size"]?
              "https://cdn/pic_#{size}.jpg"
            }
          )
        }
      )

      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              arguments: {
                "id" => Oxide::Argument.new(type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::IntType.new))
              },
              type: user_type,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                id = resolution.arguments["id"].as_i
                {"id" => JSON::Any.new(id.to_i64), "name" => JSON::Any.new("Mark Zuckerberg")}
              }
            )
          }
        )
      )

      # Example #31 - Query with variable definition
      query_string = <<-QUERY
        query getZuckProfile($devicePicSize: Int) {
          user(id: 4) {
            id
            name
            profilePic(size: $devicePicSize)
          }
        }
      QUERY

      # Example #32 - Variable values as JSON
      variables = {"devicePicSize" => JSON::Any.new(60_i64)}

      query = Oxide::Query.new(query_string, variables: variables)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      user = data["user"].as(Hash)
      user["id"].should eq(4)
      user["name"].should eq("Mark Zuckerberg")
      user["profilePic"].should eq("https://cdn/pic_60.jpg")
    end
  end

  describe "variable coercion with default values" do
    it "uses default value when variable not provided" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "greeting" => Oxide::Field.new(
              arguments: {
                "name" => Oxide::Argument.new(type: Oxide::Types::StringType.new)
              },
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                name = resolution.arguments["name"]?.try(&.as_s) || "World"
                "Hello, #{name}!"
              }
            )
          }
        )
      )

      query_string = <<-QUERY
        query greet($name: String = "Default") {
          greeting(name: $name)
        }
      QUERY

      # Don't provide the variable
      query = Oxide::Query.new(query_string, variables: {} of String => JSON::Any)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["greeting"].should eq("Hello, Default!")
    end

    it "overrides default value when variable is provided" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "greeting" => Oxide::Field.new(
              arguments: {
                "name" => Oxide::Argument.new(type: Oxide::Types::StringType.new)
              },
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                name = resolution.arguments["name"]?.try(&.as_s) || "World"
                "Hello, #{name}!"
              }
            )
          }
        )
      )

      query_string = <<-QUERY
        query greet($name: String = "Default") {
          greeting(name: $name)
        }
      QUERY

      # Provide the variable
      variables = {"name" => JSON::Any.new("Alice")}
      query = Oxide::Query.new(query_string, variables: variables)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["greeting"].should eq("Hello, Alice!")
    end
  end

  describe "variable coercion with non-null types" do
    it "raises error when non-null variable not provided and has no default" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              arguments: {
                "id" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
              },
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "user" }
            )
          }
        )
      )

      query_string = <<-QUERY
        query getUser($id: Int!) {
          user(id: $id)
        }
      QUERY

      # Don't provide the required variable
      query = Oxide::Query.new(query_string, variables: {} of String => JSON::Any)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.errors.should_not be_nil
      response.errors.not_nil!.size.should eq(1)
      response.errors.not_nil!.first.message.should match(/Variable.*id.*null/)
    end

    it "raises error when non-null variable provided as null" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              arguments: {
                "id" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
              },
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "user" }
            )
          }
        )
      )

      query_string = <<-QUERY
        query getUser($id: Int!) {
          user(id: $id)
        }
      QUERY

      # Provide null for required variable
      variables = {"id" => JSON::Any.new(nil)}
      query = Oxide::Query.new(query_string, variables: variables)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.errors.should_not be_nil
      response.errors.not_nil!.size.should eq(1)
      response.errors.not_nil!.first.message.should match(/Variable.*id.*null/)
    end
  end

  describe "variable coercion with null values" do
    it "allows null for nullable variable types" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "greeting" => Oxide::Field.new(
              arguments: {
                "name" => Oxide::Argument.new(type: Oxide::Types::StringType.new)
              },
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                name = resolution.arguments["name"]?
                if name && !name.raw.nil?
                  "Hello, #{name.as_s}!"
                else
                  "Hello, stranger!"
                end
              }
            )
          }
        )
      )

      query_string = <<-QUERY
        query greet($name: String) {
          greeting(name: $name)
        }
      QUERY

      # Provide null value
      variables = {"name" => JSON::Any.new(nil)}
      query = Oxide::Query.new(query_string, variables: variables)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["greeting"].should eq("Hello, stranger!")
      response.errors.should be_nil
    end
  end

  describe "variable coercion with complex types" do
    it "coerces list variables" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "sum" => Oxide::Field.new(
              arguments: {
                "numbers" => Oxide::Argument.new(type: Oxide::Types::ListType.new(of_type: Oxide::Types::IntType.new))
              },
              type: Oxide::Types::IntType.new,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                numbers = resolution.arguments["numbers"]?.try(&.as_a) || [] of JSON::Any
                numbers.sum(&.as_i)
              }
            )
          }
        )
      )

      query_string = <<-QUERY
        query calcSum($nums: [Int]) {
          sum(numbers: $nums)
        }
      QUERY

      variables = {"nums" => JSON::Any.new([JSON::Any.new(1_i64), JSON::Any.new(2_i64), JSON::Any.new(3_i64)])}
      query = Oxide::Query.new(query_string, variables: variables)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["sum"].should eq(6)
    end
  end
end
