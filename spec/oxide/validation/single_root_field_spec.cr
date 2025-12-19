require "../../spec_helper"

describe Oxide::Validation::SingleRootField do
  it "allows subscription with single root field" do
    query_string = <<-QUERY
      subscription OnMessage {
        newMessage {
          id
          text
        }
      }
    QUERY

    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      ),
      subscription: Oxide::Types::ObjectType.new(
        name: "Subscription",
        fields: {
          "newMessage" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "message" }
          )
        }
      )
    )

    query = Oxide::Query.new(query_string)
    validator = Oxide::Validation::Runtime.new(schema, query)
    validator.execute

    validator.errors.should be_empty
  end

  it "allows subscription with single root field and __typename" do
    query_string = <<-QUERY
      subscription OnMessage {
        newMessage {
          id
        }
        __typename
      }
    QUERY

    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      ),
      subscription: Oxide::Types::ObjectType.new(
        name: "Subscription",
        fields: {
          "newMessage" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "message" }
          )
        }
      )
    )

    query = Oxide::Query.new(query_string)
    validator = Oxide::Validation::Runtime.new(schema, query)
    validator.execute

    validator.errors.should be_empty
  end

  it "rejects subscription with multiple root fields" do
    query_string = <<-QUERY
      subscription MultipleFields {
        newMessage {
          id
        }
        newUser {
          id
        }
      }
    QUERY

    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      ),
      subscription: Oxide::Types::ObjectType.new(
        name: "Subscription",
        fields: {
          "newMessage" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "message" }
          ),
          "newUser" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "user" }
          )
        }
      )
    )

    query = Oxide::Query.new(query_string)
    validator = Oxide::Validation::Runtime.new(schema, query)
    validator.execute

    validator.errors.size.should eq(1)
    validator.errors.first.message.should eq("Subscription \"MultipleFields\" must have only one root field.")
  end

  it "rejects anonymous subscription with multiple root fields" do
    query_string = <<-QUERY
      subscription {
        newMessage {
          id
        }
        newUser {
          id
        }
        newComment {
          id
        }
      }
    QUERY

    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      ),
      subscription: Oxide::Types::ObjectType.new(
        name: "Subscription",
        fields: {
          "newMessage" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "message" }
          ),
          "newUser" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "user" }
          ),
          "newComment" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "comment" }
          )
        }
      )
    )

    query = Oxide::Query.new(query_string)
    validator = Oxide::Validation::Runtime.new(schema, query)
    validator.execute

    validator.errors.size.should eq(1)
    validator.errors.first.message.should eq("Subscription \"Anonymous\" must have only one root field.")
  end

  it "does not validate query operations" do
    query_string = <<-QUERY
      query MultipleFields {
        field1
        field2
        field3
      }
    QUERY

    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "field1" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "1" }
          ),
          "field2" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "2" }
          ),
          "field3" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "3" }
          )
        }
      )
    )

    query = Oxide::Query.new(query_string)
    validator = Oxide::Validation::Runtime.new(schema, query)
    validator.execute

    validator.errors.should be_empty
  end

  it "does not validate mutation operations" do
    query_string = <<-QUERY
      mutation MultipleFields {
        createUser
        deleteUser
      }
    QUERY

    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      ),
      mutation: Oxide::Types::ObjectType.new(
        name: "Mutation",
        fields: {
          "createUser" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "created" }
          ),
          "deleteUser" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "deleted" }
          )
        }
      )
    )

    query = Oxide::Query.new(query_string)
    validator = Oxide::Validation::Runtime.new(schema, query)
    validator.execute

    validator.errors.should be_empty
  end

  it "rejects subscription with fragment spread and field" do
    query_string = <<-QUERY
      subscription WithFragment {
        newMessage {
          id
        }
        ...MessageFragment
      }

      fragment MessageFragment on Subscription {
        newUser {
          id
        }
      }
    QUERY

    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      ),
      subscription: Oxide::Types::ObjectType.new(
        name: "Subscription",
        fields: {
          "newMessage" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "message" }
          ),
          "newUser" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "user" }
          )
        }
      )
    )

    query = Oxide::Query.new(query_string)
    validator = Oxide::Validation::Runtime.new(schema, query)
    validator.execute

    validator.errors.size.should be >= 1
    validator.errors.any? { |e| e.message == "Subscription \"WithFragment\" must have only one root field." }.should be_true
  end

  it "rejects subscription with inline fragment and field" do
    query_string = <<-QUERY
      subscription WithInlineFragment {
        newMessage {
          id
        }
        ... on Subscription {
          newUser {
            id
          }
        }
      }
    QUERY

    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "test" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "test" }
          )
        }
      ),
      subscription: Oxide::Types::ObjectType.new(
        name: "Subscription",
        fields: {
          "newMessage" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "message" }
          ),
          "newUser" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(object : Nil, resolution : Oxide::Resolution) { "user" }
          )
        }
      )
    )

    query = Oxide::Query.new(query_string)
    validator = Oxide::Validation::Runtime.new(schema, query)
    validator.execute

    validator.errors.size.should be >= 1
    validator.errors.any? { |e| e.message == "Subscription \"WithInlineFragment\" must have only one root field." }.should be_true
  end
end
