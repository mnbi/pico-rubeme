# frozen_string_literal: true

module PicoRubeme

  module Parser

    class Phase1Parser < Component
      private_include AST
      private_include Utils

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

      TOKEN_START_DELIMITERS = [ # :nodoc:
        "lparen",                # list: ( ... )
        "vec-lparen",            # vector: #( ... )
        "bytevec-lparen",        # bytevector: #u8( ... )
        "quotation",             # quotation: '<something>
        "backquote",             # quasiquote: `<something>
        "comma",                 # used in quasiquote
        "comma-at",              # used in quasiquote
        "comment-lparen",        # comment start
      ]

      def start_delimiter?(token)
        TOKEN_START_DELIMITERS.include?(token_type(token))
      end

      def parse_simple_expression(lexer)
        token = lexer.next
        ast_type = simple_type(token_type(token))
        if ast_type != "illegal"
          make_ast_node(ast_type, token_literal(token))
        else
          raise SchemeSyntaxError, "%s" % token_literal(token)
        end
      end

      SUPPORTED_SIMPLE_TYPES = [ # :nodoc:
        "identifier", "boolean", "character", "number", "string",
        "dot",
      ]

      def simple_type(token_type)
        SUPPORTED_SIMPLE_TYPES.include?(token_type) ? token_type : "illegal"
      end

      def parse_compound_expression(lexer)
        case token_type(lexer.peek)
        when "vec-lparen"
          parse_vector(lexer)
        when "quotation"
          parse_quotation(lexer)
        when "lparen"
          parse_list(lexer)
        else
          raise SchemeSyntaxError, "%s" % token_literal(lexer.peek)
        end
      end

      def parse_list(lexer)
        if token_type?(lexer.peek(1), "rparen")
          # an empty list
          lexer.skip_rparen(1)
          make_ast_node("empty-list")
        else
          parse_container([], lexer)
        end
      end

      def parse_vector(lexer)
        parse_container(make_ast_node("vector"), lexer)
      end

      def parse_container(container, lexer)
        lexer.skip              # skip "lparen" or "vec-lparen"
        Kernel.loop {
          break if token_type?(lexer.peek, "rparen")
          container << parse_expression(lexer)
        }
        lexer.skip_rparen
        container
      end

      def parse_quotation(lexer)
        lexer.skip              # skip "'" (quotation mark)
        exp = parse_expression(lexer)
        [make_ast_node("identifier", "quote"), exp]
      end

      # :startdoc:
    end
  end

end
