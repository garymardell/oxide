module Oxide
  class Query
    include Language::Visitable

    getter query_string : String
    getter context : Oxide::Context?
    getter variables : Hash(String, JSON::Any)
    getter operation_name : String | Nil
    getter document : Oxide::Language::Nodes::Document

    def initialize(@query_string, @context = nil, @variables = {} of String => JSON::Any, @operation_name = nil)
      @document = parse(@query_string)
    end

    def accept(visitor : Language::Visitor)
      document.accept(visitor)
    end

    private def parse(query_string)
      parser = Oxide::Language::Parser.new
      parser.parse(query_string).as(Oxide::Language::Nodes::Document)
    end
  end
end