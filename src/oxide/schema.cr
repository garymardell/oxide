require "./types"
require "./directives/*"
require "./language/*"
require "./execution"
require "./validation"
require "./loader"
require "./context"
require "./type_map"
require "./error"
require "./utils/*"

module Oxide
  class Schema
    DEFAULT_DIRECTIVES = [
      Oxide::Directives::SkipDirective,
      Oxide::Directives::IncludeDirective,
      Oxide::Directives::DeprecatedDirective,
      Oxide::Directives::SpecifiedByDirective,
      Oxide::Directives::OneOfDirective,
    ]

    getter query : Oxide::Types::ObjectType
    getter mutation : Oxide::Types::ObjectType | Nil

    getter description : String?

    getter orphan_types : Array(Oxide::Type)
    getter directives : Array(Oxide::Directive)
    getter applied_directives : Array(AppliedDirective)

    def initialize(@query, @mutation = nil, @orphan_types = [] of Oxide::Type, directives = [] of Directive, @description = nil, @applied_directives = [] of AppliedDirective)
      @directives = DEFAULT_DIRECTIVES + directives
    end

    def type_map
      traversal = TypeMap.new(self)
      traversal.generate
    end

    def types
      type_map.values
    end

    def get_type(name)
      type_map[name]?
    end

    def get_type!(name)
      type_map[name]
    end

    def resolve_type(type : Oxide::Type) : Oxide::Type
      case type
      when Oxide::Types::LateBoundType
        get_type!(type.typename)
      else
        type
      end
    end

    def get_type_from_ast(ast_node)
      case ast_node
      when Oxide::Language::Nodes::NamedType
        get_type(ast_node.name)
      when Oxide::Language::Nodes::NonNullType
        inner_type = get_type_from_ast(ast_node.of_type)

        inner_type && Oxide::Types::NonNullType.new(of_type: inner_type)
      when Oxide::Language::Nodes::ListType
        inner_type = get_type_from_ast(ast_node.of_type)

        inner_type && Oxide::Types::ListType.new(of_type: inner_type)
      else
        raise SchemaError.new("#{ast_node.class} is not supported")
      end
    end
  end
end