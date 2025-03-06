require "../../spec_helper"

describe Oxide::Language::Lexer do
  it "handles numbers" do
    Oxide::Language::Lexer.new("1").next_token.should eq(int_token("1"))
    Oxide::Language::Lexer.new("123").next_token.should eq(int_token("123"))
    Oxide::Language::Lexer.new("-1").next_token.should eq(int_token("-1"))
    Oxide::Language::Lexer.new("-123").next_token.should eq(int_token("-123"))
    Oxide::Language::Lexer.new("10.56").next_token.should eq(float_token("10.56"))
    Oxide::Language::Lexer.new("-10.56").next_token.should eq(float_token("-10.56"))
    Oxide::Language::Lexer.new("5e6").next_token.should eq(float_token("5e6"))
    Oxide::Language::Lexer.new("5E6").next_token.should eq(float_token("5E6"))
    Oxide::Language::Lexer.new("0").next_token.should eq(int_token("0"))
  end

  it "handles simple strings" do
    Oxide::Language::Lexer.new("\"hello\"").next_token.should eq(string_token("hello"))
    Oxide::Language::Lexer.new("\"hello world\"").next_token.should eq(string_token("hello world"))
  end

  it "handles empty strings" do
    Oxide::Language::Lexer.new("\"\"").next_token.should eq(string_token(""))
  end

  it "handles empty strings with escaped characters" do
    Oxide::Language::Lexer.new("\"\\\"test\\\"\"").next_token.should eq(string_token("\"test\""))
  end

  it "handles block strings" do
    input = <<-INPUT
    """
    some content here
    with a new line in
    the middle
    """
    INPUT

    output = <<-OUTPUT
    \nsome content here
    with a new line in
    the middle\n
    OUTPUT

    Oxide::Language::Lexer.new(input).next_token.should eq(string_token(output))
  end

  it "raises an error if max tokens threshold is surpassed" do
    input = <<-INPUT
      query {
        first
        second
        third
        fourth
      }
    INPUT

    lexer = Oxide::Language::Lexer.new(input, max_tokens: 4)
    lexer.next_token
    lexer.next_token
    lexer.next_token
    lexer.next_token

    expect_raises Oxide::ParseError, "Syntax Error: Document contains more than 4 tokens" do
      lexer.next_token
    end
  end
end

def string_token(value)
  token = Oxide::Language::Token.new
  token.kind = Oxide::Language::Token::Kind::String
  token.raw_value = value
  token
end

def int_token(value)
  token = Oxide::Language::Token.new
  token.kind = Oxide::Language::Token::Kind::Int
  token.raw_value = value
  token
end

def float_token(value)
  token = Oxide::Language::Token.new
  token.kind = Oxide::Language::Token::Kind::Float
  token.raw_value = value
  token
end