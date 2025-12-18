require "../../spec_helper"

describe "String Escape Sequences" do
  describe "basic escape sequences" do
    it "parses escaped double quote" do
      input = <<-INPUT
        {
          field(arg: "He said \\"Hello\\"")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("He said \"Hello\"")
    end

    it "parses escaped backslash" do
      input = <<-INPUT
        {
          field(arg: "C:\\\\Users\\\\file.txt")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("C:\\Users\\file.txt")
    end

    it "parses escaped forward slash" do
      input = <<-INPUT
        {
          field(arg: "a\\/b")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("a/b")
    end

    it "parses backspace escape" do
      input = <<-INPUT
        {
          field(arg: "before\\bafter")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("before\bafter")
    end

    it "parses form feed escape" do
      input = <<-INPUT
        {
          field(arg: "before\\fafter")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("before\fafter")
    end

    it "parses newline escape" do
      input = <<-INPUT
        {
          field(arg: "line1\\nline2")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("line1\nline2")
    end

    it "parses carriage return escape" do
      input = <<-INPUT
        {
          field(arg: "before\\rafter")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("before\rafter")
    end

    it "parses tab escape" do
      input = <<-INPUT
        {
          field(arg: "before\\tafter")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("before\tafter")
    end
  end

  describe "unicode escape sequences" do
    it "parses fixed-width unicode escape" do
      input = <<-INPUT
        {
          field(arg: "\\u0048\\u0065\\u006C\\u006C\\u006F")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("Hello")
    end

    it "parses variable-width unicode escape" do
      input = <<-INPUT
        {
          field(arg: "\\u{48}\\u{65}\\u{6C}\\u{6C}\\u{6F}")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("Hello")
    end

    it "parses emoji with variable-width unicode" do
      input = <<-INPUT
        {
          field(arg: "\\u{1F4A9}")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("💩")
    end

    it "parses surrogate pair for emoji" do
      input = <<-INPUT
        {
          field(arg: "\\uD83D\\uDCA9")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      # Surrogate pair should combine to form emoji
      value.value.should eq("💩")
    end

    it "parses unicode with leading zeros" do
      input = <<-INPUT
        {
          field(arg: "\\u000A")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("\n")
    end

    it "parses variable-width unicode with different lengths" do
      input = <<-INPUT
        {
          field(arg: "\\u{41}\\u{042}\\u{0043}\\u{00044}")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("ABCD")
    end
  end

  describe "mixed escape sequences" do
    it "handles multiple escape types in one string" do
      input = <<-INPUT
        {
          field(arg: "Hello\\nWorld\\t\\u0021")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("Hello\nWorld\t!")
    end

    it "handles escaped quotes with other content" do
      input = <<-INPUT
        {
          field(arg: "\\"quoted\\" and \\nnewline")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("\"quoted\" and \nnewline")
    end
  end

  describe "invalid escape sequences" do
    it "raises error for invalid escape character" do
      input = <<-INPUT
        {
          field(arg: "invalid\\x")
        }
      INPUT

      expect_raises(Oxide::ParseError, /Invalid character escape sequence/) do
        parser = Oxide::Language::Parser.new(input)
        parser.parse
      end
    end

    it "raises error for incomplete unicode escape" do
      input = <<-INPUT
        {
          field(arg: "incomplete\\u00")
        }
      INPUT

      expect_raises(Oxide::ParseError) do
        parser = Oxide::Language::Parser.new(input)
        parser.parse
      end
    end

    it "raises error for invalid unicode value (unpaired surrogate)" do
      input = <<-INPUT
        {
          field(arg: "\\uDEAD")
        }
      INPUT

      expect_raises(Oxide::ParseError, /invalid.*surrogate/i) do
        parser = Oxide::Language::Parser.new(input)
        parser.parse
      end
    end

    it "raises error for unicode value out of range" do
      input = <<-INPUT
        {
          field(arg: "\\u{110000}")
        }
      INPUT

      expect_raises(Oxide::ParseError, /out of range/i) do
        parser = Oxide::Language::Parser.new(input)
        parser.parse
      end
    end

    it "raises error for invalid hex digits in unicode" do
      input = <<-INPUT
        {
          field(arg: "\\u00GG")
        }
      INPUT

      expect_raises(Oxide::ParseError) do
        parser = Oxide::Language::Parser.new(input)
        parser.parse
      end
    end
  end

  describe "spec edge cases" do
    it "handles empty string" do
      input = <<-INPUT
        {
          field(arg: "")
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

    it "handles string with only escapes" do
      input = <<-INPUT
        {
          field(arg: "\\n\\t\\r")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("\n\t\r")
    end

    it "allows non-ASCII characters directly" do
      input = <<-INPUT
        {
          field(arg: "Hello 世界 🌍")
        }
      INPUT

      parser = Oxide::Language::Parser.new(input)
      document = parser.parse

      operation = document.definitions[0].as(Oxide::Language::Nodes::OperationDefinition)
      field = operation.selection_set.selections[0].as(Oxide::Language::Nodes::Field)
      arg = field.arguments[0]
      value = arg.value.as(Oxide::Language::Nodes::StringValue)

      value.value.should eq("Hello 世界 🌍")
    end
  end
end