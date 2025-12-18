module Oxide
  module Language
    class Lexer
      getter token : Token

      def initialize(input : String, @max_tokens : Int32? = nil)
        @reader = Char::Reader.new(input)
        @token = Token.new
        @token_count = 0
        @line_number = 1
        @column_number = 1
      end

      def next_token : Token
        increment_and_validate_max_tokens
        skip_whitespace

        @token.line_number = @line_number
        @token.column_number = @column_number

        case current_char
        when '\0'
          @token.kind = :EOF
        when '!'
          next_char :bang
        when '$'
          next_char :dollar
        when '&'
          next_char :amp
        when '('
          next_char :l_paren
        when ')'
          next_char :r_paren
        when '.'
          # If the next two values are . then we have a spread
          if next_char == '.' && next_char == '.'
            next_char
            @token.kind = :spread
          end
        when ':'
          next_char :colon
        when '='
          next_char :equals
        when '@'
          next_char :at
        when '['
          next_char :l_bracket
        when ']'
          next_char :r_bracket
        when '|'
          next_char :pipe
        when '{'
          next_char :l_brace
        when '}'
          next_char :r_brace
        when '?'
          next_char :question_mark
        when '"'
          consume_string
        when '#'
          skip_comment
          next_token
        else
          if current_char.ascii_number? || current_char == '-'
            consume_number
            return @token
          end

          if start_of_name?(current_char)
            consume_name
          else
            if current_char == '\''
              raise "Unexpected single quote character (\'), did you mean to use a double quote (\")?"
            else
              raise "Unexpected character: #{current_char}"
            end
          end
        end

        @token
      end

      def consume_number
        is_float = false

        value = String.build do |io|
          # If negative we should consume
          if current_char == '-'
            io << current_char
            next_char
          end

          if current_char == '0'
            # Check that the following number isn't a digit
            io << current_char
            next_char

            if current_char.ascii_number?
              raise "Invalid number, unexpected digit after 0: #{current_char}"
            end
          else
            read_digits(io)
          end

          if current_char == '.'
            is_float = true
            io << current_char
            next_char
            read_digits(io)
          end

          if current_char == 'E' || current_char == 'e'
            is_float = true
            io << current_char
            next_char

            if current_char == '+' || current_char == '-'
              io << current_char
              next_char
            end

            read_digits(io)
          end

          if current_char == '.' || start_of_name?(current_char)
            raise "Invalid number, expected digit but got: #{current_char}"
          end
        end

        @token.kind = is_float ? Token::Kind::Float : Token::Kind::Int
        @token.raw_value = value
      end

      def read_digits(io : IO)
        unless current_char.ascii_number?
          raise "Invalid number, expected digit but got: #{current_char}"
        end

        while current_char.ascii_number?
          io << current_char
          next_char
        end
      end

      def current_char
        @reader.current_char
      end

      def consume_string
        @token.kind = :string
        # If the next 2 characters are also '"' then it is a block string
        is_quote = next_char == '"'

        if is_quote
          if next_char == '"'
            @token.block_string = true
            consume_block_string
          else
            @token.block_string = false
            @token.raw_value = ""
            return
          end
        else
          @token.block_string = false
          consume_simple_string
        end

        next_char
      end

      def consume_simple_string(initial_char : Char? = nil)
        @token.raw_value = String.build do |io|
          io << initial_char if initial_char

          while current_char != 0x000A.unsafe_chr && current_char != 0x00D.unsafe_chr && current_char != '"'
            if current_char < 0x0020.unsafe_chr && current_char != 0x0009.unsafe_chr
              raise "Invalid character within string: #{current_char}"
            end

            # Handle escaped characters
            if current_char == '\\'
              next_char

              case current_char
              when '"'
                io << '"'
                next_char
              when '\\'
                io << '\\'
                next_char
              when '/'
                io << '/'
                next_char
              when 'b'
                io << '\b'
                next_char
              when 'f'
                io << '\f'
                next_char
              when 'n'
                io << '\n'
                next_char
              when 'r'
                io << '\r'
                next_char
              when 't'
                io << '\t'
                next_char
              when 'u'
                io << parse_unicode_escape
              else
                raise "Invalid character escape sequence: \\#{current_char}"
              end
            else
              io << current_char
              next_char
            end
          end
        end
      end

      def parse_unicode_escape : Char
        next_char
        
        # Check if it's variable-width format \u{...}
        if current_char == '{'
          next_char
          hex_string = String.build do |hex_io|
            while current_char != '}' && current_char != '\0'
              unless current_char.hex?
                raise "Invalid unicode escape sequence: expected hexadecimal digit"
              end
              hex_io << current_char
              next_char
            end
          end
          
          if current_char != '}'
            raise "Invalid unicode escape sequence: expected }"
          end
          next_char
          
          if hex_string.empty?
            raise "Invalid unicode escape sequence: empty"
          end
          
          code_point = hex_string.to_i(16)
          validate_unicode_scalar(code_point)
          code_point.chr
        else
          # Fixed-width format \uXXXX
          hex_chars = String.build do |hex_io|
            4.times do
              unless current_char.hex?
                raise "Invalid unicode escape sequence: expected 4 hexadecimal digits"
              end
              hex_io << current_char
              next_char
            end
          end
          
          code_point = hex_chars.to_i(16)
          
          # Check for surrogate pairs
          if code_point >= 0xD800 && code_point <= 0xDBFF
            # Leading surrogate, expect trailing surrogate
            unless current_char == '\\' && next_char == 'u'
              raise "Invalid unicode escape sequence: unpaired surrogate"
            end
            next_char # consume 'u'
            
            trailing_hex = String.build do |hex_io|
              4.times do
                unless current_char.hex?
                  raise "Invalid unicode escape sequence: expected 4 hexadecimal digits"
                end
                hex_io << current_char
                next_char
              end
            end
            
            trailing_code_point = trailing_hex.to_i(16)
            
            unless trailing_code_point >= 0xDC00 && trailing_code_point <= 0xDFFF
              raise "Invalid unicode escape sequence: expected trailing surrogate"
            end
            
            # Combine surrogate pair
            combined = (code_point - 0xD800) * 0x400 + (trailing_code_point - 0xDC00) + 0x10000
            return combined.chr
          elsif code_point >= 0xDC00 && code_point <= 0xDFFF
            # Unpaired trailing surrogate
            raise "Invalid unicode escape sequence: unpaired trailing surrogate"
          else
            validate_unicode_scalar(code_point)
            code_point.chr
          end
        end
      end

      def validate_unicode_scalar(code_point : Int32)
        unless (code_point >= 0 && code_point <= 0xD7FF) || (code_point >= 0xE000 && code_point <= 0x10FFFF)
          raise "Invalid unicode escape sequence: code point out of range or invalid"
        end
      end

      def consume_block_string
        @token.raw_value = String.build do |io|
          quote_count = 0
          next_char

          while current_char != '\0'
            # We terminate when we get either a end of input or 3 '"' in a row
            if current_char == '"'
              quote_count += 1

              if quote_count == 3
                break
              else
                next_char
              end
            elsif current_char == '\\'
              # Check for escaped triple quotes
              quote_count.times { io << '"' }
              quote_count = 0
              
              next_char
              if current_char == '"' && next_char == '"' && next_char == '"'
                io << "\"\"\""
                next_char
              else
                io << '\\'
                io << current_char
                next_char
              end
            else
              quote_count.times { io << '"' }
              quote_count = 0

              io << current_char
              next_char
            end
          end
        end
      end

      def consume_name
        # Iterate through characters until non name or end
        value = String.build do |io|
          while current_char.ascii_alphanumeric? || current_char == '_'
            io << current_char
            next_char
          end
        end

        @token.kind = :name
        @token.raw_value = value
      end

      private def start_of_name?(character)
        character.ascii_letter? || character == '_'
      end

      private def next_char
        @column_number += 1

        char = @reader.next_char
        if char == '\0' && @reader.pos != @reader.string.bytesize
          raise "Unexpectedly reached the end of input"
        end
        char
      end

      private def next_char(kind : Token::Kind)
        @token.kind = kind
        next_char
      end

      private def skip_comment
        if current_char == '#'
          next_char

          # Read the comment
          while current_char != '\0'
            if current_char == '\n' || current_char == '\r'
              @line_number += 1
              @column_number = 0
              break
            end

            if current_char.ascii_control?
              break
            end

            next_char
          end
        end
      end

      private def skip_whitespace
        while whitespace?(current_char) || current_char == ','
          if current_char == '\n'
            @line_number += 1
            @column_number = 0
          end
          next_char
        end
      end

      private def whitespace?(char)
        case char
        when ' ', '\t', '\n', '\r'
          true
        else
          false
        end
      end

      private def increment_and_validate_max_tokens
        return unless @max_tokens

        @token_count += 1

        if @token_count > @max_tokens.not_nil!
          raise "Document contains more than #{@max_tokens} tokens"
        end
      end

      private def raise(message)
        ::raise ParseError.new("Syntax Error: #{message}", [Location.new(@line_number, @column_number)])
      end
    end
  end
end