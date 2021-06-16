# frozen_string_literal: true

module PicoRubeme

  def self.parser
    Parser::Parser.new
  end

  module Parser
    require_relative "parser/phase1_parser"
    require_relative "parser/phase2_parser"

    class Parser < Component
      include AST

      def initialize
        super()
        @components[:p1] = Phase1Parser.new
        @components[:p2] = Phase2Parser.new
      end

      def parse(lexer)
        return [] if lexer.nil?
        program = make_ast_node("program")
        Kernel.loop {
          program << @components[:p2].parse(@components[:p1].parse(lexer))
        }
        program
      end
    end

  end                           # end of Parser (module)
end
