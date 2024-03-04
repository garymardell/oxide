require "log"
require "./lexer"

module Oxide
  module Language
    class Parser
      delegate token, to: @lexer
      delegate next_token, to: @lexer

      def self.parse(input : String)
        parser = self.new(input)
        parser.parse
      end

      def initialize(input : String)
        @lexer = Lexer.new(input)

        next_token
      end

      macro with_location(method_def)
        def {{method_def.name}}(
          {% for arg in method_def.args %}
            {{ arg.name }}{% if arg.restriction %} : {{ arg.restriction }}{% end %},
          {% end %}
        )
          begin_line = token.line_number
          begin_column = token.column_number

          {{method_def.body}}.tap do |node|
            node.begin_line = begin_line
            node.begin_column = begin_column
          end
        end
      end

      with_location def parse : Nodes::Document
        definitions = [] of Nodes::Definition

        loop do
          definitions << parse_definition

          break if token.kind.eof?
        end

        Nodes::Document.new(definitions: definitions)
      end

      with_location def parse_definition : Nodes::Definition
        if token.kind.l_brace?
          return parse_operation_definition
        end

        # TODO: Process descriptions

        case token.raw_value
        when "query", "mutation", "subscription"
          parse_operation_definition
        when "fragment"
          parse_fragment_definition
        else
          raise "Expected (query, mutation, subscription, fragment), found #{token.raw_value}"
        end
      end

      with_location def parse_operation_definition : Nodes::OperationDefinition
        if token.kind.l_brace?
          return Nodes::OperationDefinition.new(
            operation_type: "query",
            name: nil,
            selection_set: parse_selection_set
          )
        end

        operation = parse_operation_definition_type

        name = nil
        if token.kind.name?
          name = parse_name
        end

        Nodes::OperationDefinition.new(
          operation_type: operation,
          name: name,
          variable_definitions: parse_variable_definitions,
          directives: parse_directives(false),
          selection_set: parse_selection_set
        )
      end

      def parse_operation_definition_type
        operation = token.raw_value
        consume_token(Token::Kind::Name)

        case operation
        when "query", "mutation", "subscription"
          operation
        else
          raise "Expected (query, mutation, subscription), found #{operation}"
        end
      end

      with_location def parse_fragment_definition : Nodes::FragmentDefinition
        expect_current_token(Token::Kind::Name)
        expect_keyword_and_consume("fragment")

        name = parse_fragment_name

        expect_keyword_and_consume("on")

        Nodes::FragmentDefinition.new(
          name: name,
          type_condition: parse_named_type,
          directives: parse_directives(false),
          selection_set: parse_selection_set
        )
      end

      def parse_fragment_name
        if token.raw_value == "on"
          raise_unexpected
        end

        parse_name
      end

      def parse_variable_definitions : Array(Nodes::VariableDefinition)
        definitions = [] of Nodes::VariableDefinition

        unless token.kind.l_paren?
          return definitions
        end

        consume_token(Token::Kind::LParen)

        loop do
          definitions << parse_variable_definition

          break if token.kind.r_paren?
        end

        consume_token(Token::Kind::RParen)

        definitions
      end

      with_location def parse_variable_definition : Nodes::VariableDefinition
        variable = parse_variable
        consume_token(Token::Kind::Colon)
        type = parse_type_reference

        default_value = if token.kind.equals?
          consume_token(Token::Kind::Equals)
          parse_value_literal(true)
        end

        Nodes::VariableDefinition.new(
          variable: variable,
          type: type,
          default_value: default_value
        )
      end

      with_location def parse_type_reference : Nodes::Type
        type = if token.kind.l_bracket?
          consume_token(Token::Kind::LBracket)
          inner_type = parse_type_reference
          consume_token(Token::Kind::RBracket)

          Nodes::ListType.new(
            of_type: inner_type
          )
        else
          parse_named_type
        end

        if token.kind.bang?
          consume_token(Token::Kind::Bang)

          return Nodes::NonNullType.new(
            of_type: type
          )
        end

        type
      end

      with_location def parse_variable : Nodes::Variable
        consume_token(Token::Kind::Dollar)

        Nodes::Variable.new(
          name: parse_name,
        )
      end

      def parse_name
        expect_current_token(Token::Kind::Name)

        token.raw_value.tap do
          next_token
        end
      end

      with_location def parse_selection_set : Nodes::SelectionSet
        selections = [] of Nodes::Selection

        consume_token(Token::Kind::LBrace)
        loop do
          selections << parse_selection
          break if token.kind.r_brace?
        end
        consume_token(Token::Kind::RBrace)

        Nodes::SelectionSet.new(
          selections: selections
        )
      end

      with_location def parse_selection : Nodes::Selection
        if token.kind.spread?
          parse_fragment
        else
          parse_field
        end
      end

      with_location def parse_fragment : Nodes::FragmentSpread | Nodes::InlineFragment
        consume_token(Token::Kind::Spread)

        has_type_condition = if token.kind.name? && token.raw_value == "on"
          next_token
          true
        else
          false
        end

        if !has_type_condition && token.kind.name?
          name = token.raw_value
          next_token

          Nodes::FragmentSpread.new(
            name: name,
            directives: parse_directives(false)
          )
        else
          type_condition = if has_type_condition
            parse_named_type
          end

          Nodes::InlineFragment.new(
            type_condition: type_condition,
            directives: parse_directives(false),
            selection_set: parse_selection_set
          )
        end
      end

      with_location def parse_named_type : Nodes::NamedType
        Nodes::NamedType.new(
          name: parse_name,
        )
      end

      with_location def parse_field : Nodes::Field
        expect_current_token(Token::Kind::Name)
        name_or_alias = token.raw_value
        next_token

        alias_name = nil
        name = nil

        if token.kind.colon?
          alias_name = name_or_alias
          next_token
          expect_current_token(Token::Kind::Name)
          name = token.raw_value
          next_token
        else
          name = name_or_alias
        end

        Nodes::Field.new(
          name: name,
          alias: alias_name,
          arguments: parse_arguments(false),
          directives: parse_directives(false),
          selection_set: if token.kind.l_brace?
            parse_selection_set
          end
        )
      end

      def parse_directives(is_const) : Array(Nodes::Directive)
        directives = [] of Nodes::Directive

        while token.kind.at?
          directives << parse_directive(is_const)
        end

        directives
      end

      with_location def parse_directive(is_const) : Nodes::Directive
        consume_token(Token::Kind::At)

        Nodes::Directive.new(
          name: parse_name,
          arguments: parse_arguments(is_const)
        )
      end

      def parse_arguments(is_const) : Array(Nodes::Argument)
        unless token.kind.l_paren?
          return [] of Nodes::Argument
        end

        consume_token(Token::Kind::LParen)

        arguments = [] of Nodes::Argument

        loop do
          arguments << parse_argument(is_const)

          break if token.kind.r_paren?
        end

        consume_token(Token::Kind::RParen)

        arguments
      end

      with_location def parse_argument(is_const) : Nodes::Argument
        name = parse_name
        consume_token(Token::Kind::Colon)

        Nodes::Argument.new(
          name: name,
          value: parse_value_literal(is_const)
        )
      end

      with_location def parse_value_literal(is_const) : Nodes::Value
        case token.kind
        when .l_bracket?
          parse_list(is_const)
        when .l_brace?
          parse_object(is_const)
        when .int?
          Nodes::IntValue.new(token.int_value).tap { next_token }
        when .float?
          Nodes::FloatValue.new(token.float_value).tap { next_token }
        when .string?
          Nodes::StringValue.new(token.raw_value).tap { next_token }
        when .name?
          # Could actually be a boolean value or null
          case token.raw_value
          when "true"
            Nodes::BooleanValue.new(true).tap { next_token }
          when "false"
            Nodes::BooleanValue.new(false).tap { next_token }
          when "null"
            Nodes::NullValue.new.tap { next_token }
          else
            Nodes::EnumValue.new(token.raw_value).tap { next_token }
          end
        when .dollar?
          if is_const
            next_token
            if token.kind.name?
              variable_name = token.raw_value
              raise "Unexpected variable \"$#{variable_name}\" in constant value."
            else
              raise_unexpected
            end
          end

          parse_variable
        else
          raise_unexpected
        end
      end

      with_location def parse_list(is_const) : Nodes::ListValue
        values = [] of Nodes::Value

        consume_token(Token::Kind::LBracket)
        loop do
          values << parse_value_literal(is_const)
          next_token

          break if token.kind.r_bracket?
        end
        consume_token(Token::Kind::RBracket)

        Nodes::ListValue.new(values: values)
      end

      with_location def parse_object(is_const) : Nodes::ObjectValue
        fields = [] of Nodes::ObjectField

        consume_token(Token::Kind::LBrace)
        loop do
          fields << parse_object_field(is_const)
          break if token.kind.r_brace?
        end
        consume_token(Token::Kind::RBrace)

        Nodes::ObjectValue.new(fields)
      end

      with_location def parse_object_field(is_const) : Nodes::ObjectField
        name = parse_name
        consume_token(Token::Kind::Colon)

        Nodes::ObjectField.new(
          name: name,
          value: parse_value_literal(is_const)
        )
      end

      def consume_token(kind : Token::Kind)
        expect_current_token(kind)
        next_token
      end


      def expect_current_token(kind : Token::Kind)
        unless token.kind == kind
          raise "Expected #{kind}, found #{token.kind}."
        end
      end

      def expect_keyword_and_consume(value : String)
        unless token.raw_value == value
          raise "Expected #{value}, found #{token.raw_value}."
        end

        next_token
      end

      def raise_unexpected
        raise "Unexpected #{token.kind}"
      end

      private def raise(message)
        ::raise ParseException.new("Syntax Error: #{message}", token.line_number, token.column_number)
      end
    end
  end
end