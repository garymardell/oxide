require "./visitable"

module Oxide
  module Language
    module Nodes
      alias Definition = OperationDefinition | FragmentDefinition | SchemaDefinition | TypeDefinition | DirectiveDefinition
      alias Selection = Field | FragmentSpread | InlineFragment
      alias DirectiveLocation = String

      alias ValueType = String | Int32 | Float32 | Bool | Nil | Array(Value) | Hash(String, Value) | Variable

      abstract class Node
        include Visitable

        property begin_line : Int32?
        property begin_column : Int32?

        def to_location
          Oxide::Location.new(line: begin_line.not_nil!, column: begin_column.not_nil!)
        end
      end

      abstract class Type < Node
        abstract def unwrap
        abstract def to_s(io)

        def to_s
          String.build do |io|
            to_s(io)
          end
        end
      end

      class Document < Node
        getter definitions : Array(Definition)

        def initialize(@definitions = [] of Definition)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          definitions.each do |definition|
            definition.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash definitions
      end

      class OperationDefinition < Node
        getter name : String?
        getter operation_type : String
        getter! selection_set : SelectionSet
        getter variable_definitions : Array(VariableDefinition)
        getter directives : Array(Directive)

        def initialize(@operation_type, @name = nil, @selection_set = nil, @variable_definitions = [] of VariableDefinition, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          selection_set.accept(visitor)

          variable_definitions.each do |variable_definition|
            variable_definition.accept(visitor)
          end

          directives.each do |directive|
            directive.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash name, operation_type, selection_set, variable_definitions, directives
      end

      class SelectionSet < Node
        getter selections : Array(Selection)

        def initialize(@selections = [] of Selection)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          selections.each do |selection|
            selection.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash selections
      end

      class FragmentDefinition < Node
        getter name : String
        getter! type_condition : NamedType
        getter! selection_set : SelectionSet
        getter directives : Array(Directive)

        def initialize(@name, @type_condition = nil, @selection_set = nil, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          selection_set.accept(visitor)

          directives.each do |directive|
            directive.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash name, type_condition, selection_set, directives
      end

      class SchemaDefinition < Node
        getter description : String?
        getter directives : Array(Directive)
        getter operation_type_definitions : Array(OperationTypeDefinition)

        def initialize(@description = nil, @operation_type_definitions = [] of OperationTypeDefinition, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          directives.each do |directive|
            directive.accept(visitor)
          end

          operation_type_definitions.each do |operation_type_definition|
            operation_type_definition.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash directives, operation_type_definitions
      end

      class OperationTypeDefinition < Node
        getter operation_type : String
        getter! named_type : NamedType

        def initialize(@operation_type, @named_type = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end

        def_equals_and_hash operation_type, named_type
      end

      class FragmentSpread < Node
        getter name : String
        getter directives : Array(Directive)

        def initialize(@name, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          directives.each do |directive|
            directive.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash name, directives
      end

      class InlineFragment < Node
        getter type_condition : NamedType?
        getter! selection_set : SelectionSet
        getter directives : Array(Directive)

        def initialize(@type_condition = nil, @selection_set = nil, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          directives.each do |directive|
            directive.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash type_condition, selection_set, directives
      end

      class Field < Node
        getter alias : String?
        getter name : String
        getter arguments : Array(Argument)
        getter selection_set : SelectionSet?
        getter directives : Array(Directive)

        def initialize(@name, @alias = nil, @arguments = [] of Argument, @selection_set = nil, @directives = [] of Directive)
        end

        # TODO: Re-serailize errors properly
        def to_json_object_key
          name
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          arguments.each do |argument|
            argument.accept(visitor)
          end

          unless selection_set.nil?
            selection_set.not_nil!.accept(visitor)
          end

          directives.each do |directive|
            directive.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash @alias, name, arguments, selection_set, directives
      end

      class Argument < Node
        getter name : String
        getter value : Value?

        def initialize(@name, @value = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless value.nil?
            value.not_nil!.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash name, value
      end

      class VariableDefinition < Node
        getter! variable : Variable
        getter! type : Type?
        getter default_value : Value?

        def initialize(@variable = nil, @type = nil, @default_value = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          variable.accept(visitor)

          visitor.leave(self)
        end

        def_equals_and_hash variable, type, default_value
      end

      class NamedType < Type
        getter name : String

        def initialize(@name)
        end

        def unwrap
          self
        end

        def to_s(io)
          io << name
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end

        def_equals_and_hash name
      end

      class ListType < Type
        getter of_type : NamedType | ListType | Nil

        def initialize(@of_type = nil)
        end

        def unwrap
          of_type.try &.unwrap
        end

        def to_s(io)
          io << "["
          of_type.to_s(io)
          io << "]"
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless of_type.nil?
            of_type.not_nil!.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash of_type
      end

      class NonNullType < Type
        getter of_type : NamedType | ListType | Nil

        def initialize(@of_type = nil)
        end

        def unwrap
          of_type.try &.unwrap
        end

        def to_s(io)
          of_type.to_s(io)
          io << "!"
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless of_type.nil?
            of_type.not_nil!.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash of_type
      end

      abstract class Value < Node
        abstract def value
        abstract def to_s(io)

        def to_s
          String.build do |io|
            to_s(io)
          end
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          visitor.leave(self)
        end

        def_equals_and_hash value
      end

      class StringValue < Value
        getter value : String

        def initialize(@value)
        end

        def to_s(io)
          io << value
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class Variable < Value
        getter name : String

        def initialize(@name)
        end

        def value
          name
        end

        def to_s(io)
          io << "$" << value
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class IntValue < Value
        getter value : Int64

        def initialize(@value)
        end

        def to_s(io)
          io << value
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class FloatValue < Value
        getter value : Float64

        def initialize(@value)
        end

        def to_s(io)
          io << value
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class BooleanValue < Value
        getter value : Bool

        def initialize(@value)
        end

        def to_s(io)
          io << value
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class NullValue < Value
        def value
          nil
        end

        def to_s(io)
          io << "null"
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class EnumValue < Value
        getter value : String

        def initialize(@value)
        end

        def to_s(io)
          io << value
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class ListValue < Value
        getter values : Array(Value)

        def initialize(@values = [] of Value)
        end

        def value
          values
        end

        def to_s(io)
          io << "["
          values.each_with_index(1) do |value, index|
            value.to_s(io)
            io << ", " if index < values.size
          end
          io << "]"
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          visitor.leave(self)
        end
      end

      class ObjectValue < Value
        getter fields : Array(ObjectField)

        def initialize(@fields = [] of ObjectField)
        end

        def value
          fields.reduce({} of String => Value) do |memo, field|
            memo[field.name] = field.value
            memo
          end
        end

        def to_s(io)
          io << "{"
          fields.each_with_index(1) do |field, index|
            io << field.name << ": "
            field.value.to_s(io)
            io << ", " if index < fields.size
          end
          io << "}"
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          fields.each do |field|
            field.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash fields
      end

      class ObjectField < Node
        getter name : String
        getter value : Value

        def initialize(@name, @value)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          value.accept(visitor)

          visitor.leave(self)
        end

        def_equals_and_hash name, value
      end

      class Directive < Node
        getter name : String
        getter arguments : Array(Argument)

        def initialize(@name, @arguments = [] of Argument)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          arguments.each do |argument|
            argument.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash name, arguments
      end

      abstract class TypeDefinition < Node
        abstract def name : String
      end

      class ScalarTypeDefinition < TypeDefinition
        getter name : String
        getter description : String?
        getter directives : Array(Directive)

        def initialize(@name, @description = nil, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end

        def_equals_and_hash name, directives
      end

      class ObjectTypeDefinition < TypeDefinition
        getter name : String
        getter description : String?
        getter implements : Array(NamedType)
        getter directives : Array(Directive)
        getter field_definitions : Array(FieldDefinition)

        def initialize(@name, @description = nil, @implements = [] of NamedType, @directives = [] of Directive, @field_definitions = [] of FieldDefinition)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          implements.each do |implement|
            implement.accept(visitor)
          end

          field_definitions.each do |field_definition|
            field_definition.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash name, implements, directives, field_definitions
      end

      class FieldDefinition < Node
        getter name : String
        getter description : String?
        getter argument_definitions : Array(InputValueDefinition)
        getter type : NamedType | ListType | NonNullType | Nil
        getter directives : Array(Directive)

        def initialize(@name, @description = nil, @argument_definitions = [] of InputValueDefinition, @type = nil, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          argument_definitions.each do |argument_definition|
            argument_definition.accept(visitor)
          end

          unless type.nil?
            type.not_nil!.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash name, argument_definitions, type, directives
      end

      class InputValueDefinition < Node
        getter name : String
        getter type : NamedType | ListType | NonNullType | Nil
        getter default_value : Value | Nil
        getter directives : Array(Directive)

        def initialize(@name, @type = nil, @default_value = nil, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless type.nil?
            type.not_nil!.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash name, type, default_value, directives
      end

      class InterfaceTypeDefinition < TypeDefinition
        getter name : String
        getter description : String?
        getter implements_interfaces : Array(NamedType)
        getter field_definitions : Array(FieldDefinition)
        getter directives : Array(Directive)

        def initialize(@name, @description = nil, @implements_interfaces = [] of NamedType, @field_definitions = [] of FieldDefinition, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          field_definitions.each do |field_definition|
            field_definition.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash name, field_definitions, directives
      end

      class UnionTypeDefinition < TypeDefinition
        getter name : String
        getter description : String?
        getter member_types : Array(NamedType)
        getter directives : Array(Directive)

        def initialize(@name, @description = nil, @member_types = [] of NamedType, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          member_types.each do |member_type|
            member_type.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash name, member_types, directives
      end

      class EnumTypeDefinition < TypeDefinition
        getter name : String
        getter description : String?
        getter value_definitions : Array(EnumValueDefinition)
        getter directives : Array(Directive)

        def initialize(@name, @description = nil, @directives = [] of Directive, @value_definitions = [] of EnumValueDefinition)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          value_definitions.each do |value_definition|
            value_definition.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash name, value_definitions, directives
      end

      class EnumValueDefinition < Node
        getter name : String
        getter description : String?
        getter directives : Array(Directive)

        def initialize(@name, @description = nil, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end

        def_equals_and_hash name, directives
      end

      class InputObjectTypeDefinition < TypeDefinition
        getter name : String
        getter description : String?
        getter directives : Array(Directive)
        getter fields : Array(InputValueDefinition)

        def initialize(@name, @description = nil, @directives = [] of Directive, @fields = [] of InputValueDefinition)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class DirectiveDefinition < Node
        getter name : String
        getter description : String?
        getter repeatable : Bool
        getter arguments_definitions : Array(InputValueDefinition)
        getter directive_locations : Array(DirectiveLocation)

        def initialize(@name, @description = nil, @repeatable = false, @arguments_definitions = [] of InputValueDefinition, @directive_locations = [] of DirectiveLocation)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          arguments_definitions.each do |arguments_definition|
            arguments_definition.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash name, arguments_definitions, directive_locations
      end

      class ArgumentsDefintion < Node
        getter input_value_definitions : Array(InputValueDefinition)

        def initialize(@input_value_definitions = [] of InputValueDefinition)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          input_value_definitions.each do |input_value_definition|
            input_value_definition.accept(visitor)
          end

          visitor.leave(self)
        end

        def_equals_and_hash input_value_definitions
      end
    end
  end
end
