require "../../spec_helper"

# Tests for Field Aliases
# Examples #13-16 from GraphQL spec
describe "Field Aliases" do
  describe "examples #13 and #14: field aliases with different arguments" do
    it "allows same field multiple times with aliases" do
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
              id = obj["id"].to_s
              "https://cdn.site.io/pic-#{id}-#{size}.jpg"
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

      # Example #13
      query_string = <<-QUERY
        {
          user(id: 4) {
            id
            name
            smallPic: profilePic(size: 64)
            bigPic: profilePic(size: 1024)
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      # Example #14 - Expected result
      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      user = data["user"].as(Hash)
      user["id"].should eq("4")
      user["name"].should eq("Mark Zuckerberg")
      user["smallPic"].should eq("https://cdn.site.io/pic-4-64.jpg")
      user["bigPic"].should eq("https://cdn.site.io/pic-4-1024.jpg")
    end
  end

  describe "examples #15 and #16: top-level field alias" do
    it "allows aliasing root fields" do
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

      # Example #15
      query_string = <<-QUERY
        {
          zuck: user(id: 4) {
            id
            name
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      # Example #16 - Expected result
      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data.has_key?("user").should be_false
      data.has_key?("zuck").should be_true
      
      zuck = data["zuck"].as(Hash)
      zuck["id"].should eq("4")
      zuck["name"].should eq("Mark Zuckerberg")
    end
  end

  describe "multiple aliases for different fields" do
    it "handles multiple aliases in single query" do
      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
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

      query_string = <<-QUERY
        {
          first: firstName
          last: lastName
          alsoFirst: firstName
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      data["first"].should eq("John")
      data["last"].should eq("Doe")
      data["alsoFirst"].should eq("John")
    end
  end

  describe "aliases with nested selections" do
    it "handles aliases on fields with nested selections" do
      address_type = Oxide::Types::ObjectType.new(
        name: "Address",
        fields: {
          "city" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["city"] }
          ),
          "country" => Oxide::Field.new(
            type: Oxide::Types::StringType.new,
            resolve: ->(obj : Hash(String, JSON::Any), res : Oxide::Resolution) { obj["country"] }
          )
        }
      )

      schema = Oxide::Schema.new(
        query: Oxide::Types::ObjectType.new(
          name: "Query",
          fields: {
            "getAddress" => Oxide::Field.new(
              type: address_type,
              resolve: ->(obj : Query, res : Oxide::Resolution) {
                {
                  "city" => JSON::Any.new("New York"),
                  "country" => JSON::Any.new("USA")
                }
              }
            )
          }
        )
      )

      query_string = <<-QUERY
        {
          location: getAddress {
            cityName: city
            countryName: country
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)
      runtime = Oxide::Execution::Runtime.new(schema)
      response = runtime.execute(query, initial_value: Query.new)

      response.data.should_not be_nil
      data = response.data.not_nil!.as(Hash)
      location = data["location"].as(Hash)
      location["cityName"].should eq("New York")
      location["countryName"].should eq("USA")
    end
  end
end
