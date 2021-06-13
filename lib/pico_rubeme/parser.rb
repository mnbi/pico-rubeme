# frozen_string_literal: true

module PicoRubeme

  def self.parser
    Parser::Parser.new
  end

  module Parser

    module Utils
      def not_implemented_yet(feature)
        raise NotImplementedYetError, feature
      end
    end

    require_relative "parser/phase1_parser"
    require_relative "parser/phase2_parser"

    class Parser < Component

      def initialize
        super()
        @components[:p1] = Phase1Parser.new
        @components[:p2] = Phase2Parser.new
      end

      def parse(lexer)
        return [] if lexer.nil?
        program = ["*program*"]
        Kernel.loop {
          program << @components[:p2].parse(@components[:p1].parse(lexer))
        }
        program
      end
    end

  end                           # end of Parser (module)
end
