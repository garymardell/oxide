require "../../spec_helper"

describe "Error Path Tracking" do
  it "includes path for field errors" do
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "user" => Oxide::Field.new(
            type: Oxide::Types::ObjectType.new(
              name: "User",
              fields: {
                "name" => Oxide::Field.new(
                  type: Oxide::Types::NonNullType.new(
                    of_type: Oxide::Types::StringType.new
                  ),
                  resolve: ->(obj : Query, res : Oxide::Resolution) { nil }
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
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)
    runtime = Oxide::Execution::Runtime.new(schema)
    response = runtime.execute(query, initial_value: Query.new)

    response.errors.should_not be_nil
    response.errors.not_nil!.size.should eq(1)
    
    error = response.errors.not_nil!.first
    error.path.should eq(["user", "name"])
  end

  it "includes path with list indices" do
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "users" => Oxide::Field.new(
            type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::ObjectType.new(
                name: "User",
                fields: {
                  "email" => Oxide::Field.new(
                    type: Oxide::Types::NonNullType.new(
                      of_type: Oxide::Types::StringType.new
                    ),
                    resolve: ->(obj : Query, res : Oxide::Resolution) { nil }
                  )
                }
              )
            ),
            resolve: ->(obj : Query, res : Oxide::Resolution) {
              [Query.new, Query.new, Query.new]
            }
          )
        }
      )
    )

    query_string = <<-QUERY
      {
        users {
          email
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)
    runtime = Oxide::Execution::Runtime.new(schema)
    response = runtime.execute(query, initial_value: Query.new)

    response.errors.should_not be_nil
    # Should have 3 errors (one for each list item)
    response.errors.not_nil!.size.should eq(3)
    
    errors = response.errors.not_nil!.to_a
    errors[0].path.should eq(["users", 0, "email"])
    errors[1].path.should eq(["users", 1, "email"])
    errors[2].path.should eq(["users", 2, "email"])
  end

  it "includes path for nested object errors" do
    schema = Oxide::Schema.new(
      query: Oxide::Types::ObjectType.new(
        name: "Query",
        fields: {
          "post" => Oxide::Field.new(
            type: Oxide::Types::ObjectType.new(
              name: "Post",
              fields: {
                "author" => Oxide::Field.new(
                  type: Oxide::Types::ObjectType.new(
                    name: "Author",
                    fields: {
                      "email" => Oxide::Field.new(
                        type: Oxide::Types::NonNullType.new(
                          of_type: Oxide::Types::StringType.new
                        ),
                        resolve: ->(obj : Query, res : Oxide::Resolution) { nil }
                      )
                    }
                  ),
                  resolve: ->(obj : Query, res : Oxide::Resolution) { Query.new }
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
        post {
          author {
            email
          }
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)
    runtime = Oxide::Execution::Runtime.new(schema)
    response = runtime.execute(query, initial_value: Query.new)

    response.errors.should_not be_nil
    response.errors.not_nil!.size.should eq(1)
    
    error = response.errors.not_nil!.first
    error.path.should eq(["post", "author", "email"])
  end
end
