module Oxide
  module Language
    class Printer
      private getter io : IO
      private getter query : Oxide::Query

      SPACE = "  "

      def initialize(@io : IO, @query : Oxide::Query)
      end

      def print
        @query.document.definitions.each do |definition|
          print_node(definition, 0)
        end
      end

      def print_node(node : Nodes::OperationDefinition, level)
        if node.name
          io << "query " << node.name
        else
          io << node.operation_type
        end

        if node.variable_definitions.any?
          io << " ("
          node.variable_definitions.each_with_index(1) do |definition, index|
            print(definition, level)
            io << ", " if index < node.variable_definitions.size
          end
          io << ")"
        end

        if node.directives.any?
          io << " "
          node.directives.each_with_index(1) do |directive, index|
            print(directive, level)
            io << " " if index < node.directives.size
          end
        end

        print(node.selection_set, level)
      end

      def print_node(node : Nodes::VariableDefinition, level)
        io << "$" << node.variable.name << ": "
        node.type.to_s(io)
      end

      def print_node(node : Nodes::Directive, level)
        io << "@" << node.name

        if node.arguments.any?
          io << " ("
          node.arguments.each_with_index(1) do |argument, index|
            print(argument, level)
            io << ", " if index < node.arguments.size
          end
          io << ")"
        end
      end

      def print_node(node : Nodes::Argument, level)
        io << node.name << ": "
        node.value.to_s(io)
      end

      def print_node(node : Nodes::SelectionSet, level)
        io << " {\n"

        node.selections.each do |selection|
          print(selection, level + 1)
          io << "\n"
        end

        io << SPACE * level
        io << "}"
      end

      def print_node(node : Nodes::Field, level)
        io << SPACE * level

        if name = node.alias
          io << name << ": "
        end

        io << node.name

        if node.arguments.any?
          io << " ("
          node.arguments.each_with_index(1) do |argument, index|
            print(argument, level)
            io << ", " if index < node.arguments.size
          end
          io << ")"
        end

        if node.directives.any?
          io << " "
          node.directives.each_with_index(1) do |directive, index|
            print(directive, level)
            io << " " if index < node.directives.size
          end
        end

        if selection_set = node.selection_set
          print(selection_set, level)
        end
      end

      def print_node(node : Nodes::FragmentSpread, level)
      end

      def print_node(node : Nodes::InlineFragment, level)
        if type_condition = node.type_condition
          io << "... on " << type_condition.name
        else
          io << "..."
        end

        if node.directives.any?
          io << " "
          node.directives.each_with_index(1) do |directive, index|
            print(directive, level)
            io << " " if index < node.directives.size
          end
        end

        print(node.selection_set, level)
      end

      def print_node(node, level)
      end
    end
  end
end