require "./libgraphqlparser"

module Graphene
  module Language
    class SchemaParser < Parser
      def initialize
        super

        @callbacks.visit_list_type = ->(node : LibGraphqlParser::GraphQLAstListType, data : Pointer(Void)) {
          log_visit("visit_list_type")

          stack = data.as(Pointer(Stack)).value

          list_type = Nodes::ListType.new

          stack.push(list_type)

          return 1
        }

        @callbacks.end_visit_list_type = ->(node : LibGraphqlParser::GraphQLAstListType, data : Pointer(Void)) {
          log_visit("end_visit_list_type")

          stack = data.as(Pointer(Stack)).value

          list_type = stack.pop.as(Nodes::ListType)

          case stack.peek
          when Nodes::NonNullType
            stack.peek.as(Nodes::NonNullType).of_type = list_type
          when Nodes::FieldDefinition
            stack.peek.as(Nodes::FieldDefinition).type = list_type
          when Nodes::InputValueDefinition
            stack.peek.as(Nodes::InputValueDefinition).type = list_type
          end
        }

        @callbacks.end_visit_non_null_type = ->(node : LibGraphqlParser::GraphQLAstNonNullType, data : Pointer(Void)) {
          log_visit("end_visit_non_null_type")

          stack = data.as(Pointer(Stack)).value

          type = stack.pop.as(Nodes::NonNullType)

          case stack.peek
          when Nodes::FieldDefinition
            stack.peek.as(Nodes::FieldDefinition).type = type
          when Nodes::InputValueDefinition
            stack.peek.as(Nodes::InputValueDefinition).type = type
          end
        }

        @callbacks.end_visit_named_type = ->(node : LibGraphqlParser::GraphQLAstNamedType, data : Pointer(Void)) {
          log_visit("end_visit_named_type")

          stack = data.as(Pointer(Stack)).value
          named_type = stack.pop.as(Nodes::NamedType)

          case stack.peek
          when Nodes::OperationTypeDefinition
            stack.peek.as(Nodes::OperationTypeDefinition).named_type = named_type
          when Nodes::FieldDefinition
            stack.peek.as(Nodes::FieldDefinition).type = named_type
          when Nodes::NonNullType
            stack.peek.as(Nodes::NonNullType).of_type = named_type
          when Nodes::InputValueDefinition
            stack.peek.as(Nodes::InputValueDefinition).type = named_type
          when Nodes::ObjectTypeDefinition
            stack.peek.as(Nodes::ObjectTypeDefinition).implements << named_type
          when Nodes::UnionTypeDefinition
            stack.peek.as(Nodes::UnionTypeDefinition).member_types << named_type
          end
        }

        @callbacks.visit_schema_definition = ->(node : LibGraphqlParser::GraphQLAstSchemaDefinition, data : Pointer(Void)) {
          log_visit("visit_schema_definition")

          stack = data.as(Pointer(Stack)).value

          schema_definition = Nodes::SchemaDefinition.new

          copy_location_from_ast(node, schema_definition)

          stack.push(schema_definition)

          return 1
        }

        @callbacks.end_visit_schema_definition = ->(node : LibGraphqlParser::GraphQLAstSchemaDefinition, data : Pointer(Void)) {
          log_visit("end_visit_schema_definition")

          stack = data.as(Pointer(Stack)).value

          schema_definition = stack.pop.as(Nodes::SchemaDefinition)

          stack.peek.as(Nodes::Document).definitions << schema_definition
        }

        @callbacks.visit_operation_type_definition = ->(node : LibGraphqlParser::GraphQLAstOperationTypeDefinition, data : Pointer(Void)) {
          log_visit("visit_operation_type_definition")

          stack = data.as(Pointer(Stack)).value

          operation = LibGraphqlParser.GraphQLAstOperationTypeDefinition_get_operation(node)

          operation_type_definition = Nodes::OperationTypeDefinition.new(String.new(operation))

          copy_location_from_ast(node, operation_type_definition)

          stack.push(operation_type_definition)

          return 1
        }

        @callbacks.end_visit_operation_type_definition = ->(node : LibGraphqlParser::GraphQLAstOperationTypeDefinition, data : Pointer(Void)) {
          log_visit("end_visit_operation_type_definition")

          stack = data.as(Pointer(Stack)).value

          operation_type_definition = stack.pop.as(Nodes::OperationTypeDefinition)

          stack.peek.as(Nodes::SchemaDefinition).operation_type_definitions << operation_type_definition
        }

        @callbacks.visit_scalar_type_definition = ->(node : LibGraphqlParser::GraphQLAstScalarTypeDefinition, data : Pointer(Void)) {
          log_visit("visit_scalar_type_definition")

          stack = data.as(Pointer(Stack)).value

          scalar_type_definition_name = LibGraphqlParser.GraphQLAstScalarTypeDefinition_get_name(node)
          scalar_type_definition_value = LibGraphqlParser.GraphQLAstName_get_value(scalar_type_definition_name)

          scalar_type_definition = Nodes::ScalarTypeDefinition.new(String.new(scalar_type_definition_value))

          copy_location_from_ast(node, scalar_type_definition)

          stack.push(scalar_type_definition)

          return 1
        }

        @callbacks.end_visit_scalar_type_definition = ->(node : LibGraphqlParser::GraphQLAstScalarTypeDefinition, data : Pointer(Void)) {
          log_visit("end_visit_scalar_type_definition")

          stack = data.as(Pointer(Stack)).value

          scalar_type_definition = stack.pop.as(Nodes::ScalarTypeDefinition)

          case stack.peek
          when Nodes::Document
            stack.peek.as(Nodes::Document).definitions << scalar_type_definition
          end
        }

        @callbacks.visit_object_type_definition = ->(node : LibGraphqlParser::GraphQLAstObjectTypeDefinition, data : Pointer(Void)) {
          log_visit("visit_object_type_definition")

          stack = data.as(Pointer(Stack)).value

          object_type_definition_name = LibGraphqlParser.GraphQLAstObjectTypeDefinition_get_name(node)
          object_type_definition_value = LibGraphqlParser.GraphQLAstName_get_value(object_type_definition_name)

          object_type_definition = Nodes::ObjectTypeDefinition.new(String.new(object_type_definition_value))

          copy_location_from_ast(node, object_type_definition)

          stack.push(object_type_definition)

          return 1
        }

        @callbacks.end_visit_object_type_definition = ->(node : LibGraphqlParser::GraphQLAstObjectTypeDefinition, data : Pointer(Void)) {
          log_visit("end_visit_object_type_definition")

          stack = data.as(Pointer(Stack)).value

          object_type_definition = stack.pop.as(Nodes::ObjectTypeDefinition)

          stack.peek.as(Nodes::Document).definitions << object_type_definition
        }

        @callbacks.visit_field_definition = ->(node : LibGraphqlParser::GraphQLAstFieldDefinition, data : Pointer(Void)) {
          log_visit("visit_field_definition")

          stack = data.as(Pointer(Stack)).value

          field_definition_name = LibGraphqlParser.GraphQLAstFieldDefinition_get_name(node)
          field_definition_value = LibGraphqlParser.GraphQLAstName_get_value(field_definition_name)

          field_definition = Nodes::FieldDefinition.new(String.new(field_definition_value))

          copy_location_from_ast(node, field_definition)

          stack.push(field_definition)

          return 1
        }

        @callbacks.end_visit_field_definition = ->(node : LibGraphqlParser::GraphQLAstFieldDefinition, data : Pointer(Void)) {
          log_visit("end_visit_field_definition")

          stack = data.as(Pointer(Stack)).value

          field_definition = stack.pop.as(Nodes::FieldDefinition)

          default_value = if stack.peek.is_a?(Nodes::Value)
            stack.pop.as(Nodes::Value)
          else
            nil
          end

          case stack.peek
          when Nodes::ObjectTypeDefinition
            stack.peek.as(Nodes::ObjectTypeDefinition).field_definitions << field_definition
          when Nodes::InterfaceTypeDefinition
            stack.peek.as(Nodes::InterfaceTypeDefinition).field_definitions << field_definition
          end
        }

        @callbacks.visit_input_value_definition = ->(node : LibGraphqlParser::GraphQLAstInputValueDefinition, data : Pointer(Void)) {
          log_visit("visit_input_value_definition")

          stack = data.as(Pointer(Stack)).value

          input_value_definition_name = LibGraphqlParser.GraphQLAstInputValueDefinition_get_name(node)
          input_value_definition_value = LibGraphqlParser.GraphQLAstName_get_value(input_value_definition_name)

          input_value_definition = Nodes::InputValueDefinition.new(String.new(input_value_definition_value))

          copy_location_from_ast(node, input_value_definition)

          stack.push(input_value_definition)

          return 1
        }

        @callbacks.end_visit_input_value_definition = ->(node : LibGraphqlParser::GraphQLAstInputValueDefinition, data : Pointer(Void)) {
          log_visit("end_visit_input_value_definition")

          stack = data.as(Pointer(Stack)).value

          default_value = if stack.peek.is_a?(Nodes::Value)
            stack.pop.as(Nodes::Value)
          else
            nil
          end

          input_value_definition = stack.pop.as(Nodes::InputValueDefinition)
          input_value_definition.default_value = default_value

          case stack.peek
          when Nodes::FieldDefinition
            stack.peek.as(Nodes::FieldDefinition).argument_definitions << input_value_definition
          end
        }

        @callbacks.visit_interface_type_definition = ->(node : LibGraphqlParser::GraphQLAstInterfaceTypeDefinition, data : Pointer(Void)) {
          log_visit("visit_interface_type_definition")

          stack = data.as(Pointer(Stack)).value

          interface_type_definition_name = LibGraphqlParser.GraphQLAstInterfaceTypeDefinition_get_name(node)
          interface_type_definition_value = LibGraphqlParser.GraphQLAstName_get_value(interface_type_definition_name)

          interface_type_definition = Nodes::InterfaceTypeDefinition.new(String.new(interface_type_definition_value))

          copy_location_from_ast(node, interface_type_definition)

          stack.push(interface_type_definition)

          return 1
        }

        @callbacks.end_visit_interface_type_definition = ->(node : LibGraphqlParser::GraphQLAstInterfaceTypeDefinition, data : Pointer(Void)) {
          log_visit("end_visit_interface_type_definition")

          stack = data.as(Pointer(Stack)).value

          interface_type_definition = stack.pop.as(Nodes::InterfaceTypeDefinition)

          case stack.peek
          when Nodes::Document
            stack.peek.as(Nodes::Document).definitions << interface_type_definition
          end
        }

        @callbacks.visit_union_type_definition = ->(node : LibGraphqlParser::GraphQLAstUnionTypeDefinition, data : Pointer(Void)) {
          log_visit("visit_union_type_definition")

          stack = data.as(Pointer(Stack)).value

          union_type_definition_name = LibGraphqlParser.GraphQLAstUnionTypeDefinition_get_name(node)
          union_type_definition_value = LibGraphqlParser.GraphQLAstName_get_value(union_type_definition_name)

          union_type_definition = Nodes::UnionTypeDefinition.new(String.new(union_type_definition_value))

          copy_location_from_ast(node, union_type_definition)

          stack.push(union_type_definition)

          return 1
        }

        @callbacks.end_visit_union_type_definition = ->(node : LibGraphqlParser::GraphQLAstUnionTypeDefinition, data : Pointer(Void)) {
          log_visit("end_visit_union_type_definition")

          stack = data.as(Pointer(Stack)).value

          union_type_definition = stack.pop.as(Nodes::UnionTypeDefinition)

          case stack.peek
          when Nodes::Document
            stack.peek.as(Nodes::Document).definitions << union_type_definition
          end
        }

        @callbacks.visit_enum_type_definition = ->(node : LibGraphqlParser::GraphQLAstEnumTypeDefinition, data : Pointer(Void)) {
          log_visit("visit_enum_type_definition")

          stack = data.as(Pointer(Stack)).value

          enum_type_definition_name = LibGraphqlParser.GraphQLAstEnumTypeDefinition_get_name(node)
          enum_type_definition_value = LibGraphqlParser.GraphQLAstName_get_value(enum_type_definition_name)

          enum_type_definition = Nodes::EnumTypeDefinition.new(String.new(enum_type_definition_value))

          copy_location_from_ast(node, enum_type_definition)

          stack.push(enum_type_definition)

          return 1
        }

        @callbacks.end_visit_enum_type_definition = ->(node : LibGraphqlParser::GraphQLAstEnumTypeDefinition, data : Pointer(Void)) {
          log_visit("end_visit_enum_type_definition")

          stack = data.as(Pointer(Stack)).value

          enum_type_definition = stack.pop.as(Nodes::EnumTypeDefinition)

          case stack.peek
          when Nodes::Document
            stack.peek.as(Nodes::Document).definitions << enum_type_definition
          end
        }

        @callbacks.visit_enum_value_definition = ->(node : LibGraphqlParser::GraphQLAstEnumValueDefinition, data : Pointer(Void)) {
          log_visit("visit_enum_value_definition")

          stack = data.as(Pointer(Stack)).value

          enum_value_definition_name = LibGraphqlParser.GraphQLAstEnumValueDefinition_get_name(node)
          enum_value_definition_value = LibGraphqlParser.GraphQLAstName_get_value(enum_value_definition_name)

          enum_value_definition = Nodes::EnumValueDefinition.new(String.new(enum_value_definition_value))

          stack.push(enum_value_definition)

          return 1
        }

        @callbacks.end_visit_enum_value_definition = ->(node : LibGraphqlParser::GraphQLAstEnumValueDefinition, data : Pointer(Void)) {
          log_visit("end_visit_enum_value_definition")

          stack = data.as(Pointer(Stack)).value

          enum_value_definition = stack.pop.as(Nodes::EnumValueDefinition)

          case stack.peek
          when Nodes::EnumTypeDefinition
            stack.peek.as(Nodes::EnumTypeDefinition).value_definitions << enum_value_definition
          end
        }
      end

      def parse(string)
        node = LibGraphqlParser.parse_string_with_schema(string, out error)

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