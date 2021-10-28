require "./type/*"
require "./schema/*"
require "./schema/directives/*"
require "./language/*"
require "./execution"
require "./validation"
require "./lazy"
require "./loader"
require "./context"

module Graphene
  class Schema
    DEFAULT_DIRECTIVES = [
      Graphene::Schema::Directives::SkipDirective.new,
      Graphene::Schema::Directives::IncludeDirective.new
    ]

    getter query : Graphene::Type::Object
    getter mutation : Graphene::Type::Object | Nil

    getter orphan_types : Array(Graphene::Type)
    getter directives : Array(Graphene::Schema::Directive)

    def initialize(@query, @mutation = nil, @orphan_types = [] of Graphene::Type, directives = [] of Directive)
      @directives = DEFAULT_DIRECTIVES + directives
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
      when Graphene::Language::Nodes::NamedType
        get_type(ast_node.name)
      when Graphene::Language::Nodes::NonNullType
        inner_type = get_type_from_ast(ast_node.of_type)

        Graphene::Type::NonNull.new(of_type: inner_type)
      when Graphene::Language::Nodes::ListType
        inner_type = get_type_from_ast(ast_node.of_type)

        Graphene::Type::List.new(of_type: inner_type)
      else
        raise "Couldn't get type #{ast_node}"
      end
    end
  end
end