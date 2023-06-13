require "./visitable"

module Oxide
  module Language
    module Nodes
      alias Type = NamedType | ListType | NonNullType
      alias TypeDefinition = ScalarTypeDefinition | ObjectTypeDefinition | InterfaceTypeDefinition | UnionTypeDefinition | EnumTypeDefinition | InputObjectTypeDefinition
      alias Definition = OperationDefinition | FragmentDefinition | SchemaDefinition | TypeDefinition | DirectiveDefinition
      alias Selection = Field | FragmentSpread | InlineFragment
      alias DirectiveLocation = String

      alias ValueType = String | Int32 | Float32 | Bool | Nil | Array(Value) | Hash(String, Value) | Variable

      abstract class Node
        include Visitable

        property beginLine : Int32?
        property beginColumn : Int32?
        property endLine : Int32?
        property endColumn : Int32?
      end

      class Document < Node
        property definitions : Array(Definition)

        def initialize(@definitions = [] of Definition)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          definitions.each do |definition|
            definition.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class OperationDefinition < Node
        property name : String?
        property operation_type : String
        property selection_set : SelectionSet?
        property variable_definitions : Array(VariableDefinition)
        property directives : Array(Directive)

        def initialize(@operation_type, @name = nil, @selection_set = nil, @variable_definitions = [] of VariableDefinition, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless selection_set.nil?
            selection_set.not_nil!.accept(visitor)
          end

          variable_definitions.each do |variable_definition|
            variable_definition.accept(visitor)
          end

          directives.each do |directive|
            directive.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class SelectionSet < Node
        property selections : Array(Selection)

        def initialize(@selections = [] of Selection)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          selections.each do |selection|
            selection.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class FragmentDefinition < Node
        property name : String
        property type_condition : NamedType?
        property selection_set : SelectionSet?
        property directives : Array(Directive)

        def initialize(@name, @type_condition = nil, @selection_set = nil, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless selection_set.nil?
            selection_set.not_nil!.accept(visitor)
          end

          directives.each do |directive|
            directive.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class SchemaDefinition < Node
        property directives : Array(Directive)
        property operation_type_definitions : Array(OperationTypeDefinition)

        def initialize(@operation_type_definitions = [] of OperationTypeDefinition, @directives = [] of Directive)
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
      end

      class OperationTypeDefinition < Node
        property operation_type : String
        property named_type : NamedType?

        def initialize(@operation_type, @named_type = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class FragmentSpread < Node
        property name : String
        property directives : Array(Directive)

        def initialize(@name, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          directives.each do |directive|
            directive.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class InlineFragment < Node
        property type_condition : NamedType?
        property selection_set : SelectionSet?
        property directives : Array(Directive)

        def initialize(@type_condition = nil, @selection_set = nil, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          directives.each do |directive|
            directive.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class Field < Node
        property alias : String?
        property name : String
        property arguments : Array(Argument)
        property selection_set : SelectionSet?
        property directives : Array(Directive)

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
      end

      class Argument < Node
        property name : String
        property value : Value?

        def initialize(@name, @value = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class VariableDefinition < Node
        property variable : Variable?
        property type : Type?
        property default_value : Value?

        def initialize(@variable = nil, @type = nil, @default_value = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless variable.nil?
            variable.not_nil!.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class NamedType < Node
        property name : String

        def initialize(@name)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class ListType < Node
        property of_type : NamedType | ListType | Nil

        def initialize(@of_type = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless of_type.nil?
            of_type.not_nil!.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class NonNullType < Node
        property of_type : NamedType | ListType | Nil

        def initialize(@of_type = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless of_type.nil?
            of_type.not_nil!.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      abstract class Value < Node
        abstract def value

        def accept(visitor : Visitor)
          visitor.enter(self)

          visitor.leave(self)
        end
      end

      class StringValue < Value
        property value : String

        def initialize(@value)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class Variable < Value
        property name : String

        def initialize(@name)
        end

        def value
          name
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class IntValue < Value
        property value : Int32

        def initialize(@value)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class FloatValue < Value
        property value : Float32

        def initialize(@value)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class BooleanValue < Value
        property value : Bool

        def initialize(@value)
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

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class EnumValue < Value
        property value : String

        def initialize(@value)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class ListValue < Value
        property values : Array(Value)

        def initialize(@values = [] of Value)
        end

        def value
          values
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          visitor.leave(self)
        end
      end

      class ObjectValue < Value
        property fields : Array(ObjectField)

        def initialize(@fields = [] of ObjectField)
        end

        def value
          fields.reduce({} of String => Value) do |memo, field|
            memo[field.name] = field.value
            memo
          end
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          fields.each do |field|
            field.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class ObjectField < Node
        property name : String
        property value : Value

        def initialize(@name, @value)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          visitor.leave(self)
        end
      end

      class Directive < Node
        property name : String
        property arguments : Array(Argument)

        def initialize(@name, @arguments = [] of Argument)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          arguments.each do |argument|
            argument.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class ScalarTypeDefinition < Node
        property name : String
        property directives : Array(Directive)

        def initialize(@name, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class ObjectTypeDefinition < Node
        property name : String
        property implements : Array(NamedType)
        property directives : Array(Directive)
        property field_definitions : Array(FieldDefinition)

        def initialize(@name, @implements = [] of NamedType, @directives = [] of Directive, @field_definitions = [] of FieldDefinition)
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
      end

      class FieldDefinition < Node
        property name : String
        property argument_definitions : Array(InputValueDefinition)
        property type : NamedType | ListType | NonNullType | Nil
        property directives : Array(Directive)

        def initialize(@name, @argument_definitions = [] of InputValueDefinition, @type = nil, @directives = [] of Directive)
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
      end

      class InputValueDefinition < Node
        property name : String
        property type : NamedType | ListType | NonNullType | Nil
        property default_value : Value | Nil
        property directives : Array(Directive)

        def initialize(@name, @type = nil, @default_value = nil, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless type.nil?
            type.not_nil!.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class InterfaceTypeDefinition < Node
        property name : String
        property field_definitions : Array(FieldDefinition)
        property directives : Array(Directive)

        def initialize(@name, @field_definitions = [] of FieldDefinition, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          field_definitions.each do |field_definition|
            field_definition.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class UnionTypeDefinition < Node
        property name : String
        property member_types : Array(NamedType)
        property directives : Array(Directive)

        def initialize(@name, @member_types = [] of NamedType, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          member_types.each do |member_type|
            member_type.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class EnumTypeDefinition < Node
        property name : String
        property value_definitions : Array(EnumValueDefinition)
        property directives : Array(Directive)

        def initialize(@name, @directives = [] of Directive, @value_definitions = [] of EnumValueDefinition)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          value_definitions.each do |value_definition|
            value_definition.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class EnumValueDefinition < Node
        property name : String
        property directives : Array(Directive)

        def initialize(@name, @directives = [] of Directive)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class InputObjectTypeDefinition < Node
        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.leave(self)
        end
      end

      class DirectiveDefinition < Node
        property name : String
        property arguments_definitions : Array(InputValueDefinition)
        property directive_locations : Array(DirectiveLocation)

        def initialize(@name, @arguments_definitions = [] of InputValueDefinition, @directive_locations = [] of DirectiveLocation)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          arguments_definitions.each do |arguments_definition|
            arguments_definition.accept(visitor)
          end

          visitor.leave(self)
        end
      end

      class ArgumentsDefintion < Node
        property input_value_definitions : Array(InputValueDefinition)

        def initialize(@input_value_definitions = [] of InputValueDefinition)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          input_value_definitions.each do |input_value_definition|
            input_value_definition.accept(visitor)
          end

          visitor.leave(self)
        end
      end
    end
  end
end
