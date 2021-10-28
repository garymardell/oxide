require "./visitable"

module Graphene
  module Language
    module Nodes
      alias ValueType = String | Int32 | Int64 | Float64 | Bool | Nil | Array(ValueType) | Hash(String, ValueType) | Variable

      alias TypeDefinition = ScalarTypeDefinition | ObjectTypeDefinition | InterfaceTypeDefinition | UnionTypeDefinition | EnumTypeDefinition | InputObjectTypeDefinition
      alias Definition = OperationDefinition | FragmentDefinition | SchemaDefinition | TypeDefinition
      alias Selection = Field | FragmentSpread

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

          visitor.exit(self)
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

          visitor.exit(self)
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

          visitor.exit(self)
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

          visitor.exit(self)
        end
      end

      class SchemaDefinition < Node
        property operation_type_definitions : Array(OperationTypeDefinition)

        def initialize(@operation_type_definitions = [] of OperationTypeDefinition)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          operation_type_definitions.each do |operation_type_definition|
            operation_type_definition.accept(visitor)
          end

          visitor.exit(self)
        end
      end

      class OperationTypeDefinition < Node
        property operation_type : String
        property named_type : NamedType?

        def initialize(@operation_type, @named_type = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.exit(self)
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

          visitor.exit(self)
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

          visitor.exit(self)
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

          visitor.exit(self)
        end
      end

      class Argument < Node
        property name : String
        property value : Value?

        def initialize(@name, @value = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.exit(self)
        end
      end

      class VariableDefinition < Node
        property variable : Variable?
        #  property type : # TODO:  NamedType, ListType, NonNullType
        property type : Type?
        property default_value : Value? # TODO: Support default value
        # getter? has_default_value : Bool

        def initialize(@variable = nil, @type = nil, @default_value = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless variable.nil?
            variable.not_nil!.accept(visitor)
          end

          visitor.exit(self)
        end
      end

      class Variable < Node
        property name : String

        def initialize(@name)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.exit(self)
        end
      end


      class Type < Node
        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.exit(self)
        end
      end

      class NamedType < Type
        property name : String

        def initialize(@name)
        end
      end

      class ListType < Type
        property of_type : NamedType | ListType | Nil

        def initialize(@of_type = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless of_type.nil?
            of_type.not_nil!.accept(visitor)
          end

          visitor.exit(self)
        end
      end

      class NonNullType < Type
        property of_type : NamedType | ListType | Nil

        def initialize(@of_type = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless of_type.nil?
            of_type.not_nil!.accept(visitor)
          end

          visitor.exit(self)
        end
      end

      class Value < Node
        property value : ValueType

        def initialize(@value)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          visitor.exit(self)
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

          visitor.exit(self)
        end
      end

      class ScalarTypeDefinition < Node
        property name : String

        def initialize(@name)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.exit(self)
        end
      end

      class ObjectTypeDefinition < Node
        property name : String
        property implements : Array(NamedType)
        property field_definitions : Array(FieldDefinition)

        def initialize(@name, @implements = [] of NamedType, @field_definitions = [] of FieldDefinition)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          implements.each do |implement|
            implement.accept(visitor)
          end

          field_definitions.each do |field_definition|
            field_definition.accept(visitor)
          end

          visitor.exit(self)
        end
      end

      class FieldDefinition < Node
        property name : String
        property argument_definitions : Array(InputValueDefinition)
        property type : NamedType | ListType | NonNullType | Nil

        def initialize(@name, @argument_definitions = [] of InputValueDefinition, @type = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          argument_definitions.each do |argument_definition|
            argument_definition.accept(visitor)
          end

          unless type.nil?
            type.not_nil!.accept(visitor)
          end

          visitor.exit(self)
        end
      end

      class InputValueDefinition < Node
        property name : String
        property type : NamedType | ListType | NonNullType | Nil
        property default_value : Value | Nil

        def initialize(@name, @type = nil, @default_value = nil)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          unless type.nil?
            type.not_nil!.accept(visitor)
          end

          visitor.exit(self)
        end
      end

      class InterfaceTypeDefinition < Node
        property name : String
        property field_definitions : Array(FieldDefinition)

        def initialize(@name, @field_definitions = [] of FieldDefinition)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          field_definitions.each do |field_definition|
            field_definition.accept(visitor)
          end

          visitor.exit(self)
        end
      end

      class UnionTypeDefinition < Node
        property name : String
        property member_types : Array(NamedType)

        def initialize(@name, @member_types = [] of NamedType)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          member_types.each do |member_type|
            member_type.accept(visitor)
          end

          visitor.exit(self)
        end
      end

      class EnumTypeDefinition < Node
        property name : String
        property value_definitions : Array(EnumValueDefinition)

        def initialize(@name, @value_definitions = [] of EnumValueDefinition)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)

          value_definitions.each do |value_definition|
            value_definition.accept(visitor)
          end

          visitor.exit(self)
        end
      end

      class EnumValueDefinition < Node
        property name : String

        def initialize(@name)
        end

        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.exit(self)
        end
      end

      class InputObjectTypeDefinition < Node
        def accept(visitor : Visitor)
          visitor.enter(self)
          visitor.exit(self)
        end
      end
    end
  end
end
