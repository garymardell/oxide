require "./type/*"
require "./schema/*"
require "./language/*"
require "./execution"

module Graphql
  class Schema
    getter query : Graphql::Type::Object
    getter mutation : Graphql::Type::Object | Nil

    getter orphan_types : Array(Graphql::Type)

    def initialize(@query, @mutation = nil, @orphan_types = [] of Graphql::Type)
    end

    def type_map
      traversal = TypeMap.new(self)
      traversal.generate
    end

    def types
      types = Types.new(self)
      types.generate
    end

    def get_type(name)
      type_map[name]
    end

    def get_type_from_ast(ast_node)
      case ast_node
      when Graphql::Language::Nodes::NamedType
        get_type(ast_node.name)
      when Graphql::Language::Nodes::NonNullType
        inner_type = get_type_from_ast(ast_node.of_type)

        Graphql::Type::NonNull.new(of_type: inner_type)
      when Graphql::Language::Nodes::ListType
        inner_type = get_type_from_ast(ast_node.of_type)

        Graphql::Type::List.new(of_type: inner_type)
      else
        raise "Couldn't get type #{ast_node}"
      end
    end

    private def build_type_map

    end
  end
end