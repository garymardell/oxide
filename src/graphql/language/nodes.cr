require "./visitable"

module Graphql
  module Language
    module Nodes
      alias ValueType = String | Int32 | Int64 | Float64 | Bool | Nil | Array(ValueType) | Hash(String, ValueType) | Variable

      alias Definition = OperationDefinition | FragmentDefinition
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
          visitor.visit(self)

          definitions.each do |definition|
            definition.accept(visitor)
          end
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
          visitor.visit(self)

          unless selection_set.nil?
            selection_set.not_nil!.accept(visitor)
          end

          variable_definitions.each do |variable_definition|
            variable_definition.accept(visitor)
          end

          directives.each do |directive|
            directive.accept(visitor)
          end
        end
      end

      class SelectionSet < Node
        property selections : Array(Selection)

        def initialize(@selections = [] of Selection)
        end

        def accept(visitor : Visitor)
          visitor.visit(self)

          selections.each do |selection|
            selection.accept(visitor)
          end
        end
      end

      class FragmentDefinition < Node
        property name : String
        property type_condition : NamedType?
        property selection_set : SelectionSet?
        property directives : Array(Directive)

        def initialize(@name, @type_condition = nil, @selection_set = nil, @directives = [] of Directive)
        end
      end

      class FragmentSpread < Node
        property name : String
        property directives : Array(Directive)

        def initialize(@name, @directives = [] of Directive)
        end
      end

      class InlineFragment < Node
        property type_condition : NamedType?
        property selection_set : SelectionSet?
        property directives : Array(Directive)

        def initialize(@type_condition = nil, @selection_set = nil, @directives = [] of Directive)
        end
      end

      class Field < Node
        property name : String
        property arguments : Array(Argument)
        property selection_set : SelectionSet?
        property directives : Array(Directive)

        def initialize(@name, @arguments = [] of Argument, @selection_set = nil, @directives = [] of Directive)
        end

        # TODO: Re-serailize errors properly
        def to_json_object_key
          name
        end
      end

      class Argument < Node
        property name : String
        property value : Value?

        def initialize(@name, @value = nil)
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
      end

      class Variable < Node
        property name : String

        def initialize(@name)
        end
      end


      class Type < Node
      end

      class NamedType < Type
        property name : String

        def initialize(@name)
        end
      end

      class ListType < Type
        property of_type : NamedType | ListType

        def initialize(@of_type)
        end
      end

      class NonNullType < Type
        property of_type : NamedType | ListType | Nil

        def initialize(@of_type = nil)
        end
      end

      class Value < Node
        property value : ValueType

        def initialize(@value)
        end
      end

      class Directive < Node
        property name : String
        property arguments : Array(Argument)

        def initialize(@name, @arguments = [] of Argument)
        end
      end
    end
  end
end
