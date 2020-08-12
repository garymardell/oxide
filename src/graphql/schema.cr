require "./type/*"
require "./schema/*"
require "./language/*"
require "./execution"

module Graphql
  class Schema
    getter query : Graphql::Type::Object
    getter mutation : Graphql::Type::Object | Nil



    #getter introspection : Graphql::IntrospectionSystem

    def initialize(@query, @mutation = nil)
      #@introspection = Graphql::IntrospectionSystem.new
    end

    def get_type(name)
      traversal = Traversal.new(self)
      traversal.traverse

      traversal.type_map[name]
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
        raise "Couldn't get type"
      end
    end

    private def build_type_map

    end
  end
end