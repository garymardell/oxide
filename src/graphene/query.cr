module Graphene
  class Query
    include Language::Visitable

    getter query_string : String
    getter context : Graphene::Context?
    getter variables : Hash(String, JSON::Any)
    getter operation_name : String | Nil

    def initialize(@query_string, @context = nil, @variables = {} of String => JSON::Any, @operation_name = nil)
    end

    def document
      @document ||= begin
        parser = Graphene::Language::Parser.new
        parser.parse(query_string)
      end.as(Graphene::Language::Nodes::Document)
    end

    def accept(visitor : Language::Visitor)
      document.accept(visitor)
    end
  end
end