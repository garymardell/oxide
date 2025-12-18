require "../../spec_helper"

# Tests for Basic Query Execution
# Examples #1-8 from GraphQL spec
describe "Basic Query Execution" do
  describe "examples #1 and #2: simple field selection with argument" do
    it "executes query and returns hierarchical data" do
      user_type = Oxide::Types::ObjectType.new(
        name: "User",
        fields: {
          "id" => Oxide::Field.new(
            type: Oxide::Types::IdType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["id"] }
          ),
          "name" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["name"] }
          )
        }
      )

      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "user" => Oxide::Field.new(
              arguments: {
                "id" => Oxide::Argument.new(type: Oxide::Types::IdType.new)
              },
              type: user_type,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                id = resolution.arguments["id"]
                {
                  "id" => JSON::Any.new(id.to_s),
                  "name" => JSON::Any.new("Mark Zuckerberg")
                }
              }
            )
          }
        )
      )

      # Example #1
      query_string = <<-QUERY
        {
          user(id: 4) {
            name
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      # Example #2 - Expected result structure
      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      user = data["user"].as(Hash)
      user["name"].should eq("Mark Zuckerberg")
    end
  end

  describe "example #5: query shorthand syntax" do
    it "executes query without explicit query keyword" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "field" => Oxide::Field.new(
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "value" }
            )
          }
        )
      )

      # Example #5 - Shorthand query syntax
      query_string = <<-QUERY
        {
          field
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["field"].should eq("value")
    end
  end

  describe "example #6: multiple field selections" do
    it "executes multiple fields in selection set" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "id" => Oxide::Field.new(
              type: Oxide::Types::IdType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "12345" }
            ),
            "firstName" => Oxide::Field.new(
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "John" }
            ),
            "lastName" => Oxide::Field.new(
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "Doe" }
            )
          }
        )
      )

      # Example #6
      query_string = <<-QUERY
        {
          id
          firstName
          lastName
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["id"].should eq("12345")
      data["firstName"].should eq("John")
      data["lastName"].should eq("Doe")
    end
  end

  describe "example #7: nested field selections" do
    it "executes hierarchical field traversal" do
      birthday_type = Oxide::Types::ObjectType.new(
        name: "Birthday",
        fields: {
          "month" => Oxide::Field.new(
            type: Oxide::Types::IntType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["month"] }
          ),
          "day" => Oxide::Field.new(
            type: Oxide::Types::IntType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["day"] }
          )
        }
      )

      friend_type = Oxide::Types::ObjectType.new(
        name: "Friend",
        fields: {
          "name" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["name"] }
          )
        }
      )

      user_type = Oxide::Types::ObjectType.new(
        name: "User",
        fields: {
          "id" => Oxide::Field.new(
            type: Oxide::Types::IdType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["id"] }
          ),
          "firstName" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["firstName"] }
          ),
          "birthday" => Oxide::Field.new(
            type: birthday_type,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) {
              {
                "month" => JSON::Any.new(5_i64),
                "day" => JSON::Any.new(14_i64)
              }
            }
          ),
          "friends" => Oxide::Field.new(
            type: Oxide::Types::ListType.new(of_type: friend_type),
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) {
              [
                {"name" => JSON::Any.new("Alice")},
                {"name" => JSON::Any.new("Bob")}
              ]
            }
          )
        }
      )

      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "me" => Oxide::Field.new(
              type: user_type,
              resolve: ->(obj : Query, res : Oxide::Resolution) {
                {
                  "id" => JSON::Any.new("123"),
                  "firstName" => JSON::Any.new("Mark")
                }
              }
            )
          }
        )
      )

      # Example #7
      query_string = <<-QUERY
        {
          me {
            id
            firstName
            birthday {
              month
              day
            }
            friends {
              name
            }
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      me = data["me"].as(Hash)
      me["id"].should eq("123")
      me["firstName"].should eq("Mark")
      
      birthday = me["birthday"].as(Hash)
      birthday["month"].should eq(5)
      birthday["day"].should eq(14)
      
      friends = me["friends"].as(Array)
      friends.size.should eq(2)
      friends[0].as(Hash)["name"].should eq("Alice")
      friends[1].as(Hash)["name"].should eq("Bob")
    end
  end

  describe "example #8: common top-level field patterns" do
    it "supports both me and user(id) patterns" do
      user_type = Oxide::Types::ObjectType.new(
        name: "User",
        fields: {
          "id" => Oxide::Field.new(
            type: Oxide::Types::IdType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["id"] }
          ),
          "name" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["name"] }
          )
        }
      )

      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "me" => Oxide::Field.new(
              type: user_type,
              resolve: ->(obj : Query, res : Oxide::Resolution) {
                {
                  "id" => JSON::Any.new("current"),
                  "name" => JSON::Any.new("Current User")
                }
              }
            ),
            "user" => Oxide::Field.new(
              arguments: {
                "id" => Oxide::Argument.new(type: Oxide::Types::IdType.new)
              },
              type: user_type,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                id = resolution.arguments["id"].to_s
                {
                  "id" => JSON::Any.new(id),
                  "name" => JSON::Any.new("User #{id}")
                }
              }
            )
          }
        )
      )

      # First pattern - currently logged-in viewer
      query1 = <<-QUERY
        {
          me {
            name
          }
        }
      QUERY

      runtime = Oxide::Execution::Runtime.new(schema)
      response1 = runtime.execute(Oxide::Query.new(query1), initial_value: Query.new)

      response1.data.should_not be_nil
      data1 = response1.data.not_nil!.as(Hash)
      me = data1["me"].as(Hash)
      me["name"].should eq("Current User")

      # Second pattern - specific user via identifier
      query2 = <<-QUERY
        {
          user(id: 4) {
            name
          }
        }
      QUERY

      response2 = runtime.execute(Oxide::Query.new(query2), initial_value: Query.new)

      response2.data.should_not be_nil
      data2 = response2.data.not_nil!.as(Hash)
      user = data2["user"].as(Hash)
      user["name"].should eq("User 4")
    end
  end

  describe "example #4: mutation operation" do
    it "executes mutation with nested selections" do
      story_type = Oxide::Types::ObjectType.new(
        name: "Story",
        fields: {
          "id" => Oxide::Field.new(
            type: Oxide::Types::IdType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["id"] }
          ),
          "likeCount" => Oxide::Field.new(
            type: Oxide::Types::IntType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["likeCount"] }
          )
        }
      )

      like_result_type = Oxide::Types::ObjectType.new(
        name: "LikeStoryResult",
        fields: {
          "story" => Oxide::Field.new(
            type: story_type,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) {
              # Return the story object stored in obj["story"]
              # It's already a Hash that the story_type resolver can handle
              obj["story"].as_h
            }
          )
        }
      )

      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "dummy" => Oxide::Field.new(
              type: Oxide::Types::StringType.new,
              resolve: ->(obj : Query, res : Oxide::Resolution) { "dummy" }
            )
          }
        ),
        mutation: Oxide::Types::ObjectType.new(
          name: "Mutation",
          fields: {
            "likeStory" => Oxide::Field.new(
              arguments: {
                "storyID" => Oxide::Argument.new(type: Oxide::Types::IdType.new)
              },
              type: like_result_type,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                story_id = resolution.arguments["storyID"].to_s
                # Return a hash with "story" field that contains the story data
                # The story field will be further resolved by story_type
                {
                  "story" => JSON::Any.new({
                    "id" => JSON::Any.new(story_id),
                    "likeCount" => JSON::Any.new(124_i64)
                  }.as(Hash(String, JSON::Any)))
                }
              }
            )
          }
        )
      )

      # Example #4
      query_string = <<-QUERY
        mutation {
          likeStory(storyID: 12345) {
            story {
              likeCount
            }
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      like_result = data["likeStory"].as(Hash)
      story = like_result["story"].as(Hash)
      story["likeCount"].should eq(124)
    end
  end
end
