require "../../spec_helper"

describe Oxide::Language::Lexer do
  it "numbers" do
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