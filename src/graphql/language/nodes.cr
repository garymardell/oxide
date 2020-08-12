module Graphql
  module Language
    module Nodes
      alias ValueType = String | Int32 | Int64 | Float64 | Bool | Nil | Array(ValueType) | Hash(String, ValueType) | Variable

      alias Definition = OperationDefinition | FragmentDefinition
      alias Selection = Field | FragmentSpread

      abstract class Node
      end

      class Document < Node
        property definitions : Array(Definition)

        def initialize(@definitions = [] of Definition)
        end
      end

      class OperationDefinition < Node
        property operation_type : String
        property selections : Array(Selection)
        property variable_definitions : Array(VariableDefinition)

        def initialize(@operation_type, @selections = [] of Selection, @variable_definitions = [] of VariableDefinition)
        end
      end

      class FragmentDefinition < Node
        property name : String
        property type_condition : String | Nil
        property selections : Array(Selection)

        def initialize(@name, @type_condition = nil, @selections = [] of Selection)
        end
      end

      class FragmentSpread < Node
        property name : String

        def initialize(@name)
        end
      end

      class Field < Node
        property name : String
        property arguments : Array(Argument)
        property selections : Array(Selection)

        def initialize(@name, @arguments = [] of Argument, @selections = [] of Selection)
        end
      end

      class Argument < Node
        property name : String
        property value : ValueType

        def initialize(@name, @value)
        end
      end

      class VariableDefinition < Node
        property variable : Variable
        #  property type : # TODO:  NamedType, ListType, NonNullType
        property type : Type
        property default_value : Value? # TODO: Support default value
        # getter? has_default_value : Bool

        def initialize(@variable, @type, @default_value = nil)
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
        property of_type : NamedType | ListType

        def initialize(@of_type)
        end
      end

      class Value < Node
        property value : ValueType

        def initialize(@value)
        end
      end
    end
  end
end
