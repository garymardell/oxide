require "../../spec_helper"

# Tests for Fragment Execution
# Examples #17-23 from GraphQL spec
describe "Fragment Execution" do
  describe "example #18: basic named fragments" do
    it "executes named fragments correctly" do
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
          ),
          "profilePic" => Oxide::Field.new(
            arguments: {
              "size" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
            },
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Hash(String, JSON::Any), resolution : Oxide::Resolution) {
              size = resolution.arguments["size"]?.try(&.as_i) || 50
              "pic-#{size}.jpg"
            }
          ),
          "friends" => Oxide::Field.new(
            arguments: {
              "first" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
            },
            type: Oxide::Types::ListType.new(of_type: Oxide::Types::LateBoundType.new("User")),
            resolve: ->(obj : Hash(String, JSON::Any), resolution : Oxide::Resolution) {
              [
                {"id" => JSON::Any.new("1"), "name" => JSON::Any.new("Friend 1")},
                {"id" => JSON::Any.new("2"), "name" => JSON::Any.new("Friend 2")}
              ]
            }
          ),
          "mutualFriends" => Oxide::Field.new(
            arguments: {
              "first" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
            },
            type: Oxide::Types::ListType.new(of_type: Oxide::Types::LateBoundType.new("User")),
            resolve: ->(obj : Hash(String, JSON::Any), resolution : Oxide::Resolution) {
              [
                {"id" => JSON::Any.new("3"), "name" => JSON::Any.new("Mutual 1")}
              ]
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
                "id" => Oxide::Argument.new(type: Oxide::Types::IdType.new)
              },
              type: user_type,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                {"id" => JSON::Any.new("4"), "name" => JSON::Any.new("Mark")}
              }
            )
          }
        ),
        orphan_types: [user_type].map(&.as(Oxide::Type))
      )

      # Example #18
      query_string = <<-QUERY
        query withFragments {
          user(id: 4) {
            friends(first: 10) {
              ...friendFields
            }
            mutualFriends(first: 10) {
              ...friendFields
            }
          }
        }

        fragment friendFields on User {
          id
          name
          profilePic(size: 50)
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      user = data["user"].as(Hash)
      
      friends = user["friends"].as(Array)
      friends.size.should eq(2)
      friends[0].as(Hash)["id"].should eq("1")
      friends[0].as(Hash)["name"].should eq("Friend 1")
      friends[0].as(Hash)["profilePic"].should eq("pic-50.jpg")
      
      mutual = user["mutualFriends"].as(Array)
      mutual.size.should eq(1)
      mutual[0].as(Hash)["id"].should eq("3")
      mutual[0].as(Hash)["profilePic"].should eq("pic-50.jpg")
    end
  end

  describe "example #17: nested fragments" do
    it "executes fragments that reference other fragments" do
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
          ),
          "profilePic" => Oxide::Field.new(
            arguments: {
              "size" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
            },
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Hash(String, JSON::Any), resolution : Oxide::Resolution) {
              size = resolution.arguments["size"]?.try(&.as_i) || 50
              "pic-#{size}.jpg"
            }
          ),
          "friends" => Oxide::Field.new(
            arguments: {
              "first" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
            },
            type: Oxide::Types::ListType.new(of_type: Oxide::Types::LateBoundType.new("User")),
            resolve: ->(obj : Hash(String, JSON::Any), resolution : Oxide::Resolution) {
              [{"id" => JSON::Any.new("1"), "name" => JSON::Any.new("Friend")}]
            }
          ),
          "mutualFriends" => Oxide::Field.new(
            arguments: {
              "first" => Oxide::Argument.new(type: Oxide::Types::IntType.new)
            },
            type: Oxide::Types::ListType.new(of_type: Oxide::Types::LateBoundType.new("User")),
            resolve: ->(obj : Hash(String, JSON::Any), resolution : Oxide::Resolution) {
              [{"id" => JSON::Any.new("2"), "name" => JSON::Any.new("Mutual")}]
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
                "id" => Oxide::Argument.new(type: Oxide::Types::IdType.new)
              },
              type: user_type,
              resolve: ->(obj : Query, resolution : Oxide::Resolution) {
                {"id" => JSON::Any.new("4"), "name" => JSON::Any.new("Mark")}
              }
            )
          }
        ),
        orphan_types: [user_type].map(&.as(Oxide::Type))
      )

      # Example #17 - Nested fragments
      query_string = <<-QUERY
        query withNestedFragments {
          user(id: 4) {
            friends(first: 10) {
              ...friendFields
            }
            mutualFriends(first: 10) {
              ...friendFields
            }
          }
        }

        fragment friendFields on User {
          id
          name
          ...standardProfilePic
        }

        fragment standardProfilePic on User {
          profilePic(size: 50)
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      user = data["user"].as(Hash)
      
      friends = user["friends"].as(Array)
      friends[0].as(Hash)["id"].should eq("1")
      friends[0].as(Hash)["name"].should eq("Friend")
      friends[0].as(Hash)["profilePic"].should eq("pic-50.jpg")
    end
  end


end
