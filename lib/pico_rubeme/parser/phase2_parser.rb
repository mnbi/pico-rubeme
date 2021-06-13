# frozen_string_literal: true

module PicoRubeme

  module Parser

    class Phase2Parser < Component
      include AST
      include Utils

      def parse(list)
        if ast?(list)
          list
        elsif list.instance_of?(Array)
          to_ast(list)
        else
          raise SchemeSyntaxError,
                "unknown syntax element; got=%s" % list.to_s
        end
      end

      #:stopdoc:
      private

      def to_ast(list)
        if identifier?(list[0])
          node = to_special_form(list)
          node || to_procedure_call(list)
        elsif list[0].instance_of?(Array)
          to_procedure_call(list)
        else
          raise SchemeSyntaxError,
                "invalid application; got=%s" % list.to_s
        end
      end

      def to_special_form(list)
        case identifier(list[0])
        when "if"
          to_conditional(list)
        when "quote"
          to_quotation(list)
        when "lambda"
          to_lambda_expression(list)
        when "define"
          to_definition(list)
        end
      end

      def to_conditional(list)
        # [ *if*, <test>, <consequent> ]
        # [ *if*, <test>, <consequent>, <alternate> ]
        # <test> -> <expression>
        # <consequent> -> <expression>
        # <alternate> <expression> | <empty>
        alternate = parse(list[3]) if list.size > 3
        make_conditional(parse(list[1]), parse(list[2]), alternate)
      end

      def to_quotation(list)
        not_implemented_yet("quote")
      end

      def to_lambda_expression(list)
        # [ "*lambda*", <formals>, <body> ]
        make_lambda_expression(to_formals(list[1]), to_body(list[2..-1]))
      end

      def to_formals(list)
        # type 1: <identifier>
        # type 2: [ <identifier>* ]
        # type 3: [ <identifier>+, <dot>, <identifier> ] (not supported)
        if type?(list, "identifier")
          # type 1
          list
        else
          # type 2
          make_formals(list)
        end
      end

      def to_body(list)
        # [ <definition>*, <sequence> ]
        def_exps = []
        i = 0
        list.each { |e|
          break unless definition?(e)
          def_exps << to_definition(e)
          i += 1
        }
        make_body(make_definitions(def_exps), to_sequence(list[i..-1]))
      end

      def to_sequence(list)
        # <sequence> -> [ <command>*, <expression> ]
        # <command> -> <expression>
        exps = []
        list.each { |e|
          if definition?(e)
            raise SchemeSyntaxErrorError,
                  "wrong position of internal definition"
          end
          exps << parse(e)
        }
        make_sequence(exps)
      end

      def to_definition(list)
        # type 1: (define foo 3)
        # type 2: (define bar (lambda (x y) (+ x y)))
        # type 3: (define (hoge n m) (display n) (display m) (* n m))

        ident = nil
        exp = nil

        if type?(list[1], "identifier")
          # type 1 and type 2
          ident = list[1]
          exp = parse(list[2])
        elsif list[1].instance_of?(Array)
          # type 3
          ident = list[1][0]
          exp = make_lambda_expression(to_formals(list[1][1..-1]),
                                       to_body(list[2..-1]))
        else
          raise SchemeSyntaxError, "got=%s" % list[1].to_s
        end
        make_definition(ident, exp)
      end

      def to_procedure_call(list)
        # [ <operator>, <operands>* ]
        # <operator> -> <expression>
        # <operands> -> <expression>
        operator = parse(list[0])
        operand = []
        list[1..-1].each{ |node| operand << parse(node) }
        make_procedure_call(operator, operand)
      end

      #:startdoc:
    end
  end                           # end of Parser (module)
end
