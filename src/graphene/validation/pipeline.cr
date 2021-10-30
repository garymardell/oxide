require "./rule"
require "./rules/**"
require "../language/visitor"

module Graphene
  module Validation
    class Pipeline < Graphene::Language::Visitor
      property errors : Array(Error)

      private getter rules : Array(Rule)
      private getter schema : Graphene::Schema
      private getter query : Graphene::Query

      private getter context : Context

      def initialize(@schema, @query, rules = nil)
        @errors = [] of Error
        @rules = rules || all_rules
        @context = Context.new(
          schema,
          query
        )
      end

      def enter(node)
        case node
        when Graphene::Language::Nodes::SelectionSet
          named_type = named_type(context.type)

          context.parent_type_stack << named_type
        when Graphene::Language::Nodes::Field
          parent_type = context.parent_type

          field_definition = if parent_type
            field_definition(parent_type, node.name)
          end

          context.field_definition_stack << field_definition

          if field_definition
            context.type_stack << field_definition.type
          else
            context.type_stack << nil
          end
        when Graphene::Language::Nodes::Directive
          # TODO: Support directives
        when Graphene::Language::Nodes::OperationDefinition
          type = case node.operation_type
          when "query"
            schema.query
          when "mutation"
            schema.mutation
          else
            nil
          end

          context.type_stack << type
        when Graphene::Language::Nodes::InlineFragment
          type_condition = node.type_condition

          type = if type_condition
            schema.get_type_from_ast(type_condition)
          else
            context.type
          end

          context.type_stack << type
        when Graphene::Language::Nodes::FragmentDefinition
          type_condition = node.type_condition

          type = if type_condition
            begin
              schema.get_type_from_ast(type_condition)
            rescue KeyError
            end
          else
            context.type
          end

          context.type_stack << type
        when Graphene::Language::Nodes::VariableDefinition
          # TODO: get type from ast node.type
          # Append to input type stack
        when Graphene::Language::Nodes::Argument
          name = node.name

          # TODO: Support directives

          argument =  if field_definition = context.field_definition
            field_definition.arguments.find { |arg| arg.name == name }
          end

          argument_type = if argument
            argument.type
          end

          context.argument = argument
          context.input_type_stack << argument_type
        when Graphene::Language::Nodes::ListType
          list_type = if context.input_type.is_a?(Graphene::Types::NonNull)
            context.input_type.as(Graphene::Types::NonNull).of_type
          else
            context.input_type
          end

          case list_type
          when Graphene::Types::List
            context.input_type_stack << list_type.of_type
          else
            context.input_type_stack << nil
          end
        end

        rules.each do |rule|
          rule.enter(node, context)
        end
      end

      def exit(node)
        case node
        when Graphene::Language::Nodes::SelectionSet
          context.parent_type_stack.pop?
        when Graphene::Language::Nodes::Field
          context.field_definition_stack.pop?
          context.type_stack.pop?
        when Graphene::Language::Nodes::Directive
          # TODO: Support directives
        when Graphene::Language::Nodes::OperationDefinition, Graphene::Language::Nodes::InlineFragment, Graphene::Language::Nodes::FragmentDefinition
          context.type_stack.pop?
        when Graphene::Language::Nodes::VariableDefinition
          context.input_type_stack.pop?
        when Graphene::Language::Nodes::Argument
          context.argument = nil
          context.input_type_stack.pop?
        when Graphene::Language::Nodes::ListType
          context.input_type_stack.pop?
        end

        rules.each do |rule|
          rule.exit(node, context)
        end
      end

      def execute
        query.accept(self)

        rules.each do |rule|
          errors.concat rule.errors
        end
      end

      def errors?
        errors.any?
      end

      private def named_type(type)
        case type
        when Graphene::Types::List
          type.of_type
        when Graphene::Types::NonNull
          type.of_type
        else
          type
        end
      end

      private def field_definition(parent_type : Graphene::Types::Object, field_name)
        if field_name == "__schema" && parent_type == schema.query
          # Return a fake field definition?
        end

        if field_name == "__type" && parent_type == schema.query
          # Return a fake field definition?
        end

        if field_name == "__typename"
          # Return a fake field definition?
        end

        parent_type.fields.find { |field| field.name == field_name }
      end

      private def field_definition(parent_type, field_name)
        nil
      end

      private def all_rules
        [
          # Operations
          OperationNameUniqueness.new.as(Rule),
          LoneAnonymousOperation.new.as(Rule),
          # Fields
          # Arguments
          # Fragments
          FragmentNameUniqueness.new.as(Rule),
          FragmentsMustBeUsed.new.as(Rule),
          # Values
          # Directives
          # Variables
          VariableUniqueness.new.as(Rule)
        ]
      end
    end
  end
end