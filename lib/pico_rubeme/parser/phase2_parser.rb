# frozen_string_literal: true

module PicoRubeme

  module Parser

    class Phase2Parser < Component
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
        if ast_type?(list[0], "identifier")
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
        conditional = ["*conditional*"]
        conditional << parse(list[1])
        conditional << parse(list[2])
        if list.size > 3
          conditional << parse(list[3])
        end
        conditional
      end

      def to_quotation(list)
        not_implemented_yet("quote")
      end

      def to_lambda_expression(list)
        # [ "*lambda*", <formals>, <body> ]
        make_lambda_exp(to_formals(list[1]), to_body(list[2..-1]))
      end

      def to_formals(list)
        # type 1: <identifier>
        # type 2: [ <identifier>* ]
        # type 3: [ <identifier>+, <dot>, <identifier> ] (not supported)
        if ast_type?(list, "identifier")
          # type 1
          list
        else
          # type 2
          formals = ["*formals*"]
          list.each{ |e| formals << e }
          formals
        end
      end

      def to_body(list)
        # [ <definition>*, <sequence> ]
        body = ["*body*"]
        definitions = ["*internal_definitions*"]

        i = 0
        list.each { |e|
          break unless definition?(e)
          definitions << to_definition(e)
          i += 1
        }

        body[1] = definitions
        body[2] = to_sequence(list[i..-1])
        body
      end

      def to_sequence(list)
        # <sequence> -> [ <command>*, <expression> ]
        # <command> -> <expression>
        seq = ["*sequence*"]
        list.each { |e|
          if definition?(e)
            raise SchemeSyntaxErrorError,
                  "wrong position of internal definition"
          end
          seq << parse(e)
        }
        seq
      end

      def make_lambda_exp(formals, body)
        lambda_exp = ["*lambda_expression*"]
        lambda_exp << formals
        lambda_exp << body
        lambda_exp
      end

      def to_definition(list)
        # type 1: (define foo 3)
        # type 2: (define bar (lambda (x y) (+ x y)))
        # type 3: (define (hoge n m) (display n) (display m) (* n m))
        definition = ["*definition*"]
        if ast_type?(list[1], "identifier")
        # type 1 and type 2
          definition << list[1]
          definition << parse(list[2])
        elsif list[1].instance_of?(Array)
          # type 3
          definition << list[1][0]
          definition << make_lambda_exp(to_formals(list[1][1..-1]),
                                        to_body(list[2..-1]))
        else
          raise SchemeSyntaxError, "got=%s" % list[1].to_s
        end
        definition
      end

      def to_procedure_call(list)
        # [ <operator>, <operands>* ]
        # <operator> -> <expression>
        # <operands> -> <expression>
        proc_call = ["*procedure_call*"]
        proc_call << parse(list[0])
        list[1..-1].each{ |node| proc_call << parse(node) }
        proc_call
      end

      #:startdoc:
    end
  end                           # end of Parser (module)
end
