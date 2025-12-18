module Oxide
  module Language
    class Token
      enum Kind
        Bang
        Dollar
        Amp
        LParen
        RParen
        Spread
        Colon
        Equals
        At
        LBracket
        RBracket
        Pipe
        LBrace
        RBrace
        QuestionMark
        String
        Int
        Float
        Name
        EOF
      end

      property kind : Kind
      property raw_value : String
      property line_number : Int32
      property column_number : Int32
      property block_string : Bool

      def initialize
        @kind = :EOF
        @line_number = 0
        @column_number = 0
        @raw_value = ""
        @block_string = false
      end

      def int_value : Int64
        raw_value.to_i64
      rescue exc : ArgumentError
        raise "parsing error"
      end

      def float_value : Float64
        raw_value.to_f64
      rescue exc : ArgumentError
        raise "parsing error"
      end

      def_equals_and_hash kind, raw_value
    end
  end
end