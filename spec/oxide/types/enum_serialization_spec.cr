require "../../spec_helper"

describe Oxide::Types::EnumType do
  describe "serialization" do
    it "serializes enum values as their GraphQL names, not internal values" do
      # Create an enum type with different name/value pairs
      status_enum = Oxide::Types::EnumType.new(
        name: "Status",
        values: [
          Oxide::Types::EnumValue.new(name: "ACTIVE", value: "active"),
          Oxide::Types::EnumValue.new(name: "INACTIVE", value: "inactive"),
          Oxide::Types::EnumValue.new(name: "PENDING", value: "pending")
        ]
      )

      # Serialize internal value "active" should return GraphQL name "ACTIVE"
      status_enum.serialize("active").should eq("ACTIVE")
      status_enum.serialize("inactive").should eq("INACTIVE")
      status_enum.serialize("pending").should eq("PENDING")
    end

    it "serializes enum values when name and value are the same" do
      # When no custom value is provided, name is used as value
      direction_enum = Oxide::Types::EnumType.new(
        name: "Direction",
        values: [
          Oxide::Types::EnumValue.new(name: "NORTH"),
          Oxide::Types::EnumValue.new(name: "SOUTH"),
          Oxide::Types::EnumValue.new(name: "EAST"),
          Oxide::Types::EnumValue.new(name: "WEST")
        ]
      )

      # Should return the name
      direction_enum.serialize("NORTH").should eq("NORTH")
      direction_enum.serialize("SOUTH").should eq("SOUTH")
    end

    it "raises error when serializing unknown value" do
      status_enum = Oxide::Types::EnumType.new(
        name: "Status",
        values: [
          Oxide::Types::EnumValue.new(name: "ACTIVE", value: "active")
        ]
      )

      expect_raises(Oxide::SerializationError, "Enum value could not be serialized") do
        status_enum.serialize("unknown")
      end
    end
  end

  describe "coercion" do
    it "accepts enum value literals" do
      status_enum = Oxide::Types::EnumType.new(
        name: "Status",
        values: [
          Oxide::Types::EnumValue.new(name: "ACTIVE", value: "active"),
          Oxide::Types::EnumValue.new(name: "INACTIVE", value: "inactive")
        ]
      )

      query_type = Oxide::Types::ObjectType.new(name: "Query", fields: {} of String => Oxide::Field(Nil, Nil))
      schema = Oxide::Schema.new(query: query_type)

      # Coercing from GraphQL enum value should return internal value
      enum_node = Oxide::Language::Nodes::EnumValue.new(value: "ACTIVE")
      status_enum.coerce(schema, enum_node).should eq("active")

      enum_node2 = Oxide::Language::Nodes::EnumValue.new(value: "INACTIVE")
      status_enum.coerce(schema, enum_node2).should eq("inactive")
    end

    it "accepts string in JSON" do
      status_enum = Oxide::Types::EnumType.new(
        name: "Status",
        values: [
          Oxide::Types::EnumValue.new(name: "ACTIVE", value: "active")
        ]
      )

      query_type = Oxide::Types::ObjectType.new(name: "Query", fields: {} of String => Oxide::Field(Nil, Nil))
      schema = Oxide::Schema.new(query: query_type)

      # When coercing from JSON (variables), accepts the GraphQL name as string
      status_enum.coerce(schema, JSON::Any.new("ACTIVE")).should eq("active")
    end

    it "rejects string literals (not enum values)" do
      status_enum = Oxide::Types::EnumType.new(
        name: "Status",
        values: [
          Oxide::Types::EnumValue.new(name: "ACTIVE", value: "active")
        ]
      )

      query_type = Oxide::Types::ObjectType.new(name: "Query", fields: {} of String => Oxide::Field(Nil, Nil))
      schema = Oxide::Schema.new(query: query_type)

      # String literals in the query should be rejected
      string_node = Oxide::Language::Nodes::StringValue.new(value: "ACTIVE")
      
      expect_raises(Oxide::InputCoercionError) do
        status_enum.coerce(schema, string_node)
      end
    end
  end
end
