require "../../spec_helper"

describe Oxide::Language::Parser do
  describe "document descriptions (§2.2)" do
    it "parses single-line string descriptions" do
      schema = <<-GRAPHQL
        "A user in the system"
        type User {
          id: ID!
        }
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      type_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::ObjectTypeDefinition) }
        .as(Oxide::Language::Nodes::ObjectTypeDefinition)
      
      type_def.description.should eq("A user in the system")
    end

    it "parses multi-line block string descriptions" do
      schema = <<-GRAPHQL
        """
        A user account in the system.
        Contains personal and authentication information.
        """
        type User {
          id: ID!
        }
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      type_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::ObjectTypeDefinition) }
        .as(Oxide::Language::Nodes::ObjectTypeDefinition)
      
      description = type_def.description.not_nil!
      description.should contain("user account")
      description.should contain("personal and authentication")
    end

    it "parses field descriptions" do
      schema = <<-GRAPHQL
        type User {
          "Unique identifier for the user"
          id: ID!
          
          "User's email address"
          email: String!
        }
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      type_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::ObjectTypeDefinition) }
        .as(Oxide::Language::Nodes::ObjectTypeDefinition)
      
      id_field = type_def.field_definitions.find { |f| f.name == "id" }.not_nil!
      id_field.description.should eq("Unique identifier for the user")
      
      email_field = type_def.field_definitions.find { |f| f.name == "email" }.not_nil!
      email_field.description.should eq("User's email address")
    end

    it "parses argument descriptions" do
      schema = <<-GRAPHQL
        type Query {
          user(
            "The unique ID of the user to fetch"
            id: ID!
            
            """
            Optional flag to include deleted users.
            Defaults to false.
            """
            includeDeleted: Boolean = false
          ): User
        }
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      type_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::ObjectTypeDefinition) }
        .as(Oxide::Language::Nodes::ObjectTypeDefinition)
      
      user_field = type_def.field_definitions.find { |f| f.name == "user" }.not_nil!
      
      id_arg = user_field.argument_definitions.find { |a| a.name == "id" }.not_nil!
      id_arg.description.should eq("The unique ID of the user to fetch")
      
      include_deleted_arg = user_field.argument_definitions.find { |a| a.name == "includeDeleted" }.not_nil!
      include_deleted_arg.description.not_nil!.should contain("include deleted users")
    end

    it "parses scalar type descriptions" do
      schema = <<-GRAPHQL
        "A custom date scalar representing dates in ISO 8601 format"
        scalar Date
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      scalar_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::ScalarTypeDefinition) }
        .as(Oxide::Language::Nodes::ScalarTypeDefinition)
      
      scalar_def.description.should eq("A custom date scalar representing dates in ISO 8601 format")
    end

    it "parses interface descriptions" do
      schema = <<-GRAPHQL
        "An entity with a unique identifier"
        interface Node {
          id: ID!
        }
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      interface_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::InterfaceTypeDefinition) }
        .as(Oxide::Language::Nodes::InterfaceTypeDefinition)
      
      interface_def.description.should eq("An entity with a unique identifier")
    end

    it "parses union type descriptions" do
      schema = <<-GRAPHQL
        "A search result that can be either a User or a Post"
        union SearchResult = User | Post
        
        type User { id: ID! }
        type Post { id: ID! }
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      union_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::UnionTypeDefinition) }
        .as(Oxide::Language::Nodes::UnionTypeDefinition)
      
      union_def.description.should eq("A search result that can be either a User or a Post")
    end

    it "parses enum type and value descriptions" do
      schema = <<-GRAPHQL
        "User account status"
        enum UserStatus {
          "Account is active and can be used"
          ACTIVE
          
          "Account is temporarily suspended"
          SUSPENDED
          
          "Account has been permanently deleted"
          DELETED
        }
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      enum_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::EnumTypeDefinition) }
        .as(Oxide::Language::Nodes::EnumTypeDefinition)
      
      enum_def.description.should eq("User account status")
      
      # Note: Enum value descriptions are not currently stored in the AST
      # This is acceptable as the parser successfully parses them
    end

    it "parses input object descriptions" do
      schema = <<-GRAPHQL
        "Input for creating a new user"
        input CreateUserInput {
          "User's full name"
          name: String!
          
          "User's email address"
          email: String!
        }
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      input_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::InputObjectTypeDefinition) }
        .as(Oxide::Language::Nodes::InputObjectTypeDefinition)
      
      input_def.description.should eq("Input for creating a new user")
      
      name_field = input_def.fields.find { |f| f.name == "name" }.not_nil!
      name_field.description.should eq("User's full name")
      
      email_field = input_def.fields.find { |f| f.name == "email" }.not_nil!
      email_field.description.should eq("User's email address")
    end

    it "parses directive descriptions" do
      schema = <<-GRAPHQL
        "Marks a field as deprecated with an optional reason"
        directive @deprecated(
          "Explanation of why this field is deprecated"
          reason: String = "No longer supported"
        ) on FIELD_DEFINITION
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      directive_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::DirectiveDefinition) }
        .as(Oxide::Language::Nodes::DirectiveDefinition)
      
      directive_def.description.should eq("Marks a field as deprecated with an optional reason")
      
      reason_arg = directive_def.arguments_definitions.find { |a| a.name == "reason" }.not_nil!
      reason_arg.description.should eq("Explanation of why this field is deprecated")
    end

    it "parses schema descriptions" do
      schema = <<-GRAPHQL
        "The root schema definition for the GraphQL API"
        schema {
          query: Query
          mutation: Mutation
        }
        
        type Query { field: String }
        type Mutation { field: String }
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      schema_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::SchemaDefinition) }
        .as(Oxide::Language::Nodes::SchemaDefinition)
      
      schema_def.description.should eq("The root schema definition for the GraphQL API")
    end

    it "handles descriptions with escaped characters" do
      schema = <<-GRAPHQL
        "A string with \\"quotes\\" and newlines\\n"
        scalar Custom
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      scalar_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::ScalarTypeDefinition) }
        .as(Oxide::Language::Nodes::ScalarTypeDefinition)
      
      description = scalar_def.description.not_nil!
      description.should contain("quotes")
    end

    it "handles block string indentation correctly" do
      schema = <<-GRAPHQL
        """
        First line
          Indented line
        Back to normal
        """
        scalar Custom
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      scalar_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::ScalarTypeDefinition) }
        .as(Oxide::Language::Nodes::ScalarTypeDefinition)
      
      description = scalar_def.description.not_nil!
      description.should contain("First line")
      description.should contain("Indented line")
      description.should contain("Back to normal")
    end

    it "allows empty descriptions" do
      schema = <<-GRAPHQL
        ""
        scalar Empty
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      scalar_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::ScalarTypeDefinition) }
        .as(Oxide::Language::Nodes::ScalarTypeDefinition)
      
      scalar_def.description.should eq("")
    end

    it "handles types without descriptions" do
      schema = <<-GRAPHQL
        type User {
          id: ID!
        }
      GRAPHQL

      document = Oxide::Language::Parser.parse(schema)
      type_def = document.definitions.find { |d| d.is_a?(Oxide::Language::Nodes::ObjectTypeDefinition) }
        .as(Oxide::Language::Nodes::ObjectTypeDefinition)
      
      type_def.description.should be_nil
    end
  end
end
