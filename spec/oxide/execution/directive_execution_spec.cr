require "../../spec_helper"

describe "Directive Execution" do
  describe "@skip directive" do
    it "skips field when @skip(if: true)" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              type: Oxide::Types::ObjectType.new(
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
              ),
              resolve: ->(obj : Query, res : Oxide::Resolution) { Query.new }
            )
          }
        )
      )

      query_string = <<-QUERY
        {
          user {
            id
            name @skip(if: true)
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({
        "user" => {
          "id" => "123"
        }
      })
    end

    it "includes field when @skip(if: false)" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              type: Oxide::Types::ObjectType.new(
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
              ),
              resolve: ->(obj : Query, res : Oxide::Resolution) { Query.new }
            )
          }
        )
      )

      query_string = <<-QUERY
        {
          user {
            id
            name @skip(if: false)
          }
        }
      QUERY

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

    it "supports @skip with variables" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "message" => Oxide::Field.new(
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "Hello" }
            )
          }
        )
      )

      query_string = <<-QUERY
        query($shouldSkip: Boolean!) {
          message @skip(if: $shouldSkip)
        }
      QUERY

      variables = {"shouldSkip" => JSON::Any.new(true)}
      query = Oxide::Query.new(query_string, variables: variables)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({} of String => Oxide::SerializedOutput)
    end
  end

  describe "@include directive" do
    it "includes field when @include(if: true)" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              type: Oxide::Types::ObjectType.new(
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
              ),
              resolve: ->(obj : Query, res : Oxide::Resolution) { Query.new }
            )
          }
        )
      )

      query_string = <<-QUERY
        {
          user {
            id
            name @include(if: true)
          }
        }
      QUERY

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

    it "skips field when @include(if: false)" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              type: Oxide::Types::ObjectType.new(
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
              ),
              resolve: ->(obj : Query, res : Oxide::Resolution) { Query.new }
            )
          }
        )
      )

      query_string = <<-QUERY
        {
          user {
            id
            name @include(if: false)
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({
        "user" => {
          "id" => "123"
        }
      })
    end

    it "supports @include with variables" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "message" => Oxide::Field.new(
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "Hello" }
            )
          }
        )
      )

      query_string = <<-QUERY
        query($shouldInclude: Boolean!) {
          message @include(if: $shouldInclude)
        }
      QUERY

      variables = {"shouldInclude" => JSON::Any.new(false)}
      query = Oxide::Query.new(query_string, variables: variables)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({} of String => Oxide::SerializedOutput)
    end
  end

  describe "directive combinations" do
    it "handles both @skip and @include on same field" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "message" => Oxide::Field.new(
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "Hello" }
            )
          }
        )
      )

      # @skip(if: false) and @include(if: true) should include the field
      query_string = <<-QUERY
        {
          message @skip(if: false) @include(if: true)
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({"message" => "Hello"})
    end

    it "skips field if either directive says to skip" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "message" => Oxide::Field.new(
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "Hello" }
            )
          }
        )
      )

      # @skip(if: true) should skip even if @include(if: true)
      query_string = <<-QUERY
        {
          message @skip(if: true) @include(if: true)
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({} of String => Oxide::SerializedOutput)
    end
  end

  describe "directives on fragments" do
    it "applies @skip to fragment spread" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              type: Oxide::Types::ObjectType.new(
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
              ),
              resolve: ->(obj : Query, res : Oxide::Resolution) { Query.new }
            )
          }
        )
      )

      query_string = <<-QUERY
        {
          user {
            id
            ...UserFragment @skip(if: true)
          }
        }
        
        fragment UserFragment on User {
          name
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({
        "user" => {
          "id" => "123"
        }
      })
    end

    it "applies @include to inline fragment" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              type: Oxide::Types::ObjectType.new(
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
              ),
              resolve: ->(obj : Query, res : Oxide::Resolution) { Query.new }
            )
          }
        )
      )

      query_string = <<-QUERY
        {
          user {
            id
            ... @include(if: false) {
              name
            }
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should eq({
        "user" => {
          "id" => "123"
        }
      })
    end
  end
end
