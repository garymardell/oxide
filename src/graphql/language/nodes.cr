module Graphql
  module Language
    module Nodes
      alias Value = String | Int32 | Int64 | Float64 | Bool | Nil | Array(Value) | Hash(String, Value)

      abstract class Node
      end

      class Document < Node
        property definitions : Array(OperationDefinition)

        def initialize(@definitions = [] of OperationDefinition)
        end
      end

      class OperationDefinition < Node
        property operation_type : String
        property selections : Array(Field)

        def initialize(@operation_type, @selections = [] of Field)
        end
      end

      class Field < Node
        property name : String
        property arguments : Array(Argument)
        property selections : Array(Field)

        def initialize(@name, @arguments = [] of Argument, @selections = [] of Field)
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
