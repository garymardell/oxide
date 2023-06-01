require "./types"
require "./directives/*"
require "./language/*"
require "./execution"
require "./validation"
require "./loader"
require "./context"
require "./type_map"
require "./error"

module Graphene
  class Schema
    include Resolvable

    DEFAULT_DIRECTIVES = [
      Graphene::Directives::SkipDirective.new,
      Graphene::Directives::IncludeDirective.new
    ]

    getter query : Graphene::Types::ObjectType
    getter mutation : Graphene::Types::ObjectType | Nil

    getter orphan_types : Array(Graphene::Type)
    getter directives : Array(Graphene::Directive)

    def initialize(@query, @mutation = nil, @orphan_types = [] of Graphene::Type, directives = [] of Directive)
      @directives = DEFAULT_DIRECTIVES + directives
    end

    def resolve(field_name, argument_values, context, resolution_info) : Result
      case field_name
      when "queryType"
        query
      when "mutationType"
        mutation
      when "subscriptionType"
        nil
      when "types"
        types.map { |type| type.as(Resolvable) }
      when "directives"
        directives.map { |type| type.as(Resolvable) }
      end
    end

    def validate(query : Graphene::Query)
      pipeline = Graphene::Validation::Pipeline.new(self, query)
      pipeline.execute
    end

    def execute(query : Graphene::Query)
      runtime = Graphene::Execution::Runtime.new(self, query)
      runtime.execute
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

    def get_type_from_ast(ast_node)
      case ast_node
      when Graphene::Language::Nodes::NamedType
        get_type(ast_node.name)
      when Graphene::Language::Nodes::NonNullType
        inner_type = get_type_from_ast(ast_node.of_type)

        inner_type && Graphene::Types::NonNullType.new(of_type: inner_type)
      when Graphene::Language::Nodes::ListType
        inner_type = get_type_from_ast(ast_node.of_type)

        inner_type && Graphene::Types::ListType.new(of_type: inner_type)
      else
        raise "Couldn't get type #{ast_node}"
      end
    end
  end
end