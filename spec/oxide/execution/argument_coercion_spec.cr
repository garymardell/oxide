require "../../spec_helper"

# Tests for Argument Coercion algorithm (§6.4.1)
# Examples #9-12 from GraphQL spec
describe "Argument Coercion" do
  describe "example #9: single argument" do
    it "passes single argument to field" do
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
              size = resolution.arguments["size"]?.try(&.as_i) || 50
              "pic_#{size}.jpg"
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
                "id" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
              },
              type: user_type,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                id = resolution.arguments["id"]?.try(&.as_i) || 0
                {
                  "id" => JSON::Any.new(id.to_i64),
                  "name" => JSON::Any.new("Test User")
                }
              }
            )
          }
        )
      )

      # Example #9
      query_string = <<-QUERY
        {
          user(id: 4) {
            id
            name
            profilePic(size: 100)
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      user = data["user"].as(Hash)
      user["id"].should eq(4)
      user["name"].should eq("Test User")
      user["profilePic"].should eq("pic_100.jpg")
    end
  end

  describe "example #10: multiple arguments" do
    it "passes multiple arguments to field" do
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
              "width" => Oxide::Argument.new(type: Oxide::Types::IntType.new),
              "height" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
            },
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Hash(String, JSON::Any), resolution : Oxide::Resolution) {
              width = resolution.arguments["width"]?.try(&.as_i) || 50
              height = resolution.arguments["height"]?.try(&.as_i) || 50
              "pic_#{width}x#{height}.jpg"
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
                "id" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
              },
              type: user_type,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                {
                  "id" => JSON::Any.new(4_i64),
                  "name" => JSON::Any.new("Test User")
                }
              }
            )
          }
        )
      )

      # Example #10
      query_string = <<-QUERY
        {
          user(id: 4) {
            id
            name
            profilePic(width: 100, height: 50)
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      user = data["user"].as(Hash)
      user["profilePic"].should eq("pic_100x50.jpg")
    end
  end

  describe "examples #11 and #12: argument order independence" do
    it "produces same result regardless of argument order" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "picture" => Oxide::Field.new(
              arguments: {
                "width" => Oxide::Argument.new(type: Oxide::Types::IntType.new),
                "height" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
              },
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                width = resolution.arguments["width"]?.try(&.as_i) || 0
                height = resolution.arguments["height"]?.try(&.as_i) || 0
                "picture_#{width}x#{height}"
              }
            )
          }
        )
      )

      # Example #11
      query1 = <<-QUERY
        {
          picture(width: 200, height: 100)
        }
      QUERY

      # Example #12
      query2 = <<-QUERY
        {
          picture(height: 100, width: 200)
        }
      QUERY

      runtime = Oxide::Execution::Runtime.new(schema)
      
      response1 = runtime.execute(Oxide::Query.new(query1), initial_value: Query.new)
      response2 = runtime.execute(Oxide::Query.new(query2), initial_value: Query.new)

      response1.data.should_not be_nil
      response2.data.should_not be_nil
      
      data1 = response1.data.not_nil!.as(Hash)
      data2 = response2.data.not_nil!.as(Hash)
      
      result1 = data1["picture"]
      result2 = data2["picture"]
      
      result1.should eq("picture_200x100")
      result2.should eq("picture_200x100")
      result1.should eq(result2)
    end
  end

  describe "argument coercion with default values" do
    it "uses default value when argument not provided" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "greeting" => Oxide::Field.new(
              arguments: {
                "name" => Oxide::Argument.new(
                  type: Oxide::Types::StringType.new,
                  default_value: "World"
                )
              },
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                name = resolution.arguments["name"]?.try(&.as_s) || "Unknown"
                "Hello, #{name}!"
              }
            )
          }
        )
      )

      query_string = <<-QUERY
        {
          greeting
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["greeting"].should eq("Hello, World!")
    end

    it "overrides default value when argument is provided" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "greeting" => Oxide::Field.new(
              arguments: {
                "name" => Oxide::Argument.new(
                  type: Oxide::Types::StringType.new,
                  default_value: "World"
                )
              },
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                name = resolution.arguments["name"]?.try(&.as_s) || "Unknown"
                "Hello, #{name}!"
              }
            )
          }
        )
      )

      query_string = <<-QUERY
        {
          greeting(name: "Alice")
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["greeting"].should eq("Hello, Alice!")
    end
  end

  describe "argument coercion with non-null types" do
    it "raises error when required argument not provided" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              arguments: {
                "id" => Oxide::Argument.new(type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::IntType.new))
              },
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                "user_#{resolution.arguments["id"]}"
              }
            )
          }
        )
      )

      query_string = <<-QUERY
        {
          user
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.errors.should_not be_nil
      response.errors.not_nil!.size.should eq(1)
      response.errors.not_nil!.first.message.should match(/Argument.*id.*null/)
    end
  end

  describe "argument coercion from variables" do
    it "coerces arguments from variable values" do
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
                name = resolution.arguments["name"]?.try(&.as_s) || "Unknown"
                "Hello, #{name}!"
              }
            )
          }
        )
      )

      query_string = <<-QUERY
        query greet($userName: String) {
          greeting(name: $userName)
        }
      QUERY

      variables = {"userName" => JSON::Any.new("Bob")}
      query = Oxide::Query.new(query_string, variables: variables)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["greeting"].should eq("Hello, Bob!")
    end
  end

  describe "argument coercion with input objects" do
    it "coerces input object arguments" do
      input_type = Oxide::Types::InputObjectType.new(
        name: "UserInput",
        input_fields: {
          "name" => Oxide::Argument.new(type: Oxide::Types::StringType.new),
          "age" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
        }
      )

      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "createUser" => Oxide::Field.new(
              arguments: {
                "input" => Oxide::Argument.new(type: input_type)
              },
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                input = resolution.arguments["input"]?.try(&.as_h)
                return "no input" unless input
                name = input["name"]?.try(&.as_s) || "Unknown"
                age = input["age"]?.try(&.as_i) || 0
                "Created user #{name} aged #{age}"
              }
            )
          }
        )
      )

      query_string = <<-QUERY
        {
          createUser(input: { name: "Alice", age: 30 })
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["createUser"].should eq("Created user Alice aged 30")
    end
  end

  describe "argument coercion with lists" do
    it "coerces list arguments" do
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
        {
          sum(numbers: [1, 2, 3, 4, 5])
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["sum"].should eq(15)
    end
  end

  describe "argument coercion with enums" do
    it "coerces enum arguments" do
      color_enum = Oxide::Types::EnumType.new(
        name: "Color",
        values: [
          Oxide::Types::EnumValue.new(name: "RED", value: "RED"),
          Oxide::Types::EnumValue.new(name: "GREEN", value: "GREEN"),
          Oxide::Types::EnumValue.new(name: "BLUE", value: "BLUE")
        ]
      )

      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "paint" => Oxide::Field.new(
              arguments: {
                "color" => Oxide::Argument.new(type: color_enum)
              },
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                color = resolution.arguments["color"]?.try(&.as_s) || "UNKNOWN"
                "Painting with #{color}"
              }
            )
          }
        )
      )

      query_string = <<-QUERY
        {
          paint(color: RED)
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["paint"].should eq("Painting with RED")
    end
  end
end
