require "./libgraphqlparser"

module Graphql
  module Language
    class Builder
      private property stack : Array(Nodes::Node)

      def initialize
        @stack = [] of Nodes::Node
      end

      def document
        @stack.first
      end

      def current
        @stack.last
      end

      def push_node(node)
        @stack << node
      end

      def pop_node
        @stack.pop
      end
    end

    class Parser
      private property builder : Builder
      private property callbacks : LibGraphqlParser::GraphQLAstVisitorCallbacks

      def initialize
        @builder = Builder.new
        @callbacks = LibGraphqlParser::GraphQLAstVisitorCallbacks.new

        @callbacks.visit_document = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          builder = data.as(Pointer(Builder)).value
          builder.push_node(Nodes::Document.new)
          return 1
        }

        @callbacks.end_visit_document = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
        }

        @callbacks.visit_operation_definition = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          builder = data.as(Pointer(Builder)).value

          operation = LibGraphqlParser.GraphQLAstOperationDefinition_get_operation(node)

          operation_type = if (operation)
            String.new(operation)
          else
            "query"
          end

          operation_definition = Nodes::OperationDefinition.new(operation_type) # Remove hard coded query type

          builder.current.as(Nodes::Document).definitions << operation_definition
          builder.push_node(operation_definition)
          return 1
        }

        @callbacks.end_visit_operation_definition = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          builder = data.as(Pointer(Builder)).value
          builder.pop_node
        }

        @callbacks.visit_field = ->(field : LibGraphqlParser::GraphQLAstField, data : Pointer(Void)) {
          builder = data.as(Pointer(Builder)).value

          field_name = LibGraphqlParser.GraphQLAstField_get_name(field)
          field_name_value = LibGraphqlParser.GraphQLAstName_get_value(field_name)


          field = Nodes::Field.new(String.new(field_name_value))

          current_node = builder.current
          case current_node
          when Nodes::OperationDefinition, Nodes::Field
            current_node.selections << field
          end

          builder.push_node(field)

          return 1
        }

        @callbacks.end_visit_field = ->(node : LibGraphqlParser::GraphQLAstField, data : Pointer(Void)) {
          builder = data.as(Pointer(Builder)).value
          builder.pop_node
        }

        @callbacks.visit_argument = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          builder = data.as(Pointer(Builder)).value

          argument_name = LibGraphqlParser.GraphQLAstArgument_get_name(node)
          argument_name_value = LibGraphqlParser.GraphQLAstName_get_value(argument_name)

          argument = Nodes::Argument.new(String.new(argument_name_value))

          current_node = builder.current
          case current_node
          when Nodes::Directive
            current_node.arguments << argument
          end

          builder.push_node(argument)
          return 1
        }

        @callbacks.end_visit_argument = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          builder = data.as(Pointer(Builder)).value
          builder.pop_node
        }

        @callbacks.visit_directive = -> (node : LibGraphqlParser::GraphQLAstNode, data: Pointer(Void)) {
          builder = data.as(Pointer(Builder)).value

          directive_name = LibGraphqlParser.GraphQLAstDirective_get_name(node)
          directive_name_value = LibGraphqlParser.GraphQLAstName_get_value(directive_name)

          directive = Nodes::Directive.new(String.new(directive_name_value))

          current_node = builder.current

          case current_node
          when Nodes::Field, Nodes::FragmentDefinition
            current_node.directives << directive
          end

          builder.push_node(directive)
          return 1
        }

        @callbacks.end_visit_directive = -> (node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          builder = data.as(Pointer(Builder)).value
          builder.pop_node
        }

        @callbacks.visit_named_type = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          return 1
        }

        @callbacks.end_visit_named_type = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
        }
      end

      def parse(string)
        node = LibGraphqlParser.parse_string(string, out error)

        if node.null?
          error_message = String.new(chars: error)
          LibGraphqlParser.error_free(error)

          raise error_message
        else
          LibGraphqlParser.node_visit(node, pointerof(@callbacks), pointerof(@builder))

          @builder.document.as(Nodes::Document)
        end
      end
    end
  end
end