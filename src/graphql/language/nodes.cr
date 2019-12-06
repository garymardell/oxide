module Graphql
  module Language
    module Nodes
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
        property selections : Array(Field)

        def initialize(@name, @selections = [] of Field)
        end
      end
    end
  end
end
