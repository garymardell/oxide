require "./type/*"
require "./schema/*"
require "./language/*"
require "./execution"
require "./validation"

module Graphql
  class Schema
    getter query : Graphql::Type::Object
    getter mutation : Graphql::Type::Object | Nil

    getter orphan_types : Array(Graphql::Type)

    def initialize(@query, @mutation = nil, @orphan_types = [] of Graphql::Type)
    end

    def execute(query : Graphql::Query)
      validation_pipeline = Validation::Pipeline.new(self, query)
      validation_pipeline.execute

      if validation_pipeline.errors.any?
        return validation_pipeline.errors.to_json
      end

      runtime = Execution::Runtime.new(self, query)
      runtime.execute
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
  end
end