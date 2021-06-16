# frozen_string_literal: true

module PicoRubeme

  module AST

    def tag(name)
      "*#{name}*"
    end

    def ast?(list)
      list.instance_of?(Array) &&
        list[0].instance_of?(String) &&
        list[0].match(TAG)
    end

    def type?(list, expected_type)
      actual = type(list)
      actual && actual == expected_type
    end

    def type(list)
      if list.instance_of?(Array) && list[0].instance_of?(String)
        md = list[0].match(TAG)
        md && md[1]
      end
    end

    def nodes(list)
      ast?(list) ? list[1..-1] : list
    end

    def first(list)
      list[0]
    end

    def rest(list)
      list[1..-1]
    end

    # simple type
    def literal(list)
      list[1]
    end

    # *identifier*
    def identifier?(list)
      type?(list, "identifier")
    end

    def identifier(list)
      identifier?(list) && list[1]
    end

    # *conditional*
    def make_conditional(test, consequent, alternate = nil)
      conditional = ["*conditional*"]
      conditional << test
      conditional << consequent
      if alternate
        conditional << alternate
      end
      conditional
    end

    def test(conditional)
      conditional[1]
    end

    def consequent(conditional)
      conditional[2]
    end

    def alternalte(conditional)
      conditional[3]
    end

    # *quotation*
    def make_quotation(expression)
      quotation = ["*quotation*"]
      quotation << expression
    end

    # *lmabda_expression*
    def make_lambda_expression(formals, body)
      lambda_exp = ["*lambda_expression*"]
      lambda_exp << formals
      lambda_exp << body
      lambda_exp
    end

    def formals(lambda_exp)
      lambda_exp[1]
    end

    def body(lambda_exp)
      lambda_exp[2]
    end

    def make_formals(identifiers)
      formals = ["*formals*"]
      formals.concat(identifiers)
      formals
    end

    def make_body(definitions, sequence)
      body = ["*body*"]
      body << definitions
      body << sequence
      body
    end

    def make_definitions(def_exps)
      definitions = ["*internal_definitions*"]
      definitions.concat(def_exps)
      definitions
    end

    def make_sequence(expressions)
      seq = ["*sequence*"]
      seq.concat(expressions)
      seq
    end

    # *definition*
    def definition?(list)
      identifier?(list[0]) && identifier(list[0]) == "define"
    end

    def make_definition(identifier, expression)
      definition = ["*definition*"]
      definition << identifier
      definition << expression
      definition
    end

    def definition_identifier(definition)
      definition[1]
    end

    def definition_expression(definition)
      definition[2]
    end

    # *procedure_call*
    def make_procedure_call(operator, operand)
      proc_call = ["*procedure_call*"]
      proc_call << operator
      proc_call << operand
      proc_call
    end

    def operator(proc_call)
      proc_call[1]
    end

    def operand(proc_call)
      proc_call[2]
    end

  end                           # end of AST

end
