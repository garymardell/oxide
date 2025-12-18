require "../../spec_helper"

describe Oxide::Language::Parser do
  describe "error messages with locations" do
    it "includes line and column information in errors" do
      input = <<-INPUT
        query {
          field(arg: )
        }
      INPUT

      begin
        Oxide::Language::Parser.parse(input)
        fail "Expected ParseError to be raised"
      rescue e : Oxide::ParseError
        message = e.message
        message.should_not be_nil
        message.not_nil!.should contain("Syntax Error")
        e.locations.size.should eq(1)
        e.locations[0].line.should eq(2)
        e.locations[0].column.should be > 0
      end
    end
  end

  describe "selection set errors" do
    it "handles unclosed bracket" do
      input = <<-INPUT
        {
          example {
            thing {
          }
        }
      INPUT

      expect_raises Oxide::ParseError, "Syntax Error: Expected Name, found RBrace" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles missing opening brace" do
      input = "query MyQuery field }"

      expect_raises Oxide::ParseError, "Syntax Error: Expected LBrace, found Name" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles empty selection set" do
      input = "{ }"

      expect_raises Oxide::ParseError, "Syntax Error: Expected Name, found RBrace" do
        Oxide::Language::Parser.parse(input)
      end
    end
  end

  describe "argument errors" do
    it "handles unclosed arguments" do
      input = <<-INPUT
        {
          example(foo: "bar", another: 123 {
            thing
          }
        }
      INPUT

      expect_raises Oxide::ParseError, "Syntax Error: Expected Name, found LBrace" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles missing colon in argument" do
      input = <<-GRAPHQL
        { field(arg "value") }
      GRAPHQL

      expect_raises Oxide::ParseError, "Syntax Error: Expected Colon, found String" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles missing argument value" do
      input = "{ field(arg: ) }"

      expect_raises Oxide::ParseError, "Syntax Error: Unexpected RParen" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles missing closing paren" do
      input = <<-GRAPHQL
        { field(arg: "value" }
      GRAPHQL

      expect_raises Oxide::ParseError, "Syntax Error: Expected Name, found RBrace" do
        Oxide::Language::Parser.parse(input)
      end
    end
  end

  describe "variable errors" do
    it "handles variable in constant context (default value)" do
      input = "query ($var: String = $other) { field }"

      begin
        Oxide::Language::Parser.parse(input)
        fail "Expected ParseError to be raised"
      rescue e : Oxide::ParseError
        message = e.message
        message.should_not be_nil
        message.not_nil!.should contain("Unexpected variable")
        message.not_nil!.should contain("$other")
      end
    end

    it "handles missing variable name" do
      input = "query ($) { field }"

      expect_raises Oxide::ParseError, "Syntax Error: Expected Name, found RParen" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles missing colon in variable definition" do
      input = "query ($var String) { field }"

      expect_raises Oxide::ParseError, "Syntax Error: Expected Colon, found Name" do
        Oxide::Language::Parser.parse(input)
      end
    end
  end

  describe "type reference errors" do
    it "handles unclosed list type" do
      input = "query ($var: [String) { field }"

      expect_raises Oxide::ParseError, "Syntax Error: Expected RBracket, found RParen" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles missing type in list" do
      input = "query ($var: []) { field }"

      expect_raises Oxide::ParseError, "Syntax Error: Expected Name, found RBracket" do
        Oxide::Language::Parser.parse(input)
      end
    end
  end

  describe "fragment errors" do
    it "handles 'on' as fragment name" do
      input = "fragment on on User { id }"

      expect_raises Oxide::ParseError, "Syntax Error: Unexpected Name" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles missing fragment name" do
      input = "fragment on User { id }"

      expect_raises Oxide::ParseError, "Syntax Error: Unexpected Name" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles missing 'on' keyword" do
      input = "fragment UserFields User { id }"

      expect_raises Oxide::ParseError, "Syntax Error: Expected on, found User" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles missing type condition" do
      input = "fragment UserFields on { id }"

      expect_raises Oxide::ParseError, "Syntax Error: Expected Name, found LBrace" do
        Oxide::Language::Parser.parse(input)
      end
    end
  end

  describe "directive errors" do
    it "handles missing directive name" do
      input = "{ field @ }"

      expect_raises Oxide::ParseError, "Syntax Error: Expected Name, found RBrace" do
        Oxide::Language::Parser.parse(input)
      end
    end
  end

  describe "value literal errors" do
    it "handles incomplete list" do
      input = "{ field(arg: [1, 2, ) }"

      expect_raises Oxide::ParseError, "Syntax Error: Unexpected RParen" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles incomplete object" do
      input = "{ field(arg: {key: }) }"

      expect_raises Oxide::ParseError, "Syntax Error: Unexpected RBrace" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles missing colon in object field" do
      input = <<-GRAPHQL
        { field(arg: {key "value"}) }
      GRAPHQL

      expect_raises Oxide::ParseError, "Syntax Error: Expected Colon, found String" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles unclosed list" do
      input = "{ field(arg: [1, 2, 3 }"

      expect_raises Oxide::ParseError, "Syntax Error: Unexpected RBrace" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles unclosed object" do
      input = <<-GRAPHQL
        { field(arg: {key: "value" }
      GRAPHQL

      expect_raises Oxide::ParseError, "Syntax Error: Expected Name, found EOF" do
        Oxide::Language::Parser.parse(input)
      end
    end
  end

  describe "operation definition errors" do
    it "handles invalid operation type" do
      input = "invalid { field }"

      expect_raises Oxide::ParseError, "Syntax Error: Expected (query, mutation, subscription, fragment), found invalid" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles invalid operation type in explicit definition" do
      input = "operation MyOp { field }"

      expect_raises Oxide::ParseError, "Syntax Error: Expected (query, mutation, subscription, fragment), found operation" do
        Oxide::Language::Parser.parse(input)
      end
    end
  end

  describe "schema definition errors" do
    it "handles reserved enum value names" do
      input = <<-INPUT
        enum Status {
          SUCCESS
          true
        }
      INPUT

      expect_raises Oxide::ParseError, "Syntax Error: true is reserved and cannot be used for an enum value" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles 'false' as enum value" do
      input = "enum Bool { false }"

      expect_raises Oxide::ParseError, "Syntax Error: false is reserved and cannot be used for an enum value" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles 'null' as enum value" do
      input = "enum Maybe { null }"

      expect_raises Oxide::ParseError, "Syntax Error: null is reserved and cannot be used for an enum value" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles invalid directive location" do
      input = "directive @test on INVALID_LOCATION"

      expect_raises Oxide::ParseError, "Syntax Error: Invalid directive location \"INVALID_LOCATION\"" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles missing colon in field definition" do
      input = <<-INPUT
        type User {
          id String
        }
      INPUT

      expect_raises Oxide::ParseError, "Syntax Error: Expected Colon, found Name" do
        Oxide::Language::Parser.parse(input)
      end
    end
  end

  describe "unexpected token errors" do
    it "handles unexpected token in value position" do
      input = "{ field(arg: ]) }"

      expect_raises Oxide::ParseError, "Syntax Error: Unexpected RBracket" do
        Oxide::Language::Parser.parse(input)
      end
    end

    it "handles unexpected end of input" do
      input = "query MyQuery"

      expect_raises Oxide::ParseError, "Syntax Error: Expected LBrace, found EOF" do
        Oxide::Language::Parser.parse(input)
      end
    end
  end
end