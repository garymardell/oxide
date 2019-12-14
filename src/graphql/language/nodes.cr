module Graphql
  module Language
    module Nodes
      alias Value = String | Int32 | Int64 | Float64 | Bool | Nil | Array(Value) | Hash(String, Value)

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

        def initialize(@operation_type, @selections = [] of Selection)
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
        property value : Value
        
        def initialize(@name, @value)
        end
      end
    end
  end
end
