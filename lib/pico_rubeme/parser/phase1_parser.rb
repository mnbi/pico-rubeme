# frozen_string_literal: true

module PicoRubeme

  module Parser

    class Phase1Parser < Component
      include AST
      include Utils

      def parse(lexer)
        return [] if lexer.nil?
        parse_expression(lexer)
      end

      # :stopdoc:
      private

      def parse_expression(lexer)
        if start_delimiter?(lexer.peek)
          parse_compound_expression(lexer)
        else
          parse_simple_expression(lexer)
        end
      end

      TOKEN_START_DELIMITERS = [  # :nodoc:
        :lparen,                  # list: ( ... )
        :vec_lparen,              # vector: #( ... )
        :bytevec_lparen,          # bytevector: #u8( ... )
        :quotation,               # quotation: '<something>
        :backquote,               # quasiquote: `<something>
        :comma,                   # used in quasiquote
        :comma_at,                # used in quasiquote
        :comment_lparen,          # comment start
      ]

      def start_delimiter?(token)
        TOKEN_START_DELIMITERS.include?(token.type)
      end

      def parse_simple_expression(lexer)
        type, literal = *lexer.next
        [simple_type(type), literal]
      end

      def simple_type(token_type)
        case token_type
        when :identifier
          tag("identifier")
        when :boolean, :character, :number, :string
          tag("#{token_type}")
        when :dot
          tag("dot")
        else
          tag("illegal")
        end
      end

      def parse_compound_expression(lexer)
        case lexer.peek.type
        when :vec_lparen
          parse_vector(lexer)
        when :quotation
          parse_quotation(lexer)
        when :lparen
          parse_list(lexer)
        else
          raise SchemeSyntaxError, "%s" % lexer.peek.literal
        end
      end

      def parse_list(lexer)
        if lexer.peek(1).type == :rparen
          # an empty list
          lexer.skip_rparen(1)
          ["*empty_list*"]
        else
          parse_container([], lexer)
        end
      end

      def parse_vector(lexer)
        parse_container(["*vector*"], lexer)
      end

      def parse_container(container, lexer)
        lexer.skip              # skip :lparen or :vec_lparen
        Kernel.loop {
          break if lexer.peek.type == :rparen
          container << parse_expression(lexer)
        }
        lexer.skip_rparen
        container
      end

      def parse_quotation(lexer)
        lexer.skip              # skip "'" (quotation mark)
        exp = parse_expression(lexer)
        [[simple_type(:identifier), "quote"], exp]
      end

      # :startdoc:
    end
  end

end
