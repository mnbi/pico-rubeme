# frozen_string_literal: true

module PicoRubeme

  def self.lexer(source)
    Lexer.new(source)
  end

  TOKEN_TYPES = [             # :nodoc:
    # delimiters
    "lparen",                   # `(`
    "rparen",                   # `)`
    "vec-lparen",               # `#(`
    "bytevec-lparen",           # `#u8(`
    "quotation",                # `'`
    "backquote",                # "`" (aka quasiquote)
    "comma",                    # `,`
    "comma-at",                 # `,@`
    "dot",                      # `.`
    "semicolon",                # `;`
    "comment-lparen",           # `#|`
    "comment-rparen",           # `|#`
    # value types
    "identifier",               # `foo`
    "boolean",                  # `#f` or `#t` (`#false` or `#true`)
    "number",                   # `123`, `456.789`, `1/2`, `3+4i`
    "character",                # `#\a`
    "string",                   # `"hoge"`
    # control
    "illegal",
  ]

  class Lexer
    private_include Object

    def initialize(source)
      @tokens = tokenize(source)
      init_pos
    end

    def to_a
      @tokens.dup
    end

    def size
      @tokens.size
    end

    def current
      @tokens[@curr_pos]
    end

    def peek(offset = 0)
      # Since `peek` does not modify the position to read, raise
      # StopIteration only if the next position truly exceed the
      # bound.
      check_pos
      @tokens[@next_pos + offset]
    end

    def next(offset = 0)
      check_pos(offset)
      skip(offset)
      @tokens[@curr_pos]
    end

    def skip(offset = 0)
      check_pos(offset)
      @curr_pos = @next_pos + offset
      @next_pos += (1 + offset)
      nil
    end

    def skip_lparen(offset = 0)
      if token_type(peek(offset)) == "lparen"
        skip(offset)
      else
        raise UnexpectedTokenTypeError,
              "got=%s, expected=%s" % [token_type(peek(offset)), "lparen"]
      end
    end

    def skip_rparen(offset = 0)
      if token_type(peek(offset)) == "rparen"
        skip(offset)
      else
        MissingRightParenthesisError
      end
    end

    def rewind
      init_pos
      self
    end

    # :stopdoc:
    private

    def init_pos
      @curr_pos = @next_pos = 0
    end

    def check_pos(offset = 0)
      raise StopIteration if (@next_pos + offset) >= size
    end

    BOOLEAN    = /\A#(f(alse)?|t(rue)?)\Z/
    STRING     = /\A\"[^\"]*\"\Z/

    # numbers
    REAL_PAT   = "(([1-9][0-9]*)|0)(\.[0-9]+)?"
    RAT_PAT    = "#{REAL_PAT}\\/#{REAL_PAT}"
    C_REAL_PAT = "(#{REAL_PAT}|#{RAT_PAT})"
    C_IMAG_PAT = "#{C_REAL_PAT}"
    COMP_PAT   = "#{C_REAL_PAT}(\\+|\\-)#{C_IMAG_PAT}i"

    REAL_NUM   = Regexp.new("\\A[+-]?#{REAL_PAT}\\Z")
    RATIONAL   = Regexp.new("\\A[+-]?#{RAT_PAT}\\Z")
    COMPLEX    = Regexp.new("\\A[+-]?#{COMP_PAT}\\Z")
    PURE_IMAG  = Regexp.new("\\A[+-](#{C_IMAG_PAT})?i\\Z")

    # char
    SINGLE_CHAR_PAT = "."
    SPACE_PAT       = "space"
    NEWLINE_PAT     = "newline"

    CHAR_PREFIX = "\#\\\\"
    CHAR_PAT    = "(#{SINGLE_CHAR_PAT}|#{SPACE_PAT}|#{NEWLINE_PAT})"
    CHAR        = Regexp.new("\\A#{CHAR_PREFIX}#{CHAR_PAT}\\Z")

    def tokenize(source)
      split(escape_quotation_in_string(source)).map { |literal|
        case literal
        when "("
          make_token("lparen", literal)
        when ")"
          make_token("rparen", literal)
        when "."                # dot
          make_token("dot", literal)
        when "'"                # single quotation
          make_token("quotation", literal)
        when "#("               # sharp + lparen
          make_token("vec-lparen", literal)
        when "|"                # vertical bar
          # not supported yet
          make_token("illegal", literal)
        when BOOLEAN
          make_token("boolean", literal)
        when CHAR
          make_token("character", literal)
        when STRING
          make_token("string", literal)
        when REAL_NUM, RATIONAL, COMPLEX, PURE_IMAG
          make_token("number", literal)
        else
          if Identifier.identifier?(literal)
            make_token("identifier", literal)
          else
            make_token("illegal", literal)
          end
        end
      }
    end

    ESCAPED_QUOTATION_MARK = "__EQ__"

    def escape_quotation_in_string(source)
      source.gsub(/\\\"/, ESCAPED_QUOTATION_MARK)
    end

    def split(source, in_string = false)
      return [] if source.empty?

      result = []
      head, _, rest = source.partition("\"")

      if in_string
        head.gsub!(Regexp.new(ESCAPED_QUOTATION_MARK), "\\\"")
        result << "\"#{head}\""
        result.concat(split(rest, false))
      else
        # Split with "(", "'", space characters, and ")".
        result.concat(head.split(/(\()|(#\()|(')|\s|(\))/).delete_if{|s| s.empty?})
        result.concat(split(rest, true))
      end

      result
    end

    # Holds functions to check a literal is valid as an identifier
    # defined in R7RS.
    #
    # Call identifier? function as follows:
    #
    #   Identifier.identifier?(literal)
    #
    # It returns true if the literal is valid as an identifier.

    module Identifier

      DIGIT              = "0-9"
      LETTER             = "a-zA-Z"
      SPECIAL_INITIAL    = "!\\$%&\\*/:<=>\\?\\^_~"
      INITIAL            = "#{LETTER}#{SPECIAL_INITIAL}"
      EXPLICIT_SIGN      = "\\+\\-"
      SPECIAL_SUBSEQUENT = "#{EXPLICIT_SIGN}\\.@"
      SUBSEQUENT         = "#{INITIAL}#{DIGIT}#{SPECIAL_SUBSEQUENT}"

      REGEXP_INITIAL = Regexp.new("[#{INITIAL}]")
      REGEXP_EXPLICIT_SIGN = Regexp.new("[#{EXPLICIT_SIGN}]")
      REGEXP_SUBSEQUENT = Regexp.new("[#{SUBSEQUENT}]+")

      def self.identifier?(literal)
        size = literal.size
        c = literal[0]
        case c
        when REGEXP_INITIAL
          return true if size == 1
          subsequent?(literal[1..-1])
        when REGEXP_EXPLICIT_SIGN
          return true if size == 1
          if literal[1] == "."
            dot_identifier?(literal[1..-1])
          else
            if sign_subsequent?(literal[1])
              return true if size == 2
              subsequent?(literal[2..-1])
            else
              false
            end
          end
        when "."
          dot_identifier?(literal)
        else
          false
        end
      end

      def self.subsequent?(sub_literal)
        REGEXP_SUBSEQUENT === sub_literal
      end

      def self.sign_subsequent?(sub_literal)
        return false if sub_literal.size != 1
        case sub_literal[0]
        when REGEXP_INITIAL
          true
        when REGEXP_EXPLICIT_SIGN
          true
        when "@"
          true
        else
          false
        end
      end

      def self.dot_identifier?(sub_literal)
        return false if sub_literal[0] != "."
        return true if sub_literal.size == 1
        if dot_subsequent?(sub_literal[1])
          return true if sub_literal.size == 2
          subsequent?(sub_literal[2..-1])
        else
          false
        end
      end

      def self.dot_subsequent?(sub_literal)
        return true if sub_literal == "."
        sign_subsequent?(sub_literal)
      end

    end

    # :startdoc:
  end                           # end of Lexer
end
