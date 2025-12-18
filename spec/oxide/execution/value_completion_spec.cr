require "../../spec_helper"

describe "Value Completion" do
  describe "Scalar completion" do
    it "completes Int values" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "age" => Oxide::Field.new(
              type: Oxide::Types::IntType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { 42 }
            )
          }
        )
      )

      query_string = "{ age }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"age" => 42})
    end

    it "completes Float values" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "price" => Oxide::Field.new(
              type: Oxide::Types::FloatType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { 19.99 }
            )
          }
        )
      )

      query_string = "{ price }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      data = response.data.as(Hash)
      data["price"].as(Float32 | Float64).should be_close(19.99, 0.01)
    end

    it "completes String values" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "message" => Oxide::Field.new(
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "Hello World" }
            )
          }
        )
      )

      query_string = "{ message }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"message" => "Hello World"})
    end

    it "completes Boolean values" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "isActive" => Oxide::Field.new(
              type: Oxide::Types::BooleanType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { true }
            )
          }
        )
      )

      query_string = "{ isActive }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"isActive" => true})
    end

    it "completes ID values" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "userId" => Oxide::Field.new(
              type: Oxide::Types::IdType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "user-123" }
            )
          }
        )
      )

      query_string = "{ userId }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"userId" => "user-123"})
    end

    it "returns null for nullable scalar when resolver returns null" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "optionalMessage" => Oxide::Field.new(
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { nil }
            )
          }
        )
      )

      query_string = "{ optionalMessage }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"optionalMessage" => nil})
    end
  end

  describe "Enum completion" do
    it "completes enum values" do
      status_enum = Oxide::Types::EnumType.new(
        name: "Status",
        values: [
          Oxide::Types::EnumValue.new(name: "ACTIVE", value: "active"),
          Oxide::Types::EnumValue.new(name: "INACTIVE", value: "inactive"),
          Oxide::Types::EnumValue.new(name: "PENDING", value: "pending")
        ]
      )

      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "status" => Oxide::Field.new(
              type: status_enum,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "active" }
            )
          }
        )
      )

      query_string = "{ status }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"status" => "ACTIVE"})
    end

    it "returns null for nullable enum when resolver returns null" do
      status_enum = Oxide::Types::EnumType.new(
        name: "Status",
        values: [
          Oxide::Types::EnumValue.new(name: "ACTIVE", value: "active")
        ]
      )

      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "status" => Oxide::Field.new(
              type: status_enum,
              resolve: ->(obj : Query, res : Oxide::Resolution) { nil }
            )
          }
        )
      )

      query_string = "{ status }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"status" => nil})
    end
  end

  describe "List completion" do
    it "completes list of scalars" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "numbers" => Oxide::Field.new(
              type: Oxide::Types::ListType.new(of_type: Oxide::Types::IntType.new),
              resolve: ->(obj : Query, res : Oxide::Resolution) { [1, 2, 3, 4, 5] }
            )
          }
        )
      )

      query_string = "{ numbers }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"numbers" => [1, 2, 3, 4, 5]})
    end

    it "completes empty list" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "numbers" => Oxide::Field.new(
              type: Oxide::Types::ListType.new(of_type: Oxide::Types::IntType.new),
              resolve: ->(obj : Query, res : Oxide::Resolution) { [] of Int32 }
            )
          }
        )
      )

      query_string = "{ numbers }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"numbers" => [] of Oxide::SerializedOutput})
    end

    it "returns null for nullable list when resolver returns null" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "numbers" => Oxide::Field.new(
              type: Oxide::Types::ListType.new(of_type: Oxide::Types::IntType.new),
              resolve: ->(obj : Query, res : Oxide::Resolution) { nil }
            )
          }
        )
      )

      query_string = "{ numbers }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"numbers" => nil})
    end

    it "allows null items in list of nullable type" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "numbers" => Oxide::Field.new(
              type: Oxide::Types::ListType.new(of_type: Oxide::Types::IntType.new),
              resolve: ->(obj : Query, res : Oxide::Resolution) { [1, nil, 3] }
            )
          }
        )
      )

      query_string = "{ numbers }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"numbers" => [1, nil, 3]})
    end
  end

  describe "Non-null completion" do
    it "completes non-null scalar" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "message" => Oxide::Field.new(
              type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::StringType.new),
              resolve: ->(obj : Query, res : Oxide::Resolution) { "Hello" }
            )
          }
        )
      )

      query_string = "{ message }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"message" => "Hello"})
    end

    it "errors when non-null field returns null" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "message" => Oxide::Field.new(
              type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::StringType.new),
              resolve: ->(obj : Query, res : Oxide::Resolution) { nil }
            )
          }
        )
      )

      query_string = "{ message }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.errors.should_not be_nil
      response.errors.not_nil!.size.should eq(1)
      error_message = response.errors.not_nil!.first.message
      error_message.should_not be_nil
      error_message.not_nil!.should contain("Cannot return null")
    end
  end

  describe "Object completion" do
    it "completes nested objects" do
      user_type = Oxide::Types::ObjectType.new(
        name: "User",
        fields: {
          "id" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) { "123" }
          ),
          "name" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) { "Alice" }
          )
        }
      )

      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              type: user_type,
              resolve: ->(obj : Query, res : Oxide::Resolution) { Query.new }
            )
          }
        )
      )

      query_string = "{ user { id name } }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({
        "user" => {
          "id" => "123",
          "name" => "Alice"
        }
      })
    end

    it "returns null for nullable object when resolver returns null" do
      user_type = Oxide::Types::ObjectType.new(
        name: "User",
        fields: {
          "id" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Query, res : Oxide::Resolution) { "123" }
          )
        }
      )

      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              type: user_type,
              resolve: ->(obj : Query, res : Oxide::Resolution) { nil }
            )
          }
        )
      )

      query_string = "{ user { id } }"
      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"user" => nil})
    end
  end
end
