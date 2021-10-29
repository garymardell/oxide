require "./libgraphqlparser"
require "log"

Log.setup_from_env

module Graphene
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
        # puts {{callback}}
      end

      macro log_visit(callback, name)
        # puts {{callback}}
        # puts {{name}}
      end

      macro extract_value(method, operator)
        String.new(LibGraphqlParser.{{method.id}}(node)).{{operator.id}}
      end

      macro copy_location_from_ast(ast_node, node)
        location = LibGraphqlParser::GraphQLAstLocation.new

        LibGraphqlParser.node_get_location({{ast_node}}.as(LibGraphqlParser::GraphQLAstNode), pointerof(location))

        {{node}}.beginLine = location.beginLine
        {{node}}.endLine = location.endLine
        {{node}}.beginColumn = location.beginColumn
        {{node}}.endColumn = location.endColumn
      end

      def initialize
        @stack = Stack.new
        @callbacks = LibGraphqlParser::GraphQLAstVisitorCallbacks.new

        @callbacks.visit_document = ->(node : LibGraphqlParser::GraphQLAstDocument, data : Pointer(Void)) {
          log_visit("visit_document")

          stack = data.as(Pointer(Stack)).value
          stack.push(Nodes::Document.new)
          return 1
        }

        @callbacks.end_visit_document = ->(node : LibGraphqlParser::GraphQLAstDocument, data : Pointer(Void)) {
          log_visit("end_visit_document")

          stack = data.as(Pointer(Stack)).value
        }

        @callbacks.visit_operation_definition = ->(node : LibGraphqlParser::GraphQLAstOperationDefinition, data : Pointer(Void)) {
          log_visit("visit_operation_definition")

          operation = LibGraphqlParser.GraphQLAstOperationDefinition_get_operation(node)

          operation_name = LibGraphqlParser.GraphQLAstOperationDefinition_get_name(node)
          operation_name_value = if operation_name
            String.new(LibGraphqlParser.GraphQLAstName_get_value(operation_name))
          end

          operation_type = if (operation)
            String.new(operation)
          else
            "query"
          end

          stack = data.as(Pointer(Stack)).value

          operation_definition = Nodes::OperationDefinition.new(operation_type, name: operation_name_value)

          copy_location_from_ast(node, operation_definition)

          stack.push(operation_definition)

          return 1
        }

        @callbacks.end_visit_operation_definition = ->(node : LibGraphqlParser::GraphQLAstOperationDefinition, data : Pointer(Void)) {
          log_visit("end_visit_operation_definition")

          stack = data.as(Pointer(Stack)).value

          operation_definition = stack.pop.as(Nodes::OperationDefinition)

          stack.peek.as(Nodes::Document).definitions << operation_definition
        }

        @callbacks.visit_variable_definition = -> (node : LibGraphqlParser::GraphQLAstVariableDefinition, data : Pointer(Void)) {
          log_visit("visit_variable_definition")

          stack = data.as(Pointer(Stack)).value

          variable_definition = Nodes::VariableDefinition.new

          copy_location_from_ast(node, variable_definition)

          stack.push(variable_definition)

          return 1
        }

        @callbacks.end_visit_variable_definition = ->(node : LibGraphqlParser::GraphQLAstVariableDefinition, data : Pointer(Void)) {
          log_visit("end_visit_variable_definition")

          stack = data.as(Pointer(Stack)).value

          default_value = if stack.peek.is_a?(Nodes::Value)
            stack.pop.as(Nodes::Value)
          else
            nil
          end

          variable_definition = stack.pop.as(Nodes::VariableDefinition)
          variable_definition.default_value = default_value

          stack.peek.as(Nodes::OperationDefinition).variable_definitions << variable_definition

        }

        @callbacks.visit_selection_set = ->(node : LibGraphqlParser::GraphQLAstSelectionSet, data : Pointer(Void)) {
          log_visit("visit_selection_set")

          stack = data.as(Pointer(Stack)).value

          selection_set = Nodes::SelectionSet.new

          copy_location_from_ast(node, selection_set)

          stack.push(selection_set)

          return 1
        }

        @callbacks.end_visit_selection_set = ->(node : LibGraphqlParser::GraphQLAstSelectionSet, data : Pointer(Void)) {
          log_visit("end_visit_selection_set")

          stack = data.as(Pointer(Stack)).value

          selections = [] of Nodes::Selection

          while stack.peek.is_a?(Nodes::Field) || stack.peek.is_a?(Nodes::FragmentSpread)
            selections << stack.pop
          end

          selection_set = stack.pop.as(Nodes::SelectionSet)

          case stack.peek
          when Nodes::OperationDefinition
            stack.peek.as(Nodes::OperationDefinition).selection_set = selection_set
          when Nodes::Field
            stack.peek.as(Nodes::Field).selection_set = selection_set
          when Nodes::FragmentDefinition
            stack.peek.as(Nodes::FragmentDefinition).selection_set = selection_set
          when Nodes::InlineFragment
            stack.peek.as(Nodes::InlineFragment).selection_set = selection_set
          else
            pp stack.peek
          end
        }

        @callbacks.visit_field = ->(node : LibGraphqlParser::GraphQLAstField, data : Pointer(Void)) {
          log_visit("visit_field")

          alias_name = LibGraphqlParser.GraphQLAstField_get_alias(node)

          alias_value = if alias_name
            String.new(LibGraphqlParser.GraphQLAstName_get_value(alias_name))
          end

          field_name = LibGraphqlParser.GraphQLAstField_get_name(node)
          field_name_value = String.new(LibGraphqlParser.GraphQLAstName_get_value(field_name))

          stack = data.as(Pointer(Stack)).value

          field = Nodes::Field.new(field_name_value, alias_value)

          copy_location_from_ast(node, field)

          stack.push(field)

          return 1
        }

        @callbacks.end_visit_field = ->(node : LibGraphqlParser::GraphQLAstField, data : Pointer(Void)) {
          log_visit("end_visit_field")

          stack = data.as(Pointer(Stack)).value

          field = stack.pop.as(Nodes::Field)

          stack.peek.as(Nodes::SelectionSet).selections << field
        }

        @callbacks.visit_argument = -> (node : LibGraphqlParser::GraphQLAstArgument, data : Pointer(Void)) {
          log_visit("visit_argument")

          argument_name = LibGraphqlParser.GraphQLAstArgument_get_name(node)
          argument_name_value = String.new(LibGraphqlParser.GraphQLAstName_get_value(argument_name))

          stack = data.as(Pointer(Stack)).value

          argument = Nodes::Argument.new(argument_name_value)

          copy_location_from_ast(node, argument)

          stack.push(argument)

          return 1
        }

        @callbacks.end_visit_argument = ->(node : LibGraphqlParser::GraphQLAstArgument, data : Pointer(Void)) {
          log_visit("end_visit_argument")

          stack = data.as(Pointer(Stack)).value

          # TODO: Value could be anything
          # value = stack.pop.as(Nodes::Value?)
          value = if stack.peek.is_a?(Nodes::Value)
            stack.pop.as(Nodes::Value)
          else
            Nodes::Value.new(value: stack.pop.as(Nodes::ValueType))
          end

          argument = stack.pop.as(Nodes::Argument)
          argument.value = value

          case stack.peek
          when Nodes::Field
            stack.peek.as(Nodes::Field).arguments << argument
          when Nodes::Directive
            stack.peek.as(Nodes::Directive).arguments << argument
          else
            pp "Not a field"
          end
        }

        @callbacks.visit_fragment_spread = ->(node : LibGraphqlParser::GraphQLAstFragmentSpread, data : Pointer(Void)) {
          log_visit("visit_fragment_spread")

          stack = data.as(Pointer(Stack)).value

          fragment_spread_name = LibGraphqlParser.GraphQLAstFragmentSpread_get_name(node)
          fragment_spread_name_value = String.new(LibGraphqlParser.GraphQLAstName_get_value(fragment_spread_name))

          fragment_spread = Nodes::FragmentSpread.new(fragment_spread_name_value)

          copy_location_from_ast(node, fragment_spread)

          stack.push(fragment_spread)

          return 1
        }

        @callbacks.end_visit_fragment_spread = ->(node : LibGraphqlParser::GraphQLAstFragmentSpread, data : Pointer(Void)) {
          log_visit("end_visit_fragment_spread")

          stack = data.as(Pointer(Stack)).value

          fragment_spread = stack.pop.as(Nodes::FragmentSpread)

          stack.peek.as(Nodes::SelectionSet).selections << fragment_spread
        }

        @callbacks.visit_inline_fragment = ->(node : LibGraphqlParser::GraphQLAstInlineFragment, data : Pointer(Void)) {
          log_visit("visit_inline_fragment")

          stack = data.as(Pointer(Stack)).value

          inline_fragment = Nodes::InlineFragment.new

          copy_location_from_ast(node, inline_fragment)

          stack.push(inline_fragment)

          return 1
        }

        @callbacks.end_visit_inline_fragment = ->(node : LibGraphqlParser::GraphQLAstInlineFragment, data : Pointer(Void)) {
          log_visit("end_visit_inline_fragment")

          stack = data.as(Pointer(Stack)).value
          inline_fragment = stack.pop.as(Nodes::InlineFragment)

          stack.peek.as(Nodes::SelectionSet).selections << inline_fragment
        }

        @callbacks.visit_fragment_definition = ->(node : LibGraphqlParser::GraphQLAstFragmentDefinition, data : Pointer(Void)) {
          log_visit("visit_fragment_definition")

          stack = data.as(Pointer(Stack)).value

          fragment_name = LibGraphqlParser.GraphQLAstFragmentDefinition_get_name(node)
          fragment_name_value = String.new(LibGraphqlParser.GraphQLAstName_get_value(fragment_name))

          fragment_definition = Nodes::FragmentDefinition.new(fragment_name_value)

          copy_location_from_ast(node, fragment_definition)

          stack.push(fragment_definition)

          return 1
        }

        @callbacks.end_visit_fragment_definition = ->(node : LibGraphqlParser::GraphQLAstFragmentDefinition, data : Pointer(Void)) {
          log_visit("end_visit_fragment_definition")

          stack = data.as(Pointer(Stack)).value

          fragment_definition = stack.pop.as(Nodes::FragmentDefinition)

          stack.peek.as(Nodes::Document).definitions << fragment_definition
        }

        @callbacks.visit_variable = -> (node : LibGraphqlParser::GraphQLAstVariable, data : Pointer(Void)) {
          log_visit("visit_variable")

          stack = data.as(Pointer(Stack)).value

          variable_name = LibGraphqlParser.GraphQLAstVariable_get_name(node)
          variable_name_value = String.new(LibGraphqlParser.GraphQLAstName_get_value(variable_name))

          variable = Nodes::Variable.new(variable_name_value)

          copy_location_from_ast(node, variable)

          stack.push(variable)

          return 1
        }

        @callbacks.end_visit_variable = ->(node : LibGraphqlParser::GraphQLAstVariable, data : Pointer(Void)) {
          log_visit("end_visit_variable")

          stack = data.as(Pointer(Stack)).value

          variable = stack.pop.as(Nodes::Variable)

          case stack.peek
          when Nodes::VariableDefinition
            stack.peek.as(Nodes::VariableDefinition).variable = variable
          when Nodes::Argument
            # stack.peek.as(Nodes::Argument).value = variable
            stack.push(variable) # TODO: Values are left on the stack for now
          end
        }

        @callbacks.visit_int_value = ->(node : LibGraphqlParser::GraphQLAstIntValue, data : Pointer(Void)) {
          log_visit("visit_int_value")

          stack = data.as(Pointer(Stack)).value
          stack.push(Nodes::Value.new(extract_value("GraphQLAstIntValue_get_value", "to_i64")))
          return 1
        }

        @callbacks.end_visit_int_value = ->(node : LibGraphqlParser::GraphQLAstIntValue, data : Pointer(Void)) {
          log_visit("end_visit_int_value")
        }

        @callbacks.visit_float_value = ->(node : LibGraphqlParser::GraphQLAstFloatValue, data : Pointer(Void)) {
          log_visit("visit_float_value")

          stack = data.as(Pointer(Stack)).value
          stack.push(Nodes::Value.new(extract_value("GraphQLAstFloatValue_get_value", "to_f64")))

          return 1
        }

        @callbacks.end_visit_float_value = ->(node : LibGraphqlParser::GraphQLAstFloatValue, data : Pointer(Void)) {
          log_visit("end_visit_float_value")
        }

        @callbacks.visit_string_value = ->(node : LibGraphqlParser::GraphQLAstStringValue, data : Pointer(Void)) {
          log_visit("visit_string_value")

          stack = data.as(Pointer(Stack)).value
          stack.push(Nodes::Value.new(extract_value("GraphQLAstStringValue_get_value", "to_s")))

          return 1
        }

        @callbacks.end_visit_string_value = ->(node : LibGraphqlParser::GraphQLAstStringValue, data : Pointer(Void)) {
          log_visit("end_visit_string_value")
        }

        @callbacks.visit_boolean_value = ->(node : LibGraphqlParser::GraphQLAstBooleanValue, data : Pointer(Void)) {
          log_visit("visit_boolean_value")

          stack = data.as(Pointer(Stack)).value
          stack.push(Nodes::Value.new(!!LibGraphqlParser.GraphQLAstBooleanValue_get_value(node)))

          return 1
        }

        @callbacks.end_visit_boolean_value = ->(node : LibGraphqlParser::GraphQLAstBooleanValue, data : Pointer(Void)) {
          log_visit("end_visit_boolean_value")
        }

        @callbacks.visit_null_value = ->(node : LibGraphqlParser::GraphQLAstNullValue, data : Pointer(Void)) {
          log_visit("visit_null_value")

          stack = data.as(Pointer(Stack)).value
          stack.push(Nodes::Value.new(nil))

          return 1
        }

        @callbacks.end_visit_null_value = ->(node : LibGraphqlParser::GraphQLAstNullValue, data : Pointer(Void)) {
          log_visit("end_visit_null_value")
        }

        @callbacks.visit_enum_value = ->(node : LibGraphqlParser::GraphQLAstEnumValue, data : Pointer(Void)) {
          log_visit("visit_enum_value")

          stack = data.as(Pointer(Stack)).value

          enum_value = LibGraphqlParser.GraphQLAstEnumValue_get_value(node)

          stack.push(Nodes::Value.new(String.new(enum_value)))

          return 1
        }

        @callbacks.end_visit_enum_value = ->(node : LibGraphqlParser::GraphQLAstEnumValue, data : Pointer(Void)) {
          log_visit("end_visit_enum_value")
        }

        @callbacks.visit_list_value = ->(node : LibGraphqlParser::GraphQLAstListValue, data : Pointer(Void)) {
          log_visit("visit_list_value")
          return 1
        }

        @callbacks.end_visit_list_value = ->(node : LibGraphqlParser::GraphQLAstListValue, data : Pointer(Void)) {
          log_visit("end_visit_list_value")
        }

        @callbacks.visit_object_value = ->(node : LibGraphqlParser::GraphQLAstObjectValue, data : Pointer(Void)) {
          log_visit("visit_object_value")

          stack = data.as(Pointer(Stack)).value

          object_value = Nodes::ObjectValue.new

          stack.push(object_value)

          return 1
        }

        @callbacks.end_visit_object_value = ->(node : LibGraphqlParser::GraphQLAstObjectValue, data : Pointer(Void)) {
          log_visit("end_visit_object_value")

          stack = data.as(Pointer(Stack)).value

          object_value = stack.pop.as(Nodes::ObjectValue)

          stack.push(Nodes::Value.new(object_value))
        }

        @callbacks.visit_object_field = ->(node : LibGraphqlParser::GraphQLAstObjectField, data : Pointer(Void)) {
          log_visit("visit_object_field")
          return 1
        }

        @callbacks.end_visit_object_field = ->(node : LibGraphqlParser::GraphQLAstObjectField, data : Pointer(Void)) {
          log_visit("end_visit_object_field")

          stack = data.as(Pointer(Stack)).value

          field_name = LibGraphqlParser.GraphQLAstObjectField_get_name(node)
          field_name_value = LibGraphqlParser.GraphQLAstName_get_value(field_name)

          value = stack.pop.as(Nodes::Value)

          object_field = Nodes::ObjectField.new(String.new(field_name_value), value)

          stack.peek.as(Nodes::ObjectValue).fields << object_field
        }

        @callbacks.visit_directive = ->(node : LibGraphqlParser::GraphQLAstDirective, data : Pointer(Void)) {
          log_visit("visit_directive")

          stack = data.as(Pointer(Stack)).value

          directive_name = LibGraphqlParser.GraphQLAstDirective_get_name(node)
          directive_name_value = LibGraphqlParser.GraphQLAstName_get_value(directive_name)

          directive = Nodes::Directive.new(String.new(directive_name_value))

          copy_location_from_ast(node, directive)

          stack.push(directive)

          return 1
        }

        @callbacks.end_visit_directive = ->(node : LibGraphqlParser::GraphQLAstDirective, data : Pointer(Void)) {
          log_visit("end_visit_directive")

          stack = data.as(Pointer(Stack)).value

          directive = stack.pop.as(Nodes::Directive)

          case stack.peek
          when Nodes::OperationDefinition
            stack.peek.as(Nodes::OperationDefinition).directives << directive
          when Nodes::FragmentDefinition
            stack.peek.as(Nodes::FragmentDefinition).directives << directive
          when Nodes::FragmentSpread
            stack.peek.as(Nodes::FragmentSpread).directives << directive
          when Nodes::InlineFragment
            stack.peek.as(Nodes::InlineFragment).directives << directive
          when Nodes::SchemaDefinition
            stack.peek.as(Nodes::SchemaDefinition).directives << directive
          when Nodes::ScalarTypeDefinition
            stack.peek.as(Nodes::ScalarTypeDefinition).directives << directive
          when Nodes::ObjectTypeDefinition
            stack.peek.as(Nodes::ObjectTypeDefinition).directives << directive
          when Nodes::FieldDefinition
            stack.peek.as(Nodes::FieldDefinition).directives << directive
          when Nodes::InputValueDefinition
            stack.peek.as(Nodes::InputValueDefinition).directives << directive
          when Nodes::InterfaceTypeDefinition
            stack.peek.as(Nodes::InterfaceTypeDefinition).directives << directive
          when Nodes::UnionTypeDefinition
            stack.peek.as(Nodes::UnionTypeDefinition).directives << directive
          when Nodes::EnumTypeDefinition
            stack.peek.as(Nodes::EnumTypeDefinition).directives << directive
          when Nodes::EnumValueDefinition
            stack.peek.as(Nodes::EnumValueDefinition).directives << directive
          when Nodes::Field
            stack.peek.as(Nodes::Field).directives << directive
          end
        }

        @callbacks.visit_named_type = ->(node : LibGraphqlParser::GraphQLAstNamedType, data : Pointer(Void)) {
          log_visit("visit_named_type")

          stack = data.as(Pointer(Stack)).value

          named_type_name = LibGraphqlParser.GraphQLAstNamedType_get_name(node)
          named_type_name_value = LibGraphqlParser.GraphQLAstName_get_value(named_type_name)

          named_type = Nodes::NamedType.new(String.new(named_type_name_value))

          copy_location_from_ast(node, named_type)

          stack.push(named_type)

          return 1
        }

        @callbacks.end_visit_named_type = ->(node : LibGraphqlParser::GraphQLAstNamedType, data : Pointer(Void)) {
          log_visit("end_visit_named_type")

          stack = data.as(Pointer(Stack)).value
          named_type = stack.pop.as(Nodes::NamedType)

          case stack.peek
          when Nodes::FragmentDefinition
            stack.peek.as(Nodes::FragmentDefinition).type_condition = named_type
          when Nodes::InlineFragment
            stack.peek.as(Nodes::InlineFragment).type_condition = named_type
          when Nodes::VariableDefinition
            stack.peek.as(Nodes::VariableDefinition).type = named_type
          when Nodes::NonNullType
            stack.peek.as(Nodes::NonNullType).of_type = named_type
          end
        }

        @callbacks.visit_list_type = ->(node : LibGraphqlParser::GraphQLAstListType, data : Pointer(Void)) {
          log_visit("visit_list_type")
          return 1
        }

        @callbacks.end_visit_list_type = ->(node : LibGraphqlParser::GraphQLAstListType, data : Pointer(Void)) {
          log_visit("end_visit_list_type")
        }

        @callbacks.visit_non_null_type = ->(node : LibGraphqlParser::GraphQLAstNonNullType, data : Pointer(Void)) {
          log_visit("visit_non_null_type")

          stack = data.as(Pointer(Stack)).value

          non_null_type = Nodes::NonNullType.new

          copy_location_from_ast(node, non_null_type)

          stack.push(non_null_type)

          return 1
        }

        @callbacks.end_visit_non_null_type = ->(node : LibGraphqlParser::GraphQLAstNonNullType, data : Pointer(Void)) {
          log_visit("end_visit_non_null_type")

          # Pick up either the list type or named type
          stack = data.as(Pointer(Stack)).value

          type = stack.pop.as(Nodes::NonNullType)

          case stack.peek
          when Nodes::VariableDefinition
            stack.peek.as(Nodes::VariableDefinition).type = type
          end

          # stack.push(Nodes::NonNullType.new(type))
        }

        @callbacks.visit_name = ->(node : LibGraphqlParser::GraphQLAstName, data : Pointer(Void)) {
          log_visit("visit_name")
          return 1
        }

        @callbacks.end_visit_name = ->(node : LibGraphqlParser::GraphQLAstName, data : Pointer(Void)) {
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