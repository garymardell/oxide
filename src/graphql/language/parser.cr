require "./libgraphqlparser"
require "log"

Log.setup_from_env

module Graphql
  module Language
    class Stack
      private property array : Array(Nodes::Node)

      def initialize
        @array = [] of Nodes::Node
      end

      def document
        @array.first
      end

      def peek
        @array.last
      end

      def push(node)
        @array << node
      end

      def pop
        @array.pop
      end
    end



    class Parser
      private property stack : Stack
      private property callbacks : LibGraphqlParser::GraphQLAstVisitorCallbacks

      macro log_visit(callback)
        puts {{callback}}
      end

      def initialize
        @stack = Stack.new
        @callbacks = LibGraphqlParser::GraphQLAstVisitorCallbacks.new

        @callbacks.visit_document = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_document")

          stack = data.as(Pointer(Stack)).value
          stack.push(Nodes::Document.new)
          return 1
        }

        @callbacks.end_visit_document = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_document")
        }

        @callbacks.visit_operation_definition = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_operation_definition")
          stack = data.as(Pointer(Stack)).value

          operation = LibGraphqlParser.GraphQLAstOperationDefinition_get_operation(node)

          operation_type = if (operation)
            String.new(operation)
          else
            "query"
          end

          operation_definition = Nodes::OperationDefinition.new(operation_type) # Remove hard coded query type

          stack.peek.as(Nodes::Document).definitions << operation_definition
          stack.push(operation_definition)
          return 1
        }

        @callbacks.end_visit_operation_definition = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_operation_definition")

          stack = data.as(Pointer(Stack)).value
          stack.pop
        }

        @callbacks.visit_variable_definition = -> (node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_variable_definition")

          return 1
        }

        @callbacks.end_visit_variable_definition = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_variable_definition")

          stack = data.as(Pointer(Stack)).value

          default_value = if stack.peek.is_a?(Nodes::Value)
            stack.pop.as(Nodes::Value)
          else
            nil
          end

          variable = stack.pop.as(Nodes::Variable)
          variable_definition = Nodes::VariableDefinition.new(variable, Nodes::Type.new, default_value)

          stack.peek.as(Nodes::OperationDefinition).variable_definitions << variable_definition
        }

        @callbacks.visit_selection_set = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_selection_set")
          return 1
        }

        @callbacks.end_visit_selection_set = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_selection_set")
        }

        @callbacks.visit_field = ->(field : LibGraphqlParser::GraphQLAstField, data : Pointer(Void)) {
          log_visit("visit_field")

          stack = data.as(Pointer(Stack)).value

          field_name = LibGraphqlParser.GraphQLAstField_get_name(field)
          field_name_value = LibGraphqlParser.GraphQLAstName_get_value(field_name)


          field = Nodes::Field.new(String.new(field_name_value))

          peek_node = stack.peek
          case peek_node
          when Nodes::OperationDefinition, Nodes::Field
            peek_node.selections << field
          else
            pp peek_node
          end

          stack.push(field)

          return 1
        }

        @callbacks.end_visit_field = ->(node : LibGraphqlParser::GraphQLAstField, data : Pointer(Void)) {
          log_visit("end_visit_field")

          stack = data.as(Pointer(Stack)).value
          stack.pop
        }

        @callbacks.visit_argument = -> (node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_argument")
          return 1
        }

        @callbacks.end_visit_argument = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_argument")

          stack = data.as(Pointer(Stack)).value
          variable = stack.pop.as(Nodes::Variable)

          argument_name = LibGraphqlParser.GraphQLAstArgument_get_name(node)
          argument_name_value = LibGraphqlParser.GraphQLAstName_get_value(argument_name)

          stack.peek.as(Nodes::Field).arguments << Nodes::Argument.new(String.new(argument_name_value), variable)
        }

        @callbacks.visit_fragment_spread = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_fragment_spread")
          return 1
        }

        @callbacks.end_visit_fragment_spread = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_fragment_spread")
        }

        @callbacks.visit_inline_fragment = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_inline_fragment")
          return 1
        }

        @callbacks.end_visit_inline_fragment = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_inline_fragment")
        }

        @callbacks.visit_fragment_definition = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_fragment_definition")
          return 1
        }

        @callbacks.end_visit_fragment_definition = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_fragment_definition")
        }

        @callbacks.visit_variable = -> (node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_variable")

          stack = data.as(Pointer(Stack)).value

          variable_name = LibGraphqlParser.GraphQLAstVariable_get_name(node)
          variable_name_value = LibGraphqlParser.GraphQLAstName_get_value(variable_name)

          stack.push(Nodes::Variable.new(String.new(variable_name_value)))

          return 1
        }

        @callbacks.end_visit_variable = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_variable")
        }

        @callbacks.visit_int_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_int_value")

          stack = data.as(Pointer(Stack)).value

          int_value_string = String.new(LibGraphqlParser.GraphQLAstIntValue_get_value(node))

          stack.push(Nodes::Value.new(int_value_string.to_i64))

          return 1
        }

        @callbacks.end_visit_int_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_int_value")
        }

        @callbacks.visit_float_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_float_value")
          return 1
        }

        @callbacks.end_visit_float_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_float_value")
        }

        @callbacks.visit_string_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_string_value")
          return 1
        }

        @callbacks.end_visit_string_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_string_value")
        }

        @callbacks.visit_boolean_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_boolean_value")
          return 1
        }

        @callbacks.end_visit_boolean_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_boolean_value")
        }

        @callbacks.visit_null_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_null_value")
          return 1
        }

        @callbacks.end_visit_null_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_null_value")
        }

        @callbacks.visit_enum_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_enum_value")
          return 1
        }

        @callbacks.end_visit_enum_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_enum_value")
        }

        @callbacks.visit_list_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_list_value")
          return 1
        }

        @callbacks.end_visit_list_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_list_value")
        }

        @callbacks.visit_object_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_object_value")
          return 1
        }

        @callbacks.end_visit_object_value = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_object_value")
        }

        @callbacks.visit_object_field = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_object_field")
          return 1
        }

        @callbacks.end_visit_object_field = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_object_field")
        }

        @callbacks.visit_directive = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_directive")
          return 1
        }

        @callbacks.end_visit_directive = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_directive")
        }

        @callbacks.visit_named_type = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_named_type")
          return 1
        }

        @callbacks.end_visit_named_type = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_named_type")
        }

        @callbacks.visit_list_type = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_list_type")
          return 1
        }

        @callbacks.end_visit_list_type = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_list_type")
        }

        @callbacks.visit_non_null_type = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_non_null_type")
          return 1
        }

        @callbacks.end_visit_non_null_type = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_non_null_type")
        }

        @callbacks.visit_name = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("visit_name")
          return 1
        }

        @callbacks.end_visit_name = ->(node : LibGraphqlParser::GraphQLAstNode, data : Pointer(Void)) {
          log_visit("end_visit_name")
        }
      end

      def parse(string)
        node = LibGraphqlParser.parse_string(string, out error)

        if node.null?
          error_message = String.new(chars: error)
          LibGraphqlParser.error_free(error)

          raise error_message
        else
          LibGraphqlParser.node_visit(node, pointerof(@callbacks), pointerof(@stack))

          @stack.document.as(Nodes::Document)
        end
      end
    end
  end
end