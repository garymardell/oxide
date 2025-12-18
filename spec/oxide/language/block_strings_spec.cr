require "../../spec_helper"

describe "Block Strings" do
  describe "basic block string parsing" do
    it "parses empty block string" do
      input = <<-INPUT
        {
          field(arg: """
          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("")
    end

    it "parses block string with content" do
      input = <<-INPUT
        {
          field(arg: """
            content
          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("content")
    end
  end

  describe "example #24" do
    it "strips indentation and blank lines" do
      # Example from spec showing mutation with block string
      input = <<-INPUT
        mutation {
          sendEmail(message: """
            Hello,
              World!

            Yours,
              GraphQL.
          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      # Should strip uniform indentation and leading/trailing blank lines
      expected = "Hello,\n  World!\n\nYours,\n  GraphQL."
      value.value.should eq(expected)
    end
  end

  describe "example #25" do
    it "is identical to standard quoted string" do
      # Block string version
      block_input = <<-INPUT
        mutation {
          sendEmail(message: """
            Hello,
              World!

            Yours,
              GraphQL.
          """)
        }
      INPUT

      # Standard string version
      standard_input = <<-INPUT
        mutation {
          sendEmail(message: "Hello,\\n  World!\\n\\nYours,\\n  GraphQL.")
        }
      INPUT

      block_parser = Oxide::Language::Parser.new(block_input)
      block_document = block_parser.parse
      block_operation = block_document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      block_field = block_operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      block_value = block_field.arguments[0].value.as(Oxide::Language::Nodes::StringValue)

      standard_parser = Oxide::Language::Parser.new(standard_input)
      standard_document = standard_parser.parse
      standard_operation = standard_document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      standard_field = standard_operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      standard_value = standard_field.arguments[0].value.as(Oxide::Language::Nodes::StringValue)

      block_value.value.should eq(standard_value.value)
    end
  end

  describe "example #26" do
    it "easier to read with empty lines at start and end" do
      input = <<-INPUT
        {
          field(arg: """
          This starts with and ends with an empty line,
          which makes it easier to read.
          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      expected = "This starts with and ends with an empty line,\nwhich makes it easier to read."
      value.value.should eq(expected)
    end
  end

  describe "counter example #27" do
    it "harder to read without empty lines" do
      input = <<-INPUT
        {
          field(arg: """This does not start with or end with any empty lines,
          which makes it a little harder to read.""")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      # Still valid, just not recommended style
      expected = "This does not start with or end with any empty lines,\nwhich makes it a little harder to read."
      value.value.should eq(expected)
    end
  end

  describe "BlockStringValue algorithm" do
    it "removes uniform indentation" do
      input = <<-INPUT
        {
          field(arg: """
              line1
              line2
                indented
          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      expected = "line1\nline2\n  indented"
      value.value.should eq(expected)
    end

    it "removes leading blank lines" do
      input = <<-INPUT
        {
          field(arg: """

              content
          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      expected = "content"
      value.value.should eq(expected)
    end

    it "removes trailing blank lines" do
      input = <<-INPUT
        {
          field(arg: """
              content


          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      expected = "content"
      value.value.should eq(expected)
    end

    it "preserves non-uniform indentation" do
      input = <<-INPUT
        {
          field(arg: """
            line1
              line2
            line3
          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      expected = "line1\n  line2\nline3"
      value.value.should eq(expected)
    end

    it "handles escape sequences literally" do
      input = <<-INPUT
        {
          field(arg: """
            \\n should be literal
          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      # Backslash-n should be two characters, not a newline
      expected = "\\n should be literal"
      value.value.should eq(expected)
    end

    it "allows quotes without escaping" do
      input = <<-INPUT
        {
          field(arg: """
            He said "Hello"
          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      expected = "He said \"Hello\""
      value.value.should eq(expected)
    end

    it "handles escaped triple quotes" do
      input = <<-INPUT
        {
          field(arg: """
            Use \\""" for triple quotes
          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      expected = "Use \"\"\" for triple quotes"
      value.value.should eq(expected)
    end

    it "handles only whitespace lines" do
      input = <<-INPUT
        {
          field(arg: """
            line1
            
            line2
          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      expected = "line1\n\nline2"
      value.value.should eq(expected)
    end
  end

  describe "edge cases" do
    it "handles block string with no indentation" do
      input = <<-INPUT
        {
          field(arg: """
        content
        """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      expected = "content"
      value.value.should eq(expected)
    end

    it "handles block string on single line" do
      input = <<-INPUT
        {
          field(arg: """content""")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      expected = "content"
      value.value.should eq(expected)
    end

    it "handles empty block string with whitespace" do
      input = <<-INPUT
        {
          field(arg: """
            
          """)
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      # All whitespace lines are removed
      expected = ""
      value.value.should eq(expected)
    end
  end
end