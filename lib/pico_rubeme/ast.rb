# frozen_string_literal: true

module PicoRubeme

  module AST
    include Object

    def nodes(list)
      ast?(list) ? data(list)[1..-1] : list
    end

    def first(list)
      data(list)[0]
    end

    def rest(list)
      data(list)[1..-1]
    end

    # *identifier*
    def identifier?(list)
      ast?(list) && ast_type?(list, "identifier")
    end

    def identifier(list)
      identifier?(list) && data(list)[0]
    end

    # *conditional*
    def make_conditional(test, consequent, alternate = nil)
      conditional = make_ast_node("conditional", test, consequent)
      if alternate
        conditional << alternate
      end
      conditional
    end

    def test(conditional)
      data(conditional)[0]
    end

    def consequent(conditional)
      data(conditional)[1]
    end

    def alternalte(conditional)
      data(conditional)[2]
    end

    # *quotation*
    def make_quotation(expression)
      make_ast_node("quotation", expression)
    end

    # *lmabda_expression*
    def make_lambda_expression(formals, body)
      make_ast_node("lambda-expression", formals, body)
    end

    def formals(lambda_exp)
      data(lambda_exp)[0]
    end

    def body(lambda_exp)
      data(lambda_exp)[1]
    end

    def make_formals(identifiers)
      make_ast_node("formals", *identifiers)
    end

    def make_body(definitions, sequence)
      make_ast_node("body", definitions, sequence)
    end

    def make_definitions(def_exps)
      make_ast_node("internal-definitions", *def_exps)
    end

    def make_sequence(expressions)
      make_ast_node("sequence", *expressions)
    end

    # *definition*
    def definition?(list)
      identifier?(list[0]) && identifier(list[0]) == "define"
    end

    def make_definition(identifier, expression)
      make_ast_node("definition", identifier, expression)
    end

    def definition_identifier(definition)
      data(definition)[0]
    end

    def definition_expression(definition)
      data(definition)[1]
    end

    # *procedure_call*
    def make_procedure_call(operator, operand)
      make_ast_node("procedure-call", operator, operand)
    end

    def operator(proc_call)
      data(proc_call)[0]
    end

    def operand(proc_call)
      data(proc_call)[1]
    end

  end                           # end of AST

end
